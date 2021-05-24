public struct FileObject {
    public var name: String
    public var bucket_id: String
    public var owner: String
    public var id: String
    public var updated_at: String
    public var created_at: String
    public var last_accessed_at: String
    public var metadata: [String: Any]
    public var buckets: Bucket
}
