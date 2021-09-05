public class SupabaseStorageClient: StorageBucketApi {
    /// Storage Client initializer
    /// - Parameters:
    ///   - url: Storage HTTP URL
    ///   - headers: HTTP headers.
    override public init(url: String, headers: [String: String]) {
        super.init(url: url, headers: headers)
    }
    
    /// Storage Client initializer
    /// - Parameter config: Config object to use
    override public init(_ config: StorageApiConfig) {
        super.init(config)
    }

    /// Perform file operation in a bucket.
    /// - Parameter id: The bucket id to operate on.
    /// - Returns: StorageFileApi object
    public func from(id: String) -> StorageFileApi {
        return StorageFileApi(url: config.url, headers: config.headers, bucketId: id)
    }
}
