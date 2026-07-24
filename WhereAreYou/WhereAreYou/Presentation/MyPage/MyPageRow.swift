//
//  MyPageRow.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/24/26.
//

import UIKit

// MARK: - 마이페이지 설정 카드 내부의 행 하나
//       - 아이콘 + (제목/현재값) + 우측 액세서리(기본은 chevron, 필요 시 외부에서 교체)

final class MyPageRow: UIControl {

    var onTap: (() -> Void)?

    var value: String? {
        get { valueLabel.text }
        set { valueLabel.text = newValue }
    }

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()

    private let defaultAccessoryView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .tertiaryLabel
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconView, textStack, defaultAccessoryView])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()

    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.isUserInteractionEnabled = false
        return stack
    }()

    init(
        icon: UIImage?,
        title: String,
        isCircularImage: Bool = false,
        accessoryView: UIView? = nil,
        accessoryHasOwnInteraction: Bool = false
    ) {
        super.init(frame: .zero)

        iconView.image = icon
        iconView.contentMode = isCircularImage ? .scaleAspectFill : .scaleAspectFit
        iconView.tintColor = .label
        iconView.clipsToBounds = isCircularImage
        iconView.isUserInteractionEnabled = false

        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .caption1)
        titleLabel.textColor = .secondaryLabel

        valueLabel.font = .preferredFont(forTextStyle: .callout)
        valueLabel.textColor = .label

        setUp(accessoryView: accessoryView, accessoryHasOwnInteraction: accessoryHasOwnInteraction)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(icon:title:isCircularImage:accessoryView:accessoryHasOwnInteraction:)")
    }

    private func setUp(accessoryView: UIView?, accessoryHasOwnInteraction: Bool) {
        let iconSize: CGFloat = 22
        iconView.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: iconSize).isActive = true
        iconView.layer.cornerRadius = iconView.clipsToBounds ? iconSize / 2 : 0

        if let accessoryView {
            contentStack.removeArrangedSubview(defaultAccessoryView)
            defaultAccessoryView.removeFromSuperview()
            contentStack.addArrangedSubview(accessoryView)
            contentStack.isUserInteractionEnabled = accessoryHasOwnInteraction
        } else {
            defaultAccessoryView.widthAnchor.constraint(equalToConstant: 14).isActive = true
            contentStack.isUserInteractionEnabled = false
        }

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])

        addAction(UIAction { [weak self] _ in self?.onTap?() }, for: .touchUpInside)
    }

}
