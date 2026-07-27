//
//  PlaceSelectionViewController.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/27/26.
//

import UIKit

final class PlaceSelectionViewController: UIViewController {

    var onPlaceConfirmed: ((Place) -> Void)?

    // MARK: - Header

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "장소 선택"
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "지도를 움직여 장소를 선택해주세요"
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private lazy var closeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            pointSize: 17, weight: .medium
        )
        config.baseForegroundColor = .secondaryLabel
        config.background.backgroundColor = .secondarySystemFill
        config.background.cornerRadius = 22
        config.cornerStyle = .fixed

        let button = UIButton(configuration: config)
        button.addAction(UIAction { [weak self] _ in self?.closeTapped() }, for: .touchUpInside)
        return button
    }()

    // MARK: - Map (placeholder)

    private let mapPlaceholderView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemYellow
        return view
    }()

    // MARK: - Bottom Card

    private let bottomCard: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        return view
    }()

    private let placeNameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldPreferredFont(forTextStyle: .callout)
        label.textColor = .label
        label.text = "스타벅스 강남역점"
        return label
    }()

    private let placeAddressLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.text = "서울 강남구 테헤란로 124 1층"
        return label
    }()

    private let placeDistanceLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.text = "0.3km"
        return label
    }()

    private lazy var searchOtherPlaceButton: UIButton = {
        var config = UIButton.Configuration.filled()

        var attributedTitle = AttributedString("다른 장소 검색")
        attributedTitle.font = .preferredFont(forTextStyle: .footnote)
        config.attributedTitle = attributedTitle

        config.image = UIImage(systemName: "magnifyingglass")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            font: .preferredFont(forTextStyle: .footnote)
        )
        config.imagePlacement = .leading
        config.imagePadding = 8

        config.baseBackgroundColor = UIColor.blue2.withAlphaComponent(0.2)
        config.baseForegroundColor = .black
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 18, bottom: 0, trailing: 18)
        config.cornerStyle = .fixed
        config.background.cornerRadius = 12

        let button = UIButton(configuration: config)
        button.contentHorizontalAlignment = .leading

        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrowImageView.tintColor = .black
        arrowImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(
            font: .preferredFont(forTextStyle: .footnote)
        )
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(arrowImageView)

        NSLayoutConstraint.activate([
            arrowImageView.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -18),
            arrowImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            button.heightAnchor.constraint(equalToConstant: 37),
        ])

        return button
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton.filled(
            title: "확인", background: .blue2, tint: .white, font: .callout
        )
        button.configuration?.cornerStyle = .fixed
        button.configuration?.background.cornerRadius = 12
        button.heightAnchor.constraint(equalToConstant: 37).isActive = true
        button.addAction(UIAction { [weak self] _ in self?.confirmTapped() }, for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Action

    private func closeTapped() {
        presentingViewController?.dismiss(animated: true)
    }

    private func confirmTapped() {
        // TODO: ViewModel 도입 후 실제 선택된 Place로 교체
        let place = Place(
            id: "temp",
            name: placeNameLabel.text ?? "",
            address: placeAddressLabel.text ?? "",
            coordinate: Coordinate(latitude: 0, longitude: 0),
            type: .other
        )
        onPlaceConfirmed?(place)
        presentingViewController?.dismiss(animated: true)
    }

    // MARK: - Layout

    private func setUpLayout() {
        [titleLabel, subtitleLabel, closeButton, mapPlaceholderView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            mapPlaceholderView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            mapPlaceholderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapPlaceholderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        setUpBottomCard()
    }

    private func setUpBottomCard() {
        bottomCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomCard)

        NSLayoutConstraint.activate([
            mapPlaceholderView.bottomAnchor.constraint(equalTo: bottomCard.topAnchor),

            bottomCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomCard.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let infoStack = UIStackView(arrangedSubviews: [placeNameLabel, placeAddressLabel, placeDistanceLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 5

        let buttonStack = UIStackView(arrangedSubviews: [searchOtherPlaceButton, confirmButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = 9
        buttonStack.distribution = .fill

        let contentStack = UIStackView(arrangedSubviews: [infoStack, buttonStack])
        contentStack.axis = .vertical
        contentStack.spacing = 17
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        bottomCard.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: bottomCard.topAnchor, constant: 27),
            contentStack.leadingAnchor.constraint(equalTo: bottomCard.leadingAnchor, constant: 31),
            contentStack.trailingAnchor.constraint(equalTo: bottomCard.trailingAnchor, constant: -31),
            contentStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

}
