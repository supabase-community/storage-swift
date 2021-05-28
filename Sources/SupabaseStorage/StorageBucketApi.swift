import Foundation

/// Storage Bucket API
public class StorageBucketApi: StorageApi {
    /// StorageBucketApi initializer
    /// - Parameters:
    ///   - url: Storage HTTP URL
    ///   - headers: HTTP headers.
    override init(url: String, headers: [String: String]) {
        super.init(url: url, headers: headers)
        self.headers.merge(["Content-Type": "application/json"]) { $1 }
    }

    /// Retrieves the details of all Storage buckets within an existing product.
    /// - Parameter completion: Result<[Bucket], Error>
    public func listBuckets(completion: @escaping (Result<[Bucket], Error>) -> Void) {
        guard let url = URL(string: "\(url)/bucket") else {
            completion(.failure(StorageError(message: "badURL")))
            return
        }

        fetch(url: url, method: .get, parameters: nil, headers: headers) { result in
            switch result {
            case let .success(response):
                guard let dict: [[String: Any]] = response as? [[String: Any]] else {
                    completion(.failure(StorageError(message: "failed to parse response")))
                    return
                }
                completion(.success(dict.compactMap { Bucket(from: $0) }))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    /// Retrieves the details of an existing Storage bucket.
    /// - Parameters:
    ///   - id: The unique identifier of the bucket you would like to retrieve.
    ///   - completion: Result<Bucket, Error>
    public func getBucket(id: String, completion: @escaping (Result<Bucket, Error>) -> Void) {
        guard let url = URL(string: "\(url)/bucket/\(id)") else {
            completion(.failure(StorageError(message: "badURL")))
            return
        }

        fetch(url: url, method: .get, parameters: nil, headers: headers) { result in
            switch result {
            case let .success(response):
                guard let dict: [String: Any] = response as? [String: Any], let bucket = Bucket(from: dict) else {
                    completion(.failure(StorageError(message: "failed to parse response")))
                    return
                }
                completion(.success(bucket))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    /// Creates a new Storage bucket
    /// - Parameters:
    ///   - id: A unique identifier for the bucket you are creating.
    ///   - completion: newly created bucket id
    public func createBucket(id: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "\(url)/bucket") else {
            completion(.failure(StorageError(message: "badURL")))
            return
        }

        fetch(url: url, method: .post, parameters: ["id": id], headers: headers) { result in
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

    /// Removes all objects inside a single bucket.
    /// - Parameters:
    ///   - id: The unique identifier of the bucket you would like to empty.
    ///   - completion: Result<[String: Any], Error>
    public func emptyBucket(id: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "\(url)/bucket/\(id)/empty") else {
            completion(.failure(StorageError(message: "badURL")))
            return
        }

        fetch(url: url, method: .post, parameters: [:], headers: headers) { result in
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

    /// Deletes an existing bucket. A bucket can't be deleted with existing objects inside it.
    /// You must first `empty()` the bucket.
    /// - Parameters:
    ///   - id: The unique identifier of the bucket you would like to delete.
    ///   - completion: Result<[String: Any], Error>
    public func deleteBucket(id: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "\(url)/bucket/\(id)") else {
            completion(.failure(StorageError(message: "badURL")))
            return
        }

        fetch(url: url, method: .delete, parameters: [:], headers: headers) { result in
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
}
