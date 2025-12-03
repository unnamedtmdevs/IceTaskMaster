//
//  SettingsViewModel.swift
//  TaskMaster Pro
//

import Foundation
import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var showingDeleteConfirmation = false
    @Published var showingResetOnboardingConfirmation = false
    
    var taskService: TaskService
    var projectService: ProjectService
    var userService: UserService
    
    init(taskService: TaskService, projectService: ProjectService, userService: UserService) {
        self.taskService = taskService
        self.projectService = projectService
        self.userService = userService
    }
    
    func deleteAllData() {
        taskService.deleteAllData()
        projectService.deleteAllData()
        userService.deleteAllData()
        
        // Reload default data
        taskService.loadTasks()
        projectService.loadProjects()
        userService.loadCurrentUser()
        userService.loadTeamMembers()
    }
    
    func resetOnboarding(hasCompletedOnboarding: Binding<Bool>) {
        hasCompletedOnboarding.wrappedValue = false
    }
}

