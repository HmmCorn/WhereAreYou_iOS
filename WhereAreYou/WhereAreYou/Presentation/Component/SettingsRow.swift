//
//  SettingsRow.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/24/26.
//

import UIKit

// MARK: - 마이페이지 설정 카드 내부의 행 하나
//       - 아이콘 + (제목/현재값) + 우측 액세서리(기본은 chevron, 필요 시 외부에서 교체)
//       - 액세서리로 UISwitch를 넣으면, 행을 탭했을 때는 반응하지 않고 스위치를 직접 눌러야만 반응

final class SettingsRow: UIControl {

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
        stack.spacing = 2
        stack.isUserInteractionEnabled = false
        return stack
    }()

    init(icon: UIImage?, title: String, accessoryView: UIView? = nil) {
        super.init(frame: .zero)

        iconView.image = icon
        iconView.tintColor = .label
        iconView.contentMode = .scaleAspectFit
        iconView.isUserInteractionEnabled = false

        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .caption1)
        titleLabel.textColor = .secondaryLabel

        valueLabel.font = .preferredFont(forTextStyle: .body)
        valueLabel.textColor = .label

        setUp(accessoryView: accessoryView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(icon:title:accessoryView:)")
    }

    override var isHighlighted: Bool {
        didSet { updateHighlightAppearance() }
    }

    private func setUp(accessoryView: UIView?) {
        let iconSize: CGFloat = 22
        iconView.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: iconSize).isActive = true

        if let accessoryView {
            contentStack.removeArrangedSubview(defaultAccessoryView)
            defaultAccessoryView.removeFromSuperview()
            contentStack.addArrangedSubview(accessoryView)
        } else {
            defaultAccessoryView.widthAnchor.constraint(equalToConstant: 14).isActive = true
        }

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.isUserInteractionEnabled = true
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

    private func updateHighlightAppearance() {
        UIView.animate(withDuration: 0.12) {
            self.backgroundColor = self.isHighlighted ? UIColor.systemGray6 : .clear
        }
    }

}
