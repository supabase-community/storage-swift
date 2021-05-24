import Foundation

public class StorageBucketApi: StorageApi {
    override init(url: String, headers: [String: String]) {
        super.init(url: url, headers: headers)
        self.headers.merge(["Content-Type": "application/json"]) { $1 }
    }

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
