//
//  DeletedObject.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 16.02.21.
//

import HealthKit

public struct DeletedObject: Codable {
    public let uuid: String
    public let metadata: Metadata?
    
    init(deletedObject: HKDeletedObject) {
        self.uuid = deletedObject.uuid.uuidString
        if #available(iOS 11.0, *) {
            self.metadata = deletedObject.metadata?.asMetadata
        } else {
            self.metadata = nil
        }
    }
}
// MARK: - Factory
extension DeletedObject {
    public static func collect(
        deletedObjects: [HKDeletedObject]?
    ) -> [DeletedObject] {
        return deletedObjects?.compactMap {
            DeletedObject(deletedObject: $0)
        } ?? []
    }
}
