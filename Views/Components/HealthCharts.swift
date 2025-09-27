//
//  HealthCharts.swift
//  HealthyLivingProject
//
//  Chart components for displaying health data
//

import SwiftUI

// MARK: - Weekly Steps Chart
struct WeeklyStepsChart: View {
    let stepData: [Int]
    
    private var maxSteps: Int {
        stepData.max() ?? 1
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(0..<stepData.count, id: \.self) { index in
                VStack {
                    Rectangle()
                        .fill(Color.blue.opacity(0.7))
                        .frame(width: 20, height: CGFloat(stepData[index]) / CGFloat(maxSteps) * 80)
                        .cornerRadius(4)
                    
                    Text(dayAbbreviation(for: index))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func dayAbbreviation(for index: Int) -> String {
        let calendar = Calendar.current
        let today = Date()
        let dayDate = calendar.date(byAdding: .day, value: index - 6, to: today) ?? today
        
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: dayDate)
    }
}

// MARK: - Calories Progress Chart
struct CaloriesProgressChart: View {
    let currentCalories: Int
    let targetCalories: Int = 500 // Daily target
    
    private var progress: Double {
        min(Double(currentCalories) / Double(targetCalories), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Rectangle()
                    .fill(Color.blue.opacity(0.7))
                    .frame(height: 8)
                    .frame(width: progress * 200)
                    .cornerRadius(4)
                
                Spacer()
            }
            .frame(width: 200, height: 8)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(4)
            
            HStack {
                Text("0")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(targetCalories)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 200)
        }
    }
}

// MARK: - Health Data Card
struct HealthDataCard: View {
    let title: String
    let value: String
    let subtitle: String
    let content: AnyView
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(value)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                Spacer()
            }
            
            content
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
