// home42/HomeApiResources.swift
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

final class HomeApiResources: NSObject {
    
    static private(set) var expertises: [Int: IntraExpertise]! = nil
    static private(set) var blocs: ContiguousArray<IntraBlock>! = nil
    static private(set) var campus: ContiguousArray<IntraCampus>! = nil
    static private(set) var cursus: ContiguousArray<IntraCursus>! = nil
    static private(set) var titles: ContiguousArray<IntraTitle>! = nil
    static private(set) var groups: ContiguousArray<IntraGroup>! = nil
    static private(set) var skills: ContiguousArray<IntraSkill>! = nil
    static private(set) var projects: ContiguousArray<IntraProject>! = nil
    static private(set) var achievements: ContiguousArray<IntraUserAchievement>! = nil
    static private(set) var languages: ContiguousArray<IntraLanguage>! = nil
    static private(set) var flags: ContiguousArray<IntraFlag>! = nil
    
    final class Contributor: NSObject, Codable {
        
        typealias Group = String
        
        let id: Int
        let login: String
        let image: IntraUser.Image
        let groups: [Group]
    }
    static private(set) var contributors: [String: Contributor]! = nil
    static private(set) var contributorsGroups: [Contributor.Group]! = nil
    
    static func prepare() {
        
        func readFile<G: Codable>(_ filename: String) -> G {
            let file = try! Data(contentsOf: HomeResources.applicationDirectory.appendingPathComponent(filename))
            let elements = try! JSONDecoder.decoder.decode(G.self, from: file)
            
            return elements
        }
        
        let expertises: ContiguousArray<IntraExpertise> = readFile("res/json/expertises.json")
        let contributors: ContiguousArray<Contributor> = readFile("res/contributors/contributors.json")
        
        HomeApiResources.expertises = expertises.reduce(into: [Int: IntraExpertise](minimumCapacity: expertises.count), { $0[$1.id] = $1 })
        HomeApiResources.blocs = readFile("res/json/blocs.json")
        HomeApiResources.campus = readFile("res/json/campus.json")
        HomeApiResources.cursus = readFile("res/json/cursus.json")
        HomeApiResources.titles = readFile("res/json/titles.json")
        HomeApiResources.groups = readFile("res/json/groups.json")
        HomeApiResources.skills = readFile("res/json/skills.json")
        HomeApiResources.projects = readFile("res/json/projects.json")
        HomeApiResources.achievements = readFile("res/json/achievements.json")
        HomeApiResources.languages = readFile("res/json/languages.json")
        HomeApiResources.flags = readFile("res/json/flags.json")
        HomeApiResources.contributors = contributors.reduce(into:[String:Contributor](minimumCapacity:contributors.count), { $0[$1.login] = $1 })
        HomeApiResources.contributorsGroups = readFile("res/contributors/groups.json")
    }
    
    static let userSortOptions: [String] = ["login", "first_name", "last_name", "pool_year", "pool_month", "id", "last_seen_at"]
    static let userSortOptionsKeys: [String] = ["sort.login", "sort.first-name", "sort.last-name", "sort.pool-year", "sort.pool-month", "sort.id", "sort.last-seen-at"]
    static let eventSortOptions: [String] = ["begin_at", "end_at", "id", "name", "description", "location", "max_people", "created_at", "updated_at"]
    static let eventSortOptionsKeys: [String] = ["sort.begin-at", "sort.end-at", "sort.id", "sort.name", "sort.description", "sort.location", "sort.max-people", "sort.created-at", "sort.updated-at"]
    static let achievementOptions: [String] = ["created_at", "name", "id"]
    static let achievementOptionsKeys: [String] = ["sort.created-at", "sort.name", "sort.id"]
    static let notionOptions: [String] = ["updated_at", "created_at", "name", "id"]
    static let notionOptionsKeys: [String] = ["sort.updated-at", "sort.created-at", "sort.name", "sort.id"]
}
