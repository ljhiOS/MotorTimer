//
//  MotorTimerViewModel.swift
//  MoTi
//
//  Created by 이준희 on 11/8/25.
//

import Foundation

class MotorTimerViewModel: ObservableObject {
   
    @Published var usersGetVehicle: [User] = []
    @Published var message: String? = nil
    @Published var userName: String = "junhee"
    
    init() {
        usersGetVehicle = [
            User(id: "junhee", name: "준희", vehicles: [.car])
        ]
    }
    
    func users(with vehicle: Vehicle) -> [User] {
        return usersGetVehicle.filter {$0.vehicles.contains(vehicle)}
    } // 유저가 가진 교통수단을 필터링하는 함수
}
