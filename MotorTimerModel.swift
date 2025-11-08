//
//  MotorTimerModel.swift
//  MotorTimer
//
//  Created by 이준희 on 10/29/25.
//

import SwiftUI
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var vehicles: [Vehicle] 
    
    init(id: String? = nil, name: String, vehicles: [Vehicle]? = nil) {
        self.id = id
        self.name = name
        self.vehicles = vehicles ?? [.car]
    }

}

// 전체 교통수단
enum Vehicle: String, Codable {
    case car
    @ViewBuilder
    var imageName: some View {
        switch self {
        case .car:
            Image("carImage")
                .resizable()
                .scaledToFit()
        }
    }
}

enum ModeType {
    case stopwatch
    case timer
}
