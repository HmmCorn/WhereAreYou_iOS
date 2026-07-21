//
//  AppointmentCardBase.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/21/26.
//

import UIKit

// MARK: - 약속 카드의 공통 뼈대
//       - 배경/그림자/코너radius + 제목 + 인원/장소/날짜 3줄을 담당
//       - 제목 오른쪽 액세서리(남은 시간 라벨, 휴지통 버튼 등)는 하위 클래스가 넘겨줌 (없으면 nil)
//       - 하위 클래스는 rowStack.bottomAnchor 아래에 자신만의 콘텐츠(버튼, 탭 제스처 등)를 추가

class AppointmentCardBase: UIView {

    let rowStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 3
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()

    private let participantRow = IconLabel(iconName: "person.2.fill")
    private let placeRow = IconLabel(iconName: "location.fill")
    private let dateRow = IconLabel(iconName: "calendar.badge.clock")

    init(participantCount: Int, placeText: String, dateText: String, title: String, accessoryView: UIView?) {
        super.init(frame: .zero)
        setUp(accessoryView: accessoryView)
        configure(title: title, participantCount: participantCount, placeText: placeText, dateText: dateText)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp(accessoryView: UIView?) {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 4)

        [participantRow, placeRow, dateRow].forEach { rowStack.addArrangedSubview($0) }

        [titleLabel, rowStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),

            rowStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            rowStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 6),
            rowStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -14)
        ])

        setUpAccessoryViewIfNeeded(accessoryView)
    }

    private func setUpAccessoryViewIfNeeded(_ accessoryView: UIView?) {
        guard let accessoryView else { return }
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(accessoryView)

        NSLayoutConstraint.activate([
            accessoryView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            accessoryView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: accessoryView.leadingAnchor, constant: -8)
        ])
    }

    private func configure(title: String, participantCount: Int, placeText: String, dateText: String) {
        titleLabel.text = title
        participantRow.text = "\(participantCount)명"
        placeRow.text = placeText
        dateRow.text = dateText
    }

}
