//
//  ProjectService.swift
//  TaskMaster Pro
//

import Foundation

class ProjectService: ObservableObject {
    private let projectsKey = "TaskMasterPro_Projects"
    
    @Published var projects: [Project] = []
    
    init() {
        loadProjects()
    }
    
    func loadProjects() {
        if let data = UserDefaults.standard.data(forKey: projectsKey),
           let decoded = try? JSONDecoder().decode([Project].self, from: data) {
            projects = decoded
        } else {
            // Create default project
            projects = [
                Project(
                    name: "Default Project",
                    description: "Your first project workspace",
                    color: "#2490ad"
                )
            ]
            saveProjects()
        }
    }
    
    func saveProjects() {
        if let encoded = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(encoded, forKey: projectsKey)
        }
    }
    
    func addProject(_ project: Project) {
        projects.append(project)
        saveProjects()
    }
    
    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            saveProjects()
        }
    }
    
    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        saveProjects()
    }
    
    func getActiveProjects() -> [Project] {
        projects.filter { !$0.isArchived }
    }
    
    func deleteAllData() {
        projects = []
        UserDefaults.standard.removeObject(forKey: projectsKey)
    }
}

