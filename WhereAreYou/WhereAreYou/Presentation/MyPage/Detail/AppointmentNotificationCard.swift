//
//  AppointmentNotificationCard.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/25/26.
//

import UIKit

// MARK: - 약속별 알림 화면의 약속 카드
//       - 제목 + 인원/장소/날짜 3줄 + 우측 상단 알림 스위치로 구성
//       - AppointmentListCard와 달리 대화/지도 버튼 없이 스위치 하나만 다룸

final class AppointmentNotificationCard: AppointmentCardBase {

    var onNotificationToggle: ((Bool) -> Void)?

    private let notificationSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .blue2
        return toggle
    }()

    init(item: AppointmentListItem) {
        notificationSwitch.isOn = item.isNotificationEnabled
        super.init(
            participantCount: item.participantCount,
            placeText: item.location?.title ?? "미정",
            dateText: item.date?.appointmentDateTimeText ?? "미정",
            title: item.title,
            accessoryView: notificationSwitch
        )
        rowStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
        notificationSwitch.addAction(UIAction { [weak self] _ in
            self?.onNotificationToggle?(self?.notificationSwitch.isOn ?? false)
        }, for: .valueChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(item:)")
    }

}
