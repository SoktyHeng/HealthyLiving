//
//  ProfileSetup.swift
//  HealthyLivingProject
//
//  Created by Sokty Heng on 19/9/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileSetupView: View {
    @State private var username = ""
    @State private var birthDate = Date()
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Binding var isProfileComplete: Bool
    
    private let maxDate = Date()
    private let minDate = Calendar.current.date(byAdding: .year, value: -120, to: Date()) ?? Date()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.crop.circle.fill.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                            )
                        
                        Text("Complete Your Profile")
                            .font(.title)
                            .fontWeight(.semibold)
                        
                        Text("Help us personalize your experience")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 50)
                    
                    // Form Fields
                    VStack(spacing: 20) {
                        // Username Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Username")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Enter your username", text: $username)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        // Birth Date Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date of Birth")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            DatePicker(
                                "Select your birth date",
                                selection: $birthDate,
                                in: minDate...maxDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        // Current User Info
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(Auth.auth().currentUser?.email ?? "No email")
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Continue Button
                    Button(action: {
                        saveProfile()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            }
                            Text("Continue")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(username.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                    }
                    .disabled(username.isEmpty || isLoading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Spacer(minLength: 50)
                }
            }
            .alert("Profile Setup", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
        .interactiveDismissDisabled() // Prevent dismissing without completing
    }
    
    private func saveProfile() {
        guard let userId = Auth.auth().currentUser?.uid else {
            showError("User not authenticated")
            return
        }
        
        guard !username.isEmpty else {
            showError("Please enter a username")
            return
        }
        
        isLoading = true
        
        let userData: [String: Any] = [
            "username": username.trimmingCharacters(in: .whitespacesAndNewlines),
            "email": Auth.auth().currentUser?.email ?? "",
            "birthDate": Timestamp(date: birthDate),
            "createdAt": Timestamp(),
            "profileComplete": true
        ]
        
        Firestore.firestore().collection("users").document(userId).setData(userData, merge: true) { error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    showError("Error saving profile: \(error.localizedDescription)")
                } else {
                    // Profile saved successfully
                    isProfileComplete = true
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}

#Preview {
    ProfileSetupView(isProfileComplete: .constant(false))
}
