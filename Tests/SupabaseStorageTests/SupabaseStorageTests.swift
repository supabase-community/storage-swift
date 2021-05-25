import Foundation
@testable import SupabaseStorage
import XCTest

final class SupabaseStorageTests: XCTestCase {
    let storage = SupabaseStorageClient(url: storageURL(), headers: ["Authorization": token()])

    static func token() -> String {
        if let token = ProcessInfo.processInfo.environment["Authorization"] {
            return token
        } else {
            fatalError()
        }
    }

    static func storageURL() -> String {
        if let url = ProcessInfo.processInfo.environment["StorageURL"] {
            return url
        } else {
            fatalError()
        }
    }

    func testUploadFile() {
        let e = expectation(description: "testUploadFile")
        let data = try! Data(contentsOf: URL(string: "https://raw.githubusercontent.com/satishbabariya/storage-swift/main/README.md")!)

        let file = File(name: "README.md", data: data, fileName: "README.md", contentType: "text/html")

        print(file)

        storage.from(id: "Demo").upload(path: "\(UUID().uuidString).md", file: file, fileOptions: FileOptions(cacheControl: "3600")) { result in
            switch result {
            case let .success(res):
                print(res)
                XCTAssertEqual(true, true)
            case let .failure(error):
                print(error.localizedDescription)
                XCTFail("testUploadFile failed: \(error.localizedDescription)")
            }
            e.fulfill()
        }

        waitForExpectations(timeout: 30) { error in
            if let error = error {
                XCTFail("testUploadFile failed: \(error.localizedDescription)")
            }
        }
    }

    func testListBuckets() {
        let e = expectation(description: "listBuckets")

        SupabaseStorageClient(url: SupabaseStorageTests.storageURL(), headers: ["Authorization": SupabaseStorageTests.token()]).listBuckets { result in
            switch result {
            case let .success(buckets):
                XCTAssertEqual(buckets.count >= 0, true)
            case let .failure(error):
                print(error.localizedDescription)
                XCTFail("listBuckets failed: \(error.localizedDescription)")
            }
            e.fulfill()
        }

        waitForExpectations(timeout: 30) { error in
            if let error = error {
                XCTFail("listBuckets failed: \(error.localizedDescription)")
            }
        }
    }

    static var allTests = [
        ("testListBuckets", testListBuckets),
    ]
}
