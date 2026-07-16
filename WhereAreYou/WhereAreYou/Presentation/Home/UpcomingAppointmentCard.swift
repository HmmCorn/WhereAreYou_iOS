//
//  UpcomingAppointmentCard.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/16/26.
//

import UIKit

// MARK: - 홈 화면의 "얼마 남지 않은 약속" 카드
//       - AppointmentSummaryCard에 남은 시간 라벨(accessoryView)만 꽂아서 구성

final class UpcomingAppointmentCard: UIView {

    private let summaryCard = AppointmentSummaryCard()

    private let remainingTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .caption1).pointSize)
        label.textColor = .blue2
        return label
    }()

    init(appointment: UpcomingAppointment) {
        super.init(frame: .zero)
        setUp()
        configure(with: appointment)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(appointment:)")
    }

    private func setUp() {
        summaryCard.translatesAutoresizingMaskIntoConstraints = false
        addSubview(summaryCard)
        NSLayoutConstraint.activate([
            summaryCard.topAnchor.constraint(equalTo: topAnchor),
            summaryCard.leadingAnchor.constraint(equalTo: leadingAnchor),
            summaryCard.trailingAnchor.constraint(equalTo: trailingAnchor),
            summaryCard.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func configure(with appointment: UpcomingAppointment) {
        summaryCard.configure(with: appointment)
        remainingTimeLabel.text = appointment.date?.remainingTimeText
        summaryCard.accessoryView = remainingTimeLabel
    }

}
