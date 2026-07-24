//
//  AppointmentListCard.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/21/26.
//

import UIKit

// MARK: - 약속 목록 / 지난 약속 화면의 약속 카드
//       - 제목 + 인원/장소/날짜 3줄 + 대화 열기·지도 열기 버튼으로 구성
//       - 짧게 탭했을 땐 카드 자체는 반응하지 않고 대화/지도 버튼만 반응
//       - 꾹 눌렀을 땐 카드 전체가 반응해 컨텍스트 메뉴(알림 토글/약속 나가기)를 표시
//       - 오른쪽 상단 액세서리는 외부에서 주입

final class AppointmentListCard: AppointmentCardBase {

    var onChatTap: (() -> Void)?
    var onMapTap: (() -> Void)?
    var contextMenuProvider: (() -> UIMenu)?

    private lazy var chatButton: UIButton = {
        let button = UIButton.filled(
            title: "대화 열기",
            background: .blue2.withAlphaComponent(0.8),
            tint: .white,
            font: .preferredFont(forTextStyle: .caption1)
        )
        button.configuration?.image = UIImage(systemName: "text.bubble")
        button.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            font: .preferredFont(forTextStyle: .caption1)
        )
        button.configuration?.cornerStyle = .fixed
        button.configuration?.background.cornerRadius = 8
        button.configuration?.imagePlacement = .leading
        button.configuration?.imagePadding = 6
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
        return button
    }()

    private lazy var mapButton: UIButton = {
        let button = UIButton.filled(
            title: "지도 열기",
            background: .blue2.withAlphaComponent(0.8),
            tint: .white,
            font: .preferredFont(forTextStyle: .caption1)
        )
        button.configuration?.image = UIImage(systemName: "map")
        button.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            font: .preferredFont(forTextStyle: .caption1)
        )
        button.configuration?.cornerStyle = .fixed
        button.configuration?.background.cornerRadius = 8
        button.configuration?.imagePlacement = .leading
        button.configuration?.imagePadding = 6
        button.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
        return button
    }()

    init(item: AppointmentListItem, accessoryView: UIView?) {
        super.init(
            participantCount: item.participantCount,
            placeText: item.location?.title ?? "미정",
            dateText: item.date?.appointmentDateTimeText ?? "미정",
            title: item.title,
            accessoryView: accessoryView
        )
        setUpButtons()
        setUpContextMenu()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(item:accessoryView:)")
    }

    private func setUpButtons() {
        let buttonStack = UIStackView(arrangedSubviews: [chatButton, mapButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 8
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonStack)

        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: rowStack.bottomAnchor, constant: 10),
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            buttonStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])

        chatButton.addAction(UIAction { [weak self] _ in self?.onChatTap?() }, for: .touchUpInside)
        mapButton.addAction(UIAction { [weak self] _ in self?.onMapTap?() }, for: .touchUpInside)
    }

    private func setUpContextMenu() {
        addInteraction(UIContextMenuInteraction(delegate: self))
    }

}

// MARK: - UIContextMenuInteractionDelegate

extension AppointmentListCard: UIContextMenuInteractionDelegate {

    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(actionProvider: { [weak self] _ in self?.contextMenuProvider?() })
    }

}
