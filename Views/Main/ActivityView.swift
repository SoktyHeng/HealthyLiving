//
//  ActivityView.swift
//  HealthyLivingProject
//
//  Created by Sokty Heng on 19/9/25.
//

import SwiftUI

struct ActivityView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "figure.run")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                    .padding()
                
                Text("Activity Tracker")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text("Track your daily activities and exercises")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Activity")
        }
    }
}

#Preview {
    ActivityView()
}
