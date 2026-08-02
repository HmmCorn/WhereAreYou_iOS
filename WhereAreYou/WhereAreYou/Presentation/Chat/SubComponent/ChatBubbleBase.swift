//
//  ChatBubbleBase.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-30.
//

import UIKit

/// 채팅 버블 view의 공통점을 담은 상위 view
class ChatBubbleBase: UIView {

    static let bubbleCornerRadius: CGFloat = 16
    static let bubblePadding = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

    let bubbleContainer = UIView()

    let bubbleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        return label
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption2)
        label.textColor = .secondaryLabel
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    init(item: ChatBubbleItem) {
        super.init(frame: .zero)

        bubbleLabel.text = item.content
        bubbleContainer.layer.cornerRadius = Self.bubbleCornerRadius
        bubbleContainer.translatesAutoresizingMaskIntoConstraints = false

        bubbleLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleContainer.addSubview(bubbleLabel)

        NSLayoutConstraint.activate([
            bubbleLabel.topAnchor.constraint(equalTo: bubbleContainer.topAnchor, constant: Self.bubblePadding.top),
            bubbleLabel.leadingAnchor.constraint(equalTo: bubbleContainer.leadingAnchor, constant: Self.bubblePadding.left),
            bubbleLabel.trailingAnchor.constraint(equalTo: bubbleContainer.trailingAnchor, constant: -Self.bubblePadding.right),
            bubbleLabel.bottomAnchor.constraint(equalTo: bubbleContainer.bottomAnchor, constant: -Self.bubblePadding.bottom),
        ])

        timeLabel.text = item.timeText
        timeLabel.isHidden = item.timeText == nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
