//
//  TimeCalculation.swift
//  MotorTimer
//
//  Created by 이준희 on 11/5/25.
//

import Foundation

class TimeCalculationViewModel: ObservableObject {
    @Published var hour: Int = 0
    @Published var minute: Int = 0
    @Published var second: Int = 0
    
    @Published var isStart: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var todayTotalTime: TimeInterval = 0
    
    private var timer: Timer?
    private var startDate: Date?
    private var totalTime: Int = 0
    
    init(hour: Int, minute: Int, second: Int) {
        self.hour = hour
        self.minute = minute
        self.second = second
    }
    
    // 시작버튼을 누를시 timer 작동 함수
    func stopWatchStart() {
        isStart = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.second += 1
            
            if self.second == 60 {
                self.second = 0
                self.minute += 1
            }
            
            if self.minute == 60 {
                self.minute = 0
                self.hour += 1
            }
        }
    }
    
    func timerStart(onFinish: (()-> Void)? = nil) {
        totalTime = hour * 3600 + minute * 60 + second
        
        guard totalTime > 0 else { return } // 0이면 시작 안 함
        
        isStart = true
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            if self.totalTime > 0 {
                self.totalTime -= 1
                self.hour = self.totalTime / 3600
                self.minute = (self.totalTime % 3600) / 60
                self.second = self.totalTime % 60
            } else {
                self.stop()
                timer.invalidate()
                onFinish?() 
            }
        }
       
    }
    
    func stop() {
        isStart = false
        timer?.invalidate()
    }
    
    func initial0() {
        self.hour = 0
        self.minute = 0
        self.second = 0
    }
}
