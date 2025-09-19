//
//  AuthenticationView.swift
//  HealthyLivingProject
//
//  Created by Sokty Heng on 19/9/25.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import Firebase

struct AuthenticationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingSignUp = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Logo/Icon
                    VStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "dumbbell.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            )
                        
                        Text(isShowingSignUp ? "Create Account" : "Sign In")
                            .font(.title)
                            .fontWeight(.medium)
                            .padding(.top, 10)
                    }
                    .padding(.top, 80)
                    
                    // Input Fields
                    VStack(spacing: 16) {
                        TextField("Enter your email", text: $email)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .focused($isEmailFocused)
                            .disabled(isLoading)
                        
                        SecureField("Enter your password", text: $password)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .focused($isPasswordFocused)
                            .cornerRadius(8)
                            .disabled(isLoading)
                        
                        if !isShowingSignUp {
                            HStack {
                                Spacer()
                                Button("Forgot Password?") {
                                    resetPassword()
                                }
                                .font(.callout)
                                .foregroundColor(.blue)
                                .disabled(isLoading)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            // Dismiss keyboard first
                            isEmailFocused = false
                            isPasswordFocused = false
                            
                            if isShowingSignUp {
                                signUp()
                            } else {
                                signIn()
                            }
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                }
                                Text(isShowingSignUp ? "Create Account" : "Login")
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(isLoading ? Color.blue.opacity(0.7) : Color.blue)
                            .cornerRadius(8)
                        }
                        .disabled(isLoading)
                        .padding(.horizontal, 20)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                            Text("OR")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                        }
                        .padding(.horizontal, 20)
                        
                        // Google Sign In Button
                        Button(action: {
                            // Dismiss keyboard first
                            isEmailFocused = false
                            isPasswordFocused = false
                            signInWithGoogle()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "globe")
                                    .foregroundColor(.black)
                                
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(0.8)
                                        .foregroundColor(.black)
                                }
                                
                                Text("Continue with Google")
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(isLoading)
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 30)
                    
                    // Toggle between Sign In and Sign Up
                    Button(action: {
                        // Dismiss keyboard first
                        isEmailFocused = false
                        isPasswordFocused = false
                        
                        isShowingSignUp.toggle()
                        email = ""
                        password = ""
                    }) {
                        Text(isShowingSignUp ? "Already have an account? Sign In" : "Don't have an account? Register now")
                            .font(.callout)
                            .foregroundColor(.blue)
                    }
                    .disabled(isLoading)
                    .padding(.top, 40)
                    .padding(.bottom, 30)
                }
            }
            .contentMargins(.bottom, 0, for: .scrollContent)
            .scrollDismissesKeyboard(.interactively)
            .alert("Authentication", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    private func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            showError("Please enter both email and password")
            return
        }
        
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    showError(error.localizedDescription)
                }
                // Navigation handled by ContentView's auth state listener
            }
        }
    }
    
    private func signUp() {
        guard !email.isEmpty, !password.isEmpty else {
            showError("Please enter both email and password")
            return
        }
        
        guard password.count >= 6 else {
            showError("Password must be at least 6 characters")
            return
        }
        
        isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    showError(error.localizedDescription)
                }
                // Navigation handled by ContentView's auth state listener
            }
        }
    }
    
    private func signInWithGoogle() {
        guard let presentingViewController = getRootViewController() else {
            showError("Unable to get presenting view controller")
            return
        }
        
        isLoading = true
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    showError(error.localizedDescription)
                    return
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    showError("Failed to get Google user information")
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: user.accessToken.tokenString)
                
                // Sign in with Firebase
                Auth.auth().signIn(with: credential) { result, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            showError(error.localizedDescription)
                        }
                        // Navigation handled by ContentView's auth state listener
                    }
                }
            }
        }
    }
    
    private func resetPassword() {
        guard !email.isEmpty else {
            showError("Please enter your email address first")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                if let error = error {
                    showError(error.localizedDescription)
                } else {
                    showError("Password reset email sent!")
                }
            }
        }
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        return window.rootViewController
    }
    
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}

#Preview {
    AuthenticationView()
}
