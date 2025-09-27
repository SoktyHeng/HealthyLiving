//
//  ProfileView.swift
//  HealthyLivingProject
//
//  Created by Sokty Heng on 19/9/25.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @State private var showingSignOutAlert = false
    @State private var showingMealHistory = false
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Image
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        )
                        .padding(.top)
                    
                    // User Info
                    VStack(spacing: 8) {
                        if userManager.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Loading profile...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text(userManager.currentUser?.username ?? "User Name")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(userManager.currentUser?.email ?? Auth.auth().currentUser?.email ?? "No email")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            if let user = userManager.currentUser {
                                HStack(spacing: 20) {
                                    VStack {
                                        Text("\(user.age)")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                        Text("Years Old")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Divider()
                                        .frame(height: 30)
                                    
                                    VStack {
                                        Text("Born")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(user.formattedBirthDate)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .padding(.top, 12)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    // Profile Options
                    VStack(spacing: 16) {
                        ProfileOptionRow(icon: "person.crop.circle", title: "Edit Profile", action: {
                            // TODO: Navigate to edit profile
                        })
                        ProfileOptionRow(icon: "gear", title: "Settings", action: {})
                        ProfileOptionRow(icon: "clock.arrow.circlepath", title: "Meal History", action: {
                            showingMealHistory = true
                        })
                        ProfileOptionRow(icon: "questionmark.circle", title: "Help & Support", action: {})
                        ProfileOptionRow(icon: "info.circle", title: "About", action: {})
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    
                    // Sign Out Button
                    Button(action: {
                        showingSignOutAlert = true
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 50) // Extra padding to ensure it's above tab bar
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingMealHistory) {
                MealHistoryView()
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserManager())
}
