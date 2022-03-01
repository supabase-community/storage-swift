import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public class StorageApi {
  var url: String
  var headers: [String: String]

  init(url: String, headers: [String: String]) {
    self.url = url
    self.headers = headers
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
    url: URL, method: HTTPMethod = .get, parameters: [String: Any]?,
    headers: [String: String]? = nil, jsonSerialization _: Bool = true,
    completion: @escaping (Result<Any, Error>) -> Void
  ) -> URLSessionDataTask? {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue

    if var headers = headers {
      headers.merge(self.headers) { $1 }
      request.allHTTPHeaderFields = headers
    } else {
      request.allHTTPHeaderFields = self.headers
    }

    if let parameters = parameters {
      do {
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
      } catch {
        completion(.failure(error))
        return nil
      }
    }

    let session = URLSession.shared
    let dataTask: URLSessionDataTask = session.dataTask(
      with: request,
      completionHandler: { (data, response, error) -> Void in
        if let error = error {
          completion(.failure(error))
          return
        }

        if let resp = response as? HTTPURLResponse {
          if let data = data, let mimeType = response?.mimeType {
            do {
              switch mimeType {
              case "application/json":
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                completion(.success(try self.parse(response: json, statusCode: resp.statusCode)))
              default:
                completion(.success(try self.parse(response: data, statusCode: resp.statusCode)))
              }
            } catch {
              completion(.failure(error))
              return
            }
          }
        } else {
          completion(.failure(StorageError(message: "failed to get response")))
        }

      })

    dataTask.resume()
    return dataTask
  }

  internal func fetch(
    url: URL, method: HTTPMethod = .post, formData: FormData, headers: [String: String]? = nil,
    fileOptions: FileOptions? = nil, jsonSerialization: Bool = true,
    completion: @escaping (Result<Any, Error>) -> Void
  ) {
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

    let session = URLSession.shared
    let dataTask = session.uploadTask(
      with: request, from: formData.data,
      completionHandler: { (data, response, error) -> Void in
        if let error = error {
          completion(.failure(error))
          return
        }

        if let resp = response as? HTTPURLResponse {
          if let data = data {
            if jsonSerialization {
              do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                completion(.success(try self.parse(response: json, statusCode: resp.statusCode)))
              } catch {
                completion(.failure(error))
                return
              }
            } else {
              if let dataString = String(data: data, encoding: .utf8) {
                completion(.success(dataString))
                return
              }
            }
          }
        } else {
          completion(.failure(StorageError(message: "failed to get response")))
        }

      })

    dataTask.resume()
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
