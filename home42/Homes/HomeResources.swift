//
//  HomeResources.swift
//  home42
//
//  Created by Antoine Feuerstein on 10/04/2021.
//

import Foundation
import UIKit
import SVGKit
import Darwin.C.errno

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

final actor StorageCachingInterface<G>: NSObject where G: AnyObject {
    
    private let path: URL
    private nonisolated let cache: NSCache<NSString, G>
    
    @frozen private enum State {
        case downloading(Task<G, Error>)
        case error
    }
    private var states: Dictionary<String, StorageCachingInterface.State>
    
    init(directory: HomeResources.DocumentDirectory) {
        let path = HomeResources.documentDirectory.appendingPathComponent(directory.rawValue, isDirectory: true)
        
        if FileManager.default.fileExists(atPath: path.path) == false {
            try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
        }
        self.path = path
        self.cache = NSCache()
        self.cache.countLimit = directory.cacheLimit
        self.states = Dictionary(minimumCapacity: 50)
        super.init()
    }
    
    nonisolated func get(_ coalition: IntraCoalition) -> G? where G == SVGKImage {
        if coalition.image_url == nil {
            return HomeResources.svgUnknowCoalition
        }
        return self.cache.object(forKey: coalition.name as NSString)
    }
    nonisolated func get(_ coalition: IntraCoalition) -> G? where G == UIImage {
        if coalition.cover_url == nil {
            return UIImage.Assets.coalitionDefaultBackground.image
        }
        return self.cache.object(forKey: coalition.slug as NSString)
    }
    nonisolated func get(_ login: String) -> G? where G == UIImage {
        if login.hasPrefix("3b3") {
            return UIImage.Assets.defaultLoginAnonym.image
        }
        return self.cache.object(forKey: login as NSString)
    }
    nonisolated func get(_ achievement: IntraUserAchievement) -> G? where G == SVGKImage {
        if achievement.image == nil {
            return HomeResources.svgLogo42
        }
        return self.cache.object(forKey: "\(achievement.id)" as NSString)
    }
    
    func obtain(_ login: String) async -> (String, G)? where G == UIImage {
        if let image = try? await self.downloadImageWithoutSetStateError(id: login, url: "https://cdn.intra.42.fr/users/medium_\(login).jpg") {
            return (login, image)
        }
        if let image = try? await self.downloadImageWithoutSetStateError(id: login, url: "https://cdn.intra.42.fr/users/medium_\(login).jpeg") {
            return (login, image)
        }
        if let image = try? await self.downloadImage(id: login, url: "https://cdn.intra.42.fr/users/medium_\(login).png") {
            return (login, image)
        }
        return nil
    }
    func obtain(_ coalition: IntraCoalition) async -> (IntraCoalition, G)? where G == SVGKImage {
        do {
            return (coalition, try await self.downloadSVGKImage(id: coalition.name, url: coalition.image_url))
        }
        catch {
            return nil
        }
    }
    func obtain(_ coalition: IntraCoalition) async -> (IntraCoalition, G)? where G == UIImage {
        do {
            return (coalition, try await self.downloadImage(id: coalition.slug, url: coalition.cover_url))
        }
        catch {
            return nil
        }
    }
    func obtain(_ achievement: IntraUserAchievement) async -> (IntraUserAchievement, G)? where G == SVGKImage {
        do {
            return (achievement, try await self.downloadSVGKImage(id: "\(achievement.id)", url: achievement.image_url))
        }
        catch {
            return nil
        }
    }
    
    nonisolated func forceCachingIfSaved(_ coalition: IntraCoalition) where G == UIImage {
        let fileLocation = self.path.appendingPathComponent(coalition.cover_url).path
        
        if FileManager.default.fileExists(atPath: fileLocation), let image = UIImage(contentsOfFile: fileLocation) {
            self.cache.setObject(image, forKey: coalition.slug as NSString)
        }
    }
    
    private enum DownloadError: Error {
        case fileExistDataIrregular
        case requestFailed
        case alreadyFailed
    }
    private func downloadImage(id: String, url: String) async throws -> G where G == UIImage {
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
    private func downloadImageWithoutSetStateError(id: String, url: String) async throws -> G where G == UIImage {
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
                case .downloading(let task):
                    return try await task.value
                default:
                    break
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
                    self.states.removeValue(forKey: id)
                    throw DownloadError.requestFailed
                }
            })
            self.states[id] = .downloading(task)
            return try await task.value
        }
    }
    private func downloadSVGKImage(id: String, url: String) async throws -> G where G == SVGKImage {
        let fileLocation = self.path.appendingPathComponent(id).path
        let task: Task<SVGKImage, Error>
        
        if FileManager.default.fileExists(atPath: fileLocation) {
            if let image = SVGKImage(contentsOfFile: fileLocation) {
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
                
                requestValue = try await URLSession.shared.data(for: url.request)
                if let image = SVGKImage(data: requestValue.data) {
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
    
    nonisolated func allFilesName() throws -> [URL] {
        return try FileManager.default.contentsOfDirectory(at: self.path, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
    }
    struct Info {
        let memoryFootprint: String
    }
    struct InfoError: CustomStringConvertible, Error {
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
    
    nonisolated func allFilesInfo() throws -> Info {
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
        return Info(memoryFootprint: String(format: "%.*f %@", index, size, units[index]))
    }
    
    nonisolated func removeAllStoredFiles() {
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
    
    nonisolated func clearCache() {
        self.cache.removeAllObjects()
    }
}

final class HomeResources: NSObject {
    
    static let documentDirectory: URL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
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
    
    static let storageLoginImages: StorageCachingInterface<UIImage> = .init(directory: DocumentDirectory.logins)
    static let storageCoalitionsImages: StorageCachingInterface<UIImage> = .init(directory: DocumentDirectory.coalitions)
    static let storageSVGCoalition: StorageCachingInterface<SVGKImage> = .init(directory: DocumentDirectory.svgCoalitions)
    static let storageSVGAchievement: StorageCachingInterface<SVGKImage> = .init(directory: DocumentDirectory.svgAchievements)
    
    static var seeCacheFilesCount: Int = 0
    static var seeCacheDirectory: HomeResources.DocumentDirectory = .logins
    
    @LazySVGKImageGetter(location: "res/svg/42.svg") static var svgLogo42: SVGKImage
    @LazySVGKImageGetter(location: "res/svg/factionless.svg") static var svgUnknowCoalition: SVGKImage
        
    @inlinable static func clearCache() {
        self.storageLoginImages.clearCache()
        self.storageCoalitionsImages.clearCache()
        self.storageSVGCoalition.clearCache()
        self.storageSVGAchievement.clearCache()
    }
}
