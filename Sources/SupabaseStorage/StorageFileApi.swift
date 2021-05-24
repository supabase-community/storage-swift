public class StorageFileApi: StorageApi {
    var bucketId: String

    init(url: String, headers: [String: String], bucketId: String) {
        self.bucketId = bucketId
        super.init(url: url, headers: headers)
    }
}
