public class SupabaseStorageClient: StorageBucketApi {
  /// Storage Client initializer
  /// - Parameters:
  ///   - url: Storage HTTP URL
  ///   - headers: HTTP headers.
  override public init(url: String, headers: [String: String]) {
    super.init(url: url, headers: headers)
  }

  /// Perform file operation in a bucket.
  /// - Parameter id: The bucket id to operate on.
  /// - Returns: StorageFileApi object
  public func from(id: String) -> StorageFileApi {
    return StorageFileApi(url: url, headers: headers, bucketId: id)
  }
}
