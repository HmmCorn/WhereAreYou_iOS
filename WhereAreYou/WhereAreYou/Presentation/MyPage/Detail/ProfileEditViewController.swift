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
    private static let previewImageSize: CGFloat = 96

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

    private var selectedImageName: String {
        didSet { updatePreviewImage() }
    }
    private var nickname: String

    private let previewImageContainer: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 4
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        return view
    }()

    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .pointBackground
        imageView.tintColor = .blue2
        imageView.clipsToBounds = true
        return imageView
    }()

    private let nicknameField: UITextField = {
        let field = UITextField()
        field.font = .preferredFont(forTextStyle: .body)
        field.textAlignment = .center
        field.placeholder = "닉네임"
        field.backgroundColor = .white
        field.layer.cornerRadius = 12
        field.layer.shadowColor = UIColor.black.cgColor
        field.layer.shadowOpacity = 0.15
        field.layer.shadowRadius = 3
        field.layer.shadowOffset = CGSize(width: 0, height: 2)
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        field.leftViewMode = .always
        field.returnKeyType = .done
        field.enablesReturnKeyAutomatically = true
        return field
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
        setUpDismissKeyboardGesture()
        setUpActions()
        applySnapshot()
        updatePreviewImage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setUpLayout() {
        previewImageContainer.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        [nicknameField, collectionView, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.addSubview(previewImageContainer)
        previewImageContainer.addSubview(previewImageView)
        [nicknameField, collectionView, saveButton].forEach { view.addSubview($0) }

        NSLayoutConstraint.activate([
            previewImageContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            previewImageContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            previewImageContainer.widthAnchor.constraint(equalToConstant: Self.previewImageSize),
            previewImageContainer.heightAnchor.constraint(equalToConstant: Self.previewImageSize),

            previewImageView.topAnchor.constraint(equalTo: previewImageContainer.topAnchor),
            previewImageView.leadingAnchor.constraint(equalTo: previewImageContainer.leadingAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: previewImageContainer.trailingAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: previewImageContainer.bottomAnchor),

            nicknameField.topAnchor.constraint(equalTo: previewImageContainer.bottomAnchor, constant: 24),
            nicknameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nicknameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nicknameField.heightAnchor.constraint(equalToConstant: 40),

            collectionView.topAnchor.constraint(equalTo: nicknameField.bottomAnchor, constant: 24),
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
        section.interGroupSpacing = 20
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4)

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

    private func updatePreviewImage() {
        previewImageView.image = UIImage(named: selectedImageName) ?? UIImage(systemName: selectedImageName)
        previewImageView.layer.cornerRadius = Self.previewImageSize / 2
    }

    private func setUpDismissKeyboardGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        gesture.cancelsTouchesInView = false
        view.addGestureRecognizer(gesture)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

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
