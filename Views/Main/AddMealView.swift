//
//  AddMealView.swift
//  HealthyLivingProject
//
//  Sheet view for adding new meals
//

import SwiftUI
import FirebaseAuth
import PhotosUI
import FirebaseStorage

struct AddMealView: View {
    @ObservedObject var mealManager: MealManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var mealName = ""
    @State private var calories = ""
    @State private var selectedMealTime = MealTime.breakfast
    @State private var description = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var selectedImageData: Data?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Meal Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Meal Name:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter meal name", text: $mealName)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .autocapitalization(.words)
                    }
                    
                    // Pick Image Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pick Image:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            HStack {
                                if let selectedImage = selectedImage {
                                    selectedImage
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                    
                                    VStack(alignment: .leading) {
                                        Text("Image selected")
                                            .foregroundColor(.blue)
                                            .font(.subheadline)
                                        Text("Tap to change")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                } else {
                                    Image(systemName: "photo")
                                        .foregroundColor(.blue)
                                    Text("Choose image")
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .onChange(of: selectedPhotoItem) { _, newItem in
                            Task {
                                if let newItem = newItem {
                                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                                        selectedImageData = data
                                        if let uiImage = UIImage(data: data) {
                                            selectedImage = Image(uiImage: uiImage)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Calories Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Calories:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter calories", text: $calories)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .keyboardType(.numberPad)
                    }
                    
                    // Meal Time Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Meal Time:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Picker("Meal Time", selection: $selectedMealTime) {
                            ForEach(MealTime.allCases, id: \.self) { mealTime in
                                Text(mealTime.rawValue).tag(mealTime)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    // Description Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description:")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Add Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMeal()
                    }
                    .disabled(isLoading || !isFormValid)
                    .fontWeight(.semibold)
                    .overlay(
                        // Show loading spinner when saving
                        isLoading ?
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(0.8)
                        : nil
                    )
                }
            }
            .alert("Add Meal", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !mealName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !calories.isEmpty &&
        Int(calories) != nil &&
        Int(calories) ?? 0 > 0
    }
    
    private func saveMeal() {
        guard let userId = Auth.auth().currentUser?.uid else {
            showError("User not authenticated")
            return
        }
        
        guard let calorieValue = Int(calories), calorieValue > 0 else {
            showError("Please enter a valid calorie amount")
            return
        }
        
        let trimmedName = mealName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            showError("Please enter a meal name")
            return
        }
        
        isLoading = true
        
        // If there's an image, upload it first, then save the meal
        if let imageData = selectedImageData {
            uploadImageToStorage(imageData: imageData, userId: userId) { imageURL in
                self.saveMealToFirestore(
                    name: trimmedName,
                    calories: calorieValue,
                    mealTime: self.selectedMealTime,
                    description: self.description.trimmingCharacters(in: .whitespacesAndNewlines),
                    userId: userId,
                    imageURL: imageURL
                )
            }
        } else {
            // No image, save meal without image URL
            saveMealToFirestore(
                name: trimmedName,
                calories: calorieValue,
                mealTime: selectedMealTime,
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                userId: userId,
                imageURL: nil
            )
        }
    }
    
    private func uploadImageToStorage(imageData: Data, userId: String, completion: @escaping (String?) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        // Create a unique filename using timestamp and user ID
        let filename = "\(userId)_\(Date().timeIntervalSince1970).jpg"
        let imageRef = storageRef.child("meal_images/\(filename)")
        
        // Upload the image data
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // Get the download URL
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    completion(url?.absoluteString)
                }
            }
        }
    }
    
    private func saveMealToFirestore(name: String, calories: Int, mealTime: MealTime, description: String, userId: String, imageURL: String?) {
        mealManager.addMeal(
            name: name,
            calories: calories,
            mealTime: mealTime,
            description: description,
            userId: userId,
            imageURL: imageURL
        ) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success:
                    // Add a small delay to ensure Firebase has processed the write
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.dismiss()
                    }
                case .failure(let error):
                    self.showError("Error saving meal: \(error.localizedDescription)")
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
    AddMealView(mealManager: MealManager())
}
