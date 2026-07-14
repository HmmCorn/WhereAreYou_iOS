//
//  ParticipantBox.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import UIKit

// MARK: - ParticipantBox (인원 섹션의 아바타 한 칸)

final class ParticipantBox: UIView {

    private static let avatarSize: CGFloat = 35

    init(member: Participant) {
        super.init(frame: .zero)

        let avatar = UIImageView(image: UIImage(named: member.profileImage.rawValue))
        avatar.backgroundColor = .pointBackground
        avatar.layer.cornerRadius = Self.avatarSize / 2
        avatar.clipsToBounds = true
        avatar.contentMode = .scaleAspectFit
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.widthAnchor.constraint(equalToConstant: Self.avatarSize).isActive = true
        avatar.heightAnchor.constraint(equalToConstant: Self.avatarSize).isActive = true

        let nameLabel = UILabel()
        nameLabel.text = member.nickname
        nameLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        nameLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [avatar, nameLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
