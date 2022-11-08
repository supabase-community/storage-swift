//
//  File.swift
//
//
//  Created by Noah Kamara on 08.11.22.
//

import Foundation

struct OneKeyedResponse<Value: Decodable>: Decodable {
  var key: String
  var value: Value

  struct DynamicKeys: CodingKey {
    var stringValue: String
    var intValue: Int?

    init(stringValue: String) {
      self.stringValue = stringValue
    }

    init?(intValue: Int) {
      stringValue = "Index \(intValue)"
      self.intValue = intValue
    }
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicKeys.self)

    guard let key = container.allKeys.first, container.allKeys.count == 1 else {
      throw StorageError(message: "Expected one key")
    }

    value = try container.decode(Value.self, forKey: key)
    self.key = key.stringValue
  }
}
