//
//  ChatViewController.swift
//  WhereAreYou
//
//  Created by 이상유 on 2026-07-30.
//

import UIKit
import Combine

final class ChatViewController: UIViewController {

    // MARK: - Spacing

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

    // MARK: - Chat scroll area

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .interactive
        return sv
    }()

    private let chatStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
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

    private let searchPlaceButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        button.setImage(UIImage(systemName: "magnifyingglass", withConfiguration: config), for: .normal)
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
        // TODO: 지도 화면으로 전환
    }

    @objc private func moreButtonTapped() {
        // TODO: 약속 수정 화면 표시
    }

    // MARK: - Layout

    private func setUpLayout() {
        [scrollView, inputBarContainer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        chatStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(chatStack)

        [searchPlaceButton, messageTextField, sendButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            inputBarContainer.addSubview($0)
        }

        inputBarBottomConstraint = inputBarContainer.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: Self.inputBarBottomSpacing
        )

        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: inputBarContainer.topAnchor),

            // Chat stack inside scroll
            chatStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            chatStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: Self.horizontalPadding),
            chatStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -Self.horizontalPadding),
            chatStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            chatStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -Self.horizontalPadding * 2),

            // Input bar container
            inputBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Self.inputBarHorizontalPadding),
            inputBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Self.inputBarHorizontalPadding),
            inputBarBottomConstraint,

            // Search place button
            searchPlaceButton.leadingAnchor.constraint(equalTo: inputBarContainer.leadingAnchor, constant: Self.inputBarHorizontalPadding),
            searchPlaceButton.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
            searchPlaceButton.widthAnchor.constraint(equalToConstant: Self.inputBarButtonSize),
            searchPlaceButton.heightAnchor.constraint(equalToConstant: Self.inputBarButtonSize),

            // Text field
            messageTextField.leadingAnchor.constraint(equalTo: searchPlaceButton.trailingAnchor, constant: 6),
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
        searchPlaceButton.addAction(UIAction { _ in
            // TODO: 장소 검색 화면 표시
        }, for: .touchUpInside)

        sendButton.addAction(UIAction { [weak self] _ in
            self?.handleSend()
        }, for: .touchUpInside)

        messageTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        messageTextField.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        scrollView.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
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
        scrollToBottom(animated: true)
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
        chatStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, item) in items.enumerated() {
            let bubbleView: UIView

            switch item {
            case .myMessage(let bubble):
                bubbleView = MyChatBubble(item: bubble)
            case .otherMessage(let bubble, let showProfile):
                bubbleView = OtherChatBubble(item: bubble, showProfile: showProfile)
            }

            chatStack.addArrangedSubview(bubbleView)

            if index < items.count - 1 {
                let spacing = calculateSpacing(current: item, next: items[index + 1])
                chatStack.setCustomSpacing(spacing, after: bubbleView)
            }
        }

        scrollToBottom(animated: false)
    }

    private func calculateSpacing(current: ChatDisplayItem, next: ChatDisplayItem) -> CGFloat {
        if current.senderID != next.senderID {
            if current.isMe != next.isMe {
                return Self.differentSenderSpacing
            }
            return Self.differentSenderWithProfileSpacing
        }

        let sameMinute = Calendar.current.isDate(current.sentAt, equalTo: next.sentAt, toGranularity: .minute)
        return sameMinute ? Self.sameSenderSpacing : Self.sameMinuteSpacing
    }

    private func scrollToBottom(animated: Bool) {
        DispatchQueue.main.async {
            let bottomOffset = CGPoint(
                x: 0,
                y: max(0, self.scrollView.contentSize.height - self.scrollView.bounds.height + self.scrollView.contentInset.bottom)
            )
            self.scrollView.setContentOffset(bottomOffset, animated: animated)
        }
    }

}

// MARK: - UITextFieldDelegate

extension ChatViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return false
    }

}

// MARK: - UIGestureRecognizerDelegate

extension ChatViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        let location = touch.location(in: view)
        let inputBarFrame = inputBarContainer.convert(inputBarContainer.bounds, to: view)
        return !inputBarFrame.contains(location)
    }

}
