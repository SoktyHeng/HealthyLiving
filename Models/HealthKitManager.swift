//
//  HealthKitManager.swift
//  HealthyLivingProject
//
//  HealthKit integration for step count and calories
//

import Foundation
import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    private let healthStore = HKHealthStore()
    
    @Published var stepCount: Int = 0
    @Published var caloriesBurned: Int = 0
    @Published var weeklySteps: [Int] = Array(repeating: 0, count: 7)
    @Published var isAuthorized = false
    @Published var isLoading = false
    
    init() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                if success {
                    self?.fetchTodaysData()
                    self?.fetchWeeklySteps()
                } else if let error = error {
                    print("HealthKit authorization failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchTodaysData() {
        guard isAuthorized else { return }
        
        isLoading = true
        
        // Fetch both step count and calories concurrently
        let group = DispatchGroup()
        
        group.enter()
        fetchTodaysSteps { [weak self] steps in
            DispatchQueue.main.async {
                self?.stepCount = steps
                group.leave()
            }
        }
        
        group.enter()
        fetchTodaysCalories { [weak self] calories in
            DispatchQueue.main.async {
                self?.caloriesBurned = calories
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
        }
    }
    
    private func fetchTodaysSteps(completion: @escaping (Int) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }
            
            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            completion(steps)
        }
        
        healthStore.execute(query)
    }
    
    private func fetchTodaysCalories(completion: @escaping (Int) -> Void) {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(0)
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: calorieType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }
            
            let calories = Int(sum.doubleValue(for: HKUnit.kilocalorie()))
            completion(calories)
        }
        
        healthStore.execute(query)
    }
    
    func fetchWeeklySteps() {
        guard isAuthorized else { return }
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!
        
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: nil,
            options: .cumulativeSum,
            anchorDate: startDate,
            intervalComponents: interval
        )
        
        query.initialResultsHandler = { [weak self] query, results, error in
            guard let results = results else { return }
            
            var weeklyData: [Int] = []
            
            results.enumerateStatistics(from: startDate, to: endDate) { statistics, _ in
                let steps = statistics.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                weeklyData.append(Int(steps))
            }
            
            DispatchQueue.main.async {
                self?.weeklySteps = weeklyData
            }
        }
        
        healthStore.execute(query)
    }
}
