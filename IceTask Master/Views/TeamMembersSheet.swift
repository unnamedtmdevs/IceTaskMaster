//
//  TeamMembersSheet.swift
//  TaskMaster Pro
//

import SwiftUI

struct TeamMembersSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var userService: UserService
    @State private var showingAddMember = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#1a2962")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(userService.teamMembers) { member in
                            TeamMemberRow(member: member, userService: userService)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Team Members")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(hex: "#f7f7f7"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddMember = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "#fbaa1a"))
                    }
                }
            }
            .sheet(isPresented: $showingAddMember) {
                AddTeamMemberSheet(userService: userService)
            }
        }
    }
}

struct TeamMemberRow: View {
    let member: TeamMember
    @ObservedObject var userService: UserService
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: member.avatarColor))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(member.initials)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: "#f7f7f7"))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#f7f7f7"))
                
                Text(member.email)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#f7f7f7").opacity(0.6))
                
                Text(member.role.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#fbaa1a"))
            }
            
            Spacer()
            
            if !member.isActive {
                Text("Inactive")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#f7f7f7").opacity(0.5))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "#3c166d").opacity(0.5))
                    .cornerRadius(6)
            }
        }
        .padding(12)
        .background(Color(hex: "#3c166d").opacity(0.4))
        .cornerRadius(12)
    }
}

struct AddTeamMemberSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var userService: UserService
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var role: MemberRole = .contributor
    @State private var selectedColor: String = "#2490ad"
    
    let availableColors = ["#2490ad", "#3c166d", "#fbaa1a", "#f0048d", "#01ff00"]
    
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
                        
                        TextField("Enter name", text: $name)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#f7f7f7"))
                            .padding(12)
                            .background(Color(hex: "#3c166d").opacity(0.5))
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                        
                        TextField("Enter email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "#f7f7f7"))
                            .padding(12)
                            .background(Color(hex: "#3c166d").opacity(0.5))
                            .cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Role")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#f7f7f7").opacity(0.7))
                        
                        Menu {
                            ForEach(MemberRole.allCases, id: \.self) { r in
                                Button(r.rawValue) {
                                    role = r
                                }
                            }
                        } label: {
                            HStack {
                                Text(role.rawValue)
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
                        Text("Avatar Color")
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
                    
                    Button(action: addMember) {
                        Text("Add Team Member")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "#1a2962"))
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(Color(hex: "#fbaa1a"))
                            .cornerRadius(10)
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                    .opacity(name.isEmpty || email.isEmpty ? 0.5 : 1)
                }
                .padding(16)
            }
            .navigationTitle("Add Team Member")
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
    
    private func addMember() {
        let member = TeamMember(
            name: name,
            email: email,
            role: role,
            avatarColor: selectedColor
        )
        userService.addTeamMember(member)
        presentationMode.wrappedValue.dismiss()
    }
}

