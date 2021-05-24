import Foundation
public struct StorageError: Error {
    public var statusCode: Int?
    public var message: String?
}

extension StorageError: LocalizedError {
    public var errorDescription: String? {
        return message
    }
}
