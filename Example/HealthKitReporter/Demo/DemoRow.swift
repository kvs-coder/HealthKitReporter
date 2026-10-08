//
//  DemoRow.swift
//  HealthKitReporter_Example
//
//  Created by Victor Kachalov on 08.10.26.
//

import Foundation

/// One demo per public method of the library
enum DemoRow: String, CaseIterable {
    case requestAuthorization
    case authorizationRequestStatus
    case isAuthorizedToWrite
    case visionPrescriptionAuthorization
    case medicationAuthorization
    case healthRecordsAuthorization
    case characteristics
    case quantityQuery
    case categoryQuery
    case sampleQuery
    case sampleQueryDescriptors
    case workoutQuery
    case correlationSampleQuery
    case correlationQuery
    case anchoredObjectQuery
    case anchoredObjectQueryDescriptors
    case sourceQuery
    case activitySummary
    case statisticsQuery
    case statisticsCollectionQuery
    case statisticsCollectionBatches
    case electrocardiogramQuery
    case heartbeatSeriesQuery
    case workoutRouteQuery
    case quantitySeriesQuery
    case supportsHealthRecords
    case clinicalRecordQuery
    case verifiableClinicalRecordQuery
    case cdaDocumentQuery
    case visionPrescriptionQuery
    case audiogramQuery
    case stateOfMindQuery
    case scoredAssessmentQuery
    case workoutEffortRelationshipQuery
    case userAnnotatedMedicationQuery
    case medicationDoseEventQuery
    case saveQuantity
    case saveCategory
    case saveCorrelation
    case saveWorkout
    case saveWorkoutWithBuilder
    case addQuantity
    case addCategory
    case saveQuantitySeries
    case saveHeartbeatSeries
    case saveAudiogram
    case saveStateOfMind
    case saveScoredAssessment
    case saveVisionPrescription
    case saveCDADocument
    case relateWorkoutEffort
    case unrelateWorkoutEffort
    case delete
    case deleteObjects
    case observerQuery
    case observerQueryDescriptors
    case enableBackgroundDelivery
    case disableBackgroundDelivery
    case disableAllBackgroundDelivery
    case preferredUnits
    case earliestPermittedSampleDate
    case recalibrateEstimates
    case startWatchApp
    case stopQuery
    case addAttachment
    case attachments
    case attachmentData
    case removeAttachment
    case seed
    case deleteSeeded

    var section: DemoSection {
        switch self {
        case .requestAuthorization,
             .authorizationRequestStatus,
             .isAuthorizedToWrite,
             .visionPrescriptionAuthorization,
             .medicationAuthorization,
             .healthRecordsAuthorization:
            return .authorization
        case .characteristics:
            return .characteristics
        case .quantityQuery,
             .categoryQuery,
             .sampleQuery,
             .sampleQueryDescriptors,
             .workoutQuery,
             .correlationSampleQuery,
             .correlationQuery,
             .anchoredObjectQuery,
             .anchoredObjectQueryDescriptors,
             .sourceQuery,
             .activitySummary:
            return .read
        case .statisticsQuery,
             .statisticsCollectionQuery,
             .statisticsCollectionBatches:
            return .statistics
        case .electrocardiogramQuery,
             .heartbeatSeriesQuery,
             .workoutRouteQuery,
             .quantitySeriesQuery:
            return .series
        case .supportsHealthRecords,
             .clinicalRecordQuery,
             .verifiableClinicalRecordQuery,
             .cdaDocumentQuery,
             .visionPrescriptionQuery:
            return .records
        case .audiogramQuery,
             .stateOfMindQuery,
             .scoredAssessmentQuery,
             .workoutEffortRelationshipQuery,
             .userAnnotatedMedicationQuery,
             .medicationDoseEventQuery:
            return .wellbeing
        case .saveQuantity,
             .saveCategory,
             .saveCorrelation,
             .saveWorkout,
             .saveWorkoutWithBuilder,
             .addQuantity,
             .addCategory,
             .saveQuantitySeries,
             .saveHeartbeatSeries,
             .saveAudiogram,
             .saveStateOfMind,
             .saveScoredAssessment,
             .saveVisionPrescription,
             .saveCDADocument,
             .relateWorkoutEffort,
             .unrelateWorkoutEffort,
             .delete,
             .deleteObjects:
            return .write
        case .observerQuery,
             .observerQueryDescriptors,
             .enableBackgroundDelivery,
             .disableBackgroundDelivery,
             .disableAllBackgroundDelivery:
            return .observe
        case .preferredUnits,
             .earliestPermittedSampleDate,
             .recalibrateEstimates,
             .startWatchApp,
             .stopQuery,
             .addAttachment,
             .attachments,
             .attachmentData,
             .removeAttachment:
            return .manager
        case .seed,
             .deleteSeeded:
            return .seeding
        }
    }

    /// Rows whose query keeps running and delivers updates until **stopQuery**
    var isLive: Bool {
        switch self {
        case .anchoredObjectQueryDescriptors,
             .statisticsCollectionQuery,
             .statisticsCollectionBatches,
             .observerQuery,
             .observerQueryDescriptors:
            return true
        default:
            return false
        }
    }
}
// MARK: - Title
extension DemoRow {
    var title: String {
        switch self {
        case .requestAuthorization:
            return "Request authorization"
        case .authorizationRequestStatus:
            return "Authorization request status"
        case .isAuthorizedToWrite:
            return "Write permission per type"
        case .visionPrescriptionAuthorization:
            return "Vision prescription access"
        case .medicationAuthorization:
            return "Medication access"
        case .healthRecordsAuthorization:
            return "Health records access (needs an Apple Account)"
        case .characteristics:
            return "Characteristics"
        case .quantityQuery:
            return "Every quantity type"
        case .categoryQuery:
            return "Every category type"
        case .sampleQuery:
            return "Every sample type"
        case .sampleQueryDescriptors:
            return "Steps and sleep together"
        case .workoutQuery:
            return "Workouts"
        case .correlationSampleQuery:
            return "Blood pressure and food"
        case .correlationQuery:
            return "Blood pressure with predicates"
        case .anchoredObjectQuery:
            return "Anchored steps, re-run from anchor"
        case .anchoredObjectQueryDescriptors:
            return "Anchored updates, several types"
        case .sourceQuery:
            return "Step count sources"
        case .activitySummary:
            return "Activity rings"
        case .statisticsQuery:
            return "Steps total, heart rate range"
        case .statisticsCollectionQuery:
            return "Daily steps, per interval"
        case .statisticsCollectionBatches:
            return "Daily heart rate, live batches"
        case .electrocardiogramQuery:
            return "ECGs with voltages"
        case .heartbeatSeriesQuery:
            return "Heartbeat series"
        case .workoutRouteQuery:
            return "Workout routes"
        case .quantitySeriesQuery:
            return "Step series values"
        case .supportsHealthRecords:
            return "Health records support"
        case .clinicalRecordQuery:
            return "Clinical records"
        case .verifiableClinicalRecordQuery:
            return "SMART Health Cards"
        case .cdaDocumentQuery:
            return "CDA documents"
        case .visionPrescriptionQuery:
            return "Vision prescriptions"
        case .audiogramQuery:
            return "Audiograms"
        case .stateOfMindQuery:
            return "State of mind"
        case .scoredAssessmentQuery:
            return "GAD-7 and PHQ-9"
        case .workoutEffortRelationshipQuery:
            return "Workout effort"
        case .userAnnotatedMedicationQuery:
            return "Tracked medications"
        case .medicationDoseEventQuery:
            return "Medication doses"
        case .saveQuantity:
            return "Save steps"
        case .saveCategory:
            return "Save sleep"
        case .saveCorrelation:
            return "Save blood pressure and food"
        case .saveWorkout:
            return "Save workout with events"
        case .saveWorkoutWithBuilder:
            return "Save workout through the builder"
        case .addQuantity:
            return "Add energy to the latest workout"
        case .addCategory:
            return "Add a mindful session to the latest workout"
        case .saveQuantitySeries:
            return "Save a step series"
        case .saveHeartbeatSeries:
            return "Save a heartbeat series"
        case .saveAudiogram:
            return "Save an audiogram"
        case .saveStateOfMind:
            return "Save a state of mind"
        case .saveScoredAssessment:
            return "Save GAD-7 and PHQ-9"
        case .saveVisionPrescription:
            return "Save glasses"
        case .saveCDADocument:
            return "Save a CDA document"
        case .relateWorkoutEffort:
            return "Relate effort to the latest workout"
        case .unrelateWorkoutEffort:
            return "Unrelate effort"
        case .delete:
            return "Save, then delete steps"
        case .deleteObjects:
            return "Delete the demo's own steps"
        case .observerQuery:
            return "Observe steps"
        case .observerQueryDescriptors:
            return "Observe steps and sleep"
        case .enableBackgroundDelivery:
            return "Background delivery, every frequency"
        case .disableBackgroundDelivery:
            return "Disable step delivery"
        case .disableAllBackgroundDelivery:
            return "Disable all delivery"
        case .preferredUnits:
            return "Preferred units"
        case .earliestPermittedSampleDate:
            return "Earliest permitted date"
        case .recalibrateEstimates:
            return "Recalibrate six-minute walk"
        case .startWatchApp:
            return "Start a run on the watch"
        case .stopQuery:
            return "Stop live queries"
        case .addAttachment:
            return "Attach a scan to the latest glasses"
        case .attachments:
            return "List attachments"
        case .attachmentData:
            return "Read the first attachment"
        case .removeAttachment:
            return "Remove the first attachment"
        case .seed:
            return "Seed 7 days of demo data"
        case .deleteSeeded:
            return "Delete seeded data"
        }
    }
}
// MARK: - Call
extension DemoRow {
    /// The library call the row demonstrates
    var call: String {
        switch self {
        case .requestAuthorization:
            return "manager.requestAuthorization(toRead:toWrite:)"
        case .authorizationRequestStatus:
            return "manager.authorizationRequestStatus(toRead:toWrite:)"
        case .isAuthorizedToWrite:
            return "writer.isAuthorizedToWrite(type:)"
        case .visionPrescriptionAuthorization:
            return "manager.requestPerObjectReadAuthorization(for:)"
        case .medicationAuthorization:
            return "manager.requestPerObjectReadAuthorization(for:)"
        case .healthRecordsAuthorization:
            return "manager.requestAuthorization(toRead: ClinicalType…)"
        case .characteristics:
            return "reader.characteristics()"
        case .quantityQuery:
            return "reader.quantityQuery(type:unit:)"
        case .categoryQuery:
            return "reader.categoryQuery(type:)"
        case .sampleQuery:
            return "reader.sampleQuery(type:)"
        case .sampleQueryDescriptors:
            return "reader.sampleQuery(descriptors:)"
        case .workoutQuery:
            return "reader.workoutQuery()"
        case .correlationSampleQuery:
            return "reader.correlationQuery(type:)"
        case .correlationQuery:
            return "reader.correlationQuery(type:typePredicates:)"
        case .anchoredObjectQuery:
            return "reader.anchoredObjectQuery(type:anchor:)"
        case .anchoredObjectQueryDescriptors:
            return "reader.anchoredObjectQuery(descriptors:monitorUpdates:)"
        case .sourceQuery:
            return "reader.sourceQuery(type:)"
        case .activitySummary:
            return "reader.queryActivitySummary()"
        case .statisticsQuery:
            return "reader.statisticsQuery(type:unit:separateBySource:)"
        case .statisticsCollectionQuery:
            return "reader.statisticsCollectionQuery(…enumerationBlock:)"
        case .statisticsCollectionBatches:
            return "reader.statisticsCollectionQuery(…resultsHandler:)"
        case .electrocardiogramQuery:
            return "reader.electrocardiogramQuery(withVoltageMeasurements:)"
        case .heartbeatSeriesQuery:
            return "reader.heartbeatSeriesQuery()"
        case .workoutRouteQuery:
            return "reader.workoutRouteQuery()"
        case .quantitySeriesQuery:
            return "reader.quantitySeriesQuery(type:unit:)"
        case .supportsHealthRecords:
            return "manager.supportsHealthRecords()"
        case .clinicalRecordQuery:
            return "reader.clinicalRecordQuery(type:)"
        case .verifiableClinicalRecordQuery:
            return "reader.verifiableClinicalRecordQuery(recordTypes:)"
        case .cdaDocumentQuery:
            return "reader.cdaDocumentQuery()"
        case .visionPrescriptionQuery:
            return "reader.visionPrescriptionQuery()"
        case .audiogramQuery:
            return "reader.audiogramQuery()"
        case .stateOfMindQuery:
            return "reader.stateOfMindQuery()"
        case .scoredAssessmentQuery:
            return "reader.scoredAssessmentQuery(type:)"
        case .workoutEffortRelationshipQuery:
            return "reader.workoutEffortRelationshipQuery()"
        case .userAnnotatedMedicationQuery:
            return "reader.userAnnotatedMedicationQuery()"
        case .medicationDoseEventQuery:
            return "reader.medicationDoseEventQuery(medicationConceptIdentifier:)"
        case .saveQuantity:
            return "writer.save(sample: Quantity)"
        case .saveCategory:
            return "writer.save(sample: Category)"
        case .saveCorrelation:
            return "writer.save(sample: Correlation)"
        case .saveWorkout:
            return "writer.save(sample: Workout)"
        case .saveWorkoutWithBuilder:
            return "writer.saveWorkout(_:samples:route:)"
        case .addQuantity:
            return "writer.addQuantity(_:from:to:)"
        case .addCategory:
            return "writer.addCategory(_:from:to:)"
        case .saveQuantitySeries:
            return "writer.saveQuantitySeries(type:values:)"
        case .saveHeartbeatSeries:
            return "writer.saveHeartbeatSeries(_:)"
        case .saveAudiogram:
            return "writer.save(sample: Audiogram)"
        case .saveStateOfMind:
            return "writer.save(sample: StateOfMind)"
        case .saveScoredAssessment:
            return "writer.save(sample: ScoredAssessment)"
        case .saveVisionPrescription:
            return "writer.save(sample: VisionPrescription)"
        case .saveCDADocument:
            return "writer.save(sample: CDADocument)"
        case .relateWorkoutEffort:
            return "writer.relateWorkoutEffort(_:toWorkout:)"
        case .unrelateWorkoutEffort:
            return "writer.unrelateWorkoutEffort(_:fromWorkout:)"
        case .delete:
            return "writer.delete(sample:)"
        case .deleteObjects:
            return "writer.deleteObjects(of:predicate:)"
        case .observerQuery:
            return "observer.observerQuery(type:)"
        case .observerQueryDescriptors:
            return "observer.observerQuery(descriptors:)"
        case .enableBackgroundDelivery:
            return "observer.enableBackgroundDelivery(type:frequency:)"
        case .disableBackgroundDelivery:
            return "observer.disableBackgroundDelivery(type:)"
        case .disableAllBackgroundDelivery:
            return "observer.disableAllBackgroundDelivery()"
        case .preferredUnits:
            return "manager.preferredUnits(for:)"
        case .earliestPermittedSampleDate:
            return "manager.earliestPermittedSampleDate()"
        case .recalibrateEstimates:
            return "manager.recalibrateEstimates(for:at:)"
        case .startWatchApp:
            return "manager.startWatchApp(with:)"
        case .stopQuery:
            return "manager.stopQuery(_:)"
        case .addAttachment:
            return "manager.addAttachment(toSampleOf:uuid:…)"
        case .attachments:
            return "manager.attachments(forSampleOf:uuid:)"
        case .attachmentData:
            return "manager.attachmentData(forSampleOf:uuid:attachmentIdentifier:)"
        case .removeAttachment:
            return "manager.removeAttachment(fromSampleOf:uuid:attachmentIdentifier:)"
        case .seed:
            return "writer.save / addQuantity / addCategory"
        case .deleteSeeded:
            return "writer.deleteObjects(of:predicate:)"
        }
    }
}
