//
//  TimerView.swift
//  MotorTimer
//
//  Created by 이준희 on 11/5/25.
//

import SwiftUI

struct TimerView: View {
    let vehicle: Vehicle
    
    @StateObject private var avm: AnimationViewModel
    @StateObject private var tcvm: TimeCalculationViewModel
    @State private var isSettingTime: Bool = true
    
    init(vehicle: Vehicle) {
        self.vehicle = vehicle
        _avm = StateObject(wrappedValue: AnimationViewModel())
        _tcvm = StateObject(wrappedValue: TimeCalculationViewModel(hour: 0, minute: 0, second: 0))
    }

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            let isLandscape = w > h

            if UIDevice.current.userInterfaceIdiom == .phone {
                IPhoneTimerView(vehicle: vehicle, avm: avm, tcvm: tcvm, width: w, height: h, isLandscape: isLandscape, isSettingTime: $isSettingTime)
                    .onAppear { avm.updatBackgroundView(tileWidth: w, tileCount: 7) }
                    .onChange(of: w) { newValue in
                        avm.updatBackgroundView(tileWidth: newValue, tileCount: 7)
                    }
            } else {
                IPadTimerView(vehicle: vehicle, avm: avm, tcvm: tcvm, width: w, height: h, isLandscape: isLandscape, isSettingTime: $isSettingTime)
                    .onAppear { avm.updatBackgroundView(tileWidth: w, tileCount: 5) }
                    .onChange(of: w) { newValue in
                        avm.updatBackgroundView(tileWidth: newValue, tileCount: 5)
                    }
            }
            
            if isSettingTime {
                Color.black.opacity(0.4).ignoresSafeArea()
                VStack(spacing: 20) {
                    Text("Set Timer")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.accent)
                    
                    HStack {
                        Picker(":", selection: $tcvm.hour) {
                            ForEach(0..<24, id: \.self) {
                                Text("\($0)")
                                    .font(.title)
                            }
                        }
                        .pickerStyle(.inline)
                        .frame(width: 80)
                        
                        Picker(":", selection: $tcvm.minute) {
                            ForEach(0..<60, id: \.self) {
                                Text("\($0)")
                                    .font(.title)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80)
                        
                        Picker(":", selection: $tcvm.second) {
                            ForEach(0..<60, id: \.self) {
                                Text("\($0)")
                                    .font(.title)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80)
                    } //:HStack
                    .foregroundStyle(.accent)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    
                    Button {
                        isSettingTime = false
                    } label: {
                        Text("START")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(width: 180)
                            .background(.accent)
                            .cornerRadius(15)
                    }
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.95))
                .cornerRadius(25)
                .shadow(radius: 10)
            }
        }
    }
}

// MARK: - iPhone Layout
struct IPhoneTimerView: View {
    let vehicle: Vehicle
    @ObservedObject var avm: AnimationViewModel
    @ObservedObject var tcvm: TimeCalculationViewModel
    let width: CGFloat
    let height: CGFloat
    let isLandscape: Bool
    @Binding var isSettingTime: Bool
    var body: some View {
        VStack(spacing: height * 0.03) {
            // 타이머 텍스트
            Spacer()
            Text(String(format: "%02d:%02d:%02d", tcvm.hour, tcvm.minute, tcvm.second))
                .foregroundStyle(.accent)
                .font(.system(size: isLandscape ? height * 0.3 : height * 0.1))
                .monospacedDigit() // 숫자 폭 일정하도록 조정
            
            // START / STOP 버튼
            HStack {
                Button {
                    avm.isRunning ? avm.stop() : avm.start()
                    tcvm.isStart ? tcvm.stop() : tcvm.timerStart(onFinish: {avm.stop()})
                    
                } label: {
                    Text(avm.isRunning ? "STOP" : "START")
                        .foregroundStyle(.white)
                        .font(.system(size: height * 0.035))
                        .padding(.horizontal, width * 0.08)
                        .padding(.vertical, height * 0.015)
                        .background(.accent)
                        .cornerRadius(15)
                }
                
                Button {
                    tcvm.initial0()
                    isSettingTime = true
                } label: {
                    Text("INIT")
                        .foregroundStyle(.white)
                        .font(.system(size: height * 0.035))
                        .padding(.horizontal, width * 0.08)
                        .padding(.vertical, height * 0.015)
                        .background(.accent)
                        .cornerRadius(15)
                }
            }

            Divider()
            Spacer(minLength: height * 0.03)

            // ZStack: 배경 + 차량
            ZStack {
                // 배경 (로직 그대로)
                GeometryReader { geo in
                    let viewW = geo.size.width
                    let viewH = geo.size.height
                    let tileWidth = width
                    let safeTileWidth = tileWidth > 0 && tileWidth.isFinite ? tileWidth : 1.0
                    // 배경의 무한대 혹은 0 방지 (그럴일은 없긴함 ㅋㅋ)
                    let visibleTiles = max(1, Int(ceil(viewW / safeTileWidth)) + 2)
                    //ceil -> 올림처리 /
                    let startIndex = avm.startIndexForVisible()

                    ForEach(startIndex..<(startIndex + visibleTiles), id: \.self) { n in
                        // 뷰에 채워야 하는 배경이미지들 화면에 그리기
                        Image("backgroundImage")
                            .resizable()
                            .scaledToFill()
                            .frame(width: tileWidth, height: viewH)
                            .position(
                                x: avm.centerX(TileIndex: n, viewLeftOrigin: 0, viewWidth: viewW),
                                y: isLandscape ? viewH / 2.0 : viewH / 2.1
                            )
                    }
                    .allowsHitTesting(false)
                    // 버튼이나 UI요소를 배경 위에 올려도 잘 작동하게 한다
                }
                .ignoresSafeArea()

                // 차량
                GeometryReader { geo in
                    vehicle.imageName
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.27)
                        .position(
                            x: geo.size.width / 2,
                            y: isLandscape ? geo.size.height / 1.2 : geo.size.height / 1.6
                        )
                }
            }
            .frame(height: height / 2)
            .ignoresSafeArea()

        }
        .frame(width: width, height: height)
        .onDisappear { avm.stop() }
    }
}

// iPad 레이아웃만 다르지 아이폰과 코드는 같음
struct IPadTimerView: View {
    let vehicle: Vehicle
    @ObservedObject var avm: AnimationViewModel
    @ObservedObject var tcvm: TimeCalculationViewModel
    let width: CGFloat
    let height: CGFloat
    let isLandscape: Bool
    @Binding var isSettingTime: Bool

    var body: some View {
        VStack(spacing: height * 0.04) {
            // 타이머
            Text(String(format: "%02d:%02d:%02d", tcvm.hour, tcvm.minute, tcvm.second))
                .foregroundStyle(.accent)
                .font(.system(size: isLandscape ? height * 0.2 : height * 0.1))
                .monospacedDigit()

            // 버튼
            HStack {
                Button {
                    avm.isRunning ? avm.stop() : avm.start()
                    tcvm.isStart ? tcvm.stop() : tcvm.timerStart()
                } label: {
                    Text(avm.isRunning ? "STOP" : "START")
                        .foregroundStyle(.white)
                        .font(.system(size: height * 0.045))
                        .padding(.horizontal, width * 0.08)
                        .padding(.vertical, height * 0.02)
                        .background(.accent)
                        .cornerRadius(15)
                }
                
                Button  {
                    tcvm.initial0()
                } label: {
                    Text("INIT")
                        .foregroundStyle(.white)
                        .font(.system(size: height * 0.045))
                        .padding(.horizontal, width * 0.08)
                        .padding(.vertical, height * 0.02)
                        .background(.accent)
                        .cornerRadius(15)
                }

            }

            Spacer(minLength: height * 0.03)

            // 배경 + 차량
            ZStack {
                GeometryReader { geo in
                    let viewW = geo.size.width
                    let viewH = geo.size.height
                    let tileWidth = width
                    let safeTileWidth = tileWidth > 0 && tileWidth.isFinite ? tileWidth : 1.0
                    let visibleTiles = max(1, Int(ceil(viewW / safeTileWidth)) + 2)
                    let startIndex = avm.startIndexForVisible()

                    ForEach(startIndex..<(startIndex + visibleTiles), id: \.self) { n in
                        Image("backgroundImage")
                            .resizable()
                            .scaledToFill()
                            .frame(width: tileWidth, height: viewH)
                            .clipped()
                            .position(
                                x: avm.centerX(TileIndex: n, viewLeftOrigin: 0, viewWidth: viewW),
                                y: viewH / 2
                            )
                    }
                    .allowsHitTesting(false)
                }
                .ignoresSafeArea()

                GeometryReader { geo in
                    vehicle.imageName
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.3)
                        .position(
                            x: geo.size.width / 2,
                            y: isLandscape ? geo.size.height / 1.2 : geo.size.height / 1.5
                        )
                }
            }
            .frame(height: height / 2)
            .ignoresSafeArea()
        }
        .onDisappear { avm.stop() }
        .frame(width: width, height: height)
    }
}

#Preview {
    TimerView(vehicle: .car)
}
