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

    func testListBuckets() {
        let e = expectation(description: "listBuckets")

        storage.listBuckets { result in
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
