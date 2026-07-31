//
//  ParticipantRouteRow.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/31/26.
//

import UIKit

/// info 영역 참여자 리스트의 가로형 한 줄 (색상닷 + 이름 + 출발시간 + 이동수단 + 도착예정시간)
final class ParticipantRouteRow: UIView {

    init(participant: AppointmentRouteParticipant, color: UIColor) {
        super.init(frame: .zero)
        setUp(participant: participant, color: color)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp(participant: AppointmentRouteParticipant, color: UIColor) {
        let dot = UIView()
        dot.backgroundColor = color
        dot.layer.cornerRadius = 4
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: 8).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 8).isActive = true

        let nameLabel = UILabel()
        nameLabel.text = participant.nickname
        nameLabel.font = .boldPreferredFont(forTextStyle: .subheadline)

        let departureLabel = UILabel()
        departureLabel.text = "\(participant.departureTimeText) 출발"
        departureLabel.font = .preferredFont(forTextStyle: .caption1)
        departureLabel.textColor = .secondaryLabel

        let leadingStack = UIStackView(arrangedSubviews: [dot, nameLabel])
        leadingStack.axis = .horizontal
        leadingStack.spacing = 6
        leadingStack.alignment = .center

        let leadingColumn = UIStackView(arrangedSubviews: [leadingStack, departureLabel])
        leadingColumn.axis = .vertical
        leadingColumn.spacing = 2
        leadingColumn.alignment = .leading

        let transportIcon = UIImageView(image: UIImage(systemName: participant.transportType.icon))
        transportIcon.tintColor = participant.transportType.color
        transportIcon.contentMode = .scaleAspectFit
        transportIcon.translatesAutoresizingMaskIntoConstraints = false
        transportIcon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        transportIcon.heightAnchor.constraint(equalToConstant: 16).isActive = true

        let transportLabel = UILabel()
        transportLabel.text = participant.transportType.name
        transportLabel.font = .preferredFont(forTextStyle: .caption1)
        transportLabel.textColor = .secondaryLabel

        let transportStack = UIStackView(arrangedSubviews: [transportIcon, transportLabel])
        transportStack.axis = .horizontal
        transportStack.spacing = 4
        transportStack.alignment = .center

        let arrivalLabel = UILabel()
        arrivalLabel.text = participant.arrivalTimeText
        arrivalLabel.font = .boldPreferredFont(forTextStyle: .subheadline)
        arrivalLabel.textAlignment = .right

        let trailingColumn = UIStackView(arrangedSubviews: [transportStack, arrivalLabel])
        trailingColumn.axis = .vertical
        trailingColumn.spacing = 2
        trailingColumn.alignment = .trailing

        let mainStack = UIStackView(arrangedSubviews: [leadingColumn, UIView(), trailingColumn])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

}
