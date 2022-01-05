//
//  HomeApiResources.swift
//  home42
//
//  Created by Antoine Feuerstein on 18/04/2021.
//

import Foundation
import UIKit

final class HomeApiResources: NSObject {
    
    static private(set) var expertises: [Int: IntraExpertise]! = nil
    static private(set) var blocs: ContiguousArray<IntraBlock>! = nil
    static private(set) var campus: ContiguousArray<IntraCampus>! = nil
    static private(set) var titles: ContiguousArray<IntraTitle>! = nil
    static private(set) var groups: ContiguousArray<IntraGroup>! = nil
    static private(set) var skills: ContiguousArray<IntraSkill>! = nil
    static private(set) var projects: ContiguousArray<IntraProject>! = nil
    
    static func prepare() {
        
        func readFile<G: Codable>(_ filename: String) -> G {
            let file = try! Data(contentsOf: HomeResources.applicationDirectory.appendingPathComponent(filename))
            let elements = try! JSONDecoder.decoder.decode(G.self, from: file)
            
            return elements
        }
        
        let expertises: ContiguousArray<IntraExpertise> = readFile("res/json/expertises.json")
        
        HomeApiResources.expertises = expertises.reduce(into: [Int: IntraExpertise](minimumCapacity: expertises.count), { $0[$1.id] = $1 })
        HomeApiResources.blocs = readFile("res/json/blocs.json")
        HomeApiResources.campus = readFile("res/json/campus.json")
        HomeApiResources.titles = readFile("res/json/titles.json")
        HomeApiResources.groups = readFile("res/json/groups.json")
        HomeApiResources.skills = readFile("res/json/skills.json")
        HomeApiResources.projects = readFile("res/json/projects.json")
    }
}
