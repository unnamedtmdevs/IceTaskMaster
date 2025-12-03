//
//  TeamMember.swift
//  TaskMaster Pro
//

import Foundation

enum MemberRole: String, Codable, CaseIterable {
    case owner = "Owner"
    case admin = "Admin"
    case developer = "Developer"
    case designer = "Designer"
    case manager = "Manager"
    case contributor = "Contributor"
}

struct TeamMember: Identifiable, Codable {
    var id: String = UUID().uuidString
    var name: String
    var email: String
    var role: MemberRole
    var avatarColor: String
    var joinedDate: Date
    var isActive: Bool
    
    var initials: String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        } else {
            return String(name.prefix(2)).uppercased()
        }
    }
    
    init(
        id: String = UUID().uuidString,
        name: String,
        email: String,
        role: MemberRole,
        avatarColor: String = "#2490ad",
        joinedDate: Date = Date(),
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.avatarColor = avatarColor
        self.joinedDate = joinedDate
        self.isActive = isActive
    }
}

