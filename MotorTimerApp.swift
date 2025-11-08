//
//  MotorTimerApp.swift
//  MotorTimer
//
//  Created by 이준희 on 10/29/25.
//

import SwiftUI
import Firebase

@main
struct MotorTimerApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
