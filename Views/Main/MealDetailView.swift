//
//  MealDetailView.swift
//  HealthyLivingProject
//
//  Detailed view for individual meals
//

import SwiftUI

struct MealDetailView: View {
    let meal: Meal
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Meal Image
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
                                    .scaleEffect(1.2)
                            )
                    }
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    // Default meal image placeholder
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .frame(height: 250)
                        .overlay(
                            VStack(spacing: 12) {
                                Text("No Image")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        )
                }
                
                // Meal Info
                VStack(alignment: .leading, spacing: 16) {
                    // Meal Name and Time
                    VStack(alignment: .leading, spacing: 8) {
                        Text(meal.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack {
                            Text(meal.mealTime.rawValue)
                                .font(.title3)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text(meal.formattedDate)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Calories Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nutrition Information")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Calories")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(meal.calories)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "flame.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Description
                    if !meal.description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                            
                            Text(meal.description)
                                .font(.body)
                                .foregroundColor(.primary)
                                .lineLimit(nil)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .navigationTitle("Meal Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private func formatFullDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Detail Row Component
struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    NavigationView {
        MealDetailView(meal: Meal(
            name: "Grilled Chicken Salad",
            calories: 350,
            mealTime: .lunch,
            description: "Fresh mixed greens with grilled chicken breast, cherry tomatoes, and light vinaigrette dressing.",
            imageURL: nil,
            userId: "preview",
            createdAt: Date()
        ))
    }
}
