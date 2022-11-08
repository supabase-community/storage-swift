import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Storage Bucket API
public class StorageBucketApi: StorageApi {
  /// StorageBucketApi initializer
  /// - Parameters:
  ///   - url: Storage HTTP URL
  ///   - headers: HTTP headers.
  override init(url: URL, headers: [String: String], http: StorageHTTPClient) {
    super.init(url: url, headers: headers, http: http)
  }

  /// Retrieves the details of all Storage buckets within an existing product.
  ///
  /// > RLS policy permissions required:
  /// > - `buckets` table permissions: `select`
  /// > - `objects` table permissions: none
  ///
  public func listBuckets() async throws -> [Bucket] {
    let url = newUrl.appendingPathComponent("bucket")

    let responseData = try await fetch(
      url: url,
      method: .get,
      json: nil,
      headers: headers
    )

    let responseObject = try decoder.decode([Bucket].self, from: responseData)

    return responseObject
  }

  /// Retrieves the details of an existing Storage bucket.
  ///
  /// > RLS policy permissions required:
  /// > - `buckets` table permissions: `select`
  /// > - `objects` table permissions: none
  ///
  /// - Parameters:
  ///   - id: The unique identifier of the bucket you would like to retrieve.
  public func getBucket(id: String) async throws -> Bucket {
    let url = newUrl.appendingPathComponent("/bucket/\(id)")

    let responseData = try await fetch(
      url: url,
      method: .get,
      json: nil,
      headers: headers
    )

    let responseObject = try decoder.decode(Bucket.self, from: responseData)
    return responseObject
  }

  /// Creates a new Storage bucket
  ///
  /// > Public buckets don't require an authorization token to download objects, but still require a valid token for all other operations. By default, buckets are private.
  ///
  /// > RLS policy permissions required:
  /// > - `buckets` table permissions: `insert`
  /// > - `objects` table permissions: none
  ///
  /// - Parameters:
  ///   - isPublic: The visibility of the bucket.
  /// - Returns: newly created bucket ID
  public func createBucket(id: String, isPublic: Bool = false) async throws -> String {
    let url = newUrl.appendingPathComponent("/bucket")

    let body = Bucket.CreateRequest(id: id, isPublic: isPublic)

    let responseData = try await fetch(
      url: url,
      method: .post,
      json: body,
      headers: headers
    )

    let responseObject = try decoder.decode(OneKeyedResponse<String>.self, from: responseData)

    if responseObject.key != "name" {
      throw StorageError(message: "failed to parse response - missing 'name'")
    }

    return responseObject.value
  }

  /// Updates a Storage bucket
  ///
  /// > A bucket with `id` must already exist
  ///
  /// > RLS policy permissions required:
  /// > - `buckets` table permissions: `update`
  /// > - `objects` table permissions: none
  ///
  /// - Parameters:
  ///   - isPublic: The visibility of the bucket.
  /// - Returns: newly created bucket ID
  public func updateBucket(id: String, isPublic: Bool = false) async throws {
    let url = newUrl.appendingPathComponent("/bucket/\(id)")

    let body = Bucket.CreateRequest(id: id, isPublic: isPublic)

    let responseData = try await fetch(
      url: url,
      method: .put,
      json: body,
      headers: headers
    )

    let responseObject = try decoder.decode(OneKeyedResponse<String>.self, from: responseData)

    guard responseObject.key == "message", responseObject.value == "Successfully updated" else {
      throw StorageError(message: "'\(responseObject.key)' = '\(responseObject.value)'")
    }
  }

  /// Removes all objects inside a single bucket.
  ///
  /// > RLS policy permissions required:
  /// > - `buckets` table permissions: `select`
  /// > - `objects` table permissions: `select` and `delete`
  ///
  /// - Parameter id: The unique identifier of the bucket you would like to empty.
  public func emptyBucket(id: String) async throws {
    let url = newUrl.appendingPathComponent("/bucket/\(id)/empty")

    let responseData = try await fetch(
      url: url,
      method: .post
    )

    let responseObject = try decoder.decode(OneKeyedResponse<String>.self, from: responseData)

    if responseObject.key != "message" {
      throw StorageError(message: "failed to parse response - missing 'message'")
    }

    if responseObject.value != "Successfully emptied" {
      throw StorageError(message: "response error: \(responseObject.value)")
    }
  }

  /// Deletes an existing bucket. A bucket can't be deleted with existing objects inside it.
  ///
  /// > You must first empty the bucket using ``emptyBucket(id:)``
  ///
  /// > RLS policy permissions required:
  /// > - `buckets` table permissions: `select` and `delete`
  /// > - `objects` table permissions: none
  ///
  /// - Parameters:
  ///   - id: The unique identifier of the bucket you would like to delete.
  public func deleteBucket(id: String) async throws {
    let url = newUrl.appendingPathComponent("/bucket/\(id)")

    let responseData = try await fetch(
      url: url,
      method: .delete
    )

    let responseObject = try decoder.decode(OneKeyedResponse<String>.self, from: responseData)

    if responseObject.key == "id" {
      throw StorageError(message: "failed to parse response")
    }

    if responseObject.value != "Successfully deleted" {
      throw StorageError(message: "unknown error")
    }
  }
}
