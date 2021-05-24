
public class SupabaseStorageClient: StorageBucketApi {
    override public init(url: String, headers: [String: String]) {
        super.init(url: url, headers: headers)
    }

    public func from(id: String) -> StorageFileApi {
        return StorageFileApi(url: url, headers: headers, bucketId: id)
    }
}
