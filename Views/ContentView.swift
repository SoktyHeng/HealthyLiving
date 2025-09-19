//
//  ContentView.swift
//  HealthyLivingProject
//
//  Created by Sokty Heng on 19/9/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @State private var isUserAuthenticated = false
    @State private var isProfileComplete = false
    @State private var isCheckingProfile = false
    @State private var authStateListener: AuthStateDidChangeListenerHandle?
    @StateObject private var userManager = UserManager()
    
    var body: some View {
        Group {
            if !isUserAuthenticated {
                AuthenticationView()
            } else if isCheckingProfile {
                // Loading screen while checking profile
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading...")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else if !isProfileComplete {
                ProfileSetupView(isProfileComplete: $isProfileComplete)
            } else {
                MainAppView()
                    .environmentObject(userManager)
            }
        }
        .onAppear {
            checkAuthenticationState()
        }
        .onDisappear {
            removeAuthListener()
        }
        .onChange(of: isProfileComplete) { _, newValue in
            if newValue {
                // Refresh user data after profile completion
                if let userId = Auth.auth().currentUser?.uid {
                    userManager.fetchUser(userId: userId)
                }
            }
        }
    }
    
    private func checkAuthenticationState() {
        // Check if user is already signed in
        if let currentUser = Auth.auth().currentUser {
            isUserAuthenticated = true
            checkUserProfile(userId: currentUser.uid)
        } else {
            isUserAuthenticated = false
            isProfileComplete = false
        }
        
        // Listen for auth state changes and store the listener handle
        authStateListener = Auth.auth().addStateDidChangeListener { [weak userManager] _, user in
            withAnimation(.easeInOut(duration: 0.3)) {
                isUserAuthenticated = user != nil
                
                if let userId = user?.uid {
                    checkUserProfile(userId: userId)
                    userManager?.fetchUser(userId: userId)
                } else {
                    isProfileComplete = false
                    isCheckingProfile = false
                    userManager?.currentUser = nil
                }
            }
        }
    }
    
    private func checkUserProfile(userId: String) {
        isCheckingProfile = true
        
        userManager.checkProfileComplete(userId: userId) { profileComplete in
            withAnimation(.easeInOut(duration: 0.3)) {
                isProfileComplete = profileComplete
                isCheckingProfile = false
            }
        }
    }
    
    private func removeAuthListener() {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
            authStateListener = nil
        }
    }
}

#Preview {
    ContentView()
}
