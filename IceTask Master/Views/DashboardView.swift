//
//  DashboardView.swift
//  TaskMaster Pro
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    @State private var showingNewTaskSheet = false
    @State private var showingNewProjectSheet = false
    @State private var showingTeamSheet = false
    
    init(taskService: TaskService, projectService: ProjectService, userService: UserService) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(
            taskService: taskService,
            projectService: projectService,
            userService: userService
        ))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "#1a2962")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Stats Cards
                        statsSection
                        
                        // Filters
                        filterSection
                        
                        // Search
                        searchSection
                        
                        // Tasks List
                        tasksSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingNewTaskSheet = true }) {
                            Label("New Task", systemImage: "plus.circle")
                        }
                        Button(action: { showingNewProjectSheet = true }) {
                            Label("New Project", systemImage: "folder.badge.plus")
                        }
                        Button(action: { showingTeamSheet = true }) {
                            Label("Team Members", systemImage: "person.3")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(Color(hex: "#fbaa1a"))
                            .font(.system(size: 20))
                    }
                }
            }
            .sheet(isPresented: $showingNewTaskSheet) {
                NewTaskSheet(taskService: viewModel.taskService, projectService: viewModel.projectService, userService: viewModel.userService)
            }
            .sheet(isPresented: $showingNewProjectSheet) {
                NewProjectSheet(projectService: viewModel.projectService)
            }
            .sheet(isPresented: $showingTeamSheet) {
                TeamMembersSheet(userService: viewModel.userService)
            }
        }
    }
    
    private var statsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                StatCard(title: "Total", value: "\(viewModel.taskStats.total)", color: "#2490ad")
                StatCard(title: "To Do", value: "\(viewModel.taskStats.todo)", color: "#fbaa1a")
                StatCard(title: "In Progress", value: "\(viewModel.taskStats.inProgress)", color: "#f0048d")
                StatCard(title: "Completed", value: "\(viewModel.taskStats.completed)", color: "#01ff00")
            }
            .padding(.horizontal, 4)
        }
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(TaskFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        withAnimation {
                            viewModel.selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(hex: "#f7f7f7").opacity(0.6))
            
            TextField("Search tasks...", text: $viewModel.searchText)
                .foregroundColor(Color(hex: "#f7f7f7"))
        }
        .padding(12)
        .background(Color(hex: "#3c166d").opacity(0.5))
        .cornerRadius(10)
    }
    
    private var tasksSection: some View {
        VStack(spacing: 12) {
            if viewModel.filteredTasks.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.filteredTasks) { task in
                    NavigationLink(destination: TaskDetailView(
                        task: task,
                        taskService: viewModel.taskService,
                        userService: viewModel.userService
                    )) {
                        TaskCard(task: task, userService: viewModel.userService)
                    }
                }
            }
        }
        .padding(.bottom, 20)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(Color(hex: "#f7f7f7").opacity(0.3))
            
            Text("No tasks found")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(hex: "#f7f7f7").opacity(0.6))
            
            Text("Create a new task to get started")
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "#f7f7f7").opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: color))
        }
        .frame(width: 100)
        .padding(16)
        .background(Color(hex: "#3c166d").opacity(0.3))
        .cornerRadius(12)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? Color(hex: "#1a2962") : Color(hex: "#f7f7f7"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color(hex: "#fbaa1a") : Color(hex: "#3c166d").opacity(0.5))
                .cornerRadius(20)
        }
    }
}

struct TaskCard: View {
    let task: Task
    let userService: UserService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Priority indicator
                Circle()
                    .fill(Color(hex: task.priority.color))
                    .frame(width: 12, height: 12)
                
                Text(task.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color(hex: "#f7f7f7"))
                    .lineLimit(1)
                
                Spacer()
                
                // Status badge
                Text(task.status.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "#f7f7f7"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#3c166d"))
                    .cornerRadius(6)
            }
            
            if !task.description.isEmpty {
                Text(task.description)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                    .lineLimit(2)
            }
            
            HStack {
                // Assigned members
                if !task.assignedTo.isEmpty {
                    HStack(spacing: -8) {
                        ForEach(task.assignedTo.prefix(3), id: \.self) { memberId in
                            if let member = userService.getMember(by: memberId) {
                                Circle()
                                    .fill(Color(hex: member.avatarColor))
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Text(member.initials)
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(Color(hex: "#f7f7f7"))
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(Color(hex: "#1a2962"), lineWidth: 2)
                                    )
                            }
                        }
                        
                        if task.assignedTo.count > 3 {
                            Circle()
                                .fill(Color(hex: "#3c166d"))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Text("+\(task.assignedTo.count - 3)")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(Color(hex: "#f7f7f7"))
                                )
                        }
                    }
                }
                
                Spacer()
                
                // Time tracked
                if task.totalHours > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                        Text(String(format: "%.1fh", task.totalHours))
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(Color(hex: "#fbaa1a"))
                }
            }
        }
        .padding(16)
        .background(Color(hex: "#3c166d").opacity(0.4))
        .cornerRadius(12)
    }
}

