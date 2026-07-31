//
//  MapMarkerView.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/31/26.
//

import UIKit

/// 지도 마커 이미지를 만들기 위한 렌더링 전용 뷰
enum MapMarkerView {

    enum Kind {
        case participant(profileImage: UIImage?, tintColor: UIColor)
        case place
    }

    // MARK: - Public

    static func size(for kind: Kind) -> CGSize {
        let iconHeight = iconSize(for: kind).height
        return CGSize(
            width: contentWidth(for: kind),
            height: iconHeight + nameSpacing + nameBackgroundHeight + shadowMargin
        )
    }

    static func anchor(for kind: Kind) -> CGPoint {
        let size = size(for: kind)
        return CGPoint(x: 0.5, y: iconSize(for: kind).height / size.height)
    }

    static func renderImage(kind: Kind, name: String) -> UIImage {
        let size = size(for: kind)
        let container = makeContainer(kind: kind, name: name, size: size)
        container.frame = CGRect(origin: .zero, size: size)
        container.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            container.drawHierarchy(in: container.bounds, afterScreenUpdates: true)
        }
    }

}

// MARK: - Private

private extension MapMarkerView {

    // MARK: - Constants

    /// 하단 그림자가 잘리지 않도록 캔버스에 추가로 확보하는 여백
    static let shadowMargin: CGFloat = 8
    /// 아이콘과 이름 배경 사이 간격
    static let nameSpacing: CGFloat = 0
    /// 이름 배경 높이
    static let nameBackgroundHeight: CGFloat = 22

    // MARK: - Helpers

    static func iconSize(for kind: Kind) -> CGSize {
        switch kind {
        case .participant: return CGSize(width: 40, height: 40)
        case .place: return CGSize(width: 42, height: 42)
        }
    }

    static func contentWidth(for kind: Kind) -> CGFloat {
        switch kind {
        case .participant: return 44
        case .place: return 100
        }
    }

    static func nameFont(for kind: Kind) -> UIFont {
        switch kind {
        case .participant: return .boldPreferredFont(forTextStyle: .caption2)
        case .place: return .boldPreferredFont(forTextStyle: .caption1)
        }
    }

    // MARK: - View Building

    static func makeContainer(kind: Kind, name: String, size: CGSize) -> UIView {
        let container = UIView(frame: CGRect(origin: .zero, size: size))
        let iconSize = iconSize(for: kind)

        let iconView = makeIconView(kind: kind, size: iconSize)
        iconView.frame = CGRect(
            x: (size.width - iconSize.width) / 2,
            y: 0,
            width: iconSize.width,
            height: iconSize.height
        )
        container.addSubview(iconView)

        let nameBackground = UIView()
        nameBackground.backgroundColor = .systemBackground
        nameBackground.layer.cornerRadius = 4
        nameBackground.layer.shadowColor = UIColor.black.cgColor
        nameBackground.layer.shadowOpacity = 0.3
        nameBackground.layer.shadowOffset = CGSize(width: 0, height: 3)
        nameBackground.frame = CGRect(
            x: 0,
            y: iconSize.height + nameSpacing,
            width: size.width,
            height: nameBackgroundHeight
        )
        container.addSubview(nameBackground)

        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = nameFont(for: kind)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.frame = nameBackground.bounds.insetBy(dx: 4, dy: 0)
        nameBackground.addSubview(nameLabel)

        return container
    }

    static func makeIconView(kind: Kind, size: CGSize) -> UIView {
        switch kind {
        case .participant(let profileImage, let tintColor):
            let circleView = UIView()
            circleView.backgroundColor = .pointBackground
            circleView.clipsToBounds = true
            circleView.layer.cornerRadius = size.width / 2
            circleView.layer.borderWidth = 2.5
            circleView.layer.borderColor = tintColor.cgColor

            let inset = size.width * 0.15
            let avatar = UIImageView(image: profileImage)
            avatar.contentMode = .scaleAspectFit
            avatar.frame = CGRect(
                x: inset,
                y: inset,
                width: size.width - inset * 2,
                height: size.height - inset * 2
            )
            circleView.addSubview(avatar)

            return circleView

        case .place:
            let pinImageView = UIImageView(image: .pin)
            pinImageView.contentMode = .scaleAspectFit
            return pinImageView
        }
    }

}
