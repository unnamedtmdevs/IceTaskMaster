//
//  TaskDetailViewModel.swift
//  TaskMaster Pro
//

import Foundation
import SwiftUI

class TaskDetailViewModel: ObservableObject {
    @Published var task: Task
    @Published var showingTimeEntrySheet = false
    @Published var newTimeHours: String = ""
    @Published var newTimeNote: String = ""
    
    var taskService: TaskService
    var userService: UserService
    
    init(task: Task, taskService: TaskService, userService: UserService) {
        self.task = task
        self.taskService = taskService
        self.userService = userService
    }
    
    func updateTask() {
        taskService.updateTask(task)
    }
    
    func addTimeEntry() {
        guard let hours = Double(newTimeHours), hours > 0,
              let currentUser = userService.currentUser else {
            return
        }
        
        let entry = TimeEntry(
            hours: hours,
            note: newTimeNote,
            memberId: currentUser.id
        )
        
        task.timeEntries.append(entry)
        taskService.updateTask(task)
        
        // Reset fields
        newTimeHours = ""
        newTimeNote = ""
        showingTimeEntrySheet = false
    }
    
    func deleteTimeEntry(_ entry: TimeEntry) {
        task.timeEntries.removeAll { $0.id == entry.id }
        taskService.updateTask(task)
    }
    
    func toggleAssignment(memberId: String) {
        if task.assignedTo.contains(memberId) {
            task.assignedTo.removeAll { $0 == memberId }
        } else {
            task.assignedTo.append(memberId)
        }
        taskService.updateTask(task)
    }
    
    func isAssigned(memberId: String) -> Bool {
        task.assignedTo.contains(memberId)
    }
}

