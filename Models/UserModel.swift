//
//  UserModel.swift
//  HealthyLivingProject
//
//  Created by Sokty Heng on 19/9/25.
//

import Foundation
import Combine
import FirebaseFirestore

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    let username: String
    let email: String
    let birthDate: Date
    let createdAt: Date
    let profileComplete: Bool
    
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }
    
    var formattedBirthDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: birthDate)
    }
}

// MARK: - User Manager
class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    
    private let db = Firestore.firestore()
    
    func fetchUser(userId: String) {
        isLoading = true
        
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("Error fetching user: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = snapshot, snapshot.exists else {
                    print("User document does not exist")
                    return
                }
                
                do {
                    self?.currentUser = try snapshot.data(as: User.self)
                } catch {
                    print("Error decoding user: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func checkProfileComplete(userId: String, completion: @escaping (Bool) -> Void) {
        db.collection("users").document(userId).getDocument { snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error checking profile: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let data = snapshot?.data(),
                      let profileComplete = data["profileComplete"] as? Bool else {
                    completion(false)
                    return
                }
                
                completion(profileComplete)
            }
        }
    }
}
