//
//  ParticipantMarkerView.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/31/26.
//

import UIKit

/// 참여자 지도 마커 이미지를 만들기 위한 렌더링 전용 뷰
enum ParticipantMarkerView {

    static let size = CGSize(width: 44, height: 60)

    private static let avatarDiameter: CGFloat = 40
    private static let borderWidth: CGFloat = 2.5

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

        let nameLabel = UILabel()
        nameLabel.text = nickname
        nameLabel.font = .boldPreferredFont(forTextStyle: .caption2)
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        nameLabel.frame = CGRect(
            x: 0,
            y: avatarDiameter + 2,
            width: size.width,
            height: size.height - avatarDiameter - 2
        )
        container.addSubview(nameLabel)

        return container
    }

}
