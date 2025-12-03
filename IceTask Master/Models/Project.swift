//
//  Project.swift
//  TaskMaster Pro
//

import Foundation

struct Project: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var description: String
    var color: String
    var teamMemberIds: [String]
    var createdDate: Date
    var deadline: Date?
    var isArchived: Bool
    
    init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        color: String = "#2490ad",
        teamMemberIds: [String] = [],
        createdDate: Date = Date(),
        deadline: Date? = nil,
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.color = color
        self.teamMemberIds = teamMemberIds
        self.createdDate = createdDate
        self.deadline = deadline
        self.isArchived = isArchived
    }
}

