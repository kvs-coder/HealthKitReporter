//
//  DeletedObject.swift
//  HealthKitReporter
//
//  Created by Kachalov, Victor on 16.02.21.
//

import Foundation
import HealthKit

public struct DeletedObject: Codable {
    public let uuid: String
    public let metadata: [String: String]?
    
    init(deletedObject: HKDeletedObject) {
        self.uuid = deletedObject.uuid.uuidString
        if #available(iOS 11.0, *) {
            self.metadata = deletedObject.metadata?.compactMapValues { String(describing: $0 )}
        } else {
            self.metadata = nil
        }
    }

    public static func collect(
        deletedObjects: [HKDeletedObject]?
    ) -> [DeletedObject] {
        return deletedObjects?.compactMap {
            DeletedObject(deletedObject: $0)
        } ?? []
    }
}
