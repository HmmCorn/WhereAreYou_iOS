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

    /// 대표 멤버가 바뀌는 전환의 중간 프레임 렌더링 — progress 0은 from, 1은 to와 같은 이미지
    static func renderTransitionFrame(from: UIImage, to: UIImage, progress: CGFloat) -> UIImage {
        if progress <= 0 { return from }
        if progress >= 1 { return to }

        let imageRect = CGRect(origin: .zero, size: size)
        let avatarRect = CGRect(x: (size.width - iconSize) / 2, y: 0, width: iconSize, height: iconSize)
        let nameRect = CGRect(x: 0, y: iconSize, width: size.width, height: size.height - iconSize)
        let nameFade = min(max((progress - nameFadeRange.lowerBound) / (nameFadeRange.upperBound - nameFadeRange.lowerBound), 0), 1)

        return UIGraphicsImageRenderer(size: size).image { context in
            let cgContext = context.cgContext

            // 프로필 원 — 원형 창 안에서 이전 원은 왼쪽 위로 밀려나고 새 원은 오른쪽 아래에서 들어옴
            cgContext.saveGState()
            cgContext.addEllipse(in: avatarRect)
            cgContext.clip()
            for (image, step) in [(from, progress), (to, progress - 1)] {
                guard let avatar = croppedAvatar(of: image, in: avatarRect) else { continue }
                let movedRect = avatarRect.offsetBy(dx: slideOffset.width * step, dy: slideOffset.height * step)
                cgContext.saveGState()
                cgContext.addEllipse(in: movedRect.insetBy(dx: -0.5, dy: -0.5))
                cgContext.clip()
                avatar.draw(in: movedRect)
                cgContext.restoreGState()
            }
            cgContext.restoreGState()

            // 이름 영역 — 전환 중간에서만 교차 페이드, 더하기 합성이라 두 이름 배경이 겹쳐도 투명해지지 않음
            cgContext.saveGState()
            cgContext.clip(to: nameRect)
            from.draw(in: imageRect, blendMode: .normal, alpha: 1 - nameFade)
            to.draw(in: imageRect, blendMode: .plusLighter, alpha: nameFade)
            cgContext.restoreGState()
        }
    }

    /// 이동시켜도 이름 영역과 그 그림자가 딸려 들어오지 않도록 프로필 원 부분만 잘라낸 이미지
    private static func croppedAvatar(of image: UIImage, in rect: CGRect) -> UIImage? {
        let scale = image.scale
        let pixelRect = CGRect(x: rect.minX * scale, y: rect.minY * scale, width: rect.width * scale, height: rect.height * scale)
        return image.cgImage?.cropping(to: pixelRect).map { UIImage(cgImage: $0, scale: scale, orientation: .up) }
    }

    // MARK: - Constants

    private static let contentWidth: CGFloat = 100
    private static let iconSize: CGFloat = 40
    private static let nameBackgroundHeight: CGFloat = 22
    private static let shadowMargin: CGFloat = 8
    /// 이전 원이 창 밖으로 밀려나는 이동량 — 왼쪽 위 방향으로 원 지름 + 간격
    private static let slideOffset = CGSize(width: -(iconSize + 8) * 0.86, height: -(iconSize + 8) * 0.5)
    /// 이름 영역이 교차 페이드되는 진행 구간 — 짧게만 겹쳐 글자 번짐을 줄임
    private static let nameFadeRange: ClosedRange<CGFloat> = 0.35...0.65

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
