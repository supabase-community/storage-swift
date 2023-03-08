import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public class StorageApi {
  var url: String
  var headers: [String: String]
  var http: StorageHTTPClient

  init(url: String, headers: [String: String], http: StorageHTTPClient) {
    self.url = url
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

  @discardableResult
  internal func fetch(
    url: URL,
    method: HTTPMethod = .get,
    parameters: [String: Any]?,
    headers: [String: String]? = nil
  ) async throws -> Any {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue

    if var headers = headers {
      headers.merge(self.headers) { $1 }
      request.allHTTPHeaderFields = headers
    } else {
      request.allHTTPHeaderFields = self.headers
    }

    if let parameters = parameters {
      request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
    }

    let (data, response) = try await http.fetch(request)
    if let mimeType = response.mimeType {
      switch mimeType {
      case "application/json":
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        return try parse(response: json, statusCode: response.statusCode)
      default:
        return try parse(response: data, statusCode: response.statusCode)
      }
    } else {
      throw StorageError(message: "failed to get response")
    }
  }

  internal func fetch(
    url: URL,
    method: HTTPMethod = .post,
    formData: FormData,
    headers: [String: String]? = nil,
    fileOptions: FileOptions? = nil,
    jsonSerialization: Bool = true
  ) async throws -> Any {
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

    if jsonSerialization {
      let json = try JSONSerialization.jsonObject(with: data, options: [])
      return try parse(response: json, statusCode: response.statusCode)
    }

    if let dataString = String(data: data, encoding: .utf8) {
      return dataString
    }

    throw StorageError(message: "failed to get response")
  }

  private func parse(response: Any, statusCode: Int) throws -> Any {
    if statusCode == 200 || 200..<300 ~= statusCode {
      return response
    } else if let dict = response as? [String: Any], let error = dict["error"] as? String {
      throw StorageError(statusCode: statusCode, message: error)
    } else if let dict = response as? [String: Any], let message = dict["message"] as? String {
      throw StorageError(statusCode: statusCode, message: message)
    } else {
      throw StorageError(statusCode: statusCode, message: "something went wrong")
    }
  }
}
