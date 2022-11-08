//
//  File.swift
//
//
//  Created by Noah Kamara on 07.11.22.
//

import SupabaseStorage
import XCTest

/// Tests the bucket API
///
/// **Requires supabsaeURL & supabaseKey to be configured in** ``Config.self``
final class BucketAPITests: StorageTests {
  func testCreateBucket() async throws {
    let bucketID = UUID().uuidString
    buckets.append(bucketID)

    let id = try await storage.createBucket(id: bucketID)
    XCTAssert(id == bucketID)
  }

  func testUpdateBucket() async throws {
    let bucketID = await createBucket()

    let id = try await storage.updateBucket(id: bucketID, isPublic: true)
  }

  func testGetBucket() async throws {
    let bucketID = await createBucket()

    let bucket = try await storage.getBucket(id: bucketID)

    XCTAssert(bucket.id == bucketID)
    XCTAssert(bucket.name == bucketID)
  }

  func testListBuckets() async throws {
    _ = try await storage.listBuckets()
  }

  func testDeleteBucket() async throws {
    let bucketID = await createBucket()

    try await storage.deleteBucket(id: bucketID)
    buckets.removeAll(where: { $0 == bucketID })
  }

  func testEmptyBucket() async throws {
    let bucketID = await createBucket()
    try await storage.emptyBucket(id: bucketID)
  }
}
