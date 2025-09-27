//
//  MealHistoryView.swift
//  HealthyLivingProject
//
//  View showing all meals organized by date
//

import SwiftUI
import FirebaseAuth

struct MealHistoryView: View {
    @StateObject private var mealManager = MealManager()
    @State private var selectedMeal: Meal?
    @Environment(\.dismiss) private var dismiss
    
    // Group meals by date (excluding today)
    private var mealsByDate: [(date: Date, meals: [Meal])] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Filter out today's meals
        let pastMeals = mealManager.meals.filter { meal in
            calendar.startOfDay(for: meal.createdAt) < today
        }
        
        let grouped = Dictionary(grouping: pastMeals) { meal in
            calendar.startOfDay(for: meal.createdAt)
        }
        
        return grouped.map { (date: $0.key, meals: $0.value) }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationView {
            Group {
                if mealManager.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading meal history...")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                } else if mealsByDate.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No meal history")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Start logging meals to see your history here")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Meal history list
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(mealsByDate, id: \.date) { dateGroup in
                                MealDateSection(
                                    date: dateGroup.date,
                                    meals: dateGroup.meals,
                                    onMealTap: { meal in
                                        selectedMeal = meal
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Meal History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
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
        }
    }
}

// MARK: - Meal Date Section
struct MealDateSection: View {
    let date: Date
    let meals: [Meal]
    let onMealTap: (Meal) -> Void
    
    private var totalCalories: Int {
        meals.reduce(0) { $0 + $1.calories }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedDate)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("\(meals.count) meal\(meals.count == 1 ? "" : "s") • \(totalCalories) calories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            
            // Meals for this date
            VStack(spacing: 8) {
                ForEach(meals.sorted { $0.createdAt > $1.createdAt }, id: \.id) { meal in
                    MealHistoryRow(meal: meal) {
                        onMealTap(meal)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Meal History Row
struct MealHistoryRow: View {
    let meal: Meal
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
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
                                    .scaleEffect(0.6)
                            )
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                // Meal Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(meal.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("\(meal.mealTime.rawValue) • \(meal.formattedDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Calories
                Text("\(meal.calories) cal")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MealHistoryView()
}
