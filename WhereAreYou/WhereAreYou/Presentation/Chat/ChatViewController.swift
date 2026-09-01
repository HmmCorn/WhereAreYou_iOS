//
//  ChatViewController.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-30.
//

@preconcurrency import UIKit
import Combine

/// 채팅 화면 — 메시지 스크롤, 입력바, 키보드 처리, 하위 화면 조합
final class ChatViewController: UIViewController {

    // MARK: - Spacing
    /// 나<->친구 간 전환: 20pt / 친구<->친구(다른 사람) 전환: 10pt
    /// 동일 발신자, 분 단위 구분: 10pt / 동일 발신자, 같은 분: 5pt

    private static let horizontalPadding: CGFloat = 16
    private static let differentSenderSpacing: CGFloat = 20
    private static let differentSenderWithProfileSpacing: CGFloat = 10
    private static let sameMinuteSpacing: CGFloat = 10
    private static let sameSenderSpacing: CGFloat = 5
    private static let inputBarHorizontalPadding: CGFloat = 10
    private static let inputBarButtonSize: CGFloat = 36
    private static let inputBarBottomSpacing: CGFloat = -10

    // MARK: - Dependencies

    private let viewModel: ChatViewModel
    private var cancellables = Set<AnyCancellable>()
    private var hasLoadedInitialMessages = false

    // MARK: - Chat collection view

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.showsVerticalScrollIndicator = true
        cv.alwaysBounceVertical = true
        cv.keyboardDismissMode = .interactive
        cv.backgroundColor = .clear
        cv.contentInset.bottom = 16
        cv.register(ChatBubbleCell.self, forCellWithReuseIdentifier: ChatBubbleCell.reuseID)
        return cv
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, ChatDisplayItem> = {
        UICollectionViewDiffableDataSource<Int, ChatDisplayItem>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChatBubbleCell.reuseID,
                for: indexPath
            ) as! ChatBubbleCell
            let spacing = self?.topSpacing(at: indexPath.item) ?? 0
            cell.configure(with: item, topSpacing: spacing) { [weak self] _ in
                self?.presentAppointmentRoute()
            }
            return cell
        }
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "첫 메시지를 보내보세요!"
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        collectionView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: collectionView.frameLayoutGuide.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: collectionView.frameLayoutGuide.centerYAnchor),
        ])
        return label
    }()

    // MARK: - Input bar

    private let inputBarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.06
        view.layer.shadowRadius = 16
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        return view
    }()

    private let extraFeatureButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        button.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
        button.tintColor = .label
        return button
    }()

    private let messageTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "내용 입력..."
        tf.font = .preferredFont(forTextStyle: .subheadline)
        tf.backgroundColor = .systemBackground
        tf.layer.cornerRadius = 18
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        tf.rightViewMode = .always
        tf.returnKeyType = .send
        tf.enablesReturnKeyAutomatically = true
        return tf
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        button.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: config), for: .normal)
        button.tintColor = .label
        button.isEnabled = false
        return button
    }()

    // MARK: - Keyboard

    private var inputBarBottomConstraint: NSLayoutConstraint!

    // MARK: - Init

    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .pointBackground
        setUpNavigationBar()
        setUpLayout()
        setUpActions()
        bindViewModel()
        viewModel.fetchMessages()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    // MARK: - Navigation Bar

    private func setUpNavigationBar() {
        title = viewModel.appointmentInfo.title
        navigationItem.largeTitleDisplayMode = .always

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .pointBackground
        appearance.shadowColor = .separator
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance

        let mapItem = UIBarButtonItem(
            image: UIImage(systemName: "map"),
            style: .plain,
            target: self,
            action: #selector(mapButtonTapped)
        )
        let moreItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(moreButtonTapped)
        )
        mapItem.tintColor = .label
        moreItem.tintColor = .label
        navigationItem.rightBarButtonItems = [moreItem, mapItem]
    }

    @objc private func mapButtonTapped() {
        presentAppointmentRoute()
    }

    private func presentAppointmentRoute() {
        let routeViewModel = AppointmentRouteViewModel(
            appointmentID: viewModel.appointmentInfo.id,
            getAppointmentDetailUseCase: GetAppointmentDetailUseCase(
                repository: DIContainer.shared.resolve(AppointmentDetailRepository.self)
            )
        )
        present(AppointmentRouteViewController(viewModel: routeViewModel), animated: true)
    }

    @objc private func moreButtonTapped() {
        let repository = DIContainer.shared.resolve(AppointmentInfoRepository.self)
        let fetchUseCase = FetchAppointmentInfoUseCase(repository: repository)
        let updateUseCase = UpdateAppointmentInfoUseCase(repository: repository)
        let appointmentInfoVM = AppointmentInfoViewModel(
            appointmentID: viewModel.appointmentInfo.id,
            fetchAppointmentInfoUseCase: fetchUseCase,
            updateAppointmentInfoUseCase: updateUseCase
        )
        let appointmentInfoVC = AppointmentInfoViewController(viewModel: appointmentInfoVM)
        present(appointmentInfoVC, animated: false)
    }

    // MARK: - Layout

    private func setUpLayout() {
        [collectionView, inputBarContainer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [extraFeatureButton, messageTextField, sendButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            inputBarContainer.addSubview($0)
        }

        inputBarBottomConstraint = inputBarContainer.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: Self.inputBarBottomSpacing
        )

        NSLayoutConstraint.activate([
            // Collection view
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: inputBarContainer.topAnchor),

            // Input bar container
            inputBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Self.inputBarHorizontalPadding),
            inputBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Self.inputBarHorizontalPadding),
            inputBarBottomConstraint,

            // Extra feature button
            extraFeatureButton.leadingAnchor.constraint(equalTo: inputBarContainer.leadingAnchor, constant: Self.inputBarHorizontalPadding),
            extraFeatureButton.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
            extraFeatureButton.widthAnchor.constraint(equalToConstant: Self.inputBarButtonSize),
            extraFeatureButton.heightAnchor.constraint(equalToConstant: Self.inputBarButtonSize),

            // Text field
            messageTextField.leadingAnchor.constraint(equalTo: extraFeatureButton.trailingAnchor, constant: 6),
            messageTextField.topAnchor.constraint(equalTo: inputBarContainer.topAnchor, constant: 8),
            messageTextField.bottomAnchor.constraint(equalTo: inputBarContainer.bottomAnchor, constant: -8),
            messageTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: Self.inputBarButtonSize),

            // Send button
            sendButton.leadingAnchor.constraint(equalTo: messageTextField.trailingAnchor, constant: 6),
            sendButton.trailingAnchor.constraint(equalTo: inputBarContainer.trailingAnchor, constant: -Self.inputBarHorizontalPadding),
            sendButton.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: Self.inputBarButtonSize),
            sendButton.heightAnchor.constraint(equalToConstant: Self.inputBarButtonSize),
        ])
    }

    // MARK: - Actions

    private func setUpActions() {
        extraFeatureButton.menu = makeExtraFeatureMenu()
        extraFeatureButton.showsMenuAsPrimaryAction = true

        sendButton.addAction(UIAction { [weak self] _ in
            self?.handleSend()
        }, for: .touchUpInside)

        messageTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        messageTextField.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    private func makeExtraFeatureMenu() -> UIMenu {
        let shareLocation = UIAction(
            title: "내 위치 공유하기",
            image: UIImage(systemName: "location")
        ) { [weak self] _ in
            self?.handleShareLocation()
        }

        let searchPlace = UIAction(
            title: "모일 장소 검색하기",
            image: UIImage(systemName: "magnifyingglass")
        ) { [weak self] _ in
            self?.handleSearchPlace()
        }

        let viewSharedPlaces = UIAction(
            title: "공유된 장소 모아보기",
            image: UIImage(systemName: "list.bullet")
        ) { [weak self] _ in
            self?.handleViewSharedPlaces()
        }

        return UIMenu(children: [viewSharedPlaces, searchPlace, shareLocation])
    }

    // MARK: - Extra Feature Handlers

    private func handleShareLocation() {
        viewModel.fetchCurrentLocation { [weak self] coordinate, address in
            let confirmVC = ShareMyLocationViewController(address: address)
            confirmVC.onConfirm = {
                self?.viewModel.shareLocation(coordinate: coordinate)
            }
            self?.present(confirmVC, animated: true)
        }
    }

    private func handleSearchPlace() {
        let searchPlacesUseCase = SearchPlacesUseCase(repository: DIContainer.shared.resolve(PlaceSearchRepository.self))
        let searchPlaceCardVM = SearchPlaceCardViewModel(searchPlacesUseCase: searchPlacesUseCase)
        let shareMeVC = SearchPlaceCardViewController(
            viewModel: searchPlaceCardVM,
            selectionButtonTitle: "공유하기",
            style: .onlyHeader(title: "모일 장소 검색하기")
        )

        shareMeVC.onPlaceSelected = { [weak self] place in
            self?.viewModel.sharePlace(place)
        }

        if let sheet = shareMeVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(shareMeVC, animated: true)
    }

    private func handleViewSharedPlaces() {
        let sharedPlaceRepo = DIContainer.shared.resolve(SharedPlaceRepository.self)
        let fetchUseCase = FetchSharedPlacesUseCase(repository: sharedPlaceRepo)
        let voteUseCase = VotePlaceUseCase(repository: sharedPlaceRepo)
        let sharedPlacesVM = SharedPlacesViewModel(
            appointmentID: viewModel.appointmentInfo.id,
            currentUserID: ChatViewModel.currentUserID,
            fetchSharedPlacesUseCase: fetchUseCase,
            votePlaceUseCase: voteUseCase
        )
        let sharedPlacesVC = SharedPlacesViewController(viewModel: sharedPlacesVM)

        if let sheet = sharedPlacesVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(sharedPlacesVC, animated: true)
    }

    @objc private func textFieldDidChange() {
        viewModel.updateCanSend(text: messageTextField.text ?? "")
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func handleSend() {
        guard let text = messageTextField.text, !text.isEmpty else { return }
        viewModel.sendMessage(text)
        messageTextField.text = ""
        viewModel.updateCanSend(text: "")
    }

    // MARK: - Keyboard handling

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let info = notification.userInfo,
              let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        let keyboardHeight = keyboardFrame.height - view.safeAreaInsets.bottom
        inputBarBottomConstraint.constant = -keyboardHeight + Self.inputBarBottomSpacing

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let info = notification.userInfo,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        inputBarBottomConstraint.constant = Self.inputBarBottomSpacing

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - ViewModel binding

    private func bindViewModel() {
        viewModel.$displayItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.updateChatUI(items: items)
            }
            .store(in: &cancellables)

        viewModel.$isEmpty
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                guard let self else { return }
                if isEmpty {
                    emptyLabel.isHidden = false
                } else if emptyLabel.superview != nil {
                    emptyLabel.isHidden = true
                }
            }
            .store(in: &cancellables)

        viewModel.$canSend
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canSend in
                self?.sendButton.isEnabled = canSend
                self?.sendButton.tintColor = canSend ? .label : .tertiaryLabel
            }
            .store(in: &cancellables)
    }

    // MARK: - Update UI

    private func updateChatUI(items: [ChatDisplayItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, ChatDisplayItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(items)

        let isInitialLoad = !hasLoadedInitialMessages
        hasLoadedInitialMessages = true

        dataSource.apply(snapshot, animatingDifferences: !isInitialLoad) { [weak self] in
            self?.scrollToBottom(animated: !isInitialLoad)
        }
    }

    private func scrollToBottom(animated: Bool) {
        let itemCount = collectionView.numberOfItems(inSection: 0)
        guard itemCount > 0 else { return }
        let lastIndexPath = IndexPath(item: itemCount - 1, section: 0)
        collectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: animated)
    }

    /// 직전 메시지와의 관계에 따라 버블 상단 간격을 결정한다.
    /// - 나 ↔ 친구 전환: 20pt  /  친구 ↔ 친구(다른 사람) 전환: 10pt
    /// - 동일 발신자, 분이 다르면: 10pt  /  같은 분이면: 5pt
    private func topSpacing(at index: Int) -> CGFloat {
        let items = viewModel.displayItems
        guard index > 0 else { return 0 }

        let current = items[index]
        let previous = items[index - 1]

        if current.senderID != previous.senderID {
            return current.isMe != previous.isMe
                ? Self.differentSenderSpacing
                : Self.differentSenderWithProfileSpacing
        }

        let sameMinute = Calendar.current.isDate(current.sentAt, equalTo: previous.sentAt, toGranularity: .minute)
        return sameMinute ? Self.sameSenderSpacing : Self.sameMinuteSpacing
    }

    // MARK: - Layout

    private func makeLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 16, leading: Self.horizontalPadding,
            bottom: 0, trailing: Self.horizontalPadding
        )
        section.interGroupSpacing = 0

        return UICollectionViewCompositionalLayout { _, _ in section }
    }

}

// MARK: - UITextFieldDelegate

extension ChatViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return false
    }

}


