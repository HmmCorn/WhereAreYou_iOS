//
//  UpcomingAppointmentCard.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/16/26.
//

import UIKit

// MARK: - 홈 화면의 "얼마 남지 않은 약속" 카드
//       - 제목 + 남은 시간(옵셔널) + 인원/장소/날짜 3줄로 구성
//       - 카드 자체가 탭 가능

final class UpcomingAppointmentCard: AppointmentCardBase {

    var onTap: (() -> Void)?

    init(appointment: UpcomingAppointment) {
        let remainingTimeLabel: UILabel = {
            let label = UILabel()
            label.font = .boldPreferredFont(forTextStyle: .footnote)
            label.textColor = .blue2
            label.adjustsFontForContentSizeCategory = true
            label.setContentHuggingPriority(.required, for: .horizontal)
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            label.text = appointment.date?.remainingTimeText
            return label
        }()

        super.init(
            participantCount: appointment.participantCount,
            placeText: appointment.location?.title ?? "미정",
            dateText: appointment.date?.appointmentDateTimeText ?? "미정",
            title: appointment.title,
            accessoryView: remainingTimeLabel
        )

        rowStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14).isActive = true

        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardTapped)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(appointment:)")
    }

    @objc private func cardTapped() {
        onTap?()
    }

}
