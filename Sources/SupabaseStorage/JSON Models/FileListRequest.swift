//
//  File.swift
//
//
//  Created by Noah Kamara on 08.11.22.
//

import Foundation

struct FileListRequest: Encodable {
  let prefix: String
  let limit: Int
  let offset: Int

  init(prefix: String? = nil, limit: Int? = nil, offset: Int? = nil) {
    self.prefix = prefix ?? ""
    self.limit = limit ?? 100
    self.offset = offset ?? 0
  }

  init(path: String? = nil, options: SearchOptions?) {
    self.init(prefix: path,
              limit: options?.limit,
              offset: options?.offset)
  }
}
