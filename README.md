# Swazure

Swazure is a lightweight Swift SDK that helps you generate Azure Storage Service SAS (Shared Access Signature) URLs. It is designed to provide a clean and minimal abstraction for securely accessing Azure Blob Storage from Swift-based applications.

## Features

- Generate Service SAS tokens for Azure Blob Storage
- Support for specifying permissions, start/expiry times, allowed protocols, IP ranges, and more
- Support for custom response headers (e.g., content type)
- Built with `swift-crypto` to ensure cross-platform compatibility

## Installation

Using [Swift Package Manager](https://swift.org/package-manager/), add Swazure to your `Package.swift`:

```swift
.package(url: "https://github.com/your-username/Swazure.git", from: "0.0.1")
```

Then include `"Swazure"` in your target dependencies:

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

// Define time range
let start = Date()  // Now
let expiry = Calendar.current.date(byAdding: .hour, value: 1, to: start)! // one hour later

let url = try signer.signedURL(
    container: container,
    blob: blob,
    permissions: [.write],
    start: start,
    expiry: expiry
)

print(url.absoluteString)
```

## License

Swazure is released under the MIT License.
