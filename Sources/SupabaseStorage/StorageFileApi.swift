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

        fetch(url: url, formData: formData, headers: headers, fileOptions: fileOptions) { result in
            completion(result)
        }
    }
}
