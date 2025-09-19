//
//  HealthView.swift
//  HealthyLivingProject
//
//  Created by Sokty Heng on 19/9/25.
//

import SwiftUI

struct HealthView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                    .padding()
                
                Text("Health Tracking")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text("Monitor your vital health metrics")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Health")
        }
    }
}

#Preview {
    HealthView()
}
