//
//  TaskService.swift
//  TaskMaster Pro
//

import Foundation

class TaskService: ObservableObject {
    private let tasksKey = "TaskMasterPro_Tasks"
    
    @Published var tasks: [Task] = []
    
    init() {
        loadTasks()
    }
    
    func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        } else {
            tasks = []
        }
    }
    
    func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func getTasksForProject(_ projectId: String) -> [Task] {
        tasks.filter { $0.projectId == projectId }
    }
    
    func getTasksForMember(_ memberId: String) -> [Task] {
        tasks.filter { $0.assignedTo.contains(memberId) }
    }
    
    func addTimeEntry(to taskId: String, entry: TimeEntry) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].timeEntries.append(entry)
            saveTasks()
        }
    }
    
    func deleteAllData() {
        tasks = []
        UserDefaults.standard.removeObject(forKey: tasksKey)
    }
}

