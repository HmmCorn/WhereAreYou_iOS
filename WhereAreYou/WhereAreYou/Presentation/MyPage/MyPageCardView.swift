//
//  MyPageCardView.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/25/26.
//

import UIKit

// MARK: - 마이페이지 설정 카드의 배경/그림자만 담당하는 얇은 컨테이너
//       - 헤더 없이 MyPageRow들을 세로로 쌓아 넣는 용도

final class MyPageCardView: UIView {

    let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

    init() {
        super.init(frame: .zero)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init()")
    }

    private func setUp() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 4)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

}
