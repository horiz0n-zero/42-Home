// home42/HomeResources.swift
/* +++++++++++++++++++++++++++++++++++++++++++++++++++ *
+
+      :::       ::::::::
+     :+:       :+:    :+:
+    +:+   +:+        +:+
+   +#+   +:+       +#+
+  +#+#+#+#+#+    +#+
+       #+#     #+#
+      ###    ######## H O M E
+
+   Copyright Antoine Feuerstein. All rights reserved.
+
* ++++++++++++++++++++++++++++++++++++++++++++++++++++ */

import Foundation
import UIKit
import Darwin.C.errno
import WebKit
import SwiftUI

final class CachingInterface: NSCache<NSString, UIImage> {
    
    func getImage(url: String, id: String, block: @escaping (String, UIImage?) -> ()) {
        if let image = self.object(forKey: id as NSString) {
            DispatchQueue.main.async {
                block(id, image)
            }
        }
        URLSession.shared.dataTask(with: url.request, completionHandler: { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    block(id, image)
                    self.setObject(image, forKey: id as NSString)
                }
            }
            else {
                DispatchQueue.main.async {
                    block(id, nil)
                }
            }
        }).resume()
    }
}

protocol StorageCachingBase: AnyObject {
    
    var directory: HomeResources.DocumentDirectory { get }
    
    func allFilesName() throws -> [URL]
    func allFilesInfo() throws -> StorageCachingInfo
    func removeAllStoredFiles()
    func clearCache()
}

struct StorageCachingInfo {
    let memoryFootprint: String
}

struct StorageCachingInfoError: CustomStringConvertible, Error {
    let errnoValue: Int
    
    init() {
        self.errnoValue = Int(errno)
    }
    var description: String {
        return "\(self.errnoValue) \(String(cString: strerror(Int32(self.errnoValue))))"
    }
    var localizedDescription: String {
        return self.description
    }
}
@frozen enum StorageCachingState {
    case downloading(Task<UIImage, Error>)
    case error
}

final actor StorageCachingImage: StorageCachingBase {
    
    private let path: URL
    private nonisolated let cache: NSCache<NSString, UIImage>
    let directory: HomeResources.DocumentDirectory
    private var states: Dictionary<String, StorageCachingState>
    
    init(directory: HomeResources.DocumentDirectory) {
        let path = HomeResources.documentDirectory.appendingPathComponent(directory.rawValue, isDirectory: true)
        
        if FileManager.default.fileExists(atPath: path.path) == false {
            try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
        }
        self.path = path
        self.cache = NSCache()
        self.cache.countLimit = directory.cacheLimit
        self.states = Dictionary(minimumCapacity: 50)
        self.directory = directory
    }
    
    nonisolated func get(_ coalition: IntraCoalition) -> UIImage? {
        if coalition.cover_url == nil {
            return UIImage.Assets.coalitionDefaultBackground.image
        }
        return self.cache.object(forKey: coalition.slug as NSString)
    }
    nonisolated func get(_ userInfo: IntraUserInfo) -> UIImage? {
        if userInfo.login.hasPrefix("3b3") {
            return UIImage.Assets.defaultLoginAnonym.image
        }
        return self.cache.object(forKey: userInfo.login as NSString)
    }
    nonisolated func get(_ user: IntraUser) -> UIImage? {
        if user.login.hasPrefix("3b3") {
            return UIImage.Assets.defaultLoginAnonym.image
        }
        return self.cache.object(forKey: user.login as NSString)
    }
    nonisolated func get(_ people: People) -> UIImage? {
        if people.login.hasPrefix("3b3") {
            return UIImage.Assets.defaultLoginAnonym.image
        }
        return self.cache.object(forKey: people.login as NSString)
    }
    nonisolated func get(_ contributor: HomeApiResources.Contributor) -> UIImage? {
        if contributor.login.hasPrefix("3b3") {
            return UIImage.Assets.defaultLoginAnonym.image
        }
        return self.cache.object(forKey: contributor.login as NSString)
    }
    
    func obtain(_ userInfo: IntraUserInfo) async -> (String, UIImage)? {
        if let url = userInfo.image_url, let image = try? await self.downloadImage(id: userInfo.login, url: url) {
            return (userInfo.login, image)
        }
        return nil
    }
    func obtain(_ user: IntraUser) async -> (String, UIImage)? {
        if let url = user.image_url, let image = try? await self.downloadImage(id: user.login, url: url) {
            return (user.login, image)
        }
        return nil
    }
    func obtain(_ people: People) async -> (String, UIImage)? {
        if let url = people.image_url, let image = try? await self.downloadImage(id: people.login, url: url) {
            return (people.login, image)
        }
        return nil
    }
    func obtain(_ contributor: HomeApiResources.Contributor) async -> (String, UIImage)? {
        if let url = contributor.image_url, let image = try? await self.downloadImage(id: contributor.login, url: url) {
            return (contributor.login, image)
        }
        return nil
    }
    func obtain(_ coalition: IntraCoalition) async -> (IntraCoalition, UIImage)? {
        do {
            return (coalition, try await self.downloadImage(id: coalition.slug, url: coalition.cover_url))
        }
        catch {
            return nil
        }
    }
    
    nonisolated func forceCachingIfSaved(_ coalition: IntraCoalition) {
        guard let coverURL = coalition.cover_url else {
            return
        }
        let fileLocation = self.path.appendingPathComponent(coverURL).path
        
        if FileManager.default.fileExists(atPath: fileLocation), let image = UIImage(contentsOfFile: fileLocation) {
            self.cache.setObject(image, forKey: coalition.slug as NSString)
        }
    }
    
    private enum DownloadError: Error {
        case fileExistDataIrregular
        case requestFailed
        case alreadyFailed
    }
    
    private func downloadImage(id: String, url: String) async throws -> UIImage {
        let fileLocation = self.path.appendingPathComponent(id).path
        let task: Task<UIImage, Error>
        
        if FileManager.default.fileExists(atPath: fileLocation) {
            if let image = UIImage(contentsOfFile: fileLocation) {
                self.cache.setObject(image, forKey: id as NSString)
                return image
            }
            throw DownloadError.fileExistDataIrregular
        }
        else {
            if let state = self.states[id] {
                switch state {
                case .error:
                    throw DownloadError.alreadyFailed
                case .downloading(let task):
                    return try await task.value
                }
            }
            task = Task.init(priority: .userInitiated, operation: {
                let requestValue: (data: Data, response: URLResponse)
                
                do {
                    requestValue = try await URLSession.shared.data(for: url.request)
                }
                catch {
                    self.states.removeValue(forKey: id)
                    throw DownloadError.requestFailed
                }
                if let image = UIImage(data: requestValue.data) {
                    self.states.removeValue(forKey: id)
                    self.cache.setObject(image, forKey: id as NSString)
                    FileManager.default.createFile(atPath: fileLocation, contents: requestValue.data, attributes: [:])
                    return image
                }
                else {
                    throw DownloadError.requestFailed
                }
            })
            self.states[id] = .downloading(task)
            return try await task.value
        }
    }
    
    final nonisolated func allFilesName() throws -> [URL] {
        return try FileManager.default.contentsOfDirectory(at: self.path,
                                                           includingPropertiesForKeys: nil,
                                                           options: [.skipsHiddenFiles])
    }
    
    final nonisolated func allFilesInfo() throws -> StorageCachingInfo {
        let set: Set<URLResourceKey> = [.fileSizeKey]
        let contents: [URL] = try FileManager.default.contentsOfDirectory(at: self.path,
                                                                          includingPropertiesForKeys: [.fileSizeKey, .isExecutableKey],
                                                                          options: [.skipsHiddenFiles])
        
        let units = ["B", "kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
        var index: Int = 0
        var size: Double = 0.0
        
        for url in contents {
            size += Double(try url.resourceValues(forKeys: set).fileSize ?? 0)
        }
        while size > 1024.0 {
            size /= 1024.0
            index &+= 1
        }
        return StorageCachingInfo(memoryFootprint: String(format: "%.*f %@", index, size, units[index]))
    }
    
    final nonisolated func removeAllStoredFiles() {
        do {
            for file in try self.allFilesName() {
                try? FileManager.default.removeItem(at: file)
            }
        }
        catch {
            #if DEBUG
            print(#function, error)
            #endif
        }
    }
    
    final nonisolated func clearCache() {
        self.cache.removeAllObjects()
    }
}

final actor StorageCachingImageFromSVG: StorageCachingBase {
    
    final class SVGWebViewImageGenerator: WKWebView, WKNavigationDelegate {
        
        private var queuedWorks: [(data: Data, continuation: UnsafeContinuation<UIImage, Error>)] = []
        private var work: UnsafeContinuation<UIImage, Error>? = nil
        private let size: CGSize
        
        init(size: CGSize) {
            let pref = WKPreferences()
            let config = WKWebViewConfiguration()
            
            pref.javaScriptCanOpenWindowsAutomatically = false
            config.preferences = pref
            config.allowsAirPlayForMediaPlayback = false
            config.allowsPictureInPictureMediaPlayback = false
            self.size = size
            super.init(frame: .init(origin: .zero, size: size), configuration: config)
            self.navigationDelegate = self
            self.contentMode = .scaleToFill
            self.scrollView.isScrollEnabled = false
            self.scrollView.backgroundColor = .clear
            self.scrollView.frame = self.frame
            self.scrollView.contentSize = size
            self.backgroundColor = .clear
            self.isOpaque = false
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let config = WKSnapshotConfiguration()
            
            config.rect = .init(origin: .zero, size: self.size)
            self.takeSnapshot(with: config) { image, error in
                if let work = self.work {
                    if let image = image {
                        work.resume(returning: image)
                    }
                    if let error = error {
                        work.resume(throwing: error)
                    }
                }
                self.processNext()
            }
        }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            if let work = self.work {
                work.resume(throwing: error)
            }
            self.processNext()
        }
        
        func imageFromData(_ data: Data) async throws -> UIImage {
            if self.work == nil {
                return try await withUnsafeThrowingContinuation { continuation in
                    self.work = continuation
                    self.render(data)
                }
            }
            else {
                return try await withUnsafeThrowingContinuation { continuation in
                    self.queuedWorks.append((data, continuation))
                }
            }
        }
        
        private func processNext() {
            let next: (data: Data, continuation: UnsafeContinuation<UIImage, Error>)
            
            self.work = nil
            if self.queuedWorks.isEmpty == false {
                next = self.queuedWorks.removeFirst()
                self.work = next.continuation
                self.render(next.data)
            }
        }
        
        private func render(_ data: Data) {
            let svg = String(data: data, encoding: .utf8)!
            let w = "\(self.size.width * UIScreen.main.scale * 0.98)pt"
            let h = "\(self.size.height * UIScreen.main.scale * 0.98)pt"
            let html = "<div style=\"width: \(w); height: \(h);\">\(rewriteSVGSize(svg))</div>"
            
            func rewriteSVGSize(_ string: String) -> String {
                guard let startRange = string.range(of: "<svg") else {
                    return string
                }
                guard let endRange = string.range(of: ">", range: startRange.upperBound ..< string.endIndex) else {
                    return string
                }
                let tagRange = startRange.lowerBound ..< endRange.upperBound
                let oldTag   = string[tagRange]
                var attrs: [String: String] = {
                    
                    final class Handler: NSObject, XMLParserDelegate {
                        var attrs : [ String : String ]?
                    
                        func parser(_ parser: XMLParser, didStartElement: String,
                                    namespaceURI: String?, qualifiedName: String?,
                                    attributes: [String: String]) {
                            self.attrs = attributes
                        }
                    }
                    let parser  = XMLParser(data: Data((string[tagRange] + "</svg>").utf8))
                    let handler = Handler()
                    
                    parser.delegate = handler
                    guard parser.parse() else { return [:] }
                    return handler.attrs ?? [:]
                }()
                
                if attrs["viewBox"] == nil && (attrs["width"] != nil || attrs["height"] != nil) {
                    let w = attrs.removeValue(forKey: "width")  ?? w
                    let h = attrs.removeValue(forKey: "height") ?? h
                    let x = attrs.removeValue(forKey: "x")      ?? "0"
                    let y = attrs.removeValue(forKey: "y")      ?? "0"

                    attrs["viewBox"] = "\(x) \(y) \(w) \(h)"
                }
                attrs.removeValue(forKey: "x")
                attrs.removeValue(forKey: "y")
                attrs["width"]  = w
                attrs["height"] = h
                
                func renderTag(_ tag: String, attributes: [ String : String ]) -> String {
                    var ms = "<\(tag)"
                    
                    for ( key, value ) in attributes {
                        ms += " \(key)=\""
                        ms += value
                            .replacingOccurrences(of: "&",  with: "&amp;")
                            .replacingOccurrences(of: "<",  with: "&lt;")
                            .replacingOccurrences(of: ">",  with: "&gt;")
                            .replacingOccurrences(of: "'",  with: "&apos;")
                            .replacingOccurrences(of: "\"", with: "&quot;")
                        ms += "\""
                    }
                    ms += ">"
                    return ms
                }
                let newTag = renderTag("svg", attributes: attrs)

                return newTag == oldTag ? string : string.replacingCharacters(in: tagRange, with: newTag)
            }
            DispatchQueue.main.async {
                self.loadHTMLString(html, baseURL: nil)
            }
        }
    }
    
    private let converter: SVGWebViewImageGenerator
    private let path: URL
    private nonisolated let cache: NSCache<NSString, UIImage>
    let directory: HomeResources.DocumentDirectory
    
    @frozen private enum State {
        case downloading(Task<UIImage, Error>)
        case error
    }
    private var states: Dictionary<String, StorageCachingState>
    
    init(directory: HomeResources.DocumentDirectory, convertor: SVGWebViewImageGenerator) {
        let path = HomeResources.documentDirectory.appendingPathComponent(directory.rawValue, isDirectory: true)
        
        if FileManager.default.fileExists(atPath: path.path) == false {
            try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
        }
        self.path = path
        self.cache = NSCache()
        self.cache.countLimit = directory.cacheLimit
        self.states = Dictionary(minimumCapacity: 50)
        self.directory = directory
        self.converter = convertor
    }
    
    nonisolated func get(_ coalition: IntraCoalition) -> UIImage? {
        if coalition.image_url == nil {
            return UIImage.Assets.svgFactionless.image
        }
        return self.cache.object(forKey: coalition.name as NSString)
    }
    
    nonisolated func get(_ achievement: IntraUserAchievement) -> UIImage? {
        if achievement.image == nil {
            return UIImage.Assets.svg42.image
        }
        return self.cache.object(forKey: "\(achievement.id)" as NSString)
    }

    func obtain(_ coalition: IntraCoalition) async -> (IntraCoalition, UIImage)? {
        do {
            return (coalition, try await self.download(id: coalition.name, url: coalition.image_url, template: true))
        }
        catch {
            return nil
        }
    }
    
    func obtain(_ achievement: IntraUserAchievement) async -> (IntraUserAchievement, UIImage)? {
        do {
            return (achievement, try await self.download(id: "\(achievement.id)",
                                                         url: achievement.image_url, template: false))
        }
        catch {
            return nil
        }
    }
    
    private enum DownloadError: Error {
        case fileExistDataIrregular
        case requestFailed
        case alreadyFailed
    }
    
    private func download(id: String, url: String, template: Bool) async throws -> UIImage {
        let fileLocation = self.path.appendingPathComponent(id).path
        let task: Task<UIImage, Error>
        
        if FileManager.default.fileExists(atPath: fileLocation) {
            if var image = UIImage(contentsOfFile: fileLocation) {
                if template {
                    image = image.withRenderingMode(.alwaysTemplate)
                }
                self.cache.setObject(image, forKey: id as NSString)
                return image
            }
            throw DownloadError.fileExistDataIrregular
        }
        else {
            if let state = self.states[id] {
                switch state {
                case .error:
                    throw DownloadError.alreadyFailed
                case .downloading(let task):
                    return try await task.value
                }
            }
            task = Task.init(priority: .userInitiated, operation: {
                let requestValue: (data: Data, response: URLResponse)
                var image: UIImage
                
                requestValue = try await URLSession.shared.data(for: url.request)
                if (requestValue.response as? HTTPURLResponse)?.statusCode == 200 {
                    image = try await self.converter.imageFromData(requestValue.data)
                    if template {
                        image = image.withRenderingMode(.alwaysTemplate)
                    }
                    self.states.removeValue(forKey: id)
                    self.cache.setObject(image, forKey: id as NSString)
                    FileManager.default.createFile(atPath: fileLocation, contents: image.pngData()!, attributes: [:])
                    return image
                }
                else {
                    throw DownloadError.requestFailed
                }
            })
            self.states[id] = .downloading(task)
            return try await task.value
        }
    }
    
    final nonisolated func allFilesName() throws -> [URL] {
        return try FileManager.default.contentsOfDirectory(at: self.path,
                                                           includingPropertiesForKeys: nil,
                                                           options: [.skipsHiddenFiles])
    }
    
    final nonisolated func allFilesInfo() throws -> StorageCachingInfo {
        let set: Set<URLResourceKey> = [.fileSizeKey]
        let contents: [URL] = try FileManager.default.contentsOfDirectory(at: self.path,
                                                                          includingPropertiesForKeys: [.fileSizeKey, .isExecutableKey],
                                                                          options: [.skipsHiddenFiles])
        
        let units = ["B", "kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
        var index: Int = 0
        var size: Double = 0.0
        
        for url in contents {
            size += Double(try url.resourceValues(forKeys: set).fileSize ?? 0)
        }
        while size > 1024.0 {
            size /= 1024.0
            index &+= 1
        }
        return .init(memoryFootprint: String(format: "%.*f %@", index, size, units[index]))
    }
    
    final nonisolated func removeAllStoredFiles() {
        do {
            for file in try self.allFilesName() {
                try? FileManager.default.removeItem(at: file)
            }
        }
        catch {
            #if DEBUG
            print(#function, error)
            #endif
        }
    }
    
    final nonisolated func clearCache() {
        self.cache.removeAllObjects()
    }
}

final class HomeResources: NSObject {
    
    static let documentDirectory: URL = {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.horiz0n-zero.home42")!
    }()
    
    static let applicationDirectory: URL = {
        return Bundle.main.bundleURL
    }()
    
    @frozen enum DocumentDirectory: String {
        case logins = "images/logins"
        case coalitions = "images/coalitions"
        case svgCoalitions = "svg/coalitions"
        case svgAchievements = "svg/achievements"
        
        var isSVG: Bool {
            switch self {
            case .logins, .coalitions:
                return false
            case .svgCoalitions, .svgAchievements:
                return true
            }
        }
        var cacheLimit: Int {
            switch self {
            case .logins:
                return 1042
            case .coalitions:
                return 10
            case .svgCoalitions, .svgAchievements:
                return 50
            }
        }
    }
    
    static let storageLoginImages: StorageCachingImage = .init(directory: DocumentDirectory.logins)
    static let storageCoalitionsImages: StorageCachingImage = .init(directory: DocumentDirectory.coalitions)
    static let storageSVGCoalition: StorageCachingImageFromSVG = .init(directory: DocumentDirectory.svgCoalitions,
                                                                       convertor: .init(size: .init(width: 150.0,
                                                                                                    height: 150.0)))
    static let storageSVGAchievement: StorageCachingImageFromSVG = .init(directory: DocumentDirectory.svgAchievements,
                                                                         convertor: .init(size: .init(width: 150.0,
                                                                                                      height: 150.0)))
        
    @inlinable static func clearCache() {
        self.storageLoginImages.clearCache()
        self.storageCoalitionsImages.clearCache()
        self.storageSVGCoalition.clearCache()
        self.storageSVGAchievement.clearCache()
    }
}
