//
//  LocationPreviewViewController.swift
//  WhereAreYou
//
//  Created by 김성훈 on 9/16/26.
//

import UIKit

final class LocationPreviewViewController: UIViewController {

    private let previewTitle: String
    private let previewSubtitle: String?
    private let coordinate: Coordinate
    private let accentColor: ColorAsset

    init(title: String, subtitle: String?, coordinate: Coordinate, accentColor: ColorAsset) {
        self.previewTitle = title
        self.previewSubtitle = subtitle
        self.coordinate = coordinate
        self.accentColor = accentColor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Header

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
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

    // MARK: - Map

    private let mapView = LocationPreviewMapView(frame: .zero)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        titleLabel.text = previewTitle
        subtitleLabel.text = previewSubtitle
        subtitleLabel.isHidden = previewSubtitle == nil
        setUpLayout()
        mapView.setMarker(coordinate: coordinate, name: previewTitle, accentColor: accentColor.uiColor)
    }

    // MARK: - Action

    private func closeTapped() {
        presentingViewController?.dismiss(animated: true)
    }

    // MARK: - Layout

    private func setUpLayout() {
        [titleLabel, subtitleLabel, closeButton, mapView].forEach {
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

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            mapView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

}
