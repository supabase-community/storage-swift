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
  init(url: String, headers: [String: String], bucketId: String) {
    self.bucketId = bucketId
    super.init(url: url, headers: headers)
  }

  /// Uploads a file to an existing bucket.
  /// - Parameters:
  ///   - path: The relative file path. Should be of the format `folder/subfolder/filename.png`. The bucket must already exist before attempting to upload.
  ///   - file: The File object to be stored in the bucket.
  ///   - fileOptions: HTTP headers. For example `cacheControl`
  ///   - completion: Result<Any, Error>
  public func upload(
    path: String, file: File, fileOptions: FileOptions?,
    completion: @escaping (Result<Any, Error>) -> Void
  ) {
    guard let url = URL(string: "\(url)/object/\(bucketId)/\(path)") else {
      completion(.failure(StorageError(message: "badURL")))
      return
    }

    let formData = FormData()
    formData.append(file: file)

    fetch(url: url, method: .post, formData: formData, headers: headers, fileOptions: fileOptions) {
      result in
      completion(result)
    }
  }

  /// Replaces an existing file at the specified path with a new one.
  /// - Parameters:
  ///   - path: The relative file path. Should be of the format `folder/subfolder`. The bucket already exist before attempting to upload.
  ///   - file: The file object to be stored in the bucket.
  ///   - fileOptions: HTTP headers. For example `cacheControl`
  ///   - completion: Result<Any, Error>
  public func update(
    path: String, file: File, fileOptions: FileOptions?,
    completion: @escaping (Result<Any, Error>) -> Void
  ) {
    guard let url = URL(string: "\(url)/object/\(bucketId)/\(path)") else {
      completion(.failure(StorageError(message: "badURL")))
      return
    }

    let formData = FormData()
    formData.append(file: file)

    fetch(url: url, method: .put, formData: formData, headers: headers, fileOptions: fileOptions) {
      result in
      completion(result)
    }
  }

  /// Moves an existing file, optionally renaming it at the same time.
  /// - Parameters:
  ///   - fromPath: The original file path, including the current file name. For example `folder/image.png`.
  ///   - toPath: The new file path, including the new file name. For example `folder/image-copy.png`.
  ///   - completion: Result<[String: Any], Error>
  public func move(
    fromPath: String, toPath: String, completion: @escaping (Result<[String: Any], Error>) -> Void
  ) {
    guard let url = URL(string: "\(url)/object/move") else {
      completion(.failure(StorageError(message: "badURL")))
      return
    }

    fetch(
      url: url, method: .post,
      parameters: ["bucketId": bucketId, "sourceKey": fromPath, "destinationKey": toPath],
      headers: headers
    ) { result in
      switch result {
      case let .success(response):
        guard let dict: [String: Any] = response as? [String: Any] else {
          completion(.failure(StorageError(message: "failed to parse response")))
          return
        }
        completion(.success(dict))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }

  /// Create signed url to download file without requiring permissions. This URL can be valid for a set number of seconds.
  /// - Parameters:
  ///   - path: The file path to be downloaded, including the current file name. For example `folder/image.png`.
  ///   - expiresIn: The number of seconds until the signed URL expires. For example, `60` for a URL which is valid for one minute.
  ///   - completion: Result<URL, Error>
  public func createSignedUrl(
    path: String, expiresIn: Int, completion: @escaping (Result<URL, Error>) -> Void
  ) {
    guard let url = URL(string: "\(url)/object/sign/\(path)") else {
      completion(.failure(StorageError(message: "badURL")))
      return
    }

    fetch(url: url, method: .post, parameters: ["expiresIn": expiresIn], headers: headers) {
      result in
      switch result {
      case let .success(response):
        guard let dict: [String: Any] = response as? [String: Any],
          let signedURL: String = dict["signedURL"] as? String
        else {
          completion(.failure(StorageError(message: "failed to parse response")))
          return
        }
        completion(.success(url.appendingPathComponent(signedURL)))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }

  /// Deletes files within the same bucket
  /// - Parameters:
  ///   - paths: An array of files to be deletes, including the path and file name. For example [`folder/image.png`].
  ///   - completion: Result<[String: Any], Error>
  public func remove(paths: [String], completion: @escaping (Result<[String: Any], Error>) -> Void)
  {
    guard let url = URL(string: "\(url)/object/\(bucketId)") else {
      completion(.failure(StorageError(message: "badURL")))
      return
    }

    fetch(url: url, method: .delete, parameters: ["prefixes": paths], headers: headers) { result in
      switch result {
      case let .success(response):
        guard let dict: [String: Any] = response as? [String: Any] else {
          completion(.failure(StorageError(message: "failed to parse response")))
          return
        }
        completion(.success(dict))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }

  /// Lists all the files within a bucket.
  /// - Parameters:
  ///   - path: The folder path.
  ///   - options: Search options, including `limit`, `offset`, and `sortBy`.
  ///   - completion: Result<[FileObject], Error>
  public func list(
    path: String? = nil, options: SearchOptions? = nil,
    completion: @escaping (Result<[FileObject], Error>) -> Void
  ) {
    guard let url = URL(string: "\(url)/object/list/\(bucketId)") else {
      completion(.failure(StorageError(message: "badURL")))
      return
    }

    var sortBy: [String: String] = [:]
    sortBy["column"] = options?.sortBy?.column ?? "name"
    sortBy["order"] = options?.sortBy?.order ?? "asc"

    fetch(
      url: url, method: .post,
      parameters: [
        "prefix": path ?? "", "limit": options?.limit ?? 100, "offset": options?.offset ?? 0,
      ], headers: headers
    ) { result in
      switch result {
      case let .success(response):
        guard let arr: [[String: Any]] = response as? [[String: Any]] else {
          completion(.failure(StorageError(message: "failed to parse response")))
          return
        }
        completion(.success(arr.compactMap { FileObject(from: $0) }))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }

  /// Downloads a file.
  /// - Parameters:
  ///   - path: The file path to be downloaded, including the path and file name. For example `folder/image.png`.
  ///   - completion: Result<Data?, Error>) -> Void
  /// - Returns: URLSessionDataTask or nil
  @discardableResult
  public func download(path: String, completion: @escaping (Result<Data?, Error>) -> Void)
    -> URLSessionDataTask?
  {
    guard let url = URL(string: "\(url)/object/\(bucketId)/\(path)") else {
      completion(.failure(StorageError(message: "badURL")))
      return nil
    }

    let dataTask = fetch(url: url, parameters: nil) { result in
      switch result {
      case let .success(data):
        guard let data: Data = data as? Data else {
          completion(.failure(StorageError(message: "failed to parse response")))
          return
        }
        completion(.success(data))
      case let .failure(error):
        completion(.failure(error))
      }
    }
    return dataTask
  }
}
