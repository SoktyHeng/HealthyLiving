//
//  MealView.swift
//  HealthyLivingProject
//
//  Main meal tracking view with list and add functionality
//

import SwiftUI
import FirebaseAuth

struct MealView: View {
    @StateObject private var mealManager = MealManager()
    @State private var showingAddMeal = false
    @State private var deletingMealIds: Set<String> = []
    @State private var selectedMeal: Meal?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Meal List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(mealManager.todaysMeals.filter { meal in
                            !deletingMealIds.contains(meal.id ?? "")
                        }) { meal in
                            MealRowView(
                                meal: meal,
                                isDeleting: deletingMealIds.contains(meal.id ?? ""),
                                onDelete: {
                                    deleteMeal(meal)
                                },
                                onTap: {
                                    if !deletingMealIds.contains(meal.id ?? "") {
                                        selectedMeal = meal
                                    }
                                }
                            )
                        }
                        
                        if mealManager.todaysMeals.isEmpty && !mealManager.isLoading {
                            EmptyMealView()
                                .padding(.top, 50)
                        }
                        
                        if mealManager.isLoading {
                            ProgressView()
                                .scaleEffect(1.2)
                                .padding(.top, 50)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                
                // Total Consumption Card
                TotalConsumptionCard(mealManager: mealManager)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
            .navigationTitle("Meal List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddMeal = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    .disabled(mealManager.isLoading)
                }
            }
            .sheet(isPresented: $showingAddMeal) {
                AddMealView(mealManager: mealManager)
            }
            .sheet(item: $selectedMeal) { meal in
                NavigationView {
                    MealDetailView(meal: meal)
                }
            }
            .onAppear {
                if let userId = Auth.auth().currentUser?.uid {
                    mealManager.startListening(for: userId)
                }
            }
            .onDisappear {
                mealManager.stopListening()
            }
            .refreshable {
                // Pull to refresh functionality
                if let userId = Auth.auth().currentUser?.uid {
                    mealManager.startListening(for: userId)
                }
            }
        }
    }
    
    private func deleteMeal(_ meal: Meal) {
        guard let mealId = meal.id else { return }
        
        // Immediately hide the item from UI
        withAnimation(.easeOut(duration: 0.3)) {
            deletingMealIds.insert(mealId)
        }
        
        // Perform the actual deletion
        mealManager.deleteMeal(meal) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Meal deleted successfully")
                    // Keep the item hidden until Firebase listener updates
                    // Remove from deleting set after a delay to ensure smooth transition
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.deletingMealIds.remove(mealId)
                    }
                case .failure(let error):
                    print("Error deleting meal: \(error.localizedDescription)")
                    // Show the item again if deletion failed
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.deletingMealIds.remove(mealId)
                    }
                }
            }
        }
    }
}

// MARK: - Meal Row View
struct MealRowView: View {
    let meal: Meal
    let isDeleting: Bool
    let onDelete: () -> Void
    let onTap: () -> Void
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Meal Image or Icon
            if let imageURL = meal.imageURL, !imageURL.isEmpty {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.8)
                        )
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "fork.knife")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Meal Info
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(meal.mealTime.rawValue + " • " + meal.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Calories or Loading State
            if isDeleting {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(0.8)
            } else {
                Text("\(meal.calories) calories")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .opacity(isDeleting ? 0.6 : 1.0)
        .scaleEffect(isDeleting ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isDeleting)
        .onTapGesture {
            if !isDeleting {
                onTap()
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .disabled(isDeleting)
        }
        .alert("Delete Meal", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete '\(meal.name)'? This action cannot be undone.")
        }
        .disabled(isDeleting)
    }
}

// MARK: - Empty Meal View
struct EmptyMealView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No meals logged today")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Start tracking your meals by tapping the + button")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// MARK: - Total Consumption Card
struct TotalConsumptionCard: View {
    @ObservedObject var mealManager: MealManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Total Consumption:")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(MealTime.allCases, id: \.self) { mealTime in
                    HStack {
                        Text("\(mealTime.rawValue):")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(mealManager.caloriesByMealTime[mealTime] ?? 0) cal")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                HStack {
                    Text("Total:")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(mealManager.totalCalories) cal")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

#Preview {
    MealView()
}
