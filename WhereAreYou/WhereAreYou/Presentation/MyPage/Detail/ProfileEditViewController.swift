//
//  ProfileEditViewController.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/25/26.
//

import UIKit

final class ProfileEditViewController: UIViewController {

    var onProfileSaved: ((_ nickname: String, _ profileImageName: String) -> Void)?

    private static let profileImageCellSize: CGFloat = 90

    private static let availableProfileImageNames: [String] = {
        let assetImageNames = ["shark", "turtle"]
        let symbolImageNames = [
            "pawprint.fill", "tortoise.fill", "hare.fill", "bird.fill", "fish.fill",
            "ladybug.fill", "ant.fill", "lizard.fill", "cat.fill", "dog.fill",
            "bee.fill", "butterfly.fill", "leaf.fill", "pawprint", "tortoise",
            "hare", "bird", "fish", "ladybug", "ant"
        ]
        return assetImageNames + symbolImageNames
    }()

    private var selectedImageName: String
    private var nickname: String

    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        return label
    }()

    private let nicknameField: UITextField = {
        let field = UITextField()
        field.font = .preferredFont(forTextStyle: .body)
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.separator.cgColor
        field.layer.cornerRadius = 12
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        field.leftViewMode = .always
        field.returnKeyType = .done
        return field
    }()

    private let profileImageSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "프로필 사진"
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        return collectionView
    }()

    private let cellRegistration = UICollectionView.CellRegistration<ProfileImageCell, String> { cell, _, imageName in
        cell.configure(imageName: imageName)
    }

    private lazy var saveButton = UIButton.filled(
        title: "저장",
        background: .blue1,
        tint: .white,
        font: .body
    )

    private lazy var dataSource = makeDataSource()

    init(nickname: String, profileImageName: String) {
        self.nickname = nickname
        self.selectedImageName = profileImageName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(nickname:profileImageName:)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "프로필 편집"
        view.backgroundColor = .systemBackground
        nicknameField.text = nickname
        nicknameField.delegate = self
        setUpLayout()
        setUpActions()
        applySnapshot()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setUpLayout() {
        [nicknameLabel, nicknameField, profileImageSectionLabel, collectionView, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            nicknameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nicknameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            nicknameField.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 6),
            nicknameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nicknameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nicknameField.heightAnchor.constraint(equalToConstant: 40),

            profileImageSectionLabel.topAnchor.constraint(equalTo: nicknameField.bottomAnchor, constant: 24),
            profileImageSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            collectionView.topAnchor.constraint(equalTo: profileImageSectionLabel.bottomAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -16),

            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func makeCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let columns = 3

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(Self.profileImageCellSize),
            heightDimension: .absolute(Self.profileImageCellSize)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(Self.profileImageCellSize)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: columns)
        group.interItemSpacing = .flexible(0)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Int, String> {
        let cellRegistration = cellRegistration
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, imageName in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: imageName)
        }
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(Self.availableProfileImageNames, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: false)

        if let selectedIndex = Self.availableProfileImageNames.firstIndex(of: selectedImageName) {
            collectionView.selectItem(
                at: IndexPath(item: selectedIndex, section: 0),
                animated: false,
                scrollPosition: []
            )
        }
    }

    private func setUpActions() {
        saveButton.addAction(UIAction { [weak self] _ in
            self?.saveProfile()
        }, for: .touchUpInside)
    }

    private func saveProfile() {
        let trimmedNickname = nicknameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmedNickname.isEmpty else { return }

        onProfileSaved?(trimmedNickname, selectedImageName)
        navigationController?.popViewController(animated: true)
    }

}

// MARK: - UICollectionViewDelegate

extension ProfileEditViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImageName = Self.availableProfileImageNames[indexPath.item]
    }

}

// MARK: - UITextFieldDelegate

extension ProfileEditViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
