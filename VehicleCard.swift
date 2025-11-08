//
//  VehicleCard.swift
//  MotorTimer
//
//  Created by 이준희 on 10/30/25.
//

import SwiftUI

struct VehicleCard: View {
    let vehicle: Vehicle
   
    var body: some View {
        VStack {
            Image(systemName: "car.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 80)
        }
        .frame(width: 100, height: 100)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.gray.opacity(0.2))
        )
        
    }
}

#Preview {
    VehicleCard(vehicle: .car)
}
