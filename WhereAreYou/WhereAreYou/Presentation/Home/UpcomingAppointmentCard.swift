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

final class UpcomingAppointmentCard: UIView {

    var onTap: (() -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()

    private let remainingTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .boldPreferredFont(forTextStyle: .footnote)
        label.textColor = .blue2
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    private let participantRow = IconLabel(iconName: "person.2.fill")
    private let placeRow = IconLabel(iconName: "location.fill")
    private let dateRow = IconLabel(iconName: "calendar.badge.clock")

    private lazy var rowStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [participantRow, placeRow, dateRow])
        stack.axis = .vertical
        stack.spacing = 3
        return stack
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
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 4)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        remainingTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addSubview(remainingTimeLabel)
        addSubview(rowStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: remainingTimeLabel.leadingAnchor, constant: -8
            ),

            remainingTimeLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            remainingTimeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            rowStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            rowStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 6),
            rowStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -14),
            rowStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])

        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardTapped)))
    }

    private func configure(with appointment: UpcomingAppointment) {
        titleLabel.text = appointment.title
        remainingTimeLabel.text = appointment.date?.remainingTimeText
        participantRow.text = "\(appointment.participantCount)명"
        placeRow.text = appointment.location?.title ?? "미정"
        dateRow.text = appointment.date?.appointmentDateTimeText ?? "미정"
    }

    @objc private func cardTapped() {
        onTap?()
    }

}
