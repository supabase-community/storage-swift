//
//  File.swift
//
//
//  Created by Noah Kamara on 08.11.22.
//

import Foundation

struct MoveFileRequest: Encodable {
  var bucketID: String
  var source: String
  var destination: String

  enum CodingKeys: String, CodingKey {
    case bucketID = "bucketId"
    case source = "sourceKey"
    case destination = "destinationKey"
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(bucketID, forKey: .bucketID)
    try container.encode(source, forKey: .source)
    try container.encode(destination, forKey: .destination)
  }
}
