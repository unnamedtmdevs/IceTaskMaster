//
//  NewProjectSheet.swift
//  TaskMaster Pro
//

import SwiftUI

struct NewProjectSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var projectService: ProjectService
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedColor: String = "#2490ad"
    
    let availableColors = ["#2490ad", "#3c166d", "#1a2962", "#fbaa1a", "#f0048d", "#01ff00"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1a2962")
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                        
                        TextField("Enter project name", text: $name)
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
                            placeholder: "Enter project description...",
                            backgroundColor: UIColor(Color(hex: "#3c166d").opacity(0.5)),
                            textColor: UIColor(Color(hex: "#f7f7f7")),
                            font: UIFont.systemFont(ofSize: 16)
                        )
                        .frame(height: 100)
                        .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Color")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                        
                        HStack(spacing: 12) {
                            ForEach(availableColors, id: \.self) { color in
                                Button(action: { selectedColor = color }) {
                                    Circle()
                                        .fill(Color(hex: color))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color(hex: "#f7f7f7"), lineWidth: selectedColor == color ? 3 : 0)
                                        )
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: createProject) {
                        Text("Create Project")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "#1a2962"))
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(Color(hex: "#fbaa1a"))
                            .cornerRadius(10)
                    }
                    .disabled(name.isEmpty)
                    .opacity(name.isEmpty ? 0.5 : 1)
                }
                .padding(16)
            }
            .navigationTitle("New Project")
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
    
    private func createProject() {
        let project = Project(
            name: name,
            description: description,
            color: selectedColor
        )
        projectService.addProject(project)
        presentationMode.wrappedValue.dismiss()
    }
}

