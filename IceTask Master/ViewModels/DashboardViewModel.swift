//
//  DashboardViewModel.swift
//  TaskMaster Pro
//

import Foundation
import SwiftUI

class DashboardViewModel: ObservableObject {
    @Published var selectedFilter: TaskFilter = .all
    @Published var selectedProject: Project?
    @Published var searchText: String = ""
    
    var taskService: TaskService
    var projectService: ProjectService
    var userService: UserService
    
    init(taskService: TaskService, projectService: ProjectService, userService: UserService) {
        self.taskService = taskService
        self.projectService = projectService
        self.userService = userService
    }
    
    var filteredTasks: [Task] {
        var result = taskService.tasks
        
        // Filter by project
        if let project = selectedProject {
            result = result.filter { $0.projectId == project.id }
        }
        
        // Filter by status
        switch selectedFilter {
        case .all:
            break
        case .todo:
            result = result.filter { $0.status == .todo }
        case .inProgress:
            result = result.filter { $0.status == .inProgress }
        case .completed:
            result = result.filter { $0.status == .completed }
        case .myTasks:
            if let currentUser = userService.currentUser {
                result = result.filter { $0.assignedTo.contains(currentUser.id) }
            }
        }
        
        // Search
        if !searchText.isEmpty {
            result = result.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result.sorted { $0.createdDate > $1.createdDate }
    }
    
    var taskStats: TaskStats {
        let allTasks = taskService.tasks
        return TaskStats(
            total: allTasks.count,
            todo: allTasks.filter { $0.status == .todo }.count,
            inProgress: allTasks.filter { $0.status == .inProgress }.count,
            completed: allTasks.filter { $0.status == .completed }.count
        )
    }
}

enum TaskFilter: String, CaseIterable {
    case all = "All"
    case todo = "To Do"
    case inProgress = "In Progress"
    case completed = "Completed"
    case myTasks = "My Tasks"
}

struct TaskStats {
    let total: Int
    let todo: Int
    let inProgress: Int
    let completed: Int
}

