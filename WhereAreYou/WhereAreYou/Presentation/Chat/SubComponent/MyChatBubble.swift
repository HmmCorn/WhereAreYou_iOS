//
//  MyChatBubble.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-30.
//

import UIKit

/// '내'가 보낸 채팅 버블
final class MyChatBubble: ChatBubbleBase {

    override init(item: ChatBubbleItem) {
        super.init(item: item)

        bubbleContainer.backgroundColor = .blue2.withAlphaComponent(0.8)
        bubbleLabel.textColor = .white

        if let actionButton {
            actionButton.tintColor = .white
            addressLabel?.textColor = .white
        }

        let rowStack = UIStackView(arrangedSubviews: [timeLabel, bubbleContainer])
        rowStack.axis = .horizontal
        rowStack.alignment = .bottom
        rowStack.spacing = 4
        rowStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(rowStack)

        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: topAnchor),
            rowStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            rowStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            rowStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 60),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
