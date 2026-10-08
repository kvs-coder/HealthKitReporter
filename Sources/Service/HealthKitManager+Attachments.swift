//
//  HealthKitManager+Attachments.swift
//  HealthKitReporter
//
//  Created by Victor Kachalov on 08.10.26.
//

import HealthKit
import UniformTypeIdentifiers

// MARK: - Attachments
@available(iOS 16.0, watchOS 9.0, *)
extension HealthKitManager {
    /**
     Lists the files attached to a sample.
     - Parameter type: **SampleType** type of the sample
     - Parameter uuid: **String** uuid of the sample
     - Parameter completion: returns a block with the attachments
     */
    public func attachments(
        forSampleOf type: SampleType,
        uuid: String,
        completion: @escaping AttachmentsCompletion
    ) {
        hkAttachments(forSampleOf: type, uuid: uuid) { _, attachments, error in
            completion(attachments.map(Attachment.init(attachment:)), error)
        }
    }
    /**
     Reads the content of an attachment.
     - Parameter type: **SampleType** type of the sample
     - Parameter uuid: **String** uuid of the sample
     - Parameter attachmentIdentifier: **String** identifier of the attachment
     - Parameter completion: returns a block with the file data
     */
    public func attachmentData(
        forSampleOf type: SampleType,
        uuid: String,
        attachmentIdentifier: String,
        completion: @escaping AttachmentDataCompletion
    ) {
        hkAttachments(forSampleOf: type, uuid: uuid) { _, attachments, error in
            guard let attachment = attachments.first(where: { $0.matches(attachmentIdentifier) }) else {
                completion(
                    nil,
                    error ?? HealthKitError.invalidIdentifier("No attachment \(attachmentIdentifier)")
                )
                return
            }
            _ = HKAttachmentStore(healthStore: self.healthStore).getData(for: attachment) { data, error in
                completion(data, error)
            }
        }
    }
    /**
     Attaches a file to a sample.
     - Parameter type: **SampleType** type of the sample
     - Parameter uuid: **String** uuid of the sample
     - Parameter name: **String** file name shown to the user
     - Parameter contentType: **String** uniform type identifier, e.g. "public.jpeg"
     - Parameter url: **URL** local file
     - Parameter metadata: **Metadata** metadata (optional)
     - Parameter completion: returns a block with the new attachment
     */
    public func addAttachment( // swiftlint:disable:this function_parameter_count
        toSampleOf type: SampleType,
        uuid: String,
        name: String,
        contentType: String,
        url: URL,
        metadata: Metadata? = nil,
        completion: @escaping AttachmentCompletion
    ) {
        guard let utType = UTType(contentType) else {
            completion(nil, HealthKitError.invalidValue("Invalid content type: \(contentType)"))
            return
        }
        let attachmentMetadata: [String: Any]
        do {
            attachmentMetadata = try metadata?.asOriginal() ?? [:]
        } catch {
            completion(nil, error)
            return
        }
        healthStore.storedSample(of: type, uuid: uuid) { sample, error in
            guard let sample = sample else {
                completion(nil, error)
                return
            }
            HKAttachmentStore(healthStore: self.healthStore).addAttachment(
                to: sample,
                name: name,
                contentType: utType,
                url: url,
                metadata: attachmentMetadata
            ) { attachment, error in
                completion(attachment.map(Attachment.init(attachment:)), error)
            }
        }
    }
    /**
     Removes a file from a sample.
     - Parameter type: **SampleType** type of the sample
     - Parameter uuid: **String** uuid of the sample
     - Parameter attachmentIdentifier: **String** identifier of the attachment
     - Parameter completion: block notifies about operation status
     */
    public func removeAttachment(
        fromSampleOf type: SampleType,
        uuid: String,
        attachmentIdentifier: String,
        completion: @escaping StatusCompletionBlock
    ) {
        hkAttachments(forSampleOf: type, uuid: uuid) { sample, attachments, error in
            guard
                let sample = sample,
                let attachment = attachments.first(where: { $0.matches(attachmentIdentifier) })
            else {
                completion(
                    false,
                    error ?? HealthKitError.invalidIdentifier("No attachment \(attachmentIdentifier)")
                )
                return
            }
            HKAttachmentStore(healthStore: self.healthStore).removeAttachment(
                attachment,
                from: sample,
                completion: completion
            )
        }
    }

    private func hkAttachments(
        forSampleOf type: SampleType,
        uuid: String,
        completion: @escaping (HKSample?, [HKAttachment], Error?) -> Void
    ) {
        healthStore.storedSample(of: type, uuid: uuid) { sample, error in
            guard let sample = sample else {
                completion(nil, [], error)
                return
            }
            let store = HKAttachmentStore(healthStore: self.healthStore)
            store.getAttachments(for: sample) { attachments, error in
                completion(sample, attachments ?? [], error)
            }
        }
    }
}
