//
//  UserService.swift
//  TaskMaster Pro
//

import Foundation

class UserService: ObservableObject {
    private let membersKey = "TaskMasterPro_TeamMembers"
    private let currentUserKey = "TaskMasterPro_CurrentUser"
    
    @Published var teamMembers: [TeamMember] = []
    @Published var currentUser: TeamMember?
    
    init() {
        loadTeamMembers()
        loadCurrentUser()
    }
    
    func loadTeamMembers() {
        if let data = UserDefaults.standard.data(forKey: membersKey),
           let decoded = try? JSONDecoder().decode([TeamMember].self, from: data) {
            teamMembers = decoded
        } else {
            teamMembers = []
        }
    }
    
    func loadCurrentUser() {
        if let data = UserDefaults.standard.data(forKey: currentUserKey),
           let decoded = try? JSONDecoder().decode(TeamMember.self, from: data) {
            currentUser = decoded
        } else {
            // Create default user
            let defaultUser = TeamMember(
                name: "You",
                email: "user@taskmasterpro.com",
                role: .owner,
                avatarColor: "#fbaa1a"
            )
            currentUser = defaultUser
            saveCurrentUser()
            addTeamMember(defaultUser)
        }
    }
    
    func saveTeamMembers() {
        if let encoded = try? JSONEncoder().encode(teamMembers) {
            UserDefaults.standard.set(encoded, forKey: membersKey)
        }
    }
    
    func saveCurrentUser() {
        if let encoded = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(encoded, forKey: currentUserKey)
        }
    }
    
    func addTeamMember(_ member: TeamMember) {
        teamMembers.append(member)
        saveTeamMembers()
    }
    
    func updateTeamMember(_ member: TeamMember) {
        if let index = teamMembers.firstIndex(where: { $0.id == member.id }) {
            teamMembers[index] = member
            saveTeamMembers()
            
            if currentUser?.id == member.id {
                currentUser = member
                saveCurrentUser()
            }
        }
    }
    
    func deleteTeamMember(_ member: TeamMember) {
        teamMembers.removeAll { $0.id == member.id }
        saveTeamMembers()
    }
    
    func getMember(by id: String) -> TeamMember? {
        teamMembers.first { $0.id == id }
    }
    
    func deleteAllData() {
        teamMembers = []
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: membersKey)
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }
}

