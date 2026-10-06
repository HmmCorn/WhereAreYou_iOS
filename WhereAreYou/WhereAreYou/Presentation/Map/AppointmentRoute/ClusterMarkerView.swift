//
//  ClusterMarkerView.swift
//  WhereAreYou
//
//  Created by 김성훈 on 10/6/26.
//

import UIKit

/// 겹친 참여자 마커를 대신하는 클러스터 마커 이미지의 렌더링 소스 뷰
final class ClusterMarkerView: UIView {

    /// 클러스터에 속한 참여자의 표시 정보
    struct Member {
        let nickname: String
        let profileImage: UIImage
        let tintColor: UIColor
    }

    /// 마커 전체 크기
    static let size = CGSize(width: contentWidth, height: iconSize + nameBackgroundHeight + shadowMargin)
    /// 지도 좌표가 놓이는 비율 — 프로필 원 하단 중앙
    static let anchor = CGPoint(x: 0.5, y: iconSize / size.height)

    /// 지도 마커 아이콘으로 쓸 이미지 렌더링
    static func renderImage(members: [Member], memberIndex: Int) -> UIImage {
        let view = ClusterMarkerView(members: members, memberIndex: memberIndex)
        view.layoutIfNeeded()
        return UIGraphicsImageRenderer(size: size).image { context in
            view.layer.render(in: context.cgContext)
        }
    }

    // MARK: - Constants

    private static let contentWidth: CGFloat = 100
    private static let iconSize: CGFloat = 40
    private static let nameBackgroundHeight: CGFloat = 22
    private static let shadowMargin: CGFloat = 8

    // MARK: - Subviews

    private let avatarCircleView: UIView = {
        let view = UIView()
        view.backgroundColor = .pointBackground
        view.clipsToBounds = true
        view.layer.cornerRadius = ClusterMarkerView.iconSize / 2
        view.layer.borderWidth = 2.5
        return view
    }()

    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let nameBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 4
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: 3)
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldPreferredFont(forTextStyle: .caption2)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .boldPreferredFont(forTextStyle: .caption2)
        label.textColor = .label
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    // MARK: - Init

    private init(members: [Member], memberIndex: Int) {
        super.init(frame: CGRect(origin: .zero, size: Self.size))
        setUp()
        configure(with: members, memberIndex: memberIndex)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: - Private

private extension ClusterMarkerView {

    func setUp() {
        let nameStack = UIStackView(arrangedSubviews: [nameLabel, countLabel])
        nameStack.axis = .horizontal
        nameStack.spacing = 3

        avatarCircleView.addSubview(avatarImageView)
        nameBackgroundView.addSubview(nameStack)
        [avatarCircleView, nameBackgroundView].forEach { addSubview($0) }
        [avatarCircleView, avatarImageView, nameBackgroundView, nameStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let imageInset = Self.iconSize * 0.15
        NSLayoutConstraint.activate([
            avatarCircleView.topAnchor.constraint(equalTo: topAnchor),
            avatarCircleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarCircleView.widthAnchor.constraint(equalToConstant: Self.iconSize),
            avatarCircleView.heightAnchor.constraint(equalToConstant: Self.iconSize),

            avatarImageView.topAnchor.constraint(equalTo: avatarCircleView.topAnchor, constant: imageInset),
            avatarImageView.leadingAnchor.constraint(equalTo: avatarCircleView.leadingAnchor, constant: imageInset),
            avatarImageView.trailingAnchor.constraint(equalTo: avatarCircleView.trailingAnchor, constant: -imageInset),
            avatarImageView.bottomAnchor.constraint(equalTo: avatarCircleView.bottomAnchor, constant: -imageInset),

            nameBackgroundView.topAnchor.constraint(equalTo: avatarCircleView.bottomAnchor),
            nameBackgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            nameBackgroundView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            nameBackgroundView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            nameBackgroundView.heightAnchor.constraint(equalToConstant: Self.nameBackgroundHeight),

            nameStack.leadingAnchor.constraint(equalTo: nameBackgroundView.leadingAnchor, constant: 6),
            nameStack.trailingAnchor.constraint(equalTo: nameBackgroundView.trailingAnchor, constant: -6),
            nameStack.centerYAnchor.constraint(equalTo: nameBackgroundView.centerYAnchor),
        ])
    }

    /// memberIndex 멤버 기준으로 표시
    func configure(with members: [Member], memberIndex: Int) {
        guard members.indices.contains(memberIndex) else { return }
        let member = members[memberIndex]

        avatarImageView.image = member.profileImage
        avatarCircleView.layer.borderColor = member.tintColor.cgColor
        nameLabel.text = member.nickname
        countLabel.text = "외 \(members.count - 1)명"
        countLabel.isHidden = members.count < 2
    }

}
