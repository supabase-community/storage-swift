import Foundation

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

    internal func fetch(url: URL, method: HTTPMethod = .get, parameters: [String: Any]?, headers: [String: String]? = nil, jsonSerialization: Bool = true, completion: @escaping (Result<Any, Error>) -> Void) {
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
                return
            }
        }

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { [unowned self] (data, response, error) -> Void in
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
        if statusCode == 200 || 200 ..< 300 ~= statusCode {
            return response
        } else if let dict = response as? [String: Any], let message = dict["message"] as? String {
            throw StorageError(statusCode: statusCode, message: message)
        } else {
            throw StorageError(statusCode: statusCode, message: "something went wrong")
        }
    }
}
