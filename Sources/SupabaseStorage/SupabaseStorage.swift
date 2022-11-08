import Foundation

public class SupabaseStorageClient: StorageBucketApi {
  /// Storage Client initializer
  /// - Parameters:
  ///   - url: Storage HTTP URL
  ///   - headers: HTTP headers.
  public init(url: String, headers: [String: String], http: StorageHTTPClient? = nil) {
    super.init(url: URL(string: url)!, headers: headers, http: http ?? DefaultStorageHTTPClient())
  }

  /// Storage Client initializer
  /// - Parameters:
  ///   - url: Storage HTTP URL
  ///   - headers: HTTP headers.
  override public init(url: URL, headers: [String: String], http: StorageHTTPClient? = nil) {
    super.init(url: url, headers: headers, http: http ?? DefaultStorageHTTPClient())
  }

  /// Perform file operation in a bucket.
  /// - Parameter id: The bucket id to operate on.
  /// - Returns: StorageFileApi object
  public func from(id: String) -> StorageFileApi {
    StorageFileApi(url: url, headers: headers, bucketId: id, http: http)
  }
}
