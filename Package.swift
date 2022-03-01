// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SupabaseStorage",
  products: [
    .library(
      name: "SupabaseStorage",
      targets: ["SupabaseStorage"]
    )
  ],
  dependencies: [],
  targets: [
    .target(
      name: "SupabaseStorage",
      dependencies: []
    ),
    .testTarget(
      name: "SupabaseStorageTests",
      dependencies: ["SupabaseStorage"]
    ),
  ]
)
