//
//  ContentView.swift
//  TaskMaster Pro
//
//  Created by Simon Bakhanets on 03.12.2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var appViewModel = AppViewModel()
    
    @ObservedObject var taskService: TaskService
    @ObservedObject var projectService: ProjectService
    @ObservedObject var userService: UserService
    
    var body: some View {
        ZStack {
            if appViewModel.isCheckingAttribution {
                // Показываем загрузку пока проверяем атрибуцию AppsFlyer
                LoadingView()
            } else if appViewModel.shouldShowWebView, let campaignURL = appViewModel.campaignURL {
                // Неорганическая установка - показываем WebView с кампанией
                CampaignWebView(campaignURL: campaignURL)
            } else {
                // Органическая установка - показываем обычное приложение
                normalAppFlow
            }
        }
    }
    
    private var normalAppFlow: some View {
        Group {
            if hasCompletedOnboarding {
                TabView {
                    DashboardView(
                        taskService: taskService,
                        projectService: projectService,
                        userService: userService
                    )
                    .tabItem {
                        Label("Dashboard", systemImage: "square.grid.2x2.fill")
                    }
                    
                    SettingsView(
                        taskService: taskService,
                        projectService: projectService,
                        userService: userService,
                        hasCompletedOnboarding: $hasCompletedOnboarding
                    )
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                }
                .accentColor(Color(hex: "#fbaa1a"))
                .onAppear {
                    // Make tab bar icons more visible
                    let appearance = UITabBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = UIColor(Color(hex: "#1a2962"))
                    
                    // Customize icon colors
                    appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color(hex: "#f7f7f7").opacity(0.6))
                    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color(hex: "#f7f7f7").opacity(0.6))]
                    
                    appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(hex: "#fbaa1a"))
                    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color(hex: "#fbaa1a"))]
                    
                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                }
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color(hex: "#1a2962")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#fbaa1a")))
                    .scaleEffect(1.5)
                
                Text("TaskMaster Pro")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "#f7f7f7"))
            }
        }
    }
}
