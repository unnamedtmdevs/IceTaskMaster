//
//  OnboardingView.swift
//  TaskMaster Pro
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "#1a2962"),
                    Color(hex: "#3c166d"),
                    Color(hex: "#2490ad")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button(action: {
                        hasCompletedOnboarding = true
                    }) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#f7f7f7"))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.top, 20)
                .padding(.trailing, 20)
                
                // Content
                TabView(selection: $viewModel.currentPage) {
                    ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                // Bottom buttons
                VStack(spacing: 16) {
                    if viewModel.isLastPage {
                        Button(action: {
                            hasCompletedOnboarding = true
                        }) {
                            Text("Get Started")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(hex: "#1a2962"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color(hex: "#fbaa1a"))
                                .cornerRadius(12)
                        }
                    } else {
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation {
                                    viewModel.previousPage()
                                }
                            }) {
                                Text("Back")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "#f7f7f7"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(Color(hex: "#3c166d").opacity(0.5))
                                    .cornerRadius(12)
                            }
                            .disabled(viewModel.currentPage == 0)
                            .opacity(viewModel.currentPage == 0 ? 0.5 : 1)
                            
                            Button(action: {
                                withAnimation {
                                    viewModel.nextPage()
                                }
                            }) {
                                Text("Next")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "#1a2962"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(Color(hex: "#fbaa1a"))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: page.color).opacity(0.2))
                    .frame(width: 140, height: 140)
                
                Image(systemName: page.imageName)
                    .font(.system(size: 60, weight: .medium))
                    .foregroundColor(Color(hex: page.color))
            }
            
            VStack(spacing: 16) {
                // Title
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(hex: "#f7f7f7"))
                    .multilineTextAlignment(.center)
                
                // Description
                Text(page.description)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(Color(hex: "#f7f7f7").opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer()
        }
    }
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

