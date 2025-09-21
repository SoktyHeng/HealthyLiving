//
//  MealModel.swift
//  HealthyLivingProject
//
//  Meal tracking data models and manager
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseStorage

// MARK: - Meal Time Enum
enum MealTime: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
}

// MARK: - Meal Model
struct Meal: Codable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let calories: Int
    let mealTime: MealTime
    let description: String
    let imageURL: String?
    let userId: String
    let createdAt: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
}

// MARK: - Meal Manager
class MealManager: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var isLoading = false
    @Published var todaysMeals: [Meal] = []
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    var totalCalories: Int {
        todaysMeals.reduce(0) { $0 + $1.calories }
    }
    
    var caloriesByMealTime: [MealTime: Int] {
        var calories: [MealTime: Int] = [:]
        for mealTime in MealTime.allCases {
            calories[mealTime] = todaysMeals
                .filter { $0.mealTime == mealTime }
                .reduce(0) { $0 + $1.calories }
        }
        return calories
    }
    
    func startListening(for userId: String) {
        isLoading = true
        stopListening()
        
        listener = db.collection("meals")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        print("Error fetching meals: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    self?.meals = documents.compactMap { document in
                        try? document.data(as: Meal.self)
                    }
                    
                    self?.updateTodaysMeals()
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    private func updateTodaysMeals() {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? Date()
        
        todaysMeals = meals.filter { meal in
            meal.createdAt >= today && meal.createdAt < tomorrow
        }
    }
    
    func addMeal(name: String, calories: Int, mealTime: MealTime, description: String, userId: String, imageURL: String? = nil, completion: @escaping (Result<Void, Error>) -> Void) {
        let meal = Meal(
            name: name,
            calories: calories,
            mealTime: mealTime,
            description: description,
            imageURL: imageURL,
            userId: userId,
            createdAt: Date()
        )
        
        do {
            _ = try db.collection("meals").addDocument(from: meal) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
    func deleteMeal(_ meal: Meal, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let mealId = meal.id else {
            completion(.failure(NSError(domain: "MealManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Meal ID not found"])))
            return
        }
        
        db.collection("meals").document(mealId).delete { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}
