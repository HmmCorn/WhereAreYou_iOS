//
//  SharedPlaceCell.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-03.
//

import UIKit

/// 공유된 장소 목록의 셀 — 장소 정보, 투표자 프로필, 투표 버튼
final class SharedPlaceCell: UIView {

    var onVoteTap: (() -> Void)?

    private static let profileSize: CGFloat = 35

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .label
        return label
    }()

    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        return label
    }()

    private let voterStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = -6
        stack.alignment = .leading
        return stack
    }()

    private let voteButton: UIButton

    init(item: SharedPlaceItem) {
        if item.hasVoted {
            self.voteButton = UIButton.filled(
                title: "투표 완료",
                background: .blue2,
                tint: .white,
                font: .footnote,
                edgeInsets: NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
            )
        } else {
            self.voteButton = UIButton.filled(
                title: "투표하기",
                background: .white,
                tint: .label,
                font: .footnote,
                edgeInsets: NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
            )
            self.voteButton.layer.borderWidth = 1
            self.voteButton.layer.borderColor = UIColor.separator.cgColor
        }
        super.init(frame: .zero)

        nameLabel.text = item.placeName
        addressLabel.text = item.placeAddress
        setUpVoterImages(item.voterProfileImages)
        setUpLayout()
        setUpActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpVoterImages(_ images: [String]) {
        for imageName in images {
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.contentMode = .scaleAspectFit
            imageView.layer.cornerRadius = Self.profileSize / 2
            imageView.clipsToBounds = true
            imageView.backgroundColor = .white
            imageView.layer.borderWidth = 1
            imageView.layer.borderColor = UIColor.separator.cgColor
            imageView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: Self.profileSize),
                imageView.heightAnchor.constraint(equalToConstant: Self.profileSize),
            ])

            voterStack.addArrangedSubview(imageView)
        }
    }

    private func setUpLayout() {
        let placeInfoStack = UIStackView(arrangedSubviews: [nameLabel, addressLabel])
        placeInfoStack.axis = .vertical
        placeInfoStack.spacing = 2
        placeInfoStack.alignment = .leading

        let leftStack = UIStackView(arrangedSubviews: [placeInfoStack, voterStack])
        leftStack.axis = .horizontal
        leftStack.spacing = 20

        let contentStack = UIStackView(arrangedSubviews: [leftStack, voteButton])
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.distribution = .equalCentering
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }

    private func setUpActions() {
        voteButton.addAction(UIAction { [weak self] _ in
            self?.onVoteTap?()
        }, for: .touchUpInside)
    }

}
