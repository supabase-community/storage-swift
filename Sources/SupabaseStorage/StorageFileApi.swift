import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// Supabase Storage File API
public class StorageFileApi: StorageApi {
  /// The bucket id to operate on.
  var bucketId: String

  /// StorageFileApi initializer
  /// - Parameters:
  ///   - url: Storage HTTP URL
  ///   - headers: HTTP headers.
  ///   - bucketId: The bucket id to operate on.
  init(url: String, headers: [String: String], bucketId: String, http: StorageHTTPClient) {
    self.bucketId = bucketId
    super.init(url: url, headers: headers, http: http)
  }
    
    /// StorageFileApi initializer
    /// - Parameters:
    ///   - url: Storage HTTP URL
    ///   - headers: HTTP headers.
    ///   - bucketId: The bucket id to operate on.
    init(url: URL, headers: [String: String], bucketId: String, http: StorageHTTPClient) {
        self.bucketId = bucketId
        super.init(url: url, headers: headers, http: http)
    }
    

  /// Uploads a file to an existing bucket.
  ///
  /// > RLS policy permissions required:
  /// > - `buckets` table permissions: none
  /// > - `objects` table permissions: `insert`
  ///
  /// - Parameters:
  ///   - path: The relative file path. Should be of the format `folder/subfolder/filename.png`.
  ///   - file: The File object to be stored in the bucket.
  ///   - fileOptions: HTTP headers. For example `cacheControl`
  /// - Returns: Key of the file `bucketID/path`
  @discardableResult
  public func upload(path: String, file: File, fileOptions: FileOptions?) async throws -> String {
    let url = url.appendingPathComponent("/object/\(bucketId)/\(path)")

    let formData = FormData()
    formData.append(file: file)

    let responseData = try await fetch(
      url: url,
      method: .post,
      formData: formData,
      headers: headers,
      fileOptions: fileOptions
    )

    let responseObject = try decoder.decode(OneKeyedResponse<String>.self, from: responseData)

    if responseObject.key != "Key" {
      throw StorageError(message: "failed to parse response - missing 'Key'")
    }

    return responseObject.value
  }

  /// Replaces an existing file at the specified path with a new one.
  ///
  /// > The bucket must already exist before attempting to upload.
  ///
  /// > RLS policy permissions required:
  /// > - `buckets` table permissions: none
  /// > - `objects` table permissions: `update` and `select`
  ///
  /// - Parameters:
  ///   - path: The relative file path. Should be of the format `folder/subfolder`.
  ///   - file: The file object to be stored in the bucket.
  ///   - fileOptions: HTTP headers. For example `cacheControl`
  /// - Returns: Key of the file `bucketID/path`
  @discardableResult
  public func update(path: String, file: File, fileOptions: FileOptions?) async throws -> String {
    let url = url.appendingPathComponent("/object/\(bucketId)/\(path)")

    let formData = FormData()
    formData.append(file: file)

    let responseData = try await fetch(
      url: url,
      method: .put,
      formData: formData,
      headers: headers,
      fileOptions: fileOptions
    )

    let responseObject = try decoder.decode(OneKeyedResponse<String>.self, from: responseData)

    if responseObject.key != "Key" {
      throw StorageError(message: "failed to parse response - missing 'Key'")
    }

    return responseObject.value
  }

  /// Moves an existing file, optionally renaming it at the same time.
  ///
  /// > RLS policy permissions required:
  /// > - `buckets` table permissions: none
  /// > - `objects` table permissions: `update` and `select`
  ///
  /// - Parameters:
  ///   - fromPath: The original file path, including the current file name. For example
  /// `folder/image.png`.
  ///   - toPath: The new file path, including the new file name. For example
  /// `folder/image-copy.png`.
  public func move(fromPath: String, toPath: String) async throws {
    let url = url.appendingPathComponent("/object/move")

    let body = MoveFileRequest(
      bucketID: bucketId,
      source: fromPath,
      destination: toPath
    )

    let responseData = try await fetch(
      url: url,
      method: .post,
      json: body,
      headers: headers
    )

    let responseObject = try decoder.decode(OneKeyedResponse<String>.self, from: responseData)

    if responseObject.key != "message",
       responseObject.value == "Successfully moved"
    {
      throw StorageError(message: "failed to parse response")
    }
  }

  /// Create signed url to download file without requiring permissions.
  ///
  /// > RLS policy permissions required:
  /// > - `buckets` table permissions: none
  /// > - `objects` table permissions: `select`
  ///
  /// This URL can be valid for a set number of seconds.
  /// - Parameters:
  ///   - path: The file path to be downloaded, including the current file name. For example `folder/image.png`.
  ///   - expiresIn: The number of seconds until the signed URL expires. For example, `60` for a URL
  /// which is valid for one minute.
  public func createSignedURL(path: String, expiresIn: Int) async throws -> URL {
    let url = url.appendingPathComponent("/object/sign/\(bucketId)/\(path)")

    let responseData = try await fetch(
      url: url,
      method: .post,
      json: [
        "expiresIn": expiresIn,
      ],
      headers: headers
    )

    let responseObject = try decoder.decode(OneKeyedResponse<String>.self, from: responseData)

    guard responseObject.key == "signedURL" else {
      throw StorageError(message: "failed to parse response")
    }

    guard let url = URL(string: url.absoluteString + responseObject.value) else {
      throw StorageError(message: "failed to construct signed url with '\(responseObject.value)'")
    }

    return url
  }

  /// Deletes files within the same bucket
  ///
  /// > RLS policy permissions required:
  /// > - `buckets` table permissions: none
  /// > - `objects` table permissions: `delete` and `select`
  ///
  /// - Parameters:
  ///   - paths: An array of files to be deletes, including the path and file name. For example
  /// [`folder/image.png`].
  public func remove(paths: [String]) async throws -> [FileObject] {
    let url = url.appendingPathComponent("/object/\(bucketId)")

    let responseData = try await fetch(
      url: url,
      method: .delete,
      json: [
        "prefixes": paths,
      ],
      headers: headers
    )

    let responseObject = try decoder.decode([FileObject].self, from: responseData)

    return responseObject
  }

  /// Lists all the files within a bucket.
  ///
  /// > The bucket must already exist before attempting to upload.
  ///
  /// > RLS policy permissions required:
  /// > - `buckets` table permissions: none
  /// > - `objects` table permissions: `select`
  ///
  /// - Parameters:
  ///   - path: The folder path.
  ///   - options: Search options, including `limit`, `offset`, and `sortBy`
  public func list(
    path: String? = nil,
    options: SearchOptions? = nil
  ) async throws -> [FileObject] {
    let url = url.appendingPathComponent("/object/list/\(bucketId)")

    let body = FileListRequest(
      path: path,
      options: options
    )

    let responseData = try await fetch(
      url: url, method: .post,
      json: body,
      headers: headers
    )

    let responseObject = try decoder.decode([FileObject].self, from: responseData)

    return responseObject
  }

  /// Downloads a file.
  ///
  /// > The bucket must already exist before attempting to upload.
  ///
  /// > RLS policy permissions required:
  /// > - `buckets` table permissions: none
  /// > - `objects` table permissions: `select`
  ///
  /// - Parameters:
  ///   - path: The file path to be downloaded, including the path and file name.
  ///     For example `folder/image.png`.
  @discardableResult
  public func download(path: String) async throws -> Data {
    let url = url.appendingPathComponent("/object/\(bucketId)/\(path)")

    let responseData = try await fetch(url: url, json: nil)

    return responseData
  }
}
