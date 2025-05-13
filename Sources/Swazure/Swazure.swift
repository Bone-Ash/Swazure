import Crypto
import Foundation

public enum Swazure {
    public struct Configuration {
        public let accountName: String
        public let accountKey: String
        
        public init(accountName: String, accountKey: String) {
            self.accountName = accountName
            self.accountKey = accountKey
        }
    }
    
    public struct Signer {
        public let config: Configuration
        
        public init(_ config: Configuration) {
            self.config = config
        }
        
        public func signedURL(
            container: String,
            blob: String,
            permissions: ServiceSAS.Permission,
            start: Date,
            expiry: Date,
            responseHeaders: ServiceSAS.ResponseHeaders? = nil
        ) throws -> URL? {
            try validate(ServiceSAS(
                permissions: permissions,
                resource: .blob,
                start: start,
                expiry: expiry,
                identifier: nil,
                ipRange: nil,
                protocolType: .httpsOnly,
                version: .v2024_11_04,
                responseHeaders: responseHeaders
            ))
            
            let parameters = ServiceSAS(
                permissions: permissions,
                resource: .blob,
                start: start,
                expiry: expiry,
                identifier: nil,
                ipRange: nil,
                protocolType: .httpsOnly,
                version: .v2024_11_04,
                responseHeaders: responseHeaders
            )
            
            let queryItems = try signedQueryItems(for: parameters, container: container, blobName: blob)
            
            let baseURL = "https://\(config.accountName).blob.core.windows.net/\(container)/\(blob)"
            
            let queryString = queryItems.map { item -> String in
                if let value = item.value {
                    return "\(item.name)=\(value)"
                } else {
                    return item.name
                }
            }.joined(separator: "&")
            
            let url = URL(string: baseURL + "?" + queryString)
            return url
        }
        
        private func signedQueryItems(for parameters: ServiceSAS, container: String, blobName: String) throws -> [URLQueryItem] {
            let canonicalizedResource = "/blob/\(config.accountName)/\(container)/\(blobName)"
            
            let parts: [String] = [
                parameters.permissions.description,
                parameters.start?.iso8601 ?? "",
                parameters.expiry.iso8601,
                canonicalizedResource,
                parameters.identifier ?? "",
                parameters.ipRange ?? "",
                parameters.protocolType.rawValue,
                parameters.version.rawValue,
                parameters.resource.rawValue,
                "",
                "",
                parameters.responseHeaders?.cacheControl ?? "",
                parameters.responseHeaders?.contentDisposition ?? "",
                parameters.responseHeaders?.contentEncoding ?? "",
                parameters.responseHeaders?.contentLanguage ?? "",
                parameters.responseHeaders?.contentType ?? ""
            ]
            
            let stringToSign = parts.joined(separator: "\n")
            
            guard let keyData = Data(base64Encoded: config.accountKey) else {
                throw SigningError.invalidKey
            }
            
            let signature = HMAC<SHA256>.authenticationCode(
                for: Data(stringToSign.utf8),
                using: SymmetricKey(data: keyData)
            )
            
            let sig = Data(signature).base64EncodedString()
                .replacingOccurrences(of: "+", with: "%2B")
                .replacingOccurrences(of: "/", with: "%2F")
                .replacingOccurrences(of: "=", with: "%3D")
            
            var items: [URLQueryItem] = [
                .init(name: "sv", value: parameters.version.rawValue),
                .init(name: "sr", value: parameters.resource.rawValue),
                .init(name: "sp", value: parameters.permissions.description),
                .init(name: "se", value: parameters.expiry.iso8601),
                .init(name: "spr", value: parameters.protocolType.rawValue),
                .init(name: "sig", value: sig)
            ]
            
            if let st = parameters.start?.iso8601 {
                items.append(.init(name: "st", value: st))
            }
            if let sip = parameters.ipRange {
                items.append(.init(name: "sip", value: sip))
            }
            if let si = parameters.identifier {
                items.append(.init(name: "si", value: si))
            }
            if let headers = parameters.responseHeaders {
                if let v = headers.cacheControl     { items.append(.init(name: "rscc", value: v)) }
                if let v = headers.contentDisposition { items.append(.init(name: "rscd", value: v)) }
                if let v = headers.contentEncoding   { items.append(.init(name: "rsce", value: v)) }
                if let v = headers.contentLanguage   { items.append(.init(name: "rscl", value: v)) }
                if let v = headers.contentType       { items.append(.init(name: "rsct", value: v)) }
            }
            
            return items
        }
        
        private func validate(_ parameters: ServiceSAS) throws {
            guard !parameters.permissions.description.isEmpty else {
                throw SigningError.invalidPermissions
            }
            guard parameters.expiry > Date() else {
                throw SigningError.invalidExpiry
            }
        }
        
        public enum SigningError: Error {
            case invalidKey
            case invalidURL
            case invalidPermissions
            case invalidExpiry
        }
    }
}

private extension Date {
    var iso8601: String {
        Date.iso8601Formatter.string(from: self)
    }
    
    static let iso8601Formatter: ISO8601DateFormatter = {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime]
        fmt.timeZone = TimeZone(secondsFromGMT: 0)
        return fmt
    }()
}
