public struct Bucket {
  public var id: String
  public var name: String
  public var owner: String
  public var isPublic: Bool
  public var createdAt: String
  public var updatedAt: String

  init?(from dictionary: [String: Any]) {
    guard
      let id: String = dictionary["id"] as? String,
      let name: String = dictionary["name"] as? String,
      let owner: String = dictionary["owner"] as? String,
      let createdAt: String = dictionary["created_at"] as? String,
      let updatedAt: String = dictionary["updated_at"] as? String,
      let isPublic: Bool = dictionary["public"] as? Bool
    else {
      return nil
    }

    self.id = id
    self.name = name
    self.owner = owner
    self.isPublic = isPublic
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}
