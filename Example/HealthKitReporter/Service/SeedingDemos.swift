//
//  SeedingDemos.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Combine
import HealthKit
import HealthKitReporter
import struct HealthKitReporter.Category

/// Writes a week of plausible data for every writable type, and deletes it again
final class SeedingDemos: DemoPerformer {
    private let reporter: HealthKitReporter
    private let samples = DemoSamples(marker: "hkr-seed-")
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    init(reporter: HealthKitReporter) {
        self.reporter = reporter
    }

    func publisher(for row: DemoRow) -> AnyPublisher<String, Error> {
        guard row == .seed else {
            return reporter.publisher { [unowned self] completion in
                deleteOwnData(completion: completion)
            }
        }
        let subject = PassthroughSubject<String, Error>()
        return subject
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.seed(progress: subject)
            })
            .eraseToAnyPublisher()
    }

    // MARK: - Seeding
    private func seed(progress: PassthroughSubject<String, Error>) {
        progress.send("Looking for days already seeded…")
        seededDays { [unowned self] seeded in
            let payloads = payloads(skipping: seeded)
            guard !payloads.isEmpty else {
                progress.send("Every type already has seeded data for the last 7 days")
                progress.send(completion: .finished)
                return
            }
            save(payloads, progress: progress)
        }
    }
    /// Days per type that already carry the seed marker, so seeding runs only once per day
    private func seededDays(completion: @escaping ([String: Set<String>]) -> Void) {
        let group = DispatchGroup()
        let lock = NSLock()
        var seeded = [String: Set<String>]()
        for type in reporter.demoWriteTypes {
            group.enter()
            do {
                let query = try reporter.reader.sampleQuery(type: type, predicate: ownData) { [unowned self] _, found, _ in
                    let days = found.compactMap { seedDay(of: $0) }
                    lock.lock()
                    seeded[type.identifier ?? "", default: []].formUnion(days)
                    lock.unlock()
                    group.leave()
                }
                reporter.manager.executeQuery(query)
            } catch {
                group.leave()
            }
        }
        group.notify(queue: .global()) {
            completion(seeded)
        }
    }
    private func seedDay(of sample: Sample) -> String? {
        let metadata: Metadata?
        switch sample {
        case let quantity as Quantity:
            metadata = quantity.harmonized.metadata
        case let category as Category:
            metadata = category.harmonized.metadata
        case let workout as Workout:
            metadata = workout.harmonized.metadata
        default:
            metadata = nil
        }
        guard case .string(let marker) = metadata?[HKMetadataKeyExternalUUID], marker.hasPrefix(samples.marker) else {
            return nil
        }
        return String(marker.dropFirst(samples.marker.count).prefix(10))
    }
    private func payloads(skipping seeded: [String: Set<String>]) -> [Sample] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var payloads = [Sample]()
        for offset in 1...7 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else {
                continue
            }
            let key = dayFormatter.string(from: day)
            let marker = DemoSamples(marker: "\(samples.marker)\(key)-")
            let isMissing: (SampleType) -> Bool = { !(seeded[$0.identifier ?? ""]?.contains(key) ?? false) }
            payloads += quantities(on: day, offset: offset, with: marker, isMissing: isMissing)
            payloads += categories(on: day, offset: offset, with: marker, isMissing: isMissing)
            if isMissing(WorkoutType.workoutType) {
                payloads.append(marker.workout(start: day.addingTimeInterval(18 * 3_600), minutes: 30 + Double(offset * 5)))
            }
            if isMissing(QuantityType.bloodPressureSystolic) {
                payloads.append(marker.bloodPressure(systolic: 115 + Double(offset), diastolic: 75, at: day.addingTimeInterval(8 * 3_600)))
            }
            if isMissing(QuantityType.dietaryEnergyConsumed) {
                payloads.append(marker.food(kilocalories: 600 + Double(offset * 20), protein: 30, at: day.addingTimeInterval(13 * 3_600)))
            }
        }
        return payloads
    }
    /// Two samples per writable quantity type and day, morning and evening
    private func quantities(on day: Date, offset: Int, with marker: DemoSamples, isMissing: (SampleType) -> Bool) -> [Sample] {
        let types = reporter.demoQuantityTypes.filter { isMissing($0) && isWritable($0) }
        return types.flatMap { type -> [Sample] in
            guard let (unit, range) = plausibleValues(of: type) else {
                return []
            }
            var extra = [String: Metadata.Value]()
            if type == .insulinDelivery {
                extra[HKMetadataKeyInsulinDeliveryReason] = .number(Double(HKInsulinDeliveryReason.basal.rawValue))
            }
            return [9.0, 19.0].map { hour in
                let start = day.addingTimeInterval(hour * 3_600)
                let fraction = Double((offset * 7 + Int(hour)) % 10) / 10
                let value = range.lowerBound + (range.upperBound - range.lowerBound) * fraction
                return marker.quantity(type, value: value, unit: unit, start: start, end: start.addingTimeInterval(600), metadata: extra)
            }
        }
    }
    /// One sample per writable category type and day, cycling through its valid values
    private func categories(on day: Date, offset: Int, with marker: DemoSamples, isMissing: (SampleType) -> Bool) -> [Sample] {
        return reporter.demoCategoryTypes.filter { isMissing($0) && isWritable($0) }.map { type in
            let values = validValues(of: type)
            var extra = [String: Metadata.Value]()
            if type == .menstrualFlow {
                extra[HKMetadataKeyMenstrualCycleStart] = .bool(offset == 7)
            }
            let start = day.addingTimeInterval(22 * 3_600)
            return marker.category(
                type,
                value: values[offset % values.count],
                start: start,
                end: start.addingTimeInterval(3_600),
                metadata: extra
            )
        }
    }
    private func isWritable(_ type: SampleType) -> Bool {
        return reporter.demoWriteTypes.contains { $0.identifier == type.identifier }
    }
    private func save(_ payloads: [Sample], progress: PassthroughSubject<String, Error>) {
        let group = DispatchGroup()
        let lock = NSLock()
        var saved = 0
        var failed = 0
        for payload in payloads {
            group.enter()
            reporter.writer.save(sample: payload) { success, _ in
                lock.lock()
                if success {
                    saved += 1
                } else {
                    failed += 1
                }
                let done = saved + failed
                lock.unlock()
                if done % 50 == 0 {
                    progress.send("Seeding… \(done) of \(payloads.count)")
                }
                group.leave()
            }
        }
        group.notify(queue: .global()) {
            progress.send("Seeded \(saved) samples for the last 7 days, \(failed) failed")
            progress.send(completion: .finished)
        }
    }

    // MARK: - Deleting
    /// Samples written by this app that carry a demo or seed marker
    private var ownData: NSPredicate {
        return NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                HKQuery.predicateForObjects(from: HKSource.default()),
                HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeyExternalUUID)
            ]
        )
    }
    private func deleteOwnData(completion: @escaping DemoCompletion) {
        let group = DispatchGroup()
        let lock = NSLock()
        var deleted = 0
        for type in reporter.demoWriteTypes {
            group.enter()
            reporter.writer.deleteObjects(of: type, predicate: ownData) { _, count, _ in
                lock.lock()
                deleted += max(count, 0)
                lock.unlock()
                group.leave()
            }
        }
        group.notify(queue: .global()) {
            completion(.success("Deleted \(deleted) samples the demo wrote"))
        }
    }

    // MARK: - Values
    /// Units tried in order to find one a quantity type accepts
    private let candidateUnits = [
        "count/min", "count", "%", "m/s", "m", "g", "kcal", "s", "degC", "mmHg", "mL/kg·min",
        "L/min", "L", "mg/dL", "IU", "S", "W", "dBASPL", "kcal/hr·kg", "appleEffortScore"
    ]
    private let defaultRanges: [String: ClosedRange<Double>] = [
        "count/min": 60...100, "count": 1...200, "%": 0.2...0.9, "m/s": 1...3, "m": 200...3_000,
        "g": 1...30, "kcal": 20...300, "s": 300...1_800, "degC": 36.4...37.2, "mmHg": 75...120,
        "mL/kg·min": 35...50, "L/min": 300...500, "L": 2.5...4.5, "mg/dL": 80...120, "IU": 1...8,
        "S": 0.000_001...0.000_01, "W": 80...250, "dBASPL": 40...75, "kcal/hr·kg": 2...8, "appleEffortScore": 2...8
    ]
    /// Types whose plausible values differ from the default of their unit
    private let overrides: [QuantityType: (String, ClosedRange<Double>)] = [
        .bodyMass: ("kg", 65...80), .leanBodyMass: ("kg", 50...60), .height: ("m", 1.70...1.80),
        .waistCircumference: ("m", 0.75...0.90), .bodyMassIndex: ("count", 21...25),
        .bodyFatPercentage: ("%", 0.15...0.25), .oxygenSaturation: ("%", 0.95...0.99),
        .bloodAlcoholContent: ("%", 0...0.000_5), .peripheralPerfusionIndex: ("%", 0.02...0.10),
        .walkingDoubleSupportPercentage: ("%", 0.20...0.30), .heartRateVariabilitySDNN: ("s", 0.03...0.08),
        .restingHeartRate: ("count/min", 55...70), .respiratoryRate: ("count/min", 12...18),
        .heartRateRecoveryOneMinute: ("count/min", 15...30), .cyclingCadence: ("count/min", 70...95),
        .bloodPressureSystolic: ("mmHg", 110...125), .bloodPressureDiastolic: ("mmHg", 70...82),
        .basalBodyTemperature: ("degC", 36.2...36.7), .waterTemperature: ("degC", 15...25),
        .uvExposure: ("count", 1...8), .flightsClimbed: ("count", 1...15), .stepCount: ("count", 300...2_000),
        .numberOfTimesFallen: ("count", 1...1), .inhalerUsage: ("count", 1...2),
        .numberOfAlcoholicBeverages: ("count", 1...2), .pushCount: ("count", 50...400),
        .swimmingStrokeCount: ("count", 20...200), .walkingStepLength: ("m", 0.6...0.8),
        .runningStrideLength: ("m", 1.0...1.3), .runningVerticalOscillation: ("m", 0.06...0.10),
        .runningGroundContactTime: ("s", 0.2...0.3), .sixMinuteWalkTestDistance: ("m", 400...600),
        .underwaterDepth: ("m", 1...10), .dietaryWater: ("L", 0.2...0.5), .dietaryCaffeine: ("g", 0.05...0.2),
        .walkingSpeed: ("m/s", 1.1...1.5), .stairAscentSpeed: ("m/s", 0.3...0.6),
        .stairDescentSpeed: ("m/s", 0.3...0.6), .timeInDaylight: ("s", 600...3_600)
    ]
    private func plausibleValues(of type: QuantityType) -> (String, ClosedRange<Double>)? {
        if let override = overrides[type] {
            return override
        }
        guard let identifier = type.identifier else {
            return nil
        }
        let original = HKQuantityType(HKQuantityTypeIdentifier(rawValue: identifier))
        return candidateUnits
            .first { original.is(compatibleWith: HKUnit(from: $0)) }
            .flatMap { unit in defaultRanges[unit].map { (unit, $0) } }
    }
    /// Raw values of the **HKCategoryValue…** enum each category type uses
    private func validValues(of type: CategoryType) -> [Int] {
        switch type {
        case .sleepAnalysis:
            return Array(0...5) // HKCategoryValueSleepAnalysis
        case .intermenstrualBleeding,
             .mindfulSession,
             .highHeartRateEvent,
             .lowHeartRateEvent,
             .irregularHeartRhythmEvent,
             .toothbrushingEvent,
             .pregnancy,
             .lactation,
             .sexualActivity,
             .handwashingEvent,
             .persistentIntermenstrualBleeding,
             .prolongedMenstrualPeriods,
             .irregularMenstrualCycles,
             .infrequentMenstrualCycles,
             .sleepApneaEvent,
             .hypertensionEvent:
            return Array(0...0) // HKCategoryValue
        case .menstrualFlow:
            return Array(1...5) // HKCategoryValueMenstrualFlow
        case .ovulationTestResult:
            return Array(1...4) // HKCategoryValueOvulationTestResult
        case .cervicalMucusQuality:
            return Array(1...5) // HKCategoryValueCervicalMucusQuality
        case .appleStandHour:
            return Array(0...1) // HKCategoryValueAppleStandHour
        case .contraceptive:
            return Array(1...7) // HKCategoryValueContraceptive
        case .audioExposureEvent,
             .environmentalAudioExposureEvent:
            return Array(1...1) // HKCategoryValueEnvironmentalAudioExposureEvent
        case .headphoneAudioExposureEvent:
            return Array(1...1) // HKCategoryValueHeadphoneAudioExposureEvent
        case .lowCardioFitnessEvent:
            return Array(1...1) // HKCategoryValueLowCardioFitnessEvent
        case .appetiteChanges:
            return Array(0...3) // HKCategoryValueAppetiteChanges
        case .abdominalCramps,
             .acne,
             .bladderIncontinence,
             .bloating,
             .breastPain,
             .chestTightnessOrPain,
             .chills,
             .constipation,
             .coughing,
             .diarrhea,
             .dizziness,
             .drySkin,
             .fainting,
             .fatigue,
             .fever,
             .generalizedBodyAche,
             .hairLoss,
             .headache,
             .heartburn,
             .hotFlashes,
             .lossOfSmell,
             .lossOfTaste,
             .lowerBackPain,
             .memoryLapse,
             .nausea,
             .nightSweats,
             .pelvicPain,
             .rapidPoundingOrFlutteringHeartbeat,
             .runnyNose,
             .shortnessOfBreath,
             .sinusCongestion,
             .skippedHeartbeat,
             .soreThroat,
             .vaginalDryness,
             .vomiting,
             .wheezing:
            return Array(0...4) // HKCategoryValueSeverity
        case .moodChanges,
             .sleepChanges:
            return Array(0...1) // HKCategoryValuePresence
        case .pregnancyTestResult:
            return Array(1...3) // HKCategoryValuePregnancyTestResult
        case .progesteroneTestResult:
            return Array(1...3) // HKCategoryValueProgesteroneTestResult
        case .appleWalkingSteadinessEvent:
            return Array(1...4) // HKCategoryValueAppleWalkingSteadinessEvent
        case .bleedingAfterPregnancy,
             .bleedingDuringPregnancy:
            return Array(1...5) // HKCategoryValueVaginalBleeding
        }
    }
}
