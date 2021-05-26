import Foundation

public class StorageFileApi: StorageApi {
    var bucketId: String

    init(url: String, headers: [String: String], bucketId: String) {
        self.bucketId = bucketId
        super.init(url: url, headers: headers)
    }

    public func upload(path: String, file: File, fileOptions: FileOptions?, completion: @escaping (Result<Any, Error>) -> Void) {
        guard let url = URL(string: "\(url)/object/\(bucketId)/\(path)") else {
            completion(.failure(StorageError(message: "badURL")))
            return
        }

        let formData = FormData()
        formData.append(file: file)

        fetch(url: url, method: .post, formData: formData, headers: headers, fileOptions: fileOptions) { result in
            completion(result)
        }
    }

    public func update(path: String, file: File, fileOptions: FileOptions?, completion: @escaping (Result<Any, Error>) -> Void) {
        guard let url = URL(string: "\(url)/object/\(bucketId)/\(path)") else {
            completion(.failure(StorageError(message: "badURL")))
            return
        }

        let formData = FormData()
        formData.append(file: file)

        fetch(url: url, method: .put, formData: formData, headers: headers, fileOptions: fileOptions) { result in
            completion(result)
        }
    }

    public func move(fromPath: String, toPath: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let url = URL(string: "\(url)/object/move") else {
            completion(.failure(StorageError(message: "badURL")))
            return
        }

        fetch(url: url, method: .post, parameters: ["bucketId": bucketId, "sourceKey": fromPath, "destinationKey": toPath], headers: headers) { result in
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

    public func createSignedUrl(path: String, expiresIn: Int, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let url = URL(string: "\(url)/object/sign/\(path)") else {
            completion(.failure(StorageError(message: "badURL")))
            return
        }

        fetch(url: url, method: .post, parameters: ["expiresIn": expiresIn], headers: headers) { result in
            switch result {
            case let .success(response):
                guard let dict: [String: Any] = response as? [String: Any], let signedURL: String = dict["signedURL"] as? String else {
                    completion(.failure(StorageError(message: "failed to parse response")))
                    return
                }
                completion(.success(url.appendingPathComponent(signedURL)))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    // TODO: download

    public func remove(paths: [String], completion: @escaping (Result<[String: Any], Error>) -> Void) {
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

    public func list(path: String? = nil, options: SearchOptions? = nil, completion: @escaping (Result<[FileObject], Error>) -> Void) {
        guard let url = URL(string: "\(url)/object/list/\(bucketId)") else {
            completion(.failure(StorageError(message: "badURL")))
            return
        }

        var sortBy: [String: String] = [:]
        sortBy["column"] = options?.sortBy?.column ?? "name"
        sortBy["order"] = options?.sortBy?.order ?? "asc"

        fetch(url: url, method: .post, parameters: ["path": path ?? "", "limit": options?.limit ?? 100, "offset": options?.offset ?? 0], headers: headers) { result in
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
}
