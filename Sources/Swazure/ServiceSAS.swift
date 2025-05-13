import Foundation

public struct ServiceSAS {
    public var permissions: Permission
    public var resource: Resource
    public var start: Date?
    public var expiry: Date
    public var identifier: String?
    public var ipRange: String?
    public var protocolType: HTTPProtocol = .httpsOnly
    public var version: Version = .v2024_11_04
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
        
        public static let read                  = Permission(rawValue: 1 << 0)  // r - 读取内容、属性、元数据等
        public static let write                 = Permission(rawValue: 1 << 1)  // w - 创建或写入内容、属性、元数据等
        public static let delete                = Permission(rawValue: 1 << 2)  // d - 删除Blob
        public static let list                  = Permission(rawValue: 1 << 3)  // l - 以非递归方式列出Blob
        public static let add                   = Permission(rawValue: 1 << 4)  // a - 向追加Blob添加块
        public static let create                = Permission(rawValue: 1 << 5)  // c - 编写新的Blob、快照或复制
        public static let update                = Permission(rawValue: 1 << 6)  // u - (未在表中列出，保留以兼容旧代码)
        public static let process               = Permission(rawValue: 1 << 7)  // p - (未在表中列出，保留以兼容旧代码)
        public static let deleteVersion         = Permission(rawValue: 1 << 8)  // x - 删除Blob版本
        public static let permanentDelete       = Permission(rawValue: 1 << 9)  // y - 永久删除Blob快照或版本
        public static let tags                  = Permission(rawValue: 1 << 10)  // t - 读取或写入Blob上的标记
        public static let move                  = Permission(rawValue: 1 << 11)  // m - 移动Blob或目录及其内容
        public static let execute               = Permission(rawValue: 1 << 12)  // e - 获取系统属性和POSIX ACL
        public static let ownership             = Permission(rawValue: 1 << 13)  // o - 设置所有者或拥有组
        public static let permissionManagement  = Permission(rawValue: 1 << 14)  // p - 设置权限和POSIX ACL
        public static let immutabilityPolicy    = Permission(rawValue: 1 << 15)  // i - 设置或删除不可变性策略
        
        public var description: String {
            let all: [(Permission, String)] = [
                (.read, "r"), (.write, "w"), (.delete, "d"), (.list, "l"),
                (.add, "a"), (.create, "c"), (.update, "u"), (.process, "p"),
                (.deleteVersion, "x"), (.permanentDelete, "y"), (.tags, "t"),
                (.move, "m"), (.execute, "e"), (.ownership, "o"),
                (.permissionManagement, "p"), (.immutabilityPolicy, "i")
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
        case v2025_01_05 = "2025-01-05"
        case v2024_11_04 = "2024-11-04"
        case v2022_11_02 = "2022-11-02"
        case v2020_04_08 = "2020-04-08"
        case v2018_03_28 = "2018-03-28"
    }
}
