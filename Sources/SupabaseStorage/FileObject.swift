public struct FileObject: Decodable {
  public var id: String
  public var name: String

  public let bucketID: String?
  public var owner: String?

  public var updatedAt: String
  public var createdAt: String
  public var lastAccessedAt: String

  public var metadata: Metadata
  public var buckets: Bucket?

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case bucketID = "bucket_id"
    case owner
    case updatedAt = "updated_at"
    case createdAt = "created_at"
    case lastAccessedAt = "last_accessed_at"
    case metadata
  }
}

public extension FileObject {
  @available(swift, obsoleted: 5.7, deprecated: 5.8, renamed: "bucketID")
  var bucket_id: String? { bucketID }
}

public extension FileObject {
  struct Metadata: Decodable {
    public let size: Int
    public let mimetype: String
    public let cacheControl: String
  }
}
