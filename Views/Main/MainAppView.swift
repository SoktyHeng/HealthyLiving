//
//  MainAppView.swift
//  HealthyLivingProject
//
//  Created by Sokty Heng on 19/9/25.
//

import SwiftUI
import FirebaseAuth

struct MainAppView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            // Health Tab
            HealthView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "heart.fill" : "heart")
                    Text("Health")
                }
                .tag(1)
            
            // Activity Tab
            ActivityView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "figure.walk" : "figure.walk")
                    Text("Activity")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .onAppear {
            // Configure tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - Home View
struct HomeView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Personalized Welcome Message
                VStack(spacing: 8) {
                    if let username = userManager.currentUser?.username {
                        Text("Welcome back, \(username)!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Welcome to Healthy Living!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    }
                    
                    Text("Your journey to a healthier lifestyle starts here.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.red)
                
                Spacer()
                
                // Quick Action Cards
                VStack(spacing: 16) {
                    QuickActionCard(
                        icon: "drop.fill",
                        title: "Log Water",
                        subtitle: "Track your daily hydration",
                        color: .blue
                    )
                    
                    QuickActionCard(
                        icon: "fork.knife",
                        title: "Log Meal",
                        subtitle: "Record what you've eaten",
                        color: .green
                    )
                    
                    QuickActionCard(
                        icon: "figure.walk",
                        title: "Start Exercise",
                        subtitle: "Begin your workout session",
                        color: .orange
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Health View
struct HealthView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                    .padding()
                
                Text("Health Tracking")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text("Monitor your vital health metrics")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Health")
        }
    }
}

// MARK: - Activity View
struct ActivityView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "figure.run")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                    .padding()
                
                Text("Activity Tracker")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text("Track your daily activities and exercises")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Activity")
        }
    }
}

// MARK: - Profile View (Updated with User Data)
struct ProfileView: View {
    @State private var showingSignOutAlert = false
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
                        ProfileOptionRow(icon: "bell", title: "Notifications", action: {})
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

// MARK: - Supporting Views
struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // Add action here
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MainAppView()
}
