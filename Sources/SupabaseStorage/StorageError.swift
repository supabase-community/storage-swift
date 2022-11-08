import Foundation

public struct StorageError: Error, Codable {
  public var statusCode: Int?

  public var message: String?
  public var error: String?

  public init(
    statusCode: Int? = nil,
    message: String? = nil,
    error: String? = nil
  ) {
    self.statusCode = statusCode
    self.message = message
    self.error = error
  }

  enum CodingKeys: CodingKey {
    case statusCode
    case message
    case error
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    if let statusCodeInt = try? container.decodeIfPresent(Int.self, forKey: .statusCode) {
      statusCode = statusCodeInt
    } else if let statusCodeString = try container.decodeIfPresent(String.self, forKey: .statusCode) {
      statusCode = Int(statusCodeString)
    }

    message = try container.decodeIfPresent(String.self, forKey: .message)
    error = try container.decodeIfPresent(String.self, forKey: .error)
  }
}

extension StorageError: LocalizedError {
  public var errorDescription: String? {
    message
  }
}
