//
//  HomeViewController.swift
//  WhereAreYou
//
//  Created by 김성훈 on 7/16/26.
//

import UIKit

final class HomeViewController: UIViewController {

    private static let cardSpacing: CGFloat = 16

    private let viewModel: HomeViewModel
    weak var coordinator: HomeCoordinating?

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented — use init(viewModel:)")
    }

    // MARK: - Logo

    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Logo"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let logoTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "어딘데"
        label.font = .boldPreferredFont(forTextStyle: .title2)
        label.textColor = .blue1
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    // MARK: - Action buttons

    private let createButton: UIButton = {
        let button = UIButton.filled(
            title: "약속 만들기", background: .blue2, tint: .white, font: .headline
        )
        button.configuration?.image = UIImage(systemName: "calendar.and.person")
        button.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            font: .preferredFont(forTextStyle: .title2)
        ).applying(UIImage.SymbolConfiguration(weight: .bold))
        button.configuration?.imagePlacement = .leading
        button.configuration?.imagePadding = 32

        button.heightAnchor.constraint(equalToConstant: 73).isActive = true
        button.layer.borderWidth = 3
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 20

        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowRadius = 2
        button.layer.shadowOffset = CGSize(width: 0, height: 4)

        return button
    }()

    private let joinButton: UIButton = {
        let button = UIButton.filled(
            title: "약속 참여하기", background: .white, tint: .blue2, font: .headline
        )
        button.configuration?.image = UIImage(systemName: "person.line.dotted.person.fill")
        button.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            font: .preferredFont(forTextStyle: .title2)
        ).applying(UIImage.SymbolConfiguration(weight: .bold))
        button.configuration?.imagePlacement = .leading
        button.configuration?.imagePadding = 22

        button.heightAnchor.constraint(equalToConstant: 73).isActive = true
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.blue2.cgColor
        button.layer.cornerRadius = 20

        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowRadius = 2
        button.layer.shadowOffset = CGSize(width: 0, height: 4)

        return button
    }()

    // MARK: - Upcoming appointment section

    private let upcomingSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "얼마 남지 않은 약속"
        label.font = .preferredFont(forTextStyle: .callout)
        label.textColor = .secondaryLabel
        return label
    }()

    private let upcomingScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private let upcomingStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = HomeViewController.cardSpacing
        return stack
    }()

    // MARK: - Join sheet

    private var joinSheetOverlay: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpLayout()
        setUpActions()
        setUpUpcomingCards()
    }

    private func setUpLayout() {
        upcomingScrollView.delegate = self

        [logoImageView, logoTitleLabel, createButton,
         joinButton, upcomingSectionLabel, upcomingScrollView]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview($0)
            }

        upcomingStack.translatesAutoresizingMaskIntoConstraints = false
        upcomingScrollView.addSubview(upcomingStack)

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 43),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 119),
            logoImageView.heightAnchor.constraint(equalToConstant: 74),

            logoTitleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor),
            logoTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            createButton.topAnchor.constraint(equalTo: logoTitleLabel.bottomAnchor, constant: 60),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            joinButton.topAnchor.constraint(equalTo: createButton.bottomAnchor, constant: 45),
            joinButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            joinButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            upcomingSectionLabel.topAnchor.constraint(
                greaterThanOrEqualTo: joinButton.bottomAnchor, constant: 32
            ),
            upcomingSectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

            upcomingScrollView.topAnchor.constraint(equalTo: upcomingSectionLabel.bottomAnchor),
            upcomingScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            upcomingScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            upcomingScrollView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60
            ),

            upcomingStack.topAnchor.constraint(equalTo: upcomingScrollView.contentLayoutGuide.topAnchor, constant: 16),
            upcomingStack.leadingAnchor.constraint(equalTo: upcomingScrollView.contentLayoutGuide.leadingAnchor, constant: 40),
            upcomingStack.trailingAnchor.constraint(equalTo: upcomingScrollView.contentLayoutGuide.trailingAnchor, constant: -40),
            upcomingStack.bottomAnchor.constraint(equalTo: upcomingScrollView.contentLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func setUpActions() {
        createButton.addAction(UIAction { [weak self] _ in
            self?.presentAppointmentCreation()
        }, for: .touchUpInside)

        joinButton.addAction(UIAction { [weak self] _ in
            self?.presentJoinSheet()
        }, for: .touchUpInside)
    }

    private func setUpUpcomingCards() {
        let appointments = viewModel.upcomingAppointments
        let cards = appointments.map { UpcomingAppointmentCard(appointment: $0) }

        zip(cards, appointments).forEach { card, appointment in
            card.onTap = { [weak self] in
                self?.presentChat(appointmentID: appointment.id)
            }
            upcomingStack.addArrangedSubview(card)
            card.widthAnchor.constraint(equalTo: createButton.widthAnchor).isActive = true
        }

        if let firstCard = cards.first {
            upcomingScrollView.heightAnchor.constraint(
                equalTo: firstCard.heightAnchor, constant: 32
            ).isActive = true
        }
    }

    // MARK: - Appointment Creation

    private func presentAppointmentCreation() {
        coordinator?.showAppointmentCreation()
    }

    // MARK: - Join sheet

    private func presentJoinSheet() {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        overlay.translatesAutoresizingMaskIntoConstraints = false

        let sheet = JoinAppointmentSheet()
        sheet.onCancel = { [weak self] in self?.dismissJoinSheet() }
        sheet.onJoin = { [weak self] code in
            self?.joinAppointment(code: code)
        }

        overlay.addSubview(sheet)
        view.addSubview(overlay)
        joinSheetOverlay = overlay

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            sheet.leadingAnchor.constraint(equalTo: overlay.leadingAnchor, constant: 24),
            sheet.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -24),
            sheet.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        ])
    }

    private func dismissJoinSheet() {
        joinSheetOverlay?.removeFromSuperview()
        joinSheetOverlay = nil
    }

    private func joinAppointment(code: String) {
        viewModel.joinAppointment(code: code) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let appointmentInfo):
                    self.dismissJoinSheet()
                    self.presentChat(appointmentInfo: appointmentInfo)
                case .failure:
                    self.presentJoinFailureAlert()
                }
            }
        }
    }

    private func presentJoinFailureAlert() {
        let alert = UIAlertController(
            title: "약속을 찾을 수 없어요",
            message: "코드를 다시 확인해 주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Chat

    private func presentChat(appointmentID: String) {
        coordinator?.showChat(appointmentID: appointmentID)
    }

    private func presentChat(appointmentInfo: AppointmentInfo) {
        coordinator?.showChat(appointmentInfo: appointmentInfo)
    }

}

// MARK: - UIScrollViewDelegate

extension HomeViewController: UIScrollViewDelegate {

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        // 카드 하나가 차지하는 가로 폭(카드 너비 + 카드 사이 간격)
        let cardStride: CGFloat = createButton.bounds.width + Self.cardSpacing

        // 관성 스크롤이 원래 멈추려던 지점(targetContentOffset.x)이
        // 카드 몇 개째 지점에 해당하는지를 소수로 계산
        let rawIndex = targetContentOffset.pointee.x / cardStride

        // 소수점 인덱스를 가장 가까운 정수로 반올림해서, "몇 번째 카드"로 스냅할지 결정
        let roundedIndex = round(rawIndex)

        // 반올림된 카드 인덱스에 cardStride를 다시 곱해서,
        // 실제로 스크롤이 멈춰야 할 x좌표(카드 경계)로 되돌림
        targetContentOffset.pointee.x = roundedIndex * cardStride
    }

}
