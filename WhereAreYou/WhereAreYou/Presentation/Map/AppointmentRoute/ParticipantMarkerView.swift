//
//  ParticipantMarkerView.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/31/26.
//

import UIKit

/// 참여자 지도 마커 이미지를 만들기 위한 렌더링 전용 뷰
enum ParticipantMarkerView {

    /// 실제 콘텐츠(아바타+이름) 영역의 높이
    /// 이 영역의 하단이 Marker가 가리키는 실제 좌표 지점
    private static let contentHeight: CGFloat = 60
    /// 하단 그림자가 잘리지 않도록 캔버스에 추가로 확보하는 여백
    private static let shadowMargin: CGFloat = 8

    private static let avatarDiameter: CGFloat = 40
    private static let borderWidth: CGFloat = 2.5
    private static let nameSpacing: CGFloat = 0

    static let size = CGSize(width: 44, height: contentHeight + shadowMargin)
    static let anchor = CGPoint(x: 0.5, y: contentHeight / size.height)

    static func renderImage(
        profileImage: UIImage?,
        nickname: String,
        tintColor: UIColor
    ) -> UIImage {
        let container = makeContainer(profileImage: profileImage, nickname: nickname, tintColor: tintColor)
        container.frame = CGRect(origin: .zero, size: size)
        container.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            container.drawHierarchy(in: container.bounds, afterScreenUpdates: true)
        }
    }

    private static func makeContainer(
        profileImage: UIImage?,
        nickname: String,
        tintColor: UIColor
    ) -> UIView {
        let container = UIView(frame: CGRect(origin: .zero, size: size))

        let avatar = UIImageView(image: profileImage)
        avatar.backgroundColor = .pointBackground
        avatar.contentMode = .scaleAspectFill
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = avatarDiameter / 2
        avatar.layer.borderWidth = borderWidth
        avatar.layer.borderColor = tintColor.cgColor
        avatar.frame = CGRect(
            x: (size.width - avatarDiameter) / 2,
            y: 0,
            width: avatarDiameter,
            height: avatarDiameter
        )
        container.addSubview(avatar)

        let nameBackground = UIView()
        nameBackground.backgroundColor = .systemBackground
        nameBackground.layer.cornerRadius = 4
        nameBackground.layer.shadowColor = UIColor.black.cgColor
        nameBackground.layer.shadowOpacity = 0.3
        nameBackground.layer.shadowOffset = CGSize(width: 0, height: 3)
        nameBackground.frame = CGRect(
            x: 0,
            y: avatarDiameter + nameSpacing,
            width: size.width,
            height: contentHeight - avatarDiameter - nameSpacing
        )
        container.addSubview(nameBackground)

        let nameLabel = UILabel()
        nameLabel.text = nickname
        nameLabel.font = .boldPreferredFont(forTextStyle: .caption2)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        nameLabel.frame = nameBackground.bounds
        nameBackground.addSubview(nameLabel)

        return container
    }

}
