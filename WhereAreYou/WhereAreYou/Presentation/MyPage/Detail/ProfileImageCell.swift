//
//  ProfileImageCell.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/25/26.
//

import UIKit

// MARK: - 프로필 사진 선택 화면의 이미지 한 칸
//       - 선택된 셀은 테두리로 강조

final class ProfileImageCell: UICollectionViewCell {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .pointBackground
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = contentView.bounds.width / 2
    }

    override var isSelected: Bool {
        didSet { updateSelectionAppearance() }
    }

    func configure(imageName: String) {
        imageView.image = UIImage(named: imageName) ?? UIImage(systemName: imageName)
        imageView.tintColor = .blue2
    }

    private func setUp() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        updateSelectionAppearance()
    }

    private func updateSelectionAppearance() {
        imageView.layer.borderWidth = isSelected ? 3 : 0
        imageView.layer.borderColor = UIColor.blue1.cgColor
    }

}
