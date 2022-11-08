public struct Bucket: Decodable {
  public var id: String
  public var name: String
  public var owner: String
  public var isPublic: Bool
  public var createdAt: String
  public var updatedAt: String

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case owner
    case isPublic = "public"
    case createdAt = "created_at"
    case updatedAt = "updated_at"
  }
}

public extension Bucket {
  @available(swift, deprecated: 5.8, renamed: "createdAt")
  var created_at: String { "\(createdAt)" }

  @available(swift, obsoleted: 5.7, deprecated: 5.8, renamed: "createdAt")
  var updated_at: String { "\(createdAt)" }
}
