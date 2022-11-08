//
//  File.swift
//
//
//  Created by Noah Kamara on 07.11.22.
//

import SupabaseStorage
import XCTest

class StorageTests: XCTestCase {
  var storage: SupabaseStorageClient!
  var buckets: [String] = []

  override func setUp() async throws {
    storage = SupabaseStorageClient(
      url: Config.storageURL,
      headers: Config.headers
    )
  }

  override func tearDown() async throws {
    /// delete buckets that where created by this test
//        for bucketID in buckets {
//            do {
//                _ = try await storage.emptyBucket(id: bucketID)
//                try await storage.deleteBucket(id: bucketID)
//            } catch {
//                XCTExpectFailure()
//                XCTFail("Unable to delete Bucket \(bucketID) during cleanup")
//            }
//        }
  }

  /// creates a dummy file in the bucket using it's id/name as content
  /// - Parameter bucketID: where to create the file
  /// - Returns: the file id / name / content
  func createFile(in bucketID: String) async -> String {
    let name = UUID().uuidString

    let file = File(
      name: name,
      data: name.data(using: .utf8)!,
      fileName: name,
      contentType: "text/html"
    )

    do {
      _ = try await storage.from(id: bucketID).upload(
        path: name,
        file: file,
        fileOptions: FileOptions(cacheControl: "3600")
      )

      return name
    } catch {
      preconditionFailure("failed to create file")
    }
  }

  /// Creates a bucket with a UUID
  /// - Returns: the bucket ID
  func createBucket() async -> String {
    do {
      let bucketID = try await storage.createBucket(id: UUID().uuidString)
      buckets.append(bucketID)
      return bucketID
    } catch {
      preconditionFailure("failed to create bucket")
    }
  }
}
