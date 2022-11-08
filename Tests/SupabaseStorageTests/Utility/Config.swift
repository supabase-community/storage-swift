//
//  File.swift
//
//
//  Created by Noah Kamara on 07.11.22.
//

import Foundation

/// Config for testing
/// **requires RLS access for anon role**
struct Config {
  /// The URL of the Supabase instance
  static let supabaseURL: URL = {
    guard let urlString = ProcessInfo.processInfo.environment["supabaseUrl"] else {
      preconditionFailure("'supabaseUrl' needs to be set in environment")
    }

    guard let url = URL(string: urlString) else {
      preconditionFailure("not a valid URL: '\(urlString)'")
    }

    return url
  }()

  /// The key for the instance
  static let supabaseKey: String = {
    guard let key = ProcessInfo.processInfo.environment["supabaseKey"] else {
      preconditionFailure("'supabaseUrl' needs to be set in environment")
    }

    return key
  }()

  static var storageURL: URL { supabaseURL.appendingPathComponent("/storage/v1") }

  static let headers: [String: String] = [
    "Authorization": "Bearer \(supabaseKey)",
  ]
}
