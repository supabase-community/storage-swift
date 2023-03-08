import Foundation
import XCTest

@testable import SupabaseStorage

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

final class SupabaseStorageTests: XCTestCase {
  let storage = SupabaseStorageClient(
    url: "\(supabaseURL)/storage/v1",
    headers: [
      "Authorization": "Bearer \(apiKey)",
      "apikey": apiKey,
    ]
  )
  let bucket = "Test"

  static var apiKey: String {
    if let apiKey = ProcessInfo.processInfo.environment["apiKey"] {
      return apiKey
    }

    XCTFail("apiKey not found.")
    return ""
  }

  static var supabaseURL: String {
    if let url = ProcessInfo.processInfo.environment["supabaseURL"] {
      return url
    }

    XCTFail("supabaseURL not found.")
    return ""
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

  func testListFiles() async throws {
    let objects = try await storage.from(id: "public").list()
    XCTAssertEqual(objects.count, 4)
  }
}
