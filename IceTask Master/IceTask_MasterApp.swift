//
//  IceTask_MasterApp.swift
//  TaskMaster Pro
//
//  Created by Simon Bakhanets on 03.12.2025.
//

import SwiftUI

@main
struct IceTask_MasterApp: App {
    @StateObject private var taskService = TaskService()
    @StateObject private var projectService = ProjectService()
    @StateObject private var userService = UserService()
    
    init() {
        // Инициализируем AppsFlyer при запуске приложения
        _ = AppsFlyerManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                taskService: taskService,
                projectService: projectService,
                userService: userService
            )
        }
    }
}
