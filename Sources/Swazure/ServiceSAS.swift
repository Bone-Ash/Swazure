//
//  File.swift
//  Swazure
//
//  Created by GH on 4/23/25.
//

import Foundation

public struct ServiceSAS {
    public var permissions: Permission
    public var resource: Resource
    public var start: Date?
    public var expiry: Date
    public var identifier: String?
    public var ipRange: String?
    public var protocolType: HTTPProtocol = .httpsOnly
    public var version: Version = .v2022_11_02
    public var responseHeaders: ResponseHeaders?
    
    public enum Resource: String {
        case blob = "b"
        case container = "c"
        case file = "f"
        case queue = "q"
        case table = "t"
    }
    
    public struct Permission: OptionSet, CustomStringConvertible {
        public let rawValue: Int
        
        public static let read    = Permission(rawValue: 1 << 0)
        public static let write   = Permission(rawValue: 1 << 1)
        public static let delete  = Permission(rawValue: 1 << 2)
        public static let list    = Permission(rawValue: 1 << 3)
        public static let add     = Permission(rawValue: 1 << 4)
        public static let create  = Permission(rawValue: 1 << 5)
        public static let update  = Permission(rawValue: 1 << 6)
        public static let process = Permission(rawValue: 1 << 7)
        
        public var description: String {
            let all: [(Permission, String)] = [
                (.read, "r"), (.write, "w"), (.delete, "d"), (.list, "l"),
                (.add, "a"), (.create, "c"), (.update, "u"), (.process, "p")
            ]
            return all.compactMap { contains($0.0) ? $0.1 : nil }.joined()
        }
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public struct ResponseHeaders {
        public var cacheControl: String?
        public var contentDisposition: String?
        public var contentEncoding: String?
        public var contentLanguage: String?
        public var contentType: String?
    }
    
    public enum HTTPProtocol: String {
        case httpsOnly = "https"
        case httpsAndHttp = "https,http"
    }
    
    public enum Version: String {
        case v2022_11_02 = "2022-11-02"
        case v2020_04_08 = "2020-04-08"
        case v2018_03_28 = "2018-03-28"
    }
}
