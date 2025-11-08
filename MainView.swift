//
//  ContentView.swift
//  MotorTimer
//
//  Created by 이준희 on 10/29/25.
//

import SwiftUI

struct MainView: View {

    @ObservedObject var mtvm: MotorTimerViewModel
    let mode: ModeType
    let currentUserId = "junhee" // 테스트용
    let columns = [GridItem(.adaptive(minimum: 150, maximum: 150), spacing: 20)]
    
    @State private var selectedMode: ModeType? = nil
    
    var body: some View {
        VStack {
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Button {
                        selectedMode = .stopwatch
                    } label: {
                        Text("스톱워치")
                            .font(.headline)
                            .foregroundColor(selectedMode == .stopwatch ? .white : .accentColor)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(selectedMode == .stopwatch ? Color.accentColor : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.accentColor, lineWidth: 2)
                            )
                            .cornerRadius(10)
                    }
                    
                    Button {
                        selectedMode = .timer
                    } label: {
                        Text("타이머")
                            .font(.headline)
                            .foregroundColor(selectedMode == .timer ? .white : .accentColor)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(selectedMode == .timer ? Color.accentColor : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.accentColor, lineWidth: 2)
                            )
                            .cornerRadius(10)
                    }
                } //:HStack
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
            }
            
            Divider()
                .padding()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    if let user = mtvm.usersGetVehicle.first(where: {$0.id == currentUserId}){
                        ForEach(user.vehicles, id: \.self) { vehicle in
                            VStack(spacing: 12) {
                                VehicleCard(vehicle: vehicle)
                                
                                if let mode = selectedMode {
                                    NavigationLink {
                                        if mode == .stopwatch {
                                            AnimationView(vehicle: vehicle)
                                        } else {
                                            TimerView(vehicle: vehicle)
                                        }
                                    } label: {
                                        Text("run")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.white)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 20)
                                            .background(.accent)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                    }
                    
                }.padding(.horizontal, 20)
                    .padding(.top, 20)
            }
        }
    }
}

#Preview {
    MainView(mtvm: MotorTimerViewModel(), mode: .stopwatch)
}

