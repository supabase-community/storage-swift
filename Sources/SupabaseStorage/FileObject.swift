public struct FileObject {
  public var name: String
  public var bucket_id: String
  public var owner: String
  public var id: String
  public var updated_at: String
  public var created_at: String
  public var last_accessed_at: String
  public var metadata: [String: Any]
  public var buckets: Bucket?

  public init?(from dictionary: [String: Any]) {
    guard
      let name: String = dictionary["name"] as? String,
      let bucket_id: String = dictionary["bucket_id"] as? String,
      let owner: String = dictionary["owner"] as? String,
      let id: String = dictionary["id"] as? String,
      let updated_at: String = dictionary["updated_at"] as? String,
      let created_at: String = dictionary["created_at"] as? String,
      let last_accessed_at: String = dictionary["last_accessed_at"] as? String,
      let metadata: [String: Any] = dictionary["metadata"] as? [String: Any],
      let buckets: [String: Any] = dictionary["buckets"] as? [String: Any]

    else {
      return nil
    }

    self.name = name
    self.bucket_id = bucket_id
    self.owner = owner
    self.id = id
    self.updated_at = updated_at
    self.created_at = created_at
    self.last_accessed_at = last_accessed_at
    self.metadata = metadata
    self.buckets = Bucket(from: buckets)
  }
}
