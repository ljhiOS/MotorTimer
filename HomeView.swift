//
//  HomeView.swift
//  MotorTimer
//
//  Created by 이준희 on 10/29/25.
//

import SwiftUI

struct HomeView: View {
    
    @State private var showSetting = false
    @StateObject var mtvm: MotorTimerViewModel = MotorTimerViewModel()
    var body: some View {
        NavigationStack {
            MainView(mtvm: mtvm, mode: .stopwatch)

            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("MoTi")
                        .foregroundStyle(.accent)
                        .font(.system(size: 30))
                        .bold()
                }
            }
        } //:NavigationStack
    }
}

#Preview {
    HomeView(mtvm: MotorTimerViewModel())
}
