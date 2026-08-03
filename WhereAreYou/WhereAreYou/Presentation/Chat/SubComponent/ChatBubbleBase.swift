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

    private let bubbleContentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption2)
        label.textColor = .secondaryLabel
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    /// contentType에 따라 생성되는 액션 버튼 — 서브클래스에서 tintColor 등 설정
    private(set) var actionButton: UIButton?
    private(set) var addressLabel: UILabel?
    private(set) var duplicateLabel: UILabel?

    init(item: ChatBubbleItem) {
        super.init(frame: .zero)

        bubbleLabel.text = item.content
        bubbleContainer.layer.cornerRadius = Self.bubbleCornerRadius
        bubbleContainer.translatesAutoresizingMaskIntoConstraints = false

        bubbleContentStack.translatesAutoresizingMaskIntoConstraints = false
        bubbleContainer.addSubview(bubbleContentStack)

        NSLayoutConstraint.activate([
            bubbleContentStack.topAnchor.constraint(equalTo: bubbleContainer.topAnchor, constant: Self.bubblePadding.top),
            bubbleContentStack.leadingAnchor.constraint(equalTo: bubbleContainer.leadingAnchor, constant: Self.bubblePadding.left),
            bubbleContentStack.trailingAnchor.constraint(equalTo: bubbleContainer.trailingAnchor, constant: -Self.bubblePadding.right),
            bubbleContentStack.bottomAnchor.constraint(equalTo: bubbleContainer.bottomAnchor, constant: -Self.bubblePadding.bottom),
        ])

        bubbleContentStack.addArrangedSubview(bubbleLabel)

        switch item.contentType {
        case .text:
            break
        case .locationShare:
            bubbleLabel.font = .boldPreferredFont(forTextStyle: .footnote)
            actionButton = makeMapButton()
            bubbleContentStack.addArrangedSubview(actionButton!)
        case .placeShare(let placeName, let placeAddress, let isDuplicate):
            bubbleLabel.text = "📌 " + placeName
            bubbleLabel.font = .boldPreferredFont(forTextStyle: .callout)
            addressLabel = UILabel()
            addressLabel?.text = placeAddress
            addressLabel?.font = .preferredFont(forTextStyle: .caption1)
            addressLabel?.numberOfLines = 0
            bubbleContentStack.addArrangedSubview(addressLabel!)
            if isDuplicate {
                duplicateLabel = UILabel()
                duplicateLabel?.text = "이미 공유된 장소"
                duplicateLabel?.font = .preferredFont(forTextStyle: .caption2)
                duplicateLabel?.textColor = .secondaryLabel
                bubbleContentStack.addArrangedSubview(duplicateLabel!)
            }
            actionButton = makeMapButton()
            bubbleContentStack.addArrangedSubview(actionButton!)
        }

        timeLabel.text = item.timeText
        timeLabel.isHidden = item.timeText == nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeMapButton() -> UIButton {
        var config = UIButton.Configuration.plain()
        var attributedTitle = AttributedString("위치 보기")
        attributedTitle.font = .preferredFont(forTextStyle: .caption1)
        config.attributedTitle = attributedTitle
        config.image = UIImage(systemName: "map", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11))
        config.imagePadding = 4
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)

        let button = UIButton(configuration: config)
        button.backgroundColor = .white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 12
        button.addAction(UIAction { _ in
            // TODO: 공유된 위치를 중심으로 한 지도 화면 열기
        }, for: .touchUpInside)
        return button
    }

}
