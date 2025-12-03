//
//  SettingsView.swift
//  TaskMaster Pro
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @Binding var hasCompletedOnboarding: Bool
    
    init(taskService: TaskService, projectService: ProjectService, userService: UserService, hasCompletedOnboarding: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(
            taskService: taskService,
            projectService: projectService,
            userService: userService
        ))
        _hasCompletedOnboarding = hasCompletedOnboarding
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1a2962")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Section
                        profileSection
                        
                        // App Settings
                        settingsSection
                        
                        // About Section
                        aboutSection
                        
                        // Danger Zone
                        dangerZoneSection
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var profileSection: some View {
        VStack(spacing: 16) {
            if let currentUser = viewModel.userService.currentUser {
                // Avatar
                Circle()
                    .fill(Color(hex: currentUser.avatarColor))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(currentUser.initials)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(hex: "#f7f7f7"))
                    )
                
                VStack(spacing: 4) {
                    Text(currentUser.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "#f7f7f7"))
                    
                    Text(currentUser.email)
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                    
                    Text(currentUser.role.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "#fbaa1a"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#3c166d").opacity(0.5))
                        .cornerRadius(12)
                        .padding(.top, 4)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(hex: "#3c166d").opacity(0.3))
        .cornerRadius(16)
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("App Settings")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                .padding(.horizontal, 4)
            
            VStack(spacing: 8) {
                SettingRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    iconColor: "#fbaa1a"
                ) {
                    NotificationSettingsView()
                }
                
                SettingRow(
                    icon: "paintbrush.fill",
                    title: "Appearance",
                    iconColor: "#f0048d"
                ) {
                    AppearanceSettingsView()
                }
                
                Button(action: {
                    viewModel.showingResetOnboardingConfirmation = true
                }) {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(hex: "#2490ad").opacity(0.3))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(Color(hex: "#2490ad"))
                                .font(.system(size: 16))
                        }
                        
                        Text("Reset Onboarding")
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "#f7f7f7"))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(hex: "#f7f7f7").opacity(0.3))
                            .font(.system(size: 13))
                    }
                    .padding(12)
                    .background(Color(hex: "#3c166d").opacity(0.5))
                    .cornerRadius(10)
                }
            }
        }
        .alert("Reset Onboarding", isPresented: $viewModel.showingResetOnboardingConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                viewModel.resetOnboarding(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        } message: {
            Text("This will show the onboarding screens again on next launch.")
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                .padding(.horizontal, 4)
            
            VStack(spacing: 8) {
                InfoRow(title: "Version", value: "1.0.0")
                InfoRow(title: "Build", value: "2025.1")
                
                Button(action: {
                    // Open privacy policy
                }) {
                    HStack {
                        Text("Privacy Policy")
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "#f7f7f7"))
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .foregroundColor(Color(hex: "#f7f7f7").opacity(0.3))
                            .font(.system(size: 13))
                    }
                    .padding(12)
                    .background(Color(hex: "#3c166d").opacity(0.5))
                    .cornerRadius(10)
                }
                
                Button(action: {
                    // Open terms of service
                }) {
                    HStack {
                        Text("Terms of Service")
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "#f7f7f7"))
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .foregroundColor(Color(hex: "#f7f7f7").opacity(0.3))
                            .font(.system(size: 13))
                    }
                    .padding(12)
                    .background(Color(hex: "#3c166d").opacity(0.5))
                    .cornerRadius(10)
                }
            }
        }
    }
    
    private var dangerZoneSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Danger Zone")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.red)
                .padding(.horizontal, 4)
            
            Button(action: {
                viewModel.showingDeleteConfirmation = true
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 16))
                    
                    Text("Delete All Data")
                        .font(.system(size: 15, weight: .semibold))
                    
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(14)
                .background(Color.red.opacity(0.7))
                .cornerRadius(10)
            }
        }
        .alert("Delete All Data", isPresented: $viewModel.showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteAllData()
            }
        } message: {
            Text("This will permanently delete all tasks, projects, and team members. This action cannot be undone.")
        }
    }
}

struct SettingRow<Destination: View>: View {
    let icon: String
    let title: String
    let iconColor: String
    let destination: () -> Destination
    
    var body: some View {
        NavigationLink(destination: destination()) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: iconColor).opacity(0.3))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .foregroundColor(Color(hex: iconColor))
                        .font(.system(size: 16))
                }
                
                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(Color(hex: "#f7f7f7"))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(hex: "#f7f7f7").opacity(0.3))
                    .font(.system(size: 13))
            }
            .padding(12)
            .background(Color(hex: "#3c166d").opacity(0.5))
            .cornerRadius(10)
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "#f7f7f7"))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(hex: "#f7f7f7").opacity(0.6))
        }
        .padding(12)
        .background(Color(hex: "#3c166d").opacity(0.5))
        .cornerRadius(10)
    }
}

// Placeholder views for settings
struct NotificationSettingsView: View {
    var body: some View {
        ZStack {
            Color(hex: "#1a2962")
                .ignoresSafeArea()
            
            Text("Notification Settings")
                .foregroundColor(Color(hex: "#f7f7f7"))
                .font(.system(size: 20, weight: .semibold))
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AppearanceSettingsView: View {
    var body: some View {
        ZStack {
            Color(hex: "#1a2962")
                .ignoresSafeArea()
            
            Text("Appearance Settings")
                .foregroundColor(Color(hex: "#f7f7f7"))
                .font(.system(size: 20, weight: .semibold))
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

