# Swazure

Swazure is a lightweight Swift SDK for generating Azure Storage **Service SAS** (Shared Access Signature) URLs. It provides a clean and composable abstraction for signing Azure Storage resources from Swift-based clients.

Currently, only **Service SAS** is supported. Other SAS types (such as Account SAS and User Delegation SAS) are planned for future versions.

## TODO
- Account SAS

## Features

- Generate SAS tokens for Azure **Blob Storage**
- Fine-grained permission control (read, write, delete, list, etc.)
- Support for:
  - Custom response headers
  - IP range restrictions
  - HTTPS-only or HTTP+HTTPS protocols
  - Optional start times
  - Multiple API versions
- Cross-platform compatible via [`swift-crypto`](https://github.com/apple/swift-crypto)

## Installation

Use [Swift Package Manager](https://swift.org/package-manager/):

### `Package.swift`
```swift
.package(url: "https://github.com/Bone-Ash/Swazure.git", from: "0.0.1")
```

### Target dependencies:
```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "Swazure", package: "Swazure")
    ]
)
```

## Usage

```swift
import Swazure

let accountName = "your-storage-account-name"
let accountKey = "your-base64-encoded-account-key"

let signer = Swazure.Signer(
    .init(accountName: accountName, accountKey: accountKey)
)

let container = "your-container"
let blob = "your-object.mp4"

// Set validity time window
let start = Date()
let expiry = Calendar.current.date(byAdding: .hour, value: 1, to: start)!

// Optional response headers
let headers = ServiceSAS.ResponseHeaders(
    cacheControl: nil,
    contentDisposition: "inline",
    contentEncoding: nil,
    contentLanguage: nil,
    contentType: "video/mp4"
)

let url = try signer.signedURL(
    container: container,
    blob: blob,
    permissions: [.read],
    start: start,
    expiry: expiry,
    responseHeaders: headers
)

print(url?.absoluteString ?? "URL generation failed")
```

## Supported Permissions

You can combine multiple permissions:

```swift
[.read, .write, .delete, .list]
```

See `ServiceSAS.Permission` for the full list.

## License

Swazure is released under the MIT License.
