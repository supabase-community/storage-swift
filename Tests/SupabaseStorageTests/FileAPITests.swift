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
final class FileAPITests: StorageTests {
  func testUploadFile() async throws {
    let bucketID = await createBucket()

    let data = "Hello, World!".data(using: .utf8)!

    let file = File(
      name: "README.md",
      data: data,
      fileName: "README.md",
      contentType: "text/html"
    )

    let path = try await storage.from(id: bucketID).upload(
      path: "README.md",
      file: file,
      fileOptions: FileOptions(cacheControl: "3600")
    )

    XCTAssertEqual(path, "\(bucketID)/README.md")
  }

  func testUpdateFile() async throws {
    let bucketID = await createBucket()
    let filePath = await createFile(in: bucketID)

    let file = File(
      name: filePath,
      data: "Hello, Developer!".data(using: .utf8)!,
      fileName: filePath,
      contentType: "text/html"
    )

    let key = try await storage.from(id: bucketID).update(
      path: filePath,
      file: file,
      fileOptions: FileOptions(cacheControl: "3600")
    )

    XCTAssertEqual(key, "\(bucketID)/\(filePath)")
  }

  func testDownloadFile() async throws {
    let bucketID = await createBucket()
    let filePath = await createFile(in: bucketID)

    let data = try await storage.from(id: bucketID).download(path: filePath)

    XCTAssertEqual(data, filePath.data(using: .utf8)!)
  }

  func testMoveFile() async throws {
    let bucketID = await createBucket()
    let filePath = await createFile(in: bucketID)
    let newPath = UUID().uuidString

    try await storage.from(id: bucketID).move(
      fromPath: filePath,
      toPath: newPath
    )
  }

  func testRemoveFile() async throws {
    let bucketID = await createBucket()

    let file1 = await createFile(in: bucketID)
    let file2 = await createFile(in: bucketID)

    let files = try await storage.from(id: bucketID).remove(paths: [file1, file2])

    XCTAssertEqual(Set(files.map(\.name)), Set([file1, file2]))
  }

  func testListFiles() async throws {
    let bucketID = await createBucket()

    let file1 = await createFile(in: bucketID)
    let file2 = await createFile(in: bucketID)

    let files = try await storage.from(id: bucketID).list()

    XCTAssertEqual(Set(files.map(\.name)), Set([file1, file2]))
  }

  func testCreateSignedURL() async throws {
    let bucketID = await createBucket()
    let filePath = await createFile(in: bucketID)

    let signedURL = try await storage.from(id: bucketID).createSignedURL(
      path: filePath,
      expiresIn: 30
    )

    let (data, _) = try await URLSession.shared.data(from: signedURL)
    XCTAssertEqual(String(data: data, encoding: .utf8), filePath)
  }
}
