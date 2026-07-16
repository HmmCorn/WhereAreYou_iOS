//
//  AppointmentSummaryCard.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/16/26.
//

import UIKit

// MARK: - 약속 제목 + 인원/장소/날짜 3줄로 구성된 요약 카드
//       - 우측 상단 액세서리(남은시간 라벨, 쓰레기통 버튼 등)와 하단 버튼 영역은
//         이 컴포넌트가 내용을 알지 못하며, 사용하는 화면에서 뷰를 꽂아 조립

final class AppointmentSummaryCard: UIView {

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

    private lazy var rowStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [participantRow, placeRow, dateRow])
        stack.axis = .vertical
        stack.spacing = 3
        return stack
    }()

    /// 타이틀 우측 끝에 붙는 액세서리 뷰(남은시간 라벨, 쓰레기통 버튼 등)
    /// titleLabel은 이 뷰 앞까지만 차지하며, 넘치면 말줄임(...) 처리
    var accessoryView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            titleTrailingToSelfConstraint.isActive = accessoryView == nil

            guard let accessoryView else { return }
            accessoryView.translatesAutoresizingMaskIntoConstraints = false
            accessoryView.setContentHuggingPriority(.required, for: .horizontal)
            accessoryView.setContentCompressionResistancePriority(.required, for: .horizontal)
            addSubview(accessoryView)

            NSLayoutConstraint.activate([
                accessoryView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
                accessoryView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
                titleLabel.trailingAnchor.constraint(
                    lessThanOrEqualTo: accessoryView.leadingAnchor,
                    constant: -8
                )
            ])
        }
    }

    /// 카드 하단에 놓일 버튼 영역(대화 열기/지도 열기 등)
    var footerView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            guard let footerView else { return }
            footerView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(footerView)
            NSLayoutConstraint.activate([
                footerView.topAnchor.constraint(equalTo: rowStack.bottomAnchor, constant: 8),
                footerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
                footerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
                footerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
            ])
        }
    }

    /// accessoryView가 없을 때만 활성화되는, titleLabel이 카드 오른쪽 끝까지 차지하는 기본 constraint
    private lazy var titleTrailingToSelfConstraint =
        titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -14)

    init() {
        super.init(frame: .zero)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init()")
    }

    private func setUp() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 4)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addSubview(rowStack)

        titleTrailingToSelfConstraint.isActive = true

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),

            rowStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            rowStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: 6),
            rowStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -14),
            rowStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }

    func configure(with appointment: UpcomingAppointment) {
        titleLabel.text = appointment.title
        participantRow.text = "\(appointment.participantCount)명"
        placeRow.text = appointment.location?.title ?? "미정"
        dateRow.text = appointment.date?.koreanDateTimeString ?? "미정"
    }

}
