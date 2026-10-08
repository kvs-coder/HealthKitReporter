//
//  DeletedObject.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 16.02.21.
//

import HealthKit

/**
 **DeletedObject** a sample deleted from HealthKit.
 HealthKit reports only its uuid and metadata, not its type,
 so match the uuid against the samples you keep to route it
 */
public struct DeletedObject: Codable {
    public let uuid: String
    public let metadata: Metadata?

    init(deletedObject: HKDeletedObject) {
        self.uuid = deletedObject.uuid.uuidString
        self.metadata = deletedObject.metadata?.asMetadata
    }
}
// MARK: - Factory
extension DeletedObject {
    static func collect(
        deletedObjects: [HKDeletedObject]?
    ) -> [DeletedObject] {
        return deletedObjects?.compactMap {
            DeletedObject(deletedObject: $0)
        } ?? []
    }
}
