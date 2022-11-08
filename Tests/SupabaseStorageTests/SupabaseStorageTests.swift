import Foundation
import XCTest

@testable import SupabaseStorage

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class SupabaseStorageTests: XCTestCase {
  let storage = SupabaseStorageClient(url: storageURL(), headers: ["Authorization": token()])
  let bucket = "Test"

  static func token() -> String {
    if let token = ProcessInfo.processInfo.environment["Authorization"] {
      return token
    } else {
      fatalError()
    }
  }

  static func storageURL() -> String {
    if let url = ProcessInfo.processInfo.environment["storageURL"] {
      return url
    } else {
      fatalError()
    }
  }

  func testCreateBucket() async throws {
    let buckets = try await storage.createBucket(id: bucket)
    XCTAssertFalse(buckets.isEmpty)
  }

  func testListBuckets() async throws {
    let buckets = try await storage.listBuckets()
    XCTAssertFalse(buckets.isEmpty)
  }

  func testUploadFile() async throws {
    let data = try! Data(
      contentsOf: URL(
        string: "https://raw.githubusercontent.com/satishbabariya/storage-swift/main/README.md"
      )!
    )

    let file = File(name: "README.md", data: data, fileName: "README.md", contentType: "text/html")
    _ = try await storage.from(id: bucket).upload(
      path: "README.md", file: file, fileOptions: FileOptions(cacheControl: "3600")
    )
  }

  func testDownloadFile() async throws {
    let data = try await storage.from(id: bucket).download(path: "README.md")
    XCTAssertFalse(data.isEmpty)
  }
}
