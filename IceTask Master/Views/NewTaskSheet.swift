//
//  NewTaskSheet.swift
//  TaskMaster Pro
//

import SwiftUI

struct NewTaskSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var taskService: TaskService
    @ObservedObject var projectService: ProjectService
    @ObservedObject var userService: UserService
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var priority: TaskPriority = .medium
    @State private var selectedProject: Project?
    @State private var selectedMembers: Set<String> = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1a2962")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                            
                            TextField("Enter task title", text: $title)
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "#f7f7f7"))
                                .padding(12)
                                .background(Color(hex: "#3c166d").opacity(0.5))
                                .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                            
                            CustomTextEditor(
                                text: $description,
                                placeholder: "Enter task description...",
                                backgroundColor: UIColor(Color(hex: "#3c166d").opacity(0.5)),
                                textColor: UIColor(Color(hex: "#f7f7f7")),
                                font: UIFont.systemFont(ofSize: 16)
                            )
                            .frame(height: 100)
                            .cornerRadius(10)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Priority")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                            
                            HStack(spacing: 10) {
                                ForEach(TaskPriority.allCases, id: \.self) { p in
                                    Button(action: { priority = p }) {
                                        Text(p.rawValue)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(priority == p ? Color(hex: "#1a2962") : Color(hex: "#f7f7f7"))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(priority == p ? Color(hex: p.color) : Color(hex: "#3c166d").opacity(0.5))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Project")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                            
                            Menu {
                                Button("None") {
                                    selectedProject = nil
                                }
                                ForEach(projectService.getActiveProjects()) { project in
                                    Button(project.name) {
                                        selectedProject = project
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedProject?.name ?? "Select project")
                                        .foregroundColor(Color(hex: "#f7f7f7"))
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(Color(hex: "#f7f7f7").opacity(0.5))
                                }
                                .font(.system(size: 15))
                                .padding(12)
                                .background(Color(hex: "#3c166d").opacity(0.5))
                                .cornerRadius(10)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Assign to")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                            
                            ForEach(userService.teamMembers.filter { $0.isActive }) { member in
                                Button(action: {
                                    if selectedMembers.contains(member.id) {
                                        selectedMembers.remove(member.id)
                                    } else {
                                        selectedMembers.insert(member.id)
                                    }
                                }) {
                                    HStack {
                                        Circle()
                                            .fill(Color(hex: member.avatarColor))
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Text(member.initials)
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(Color(hex: "#f7f7f7"))
                                            )
                                        
                                        Text(member.name)
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: "#f7f7f7"))
                                        
                                        Spacer()
                                        
                                        if selectedMembers.contains(member.id) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(Color(hex: "#01ff00"))
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(Color(hex: "#f7f7f7").opacity(0.3))
                                        }
                                    }
                                    .padding(10)
                                    .background(Color(hex: "#3c166d").opacity(0.5))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        Button(action: createTask) {
                            Text("Create Task")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "#1a2962"))
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .background(Color(hex: "#fbaa1a"))
                                .cornerRadius(10)
                        }
                        .disabled(title.isEmpty)
                        .opacity(title.isEmpty ? 0.5 : 1)
                    }
                    .padding(16)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(hex: "#f7f7f7"))
                }
            }
        }
    }
    
    private func createTask() {
        let task = Task(
            title: title,
            description: description,
            priority: priority,
            projectId: selectedProject?.id,
            assignedTo: Array(selectedMembers)
        )
        taskService.addTask(task)
        presentationMode.wrappedValue.dismiss()
    }
}

