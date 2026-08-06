//
//  AppointmentInfoViewController.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-08-06.
//

import UIKit
import Combine

final class AppointmentInfoViewController: UIViewController {

    private let viewModel: AppointmentInfoViewModel
    private var cancellables = Set<AnyCancellable>()
    private var card: AppointmentInfoCard?

    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.alpha = 0
        return view
    }()

    init(viewModel: AppointmentInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setUpDimmingView()
        bindViewModel()
        viewModel.fetchAppointmentInfo()
    }

    private func setUpDimmingView() {
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimmingView)
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped))
        dimmingView.addGestureRecognizer(tapGesture)
    }

    @objc private func dimmingViewTapped() {
        dismissCard()
    }

    private func bindViewModel() {
        viewModel.$appointmentInfo
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] info in
                self?.showCard(with: info)
            }
            .store(in: &cancellables)
    }

    private func showCard(with info: AppointmentInfo) {
        card?.removeFromSuperview()

        let infoCard = AppointmentInfoCard(data: info)
        infoCard.alpha = 0
        infoCard.transform = CGAffineTransform(translationX: 0, y: 20)
        view.addSubview(infoCard)
        NSLayoutConstraint.activate([
            infoCard.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infoCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        infoCard.onClose = { [weak self] in self?.dismissCard() }
        infoCard.onCopyCodeTap = {
            UIPasteboard.general.string = info.code
        }

        card = infoCard

        UIView.animate(withDuration: 0.25) {
            self.dimmingView.alpha = 1
            infoCard.alpha = 1
            infoCard.transform = .identity
        }
    }

    private func dismissCard() {
        UIView.animate(withDuration: 0.2, animations: {
            self.dimmingView.alpha = 0
            self.card?.alpha = 0
            self.card?.transform = CGAffineTransform(translationX: 0, y: 20)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

}
