import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public class StorageApi {
  let decoder: JSONDecoder = {
    var decoder = JSONDecoder()
    return decoder
  }()

  let encoder: JSONEncoder = .init()

  var url: URL

  var headers: [String: String]
  var http: StorageHTTPClient

  init(url: URL, headers: [String: String], http: StorageHTTPClient) {
    url = url
    self.headers = headers
    self.http = http
    //        self.headers.merge(["Content-Type": "application/json"]) { $1 }
  }

  init(url: String, headers: [String: String], http: StorageHTTPClient) {
    url = URL(string: url)!
    self.headers = headers
    self.http = http
    //        self.headers.merge(["Content-Type": "application/json"]) { $1 }
  }

  internal enum HTTPMethod: String {
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case connect = "CONNECT"
    case options = "OPTIONS"
    case trace = "TRACE"
    case patch = "PATCH"
  }

  internal func parseForErrors(data: Data, response: HTTPURLResponse) throws {
    if 200 ..< 300 ~= response.statusCode {
      return
    }

    do {
      let storageError = try decoder.decode(StorageError.self, from: data)
      throw storageError
    } catch {
      throw error
    }
  }

  @discardableResult
  internal func fetch(
    url: URL,
    method: HTTPMethod = .get,
    json: (any Encodable)? = nil,
    headers: [String: String]? = nil
  ) async throws -> Data {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue

    if var headers = headers {
      headers.merge(self.headers) { $1 }
      request.allHTTPHeaderFields = headers
    } else {
      request.allHTTPHeaderFields = self.headers
    }

    if let jsonBody = json {
      request.allHTTPHeaderFields?["Content-Type"] = "application/json"
      let bodyData = try encoder.encode(jsonBody)
      request.httpBody = bodyData
    }

    let (data, response) = try! await http.fetch(request)

    try parseForErrors(data: data, response: response)

    return data
  }

  internal func fetch(
    url: URL,
    method: HTTPMethod = .post,
    formData: FormData,
    headers: [String: String]? = nil,
    fileOptions: FileOptions? = nil
  ) async throws -> Data {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue

    if let fileOptions = fileOptions {
      request.setValue(fileOptions.cacheControl, forHTTPHeaderField: "cacheControl")
    }

    var allHTTPHeaderFields = self.headers
    if let headers = headers {
      allHTTPHeaderFields.merge(headers) { $1 }
    }

    allHTTPHeaderFields.forEach { key, value in
      request.setValue(value, forHTTPHeaderField: key)
    }

    request.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")

    let (data, response) = try await http.upload(request, from: formData.data)

    try parseForErrors(data: data, response: response)

    return data
  }
}
