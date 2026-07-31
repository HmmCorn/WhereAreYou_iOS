//
//  ParticipantRouteRow.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/31/26.
//

import UIKit

/// info 영역 참여자 리스트의 가로형 한 줄
final class ParticipantRouteRow: UIView {

    private static let avatarDiameter: CGFloat = 40

    init(participant: AppointmentRouteParticipant) {
        super.init(frame: .zero)
        setUp(participant: participant)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUp(participant: AppointmentRouteParticipant) {
        let avatar = UIImageView(image: UIImage(named: participant.profileImageURL.host ?? ""))
        avatar.backgroundColor = .pointBackground
        avatar.contentMode = .scaleAspectFill
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = Self.avatarDiameter / 2
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.widthAnchor.constraint(equalToConstant: Self.avatarDiameter).isActive = true
        avatar.heightAnchor.constraint(equalToConstant: Self.avatarDiameter).isActive = true

        let nameLabel = UILabel()
        nameLabel.text = participant.nickname
        nameLabel.font = .boldPreferredFont(forTextStyle: .subheadline)

        let departureLabel = UILabel()
        departureLabel.text = "\(participant.departureTimeText) 출발"
        departureLabel.font = .preferredFont(forTextStyle: .caption1)
        departureLabel.textColor = .secondaryLabel

        let nameColumn = UIStackView(arrangedSubviews: [nameLabel, departureLabel])
        nameColumn.axis = .vertical
        nameColumn.spacing = 2
        nameColumn.alignment = .leading

        let transportIcon = UIImageView(image: UIImage(systemName: participant.transportType.icon))
        transportIcon.tintColor = participant.transportType.color
        transportIcon.contentMode = .scaleAspectFit
        transportIcon.translatesAutoresizingMaskIntoConstraints = false
        transportIcon.widthAnchor.constraint(equalToConstant: 16).isActive = true
        transportIcon.heightAnchor.constraint(equalToConstant: 16).isActive = true

        let transportLabel = UILabel()
        transportLabel.text = participant.transportType.name
        transportLabel.font = .preferredFont(forTextStyle: .caption1)
        transportLabel.textColor = participant.transportType.color

        let transportStack = UIStackView(arrangedSubviews: [transportIcon, transportLabel])
        transportStack.axis = .horizontal
        transportStack.spacing = 4
        transportStack.alignment = .center

        let arrivalLabel = UILabel()
        arrivalLabel.text = participant.arrivalTimeText
        arrivalLabel.font = .boldPreferredFont(forTextStyle: .subheadline)
        arrivalLabel.textAlignment = .center

        let arrivalCaptionLabel = UILabel()
        arrivalCaptionLabel.text = "도착 예정"
        arrivalCaptionLabel.font = .preferredFont(forTextStyle: .caption2)
        arrivalCaptionLabel.textColor = .secondaryLabel
        arrivalCaptionLabel.textAlignment = .center

        let arrivalColumn = UIStackView(arrangedSubviews: [arrivalLabel, arrivalCaptionLabel])
        arrivalColumn.axis = .vertical
        arrivalColumn.spacing = 2
        arrivalColumn.alignment = .center

        let mainStack = UIStackView(arrangedSubviews: [avatar, nameColumn, UIView(), transportStack, arrivalColumn])
        mainStack.axis = .horizontal
        mainStack.spacing = 10
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
