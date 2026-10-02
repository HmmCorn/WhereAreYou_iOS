//
//  ChatViewController+LiveActivityDebugMenu.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-09-27.
//

#if DEBUG
import UIKit

/// [임시 · 3단계에서 삭제] 채팅 + 메뉴의 "라이브 액티비티 시작 (DEBUG)" — Mock 경로 시나리오와 약속 시각을 골라 시작한다.
///
/// ⚠️ 정식 화면 코드와 다르게 ViewModel·ScreenFactory를 거치지 않고, 여기서 DIContainer로 저장소를 꺼내 유스케이스를 직접 만든다.
/// 3단계에서 폴더째 지울 코드라 ChatViewModel·ScreenFactory·DI 등록에 흔적을 남기지 않으려고 일부러 이렇게 했다. 정식 코드에서는 따라 하지 말 것
extension ChatViewController {

    func makeLiveActivityDebugMenu(appointmentID: String) -> UIMenu {
        let makeScenarioActions: (Bool) -> [UIAction] = { startsAfterAppointmentTime in
            MockMyRouteScenario.allCases.map { scenario in
                UIAction(title: scenario.title) { [weak self] _ in
                    MockAppointmentDetailRepository.myRouteScenario = scenario
                    MockAppointmentDetailRepository.startsAfterAppointmentTime = startsAfterAppointmentTime
                    self?.startLiveActivity(appointmentID: appointmentID)
                }
            }
        }

        return UIMenu(
            title: "라이브 액티비티 시작 (DEBUG)",
            image: UIImage(systemName: "hammer"),
            children: [
                UIMenu(title: "", options: .displayInline, children: makeScenarioActions(false)),
                UIMenu(
                    title: "약속 시간 지난 상태로 시작",
                    image: UIImage(systemName: "clock.badge.exclamationmark"),
                    children: makeScenarioActions(true)
                ),
            ]
        )
    }

    private func startLiveActivity(appointmentID: String) {
        let container = DIContainer.shared
        let useCase = StartRouteLiveActivityUseCase(
            appointmentDetailRepository: container.resolve(AppointmentDetailRepository.self),
            liveActivityRepository: ActivityKitRouteLiveActivityRepository(),
            permissionRepository: container.resolve(LiveActivityPermissionRepository.self)
        )

        Task { @MainActor [weak self] in
            do {
                try await useCase.execute(appointmentID: appointmentID)
                self?.showLiveActivityStartResult(error: nil)
            } catch {
                self?.showLiveActivityStartResult(error: error)
            }
        }
    }

    private func showLiveActivityStartResult(error: Error?) {
        let message: String
        if let error {
            if case AppError.permissionDenied = error {
                message = "설정 > WhereAreYou에서 실시간 현황을 허용해 주세요."
            } else {
                message = error.localizedDescription
            }
        } else {
            message = "잠금화면이나 다이나믹 아일랜드에서 확인하세요."
        }

        let alert = UIAlertController(
            title: error == nil ? "라이브 액티비티를 시작했어요" : "시작하지 못했어요",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

}
#endif
