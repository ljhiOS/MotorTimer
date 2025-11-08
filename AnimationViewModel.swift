import SwiftUI
import Combine
import Foundation

// 로직 설정을 거의 ai의 도움을 받은거 같다... 아직 부족하다
// 랭킹과 이 앱과 함께 달린 시간을 프로필 뷰에 적용하기 위해 시간을 계산하려고 함 근데 timaCalulationViewModel에는 start버튼이 두가지로 나누어져 있어서 걍 애니메이션 돌아간 시간으로 계산하려고함
final class AnimationViewModel: ObservableObject {
    
    // 애니메이션 관련 변수
    @Published private(set) var offsetX: CGFloat = 0 // offsetx -> 무한루프 배경의 위치에 대한 정보를 담은 변수
    @Published private(set) var isRunning: Bool = false // -> start버튼을 누르면 isRinning = true 즉, 버튼을 누를시 무한루프가 돌고있냐 아니냐의 정보를 담은 변수
    private var speedPointsPerSecond: Double = 150 // ?
    fileprivate private(set) var tileWidth: CGFloat = 0 // private(set) 사용 이유: // 무한루프 배경이미지의 너비
    fileprivate private(set) var tileCount: Int = 0 // 한 사이클을 구성하는 배경 이미지의 갯수

    private var displayLink: CADisplayLink? // UIKit 기반 로직 Combine의 Import 이유
    private var lastTimestamp: CFTimeInterval = 0 // 시간 초 단위 표현 타입
    private let eps: CGFloat = 0.0001 // 실수끼리의 직접 비교 warning -> if문을 통해 작으면 같다의 기준 점
    
    // 합산 시간 관련 변수
    @Published var elapsedTime: TimeInterval = 0
    @Published var todayTotalTime: TimeInterval = 0
    private var timer: Timer?
    private var startDate: Date?
    

    // 매 프레임마다 호출되어, 실제로 offsetX를 움직여서 배경이 흘러가는 것처럼 만드는 함수
    func updatBackgroundView(tileWidth: CGFloat, tileCount: Int) {
        guard tileWidth > 0, tileCount > 0 else { return }
        self.tileWidth = tileWidth
        self.tileCount = tileCount
       
        self.offsetX = normalizedOffset(self.offsetX)
    }
    
    // 무한루프 중 배경이 한사이클을 돌았을때 다시 앞으로 되감아 무한루프처럼 보이게 하는 함수
    private func normalizedOffset(_ x: CGFloat) -> CGFloat {
        guard tileWidth > eps, tileCount > 0 else { return 0 }
        let period = tileWidth * CGFloat(tileCount) // 한사이클의 너비
        var r = x.truncatingRemainder(dividingBy: period) // truncatingRemainder(dividingBy: period) -> 실수에서도 쓸 수 있도록 만든 나머지 연산 전용 메서드 이용
        // 배경은 왼쪽으로 계속 흐를건데 x의 위치는 계속해서 -가 될것임 그리하여 주기만큼 나누어서 현재 x의 위치를 계속해서 한주기 안에 가두는 역할 그것을 r에 저장함
        if r > 0 { r -= period } // 방향이 계속하여 왼쪽으로 가기 위한 안전장치
        if abs(r) < eps { r = 0 } // 예상치 못한 부동소수점의 숫자가 남아 점점 쌓이면 화면 떨림현상이 발생 -> 방지용으로 eps보다 작다면 0으로 처리하여 떨림현상을 방지하자
        return r // ?
    }

    // 무한루프의 속도 설정
    func setSpeed(pointsPerSecond: Double) {
        guard pointsPerSecond > 0 else { return }
        self.speedPointsPerSecond = pointsPerSecond
    }

    // 버튼 누를 시 무한루프 가동
    func start() {
        guard !isRunning, tileWidth > eps, tileCount > 0 else { return }
        isRunning = true
        lastTimestamp = 0
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkUpdate(_:))) //#selector -> 매 프레임마다 실행할 함수 지정 why? CADisplayLink 로직은 화면의 새로고침 주기마가 호출되는 타이머이기에
        displayLink?.preferredFramesPerSecond = 60 // 60프레임 설정
        displayLink?.add(to: .main, forMode: .common) // .common은 일반적인 모든 이벤트 루프모드(터치, 스크롤 등)에서도 계속 작동하게 하는 옵션
        // 이게 있어야 iOS가 화면을 다시 그릴때마다 해당 메서드를 불러줄수 있다고 함 어떤 메서드? #selector의 프로퍼티
               
    }

    // stop버튼 무한루프 종료
    func stop() {
        isRunning = false
        displayLink?.invalidate() // 화면 업데이트 중지
        displayLink = nil // 메모리에서 제거 ARC 개념 ARC란? 자동 참조 카운팅 참조된 것을 nil을 통해 메모리 제거 가능
        lastTimestamp = 0
    }

    // 핵심 배경 위치 이동 함수
    @objc private func displayLinkUpdate(_ link: CADisplayLink) { // @objc -> 옵젝트c 런타임에서도 호출 가능하게 하는 키워드
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp // .timestamp 메서드 -> 현재 프레임이 화면에 표시될 때의 절대 시간(초 단위) // link.timestamp -> 현재 시간
            return
        }
        let delta = link.timestamp - lastTimestamp // 다음 프레임과 이전 프레임의 시간 차이
        lastTimestamp = link.timestamp // 다음 프레임 계산을 위한 이전 현재 프레임을 이전 프레임에 저장 예) #1 2번 프레임 시간 - 1번 프레임 시간 = 프레임간 시간 차이 그럼 다음 계산을 위해 이전 프레임 시간에 현재(2번 프레임 시간)을 저장해야지 #2번 계산이 가능 #2 3번 프레임 시간 - 2번 프레임 시간 = 프레임 간 시간차이
        let move = CGFloat(speedPointsPerSecond * delta) // 속도 * 시간 = 거리

        DispatchQueue.main.async { // 동기화
            self.offsetX -= move // 배경의 위치를 프레임마다 바꿈(왼쪽으로 움직여야 하기에 -)
            self.offsetX = self.normalizedOffset(self.offsetX) // x의 위치를 계산하며 var r = x.truncatingRemainder(dividingBy: period)를 이용해 주기 안에 가둔다
        }
    }

    // 몇개의 배경이 움직였는지 확인하는 함수
    func startIndexForVisible() -> Int {
        guard tileWidth > eps else { return 0 }
        let shiftedTiles = floor((-offsetX) / tileWidth) // 몇개의 배경이 이동했는지 계산. floor 내림처리
        return max(0, Int(shiftedTiles))
    }

    // n번째 타일의 중앙 좌표를 구하는 함수 
    func centerX(TileIndex n: Int, viewLeftOrigin: CGFloat = 0, viewWidth: CGFloat) -> CGFloat {
        let left = offsetX + CGFloat(n) * tileWidth
        return viewLeftOrigin + left + tileWidth / 2
    }

    deinit {
        displayLink?.invalidate()
    }
}

