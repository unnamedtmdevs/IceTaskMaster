//
//  TaskDetailView.swift
//  TaskMaster Pro
//

import SwiftUI

struct TaskDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: TaskDetailViewModel
    
    init(task: Task, taskService: TaskService, userService: UserService) {
        _viewModel = StateObject(wrappedValue: TaskDetailViewModel(
            task: task,
            taskService: taskService,
            userService: userService
        ))
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#1a2962")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Title & Description
                    titleSection
                    
                    // Priority & Status
                    priorityStatusSection
                    
                    // Assigned Team Members
                    teamSection
                    
                    // Time Tracking
                    timeTrackingSection
                    
                    // Tags (if any)
                    if !viewModel.task.tags.isEmpty {
                        tagsSection
                    }
                    
                    // Delete Button
                    deleteButton
                }
                .padding(16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showingTimeEntrySheet) {
            AddTimeEntrySheet(viewModel: viewModel)
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Title")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
            
            TextField("Task title", text: $viewModel.task.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "#f7f7f7"))
                .padding(12)
                .background(Color(hex: "#3c166d").opacity(0.5))
                .cornerRadius(10)
                .onChange(of: viewModel.task.title) { _ in
                    viewModel.updateTask()
                }
            
            Text("Description")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                .padding(.top, 8)
            
            CustomTextEditor(
                text: $viewModel.task.description,
                placeholder: "Enter task description...",
                backgroundColor: UIColor(Color(hex: "#3c166d").opacity(0.5)),
                textColor: UIColor(Color(hex: "#f7f7f7")),
                font: UIFont.systemFont(ofSize: 16)
            )
            .frame(height: 120)
            .cornerRadius(10)
            .onChange(of: viewModel.task.description) { _ in
                viewModel.updateTask()
            }
        }
    }
    
    private var priorityStatusSection: some View {
        HStack(spacing: 12) {
            // Priority
            VStack(alignment: .leading, spacing: 8) {
                Text("Priority")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                
                Menu {
                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                        Button(action: {
                            viewModel.task.priority = priority
                            viewModel.updateTask()
                        }) {
                            HStack {
                                Text(priority.rawValue)
                                if viewModel.task.priority == priority {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Circle()
                            .fill(Color(hex: viewModel.task.priority.color))
                            .frame(width: 12, height: 12)
                        Text(viewModel.task.priority.rawValue)
                            .font(.system(size: 15, weight: .medium))
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(Color(hex: "#f7f7f7"))
                    .padding(12)
                    .background(Color(hex: "#3c166d").opacity(0.5))
                    .cornerRadius(10)
                }
            }
            
            // Status
            VStack(alignment: .leading, spacing: 8) {
                Text("Status")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                
                Menu {
                    ForEach(TaskStatus.allCases, id: \.self) { status in
                        Button(action: {
                            viewModel.task.status = status
                            viewModel.updateTask()
                        }) {
                            HStack {
                                Text(status.rawValue)
                                if viewModel.task.status == status {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(viewModel.task.status.rawValue)
                            .font(.system(size: 15, weight: .medium))
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(Color(hex: "#f7f7f7"))
                    .padding(12)
                    .background(Color(hex: "#3c166d").opacity(0.5))
                    .cornerRadius(10)
                }
            }
        }
    }
    
    private var teamSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Assigned To")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
            
            VStack(spacing: 8) {
                ForEach(viewModel.userService.teamMembers.filter { $0.isActive }) { member in
                    Button(action: {
                        viewModel.toggleAssignment(memberId: member.id)
                    }) {
                        HStack {
                            Circle()
                                .fill(Color(hex: member.avatarColor))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Text(member.initials)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color(hex: "#f7f7f7"))
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(member.name)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color(hex: "#f7f7f7"))
                                
                                Text(member.role.rawValue)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "#f7f7f7").opacity(0.6))
                            }
                            
                            Spacer()
                            
                            if viewModel.isAssigned(memberId: member.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "#01ff00"))
                                    .font(.system(size: 20))
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(Color(hex: "#f7f7f7").opacity(0.3))
                                    .font(.system(size: 20))
                            }
                        }
                        .padding(12)
                        .background(Color(hex: "#3c166d").opacity(0.5))
                        .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    private var timeTrackingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Time Tracking")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                
                Spacer()
                
                Text(String(format: "Total: %.1f hours", viewModel.task.totalHours))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "#fbaa1a"))
            }
            
            Button(action: {
                viewModel.showingTimeEntrySheet = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                    Text("Log Time")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(Color(hex: "#1a2962"))
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Color(hex: "#fbaa1a"))
                .cornerRadius(10)
            }
            
            if !viewModel.task.timeEntries.isEmpty {
                VStack(spacing: 8) {
                    ForEach(viewModel.task.timeEntries) { entry in
                        TimeEntryRow(
                            entry: entry,
                            userService: viewModel.userService,
                            onDelete: {
                                viewModel.deleteTimeEntry(entry)
                            }
                        )
                    }
                }
            }
        }
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.task.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "#f7f7f7"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(hex: "#f0048d").opacity(0.6))
                            .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    private var deleteButton: some View {
        Button(action: {
            viewModel.taskService.deleteTask(viewModel.task)
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Delete Task")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "#f7f7f7"))
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Color.red.opacity(0.7))
                .cornerRadius(10)
        }
        .padding(.top, 20)
    }
}

struct TimeEntryRow: View {
    let entry: TimeEntry
    let userService: UserService
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if let member = userService.getMember(by: entry.memberId) {
                        Text(member.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#f7f7f7"))
                    }
                    
                    Text("•")
                        .foregroundColor(Color(hex: "#f7f7f7").opacity(0.5))
                    
                    Text(String(format: "%.1fh", entry.hours))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "#fbaa1a"))
                }
                
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                }
                
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#f7f7f7").opacity(0.5))
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
            }
        }
        .padding(12)
        .background(Color(hex: "#3c166d").opacity(0.3))
        .cornerRadius(8)
    }
}

struct AddTimeEntrySheet: View {
    @ObservedObject var viewModel: TaskDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1a2962")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hours")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                        
                        TextField("Enter hours", text: $viewModel.newTimeHours)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#f7f7f7"))
                            .padding(12)
                            .background(Color(hex: "#3c166d").opacity(0.5))
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note (optional)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                        
                        TextField("What did you work on?", text: $viewModel.newTimeNote)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#f7f7f7"))
                            .padding(12)
                            .background(Color(hex: "#3c166d").opacity(0.5))
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        viewModel.addTimeEntry()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Add Time Entry")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "#1a2962"))
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(Color(hex: "#fbaa1a"))
                            .cornerRadius(10)
                    }
                    .disabled(viewModel.newTimeHours.isEmpty)
                    .opacity(viewModel.newTimeHours.isEmpty ? 0.5 : 1)
                    
                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("Log Time")
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
}

