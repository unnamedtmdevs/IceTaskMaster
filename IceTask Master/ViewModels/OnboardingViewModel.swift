//
//  OnboardingViewModel.swift
//  TaskMaster Pro
//

import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Team Collaboration",
            description: "Create and manage tasks with your team in real-time. Assign roles, track progress, and collaborate seamlessly.",
            imageName: "person.3.fill",
            color: "#2490ad"
        ),
        OnboardingPage(
            title: "Priority Mapping",
            description: "Visualize and prioritize tasks based on urgency and importance. Stay focused on what matters most.",
            imageName: "chart.bar.fill",
            color: "#fbaa1a"
        ),
        OnboardingPage(
            title: "Time Tracking",
            description: "Log hours directly within tasks. Monitor team performance and project progress with integrated time tracking.",
            imageName: "clock.fill",
            color: "#f0048d"
        ),
        OnboardingPage(
            title: "Dynamic Roles",
            description: "Assign and manage team roles dynamically based on project needs. Adapt quickly to changing requirements.",
            imageName: "person.badge.key.fill",
            color: "#3c166d"
        )
    ]
    
    var isLastPage: Bool {
        currentPage == pages.count - 1
    }
    
    func nextPage() {
        if currentPage < pages.count - 1 {
            currentPage += 1
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let color: String
}

