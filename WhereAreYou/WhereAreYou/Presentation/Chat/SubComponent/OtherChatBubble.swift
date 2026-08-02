//
//  OtherChatBubble.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-30.
//

import UIKit

/// 상대방이 보낸 채팅 버블
final class OtherChatBubble: ChatBubbleBase {

    private static let avatarSize: CGFloat = 30

    init(item: ChatBubbleItem, showProfile: Bool) {
        super.init(item: item)

        bubbleContainer.backgroundColor = .systemGray3
        bubbleLabel.textColor = .label

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            container.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -60),
        ])

        let bubbleRow = UIStackView(arrangedSubviews: [bubbleContainer, timeLabel])
        bubbleRow.axis = .horizontal
        bubbleRow.alignment = .bottom
        bubbleRow.spacing = 4

        if showProfile {
            let avatarView = makeAvatarView(imageName: item.senderProfileImage)

            let nameLabel = UILabel()
            nameLabel.text = item.senderNickname
            nameLabel.font = .preferredFont(forTextStyle: .caption1)
            nameLabel.textColor = .secondaryLabel

            let profileRow = UIStackView(arrangedSubviews: [avatarView, nameLabel])
            profileRow.axis = .horizontal
            profileRow.alignment = .center
            profileRow.spacing = 6

            let columnStack = UIStackView(arrangedSubviews: [profileRow, bubbleRow])
            columnStack.axis = .vertical
            columnStack.spacing = 3
            columnStack.alignment = .leading
            columnStack.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(columnStack)
            NSLayoutConstraint.activate([
                columnStack.topAnchor.constraint(equalTo: container.topAnchor),
                columnStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                columnStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                columnStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ])
        } else {
            bubbleRow.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(bubbleRow)
            NSLayoutConstraint.activate([
                bubbleRow.topAnchor.constraint(equalTo: container.topAnchor),
                bubbleRow.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                bubbleRow.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                bubbleRow.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ])
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeAvatarView(imageName: String) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = Self.avatarSize / 2
        imageView.clipsToBounds = true
        imageView.backgroundColor = .pointBackground
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: Self.avatarSize),
            imageView.heightAnchor.constraint(equalToConstant: Self.avatarSize),
        ])

        return imageView
    }

}
