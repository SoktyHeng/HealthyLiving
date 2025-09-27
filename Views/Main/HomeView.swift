//
//  HomeView.swift
//  HealthyLivingProject
//
//  Updated with HealthKit integration
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userManager: UserManager
    @StateObject private var healthManager = HealthKitManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Personalized Welcome Message with Profile Picture
                    HStack(spacing: 16) {
                        // Profile Picture
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.blue)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if let username = userManager.currentUser?.username {
                                Text("Welcome Back, \(username)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            } else {
                                Text("Welcome Back")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            
                            Text("Let's check your progress today")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Health Data Cards
                    VStack(spacing: 16) {
                        // Daily Steps Card
                        HealthDataCard(
                            title: "Daily Step Count",
                            value: healthManager.isLoading ? "..." : "\(healthManager.stepCount)",
                            subtitle: "Steps taken today",
                            content: AnyView(
                                WeeklyStepsChart(stepData: healthManager.weeklySteps)
                            )
                        )
                        
                        // Calories Burned Card
                        HealthDataCard(
                            title: "Calories Burned Today",
                            value: healthManager.isLoading ? "..." : "\(healthManager.caloriesBurned)",
                            subtitle: "Active calories burned",
                            content: AnyView(
                                CaloriesProgressChart(currentCalories: healthManager.caloriesBurned)
                            )
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .refreshable {
                healthManager.fetchTodaysData()
                healthManager.fetchWeeklySteps()
            }
            .onAppear {
                if healthManager.isAuthorized {
                    healthManager.fetchTodaysData()
                    healthManager.fetchWeeklySteps()
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserManager())
}
