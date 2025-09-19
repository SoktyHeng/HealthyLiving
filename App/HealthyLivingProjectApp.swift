//
//  HealthyLivingProjectApp.swift
//  HealthyLivingProject
//
//  Created by Sokty Heng on 19/9/25.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct HealthyLivingProjectApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Configure Google Sign-In
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String else {
            fatalError("Couldn't get CLIENT_ID from GoogleService-Info.plist")
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
        
        return true
    }
}
