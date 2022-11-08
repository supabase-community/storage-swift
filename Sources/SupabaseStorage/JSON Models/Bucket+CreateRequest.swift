//
//  File.swift
//
//
//  Created by Noah Kamara on 08.11.22.
//

import Foundation

internal extension Bucket {
  struct CreateRequest: Encodable {
    let name: String
    let isPublic: Bool?

    init(id: String, isPublic: Bool? = nil) {
      name = id
      self.isPublic = isPublic
    }

    enum CodingKeys: String, CodingKey {
      case name
      case isPublic = "public"
    }
  }
}
