//
//  AppViewModel.swift
//  TaskMaster Pro
//

import Foundation
import Combine

class AppViewModel: ObservableObject {
    @Published var isCheckingAttribution = false
    @Published var shouldShowWebView = false
    @Published var campaignURL: URL?
    
    init() {
        // AppsFlyer удален - всегда показываем обычное приложение
    }
}

