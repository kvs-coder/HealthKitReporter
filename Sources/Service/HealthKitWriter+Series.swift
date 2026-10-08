//
//  HealthKitWriter+Series.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit

// MARK: - Series
extension HealthKitWriter {
    /**
     Saves quantities as one quantity series sample.
     - Parameter type: **QuantityType** type
     - Parameter values: **QuantitySeriesValue** quantities, in any order
     - Parameter device: **Device** device (optional)
     - Parameter metadata: **Metadata** metadata (optional)
     - Parameter completion: block notifies about operation status
     */
    public func saveQuantitySeries(
        type: QuantityType,
        values: [QuantitySeriesValue],
        device: Device? = nil,
        metadata: Metadata? = nil,
        completion: @escaping StatusCompletionBlock
    ) {
        do {
            guard let quantityType = type.original as? HKQuantityType else {
                throw HealthKitError.invalidType("\(type) can not be represented as HKQuantityType")
            }
            guard
                let start = values.map(\.startTimestamp).min(),
                let end = values.map(\.endTimestamp).max(),
                values.allSatisfy({ $0.startTimestamp <= $0.endTimestamp })
            else {
                throw HealthKitError.invalidValue(
                    "Quantity series needs values with start <= end: \(values)"
                )
            }
            let builder = HKQuantitySeriesSampleBuilder(
                healthStore: healthStore,
                quantityType: quantityType,
                startDate: start.asDate,
                device: device?.asOriginal()
            )
            for value in values {
                try builder.insert(
                    HKQuantity(
                        unit: try quantityType.compatibleUnit(from: value.unit),
                        doubleValue: value.value
                    ),
                    for: DateInterval(start: value.startTimestamp.asDate, end: value.endTimestamp.asDate)
                )
            }
            builder.finishSeries(
                metadata: try metadata?.asOriginal(),
                endDate: end.asDate
            ) { samples, error in
                completion(samples != nil, error)
            }
        } catch {
            completion(false, error)
        }
    }
    /**
     Saves a heartbeat series, beat by beat.
     - Parameter series: **HeartbeatSeries** series; beats are the measurements' times since the series start
     - Parameter completion: block notifies about operation status
     */
    public func saveHeartbeatSeries(
        _ series: HeartbeatSeries,
        completion: @escaping StatusCompletionBlock
    ) {
        let beats = series.harmonized.measurements
        let times = beats.map(\.timeSinceSeriesStart)
        guard
            !beats.isEmpty,
            beats.count <= HKHeartbeatSeriesBuilder.maximumCount,
            times.first.map({ $0 >= 0 }) == true,
            zip(times, times.dropFirst()).allSatisfy({ $0 < $1 })
        else {
            completion(
                false,
                HealthKitError.invalidValue(
                    "Heartbeat series needs 1 to max ascending, non-negative beats: \(times)"
                )
            )
            return
        }
        let metadata: [String: Any]?
        do {
            metadata = try series.harmonized.metadata?.asOriginal()
        } catch {
            completion(false, error)
            return
        }
        let builder = HKHeartbeatSeriesBuilder(
            healthStore: healthStore,
            device: series.device?.asOriginal(),
            start: series.startTimestamp.asDate
        )
        addBeats(beats[...], to: builder) { success, error in
            guard success else {
                completion(false, error)
                return
            }
            let finish = {
                builder.finishSeries { sample, error in
                    completion(sample != nil, error)
                }
            }
            guard let metadata = metadata else {
                finish()
                return
            }
            builder.addMetadata(metadata) { success, error in
                success ? finish() : completion(false, error)
            }
        }
    }

    /// The builder takes one beat at a time, so each is added after the previous one completed
    private func addBeats(
        _ beats: ArraySlice<HeartbeatSeries.Measurement>,
        to builder: HKHeartbeatSeriesBuilder,
        completion: @escaping StatusCompletionBlock
    ) {
        guard let beat = beats.first else {
            completion(true, nil)
            return
        }
        builder.addHeartbeatWithTimeInterval(
            sinceSeriesStartDate: beat.timeSinceSeriesStart,
            precededByGap: beat.precededByGap
        ) { success, error in
            guard success else {
                completion(false, error)
                return
            }
            self.addBeats(beats.dropFirst(), to: builder, completion: completion)
        }
    }
}
