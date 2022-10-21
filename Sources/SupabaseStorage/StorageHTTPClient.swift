import Foundation

public protocol StorageHTTPClient {
  func fetch(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
  func upload(_ request: URLRequest, from data: Data) async throws -> (Data, HTTPURLResponse)
}

public struct DefaultStorageHTTPClient: StorageHTTPClient {
  public init() {}

  public func fetch(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
    try await withCheckedThrowingContinuation { continuation in
      let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }

        guard
          let data = data,
          let httpResponse = response as? HTTPURLResponse
        else {
          continuation.resume(throwing: URLError(.badServerResponse))
          return
        }

        continuation.resume(returning: (data, httpResponse))
      }

      dataTask.resume()
    }
  }

  public func upload(_ request: URLRequest, from data: Data) async throws -> (Data, HTTPURLResponse) {
    try await withCheckedThrowingContinuation { continuation in
      let task = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
        if let error = error {
          continuation.resume(throwing: error)
          return
        }

        guard
          let data = data,
          let httpResponse = response as? HTTPURLResponse
        else {
          continuation.resume(throwing: URLError(.badServerResponse))
          return
        }

        continuation.resume(returning: (data, httpResponse))
      }
      task.resume()
    }
  }
}
