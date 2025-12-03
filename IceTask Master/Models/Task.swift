//
//  Task.swift
//  TaskMaster Pro
//

import Foundation

enum TaskPriority: String, Codable, CaseIterable {
    case urgent = "Urgent"
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    var color: String {
        switch self {
        case .urgent: return "#f0048d"
        case .high: return "#fbaa1a"
        case .medium: return "#2490ad"
        case .low: return "#3c166d"
        }
    }
}

enum TaskStatus: String, Codable, CaseIterable {
    case todo = "To Do"
    case inProgress = "In Progress"
    case review = "Review"
    case completed = "Completed"
}

struct Task: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var description: String
    var priority: TaskPriority
    var status: TaskStatus
    var projectId: String?
    var assignedTo: [String] // TeamMember IDs
    var createdDate: Date
    var dueDate: Date?
    var timeEntries: [TimeEntry]
    var tags: [String]
    
    var totalHours: Double {
        timeEntries.reduce(0) { $0 + $1.hours }
    }
    
    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        priority: TaskPriority,
        status: TaskStatus = .todo,
        projectId: String? = nil,
        assignedTo: [String] = [],
        createdDate: Date = Date(),
        dueDate: Date? = nil,
        timeEntries: [TimeEntry] = [],
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
        self.status = status
        self.projectId = projectId
        self.assignedTo = assignedTo
        self.createdDate = createdDate
        self.dueDate = dueDate
        self.timeEntries = timeEntries
        self.tags = tags
    }
}

struct TimeEntry: Identifiable, Codable {
    var id: String = UUID().uuidString
    var date: Date
    var hours: Double
    var note: String
    var memberId: String
    
    init(id: String = UUID().uuidString, date: Date = Date(), hours: Double, note: String, memberId: String) {
        self.id = id
        self.date = date
        self.hours = hours
        self.note = note
        self.memberId = memberId
    }
}

