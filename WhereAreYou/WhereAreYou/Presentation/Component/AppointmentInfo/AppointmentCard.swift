//
//  AppointmentCard.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-14.
//

import UIKit

final class AppointmentCard: UIView {

    // MARK: - Public callbacks

    var onClose: (() -> Void)?
    var onDateRowTap: (() -> Void)?
    var onPlaceRowTap: (() -> Void)?
    var onMapButtonTap: (() -> Void)?
    var onNameChanged: ((String) -> Void)?
    var onCreateTap: (() -> Void)?
    var onLeaveTap: (() -> Void)?
    var onCopyCodeTap: (() -> Void)?

    let mode: AppointmentCardMode

    /// 전체 컴포넌트 스택
    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 15
        return stack
    }()

    // MARK: - Header

    private let closeButton: UIButton = {
        let button = UIButton(type: .close)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .label
        button.isHidden = true
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        return label
    }()

    // MARK: - Common fields

    private let nameField = TextFieldRow(
        icon: UIImage(systemName: "tag"),
        placeholder: "약속"
    )
    private let dateRow = ButtonRow(
        icon: UIImage(systemName: "calendar"),
        placeholder: "날짜와 시간을 선택해주세요."
    )
    private let placeRow = ButtonRow(
        icon: UIImage(systemName: "location.circle"),
        placeholder: "장소를 선택해주세요."
    )

    private let mapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "map"), for: .normal)
        button.tintColor = .blue2
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.separator.cgColor
        button.layer.cornerRadius = 12
        return button
    }()

    private lazy var placeRowContainer: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [placeRow, mapButton])
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .fill
        return stack
    }()

    private lazy var mainInfoBox: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            labeledSection(title: "약속 이름", content: nameField),
            labeledSection(title: "날짜 및 시간", content: dateRow),
            labeledSection(title: "장소", content: placeRowContainer),
            memberSection
        ])
        stack.axis = .vertical
        stack.spacing = 15
        return stack
    }()

    // MARK: - Create-only section

    private lazy var createButton = makeFooterButton(
        title: "생성하기",
        background: .blue2,
        tint: .white
    )

    // MARK: - Info-only sections

    private let memberSectionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        return label
    }()

    private let memberStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .top
        return stack
    }()

    private lazy var memberSection: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [memberSectionLabel, memberStack])
        stack.axis = .vertical
        stack.spacing = 3
        stack.alignment = .leading
        return stack
    }()

    private let codeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.layer.opacity = 0.6
        label.textAlignment = .center
        return label
    }()

    private lazy var leaveButton = makeFooterButton(
        title: "약속 나가기",
        background: .customRed.withAlphaComponent(0.8),
        tint: .white
    )
    private lazy var copyButton = makeFooterButton(
        title: "코드 복사하기",
        background: .systemGray2,
        tint: .white
    )

    private let footerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.distribution = .fillEqually
        return stack
    }()

    /// info 모드에서만 보여야 하는 서브뷰 목록
    private lazy var infoOnlyViews: [UIView] = [memberSection, codeLabel, footerStack]

    // MARK: - Init

    init(mode: AppointmentCardMode) {
        self.mode = mode
        super.init(frame: .zero)
        setUpLayout()
        setUpActions()
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(mode:name:dateText:placeText:)")
    }

    // MARK: Layout

    private func setUpLayout() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 16
        layer.shadowOffset = CGSize(width: 0, height: 4)

        let headerContainer = UIView()
        headerContainer.addSubview(closeButton)
        headerContainer.addSubview(titleLabel)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            closeButton.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 28),
            closeButton.heightAnchor.constraint(equalToConstant: 28),
            titleLabel.centerXAnchor.constraint(equalTo: headerContainer.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerContainer.centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor)
        ])

        mapButton.widthAnchor.constraint(equalToConstant: 45).isActive = true

        footerStack.addArrangedSubview(leaveButton)
        footerStack.addArrangedSubview(copyButton)

        contentStack.addArrangedSubview(headerContainer)
        contentStack.addArrangedSubview(mainInfoBox)
        contentStack.addArrangedSubview(codeLabel)
        contentStack.addArrangedSubview(createButton)
        contentStack.addArrangedSubview(footerStack)

        contentStack.setCustomSpacing(25, after: headerContainer)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }

    private func labeledSection(title: String, content: UIView) -> UIView {
        let label = UILabel()
        label.text = title
        label.font = UIFont.preferredFont(forTextStyle: .footnote)

        let stack = UIStackView(arrangedSubviews: [label, content])
        stack.axis = .vertical
        stack.spacing = 3
        return stack
    }

    private func makeFooterButton(title: String, background: UIColor?, tint: UIColor) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = background
        config.baseForegroundColor = tint
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        return UIButton(configuration: config)
    }

    // MARK: - Action

    private func setUpActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        mapButton.addTarget(self, action: #selector(mapTapped), for: .touchUpInside)
        leaveButton.addTarget(self, action: #selector(leaveTapped), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(copyTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        dateRow.onTap = { [weak self] in self?.onDateRowTap?() }
        placeRow.onTap = { [weak self] in self?.onPlaceRowTap?() }
        nameField.onTextChanged = { [weak self] text in self?.onNameChanged?(text) }

        // 텍스트필드 편집 중 카드의 다른 영역을 탭하면 키보드를 내림
        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardGesture.cancelsTouchesInView = false
        dismissKeyboardGesture.delegate = self
        addGestureRecognizer(dismissKeyboardGesture)
    }

    @objc private func closeTapped() { onClose?() }
    @objc private func mapTapped() { onMapButtonTap?() }
    @objc private func leaveTapped() { onLeaveTap?() }
    @objc private func copyTapped() { onCopyCodeTap?() }
    @objc private func createTapped() { onCreateTap?() }
    @objc private func dismissKeyboard() { endEditing(true) }

    // MARK: - Configuration

    private func configure() {

        switch mode {
        case .create:
            titleLabel.text = "약속 만들기"
            nameField.text = "약속"
            closeButton.isHidden = true
            createButton.isHidden = false
            infoOnlyViews.forEach { $0.isHidden = true }
            contentStack.setCustomSpacing(20, after: mainInfoBox)

        case .info(let data):
            titleLabel.text = "약속 정보"
            closeButton.isHidden = false
            createButton.isHidden = true
            infoOnlyViews.forEach { $0.isHidden = false }

            memberSectionLabel.text = "인원 (\(data.participants.count)명)"
            data.participants.forEach { member in
                memberStack.addArrangedSubview(ParticipantBox(member: member))
            }
            codeLabel.text = "약속 코드 : \(data.code)"
        }
    }

}

// MARK: - UIGestureRecognizerDelegate

extension AppointmentCard: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        !(touch.view is UITextField)
    }
}
