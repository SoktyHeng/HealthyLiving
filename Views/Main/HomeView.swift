//
//  HomeView.swift
//  HealthyLivingProject
//
//  Created by Sokty Heng on 19/9/25.
//

import SwiftUI

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

#Preview {
    HomeView()
        .environmentObject(UserManager())
}
