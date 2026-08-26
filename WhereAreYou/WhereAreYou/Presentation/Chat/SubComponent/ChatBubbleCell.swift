//
//  ChatBubbleCell.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-06.
//

import UIKit

/// MyChatBubble / OtherChatBubble을 UICollectionViewCell로 래핑
final class ChatBubbleCell: UICollectionViewCell {

    static let reuseID = "ChatBubbleCell"

    func configure(
        with item: ChatDisplayItem,
        topSpacing: CGFloat,
        onMapTap: ((Coordinate) -> Void)? = nil
    ) {
        contentView.subviews.forEach { $0.removeFromSuperview() }

        let bubbleView: ChatBubbleBase
        switch item {
        case .myMessage(let bubble):
            bubbleView = MyChatBubble(item: bubble)
        case .otherMessage(let bubble, let showProfile):
            bubbleView = OtherChatBubble(item: bubble, showProfile: showProfile)
        }
        bubbleView.onMapTap = onMapTap

        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleView)

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: topSpacing),
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

}
