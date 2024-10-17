//
//  CreateCapsulesViewController.swift
//  AboutXTime
//
//  Created by Nicky Y on 2024/9/13.
//

import UIKit

class CreateCapsulesViewController: UIViewController {

    private let viewModel: CreateCapsulesViewModel
    private var userId: String {
        return UserDefaults.standard.string(forKey: "userUID") ?? "defaultUserId"
    }

    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    init(viewModel: CreateCapsulesViewModel = CreateCapsulesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .black
//        title = "創建膠囊"

        setupUI()
    }

    private func setupUI() {

        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
        navigationController?.navigationBar.tintColor = STColor.C1.uiColor.withAlphaComponent(0.5)

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7)
        ])

        let imageView = UIImageView()
        imageView.image = UIImage(named: "planet\(Int.random(in: 1...18))")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        stackView.addArrangedSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 300),
            imageView.widthAnchor.constraint(equalToConstant: 300)
        ])

        let spacerView = UIView()
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(spacerView)

        for type in viewModel.capsuleTypes {
            let button = UIButton(type: .system)
            button.setTitle(type.title, for: .normal)
            button.backgroundColor = STColor.C1.uiColor.withAlphaComponent(0.2)
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 0.5
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 10
            button.tag = type.rawValue
            button.addTarget(self, action: #selector(capsuleButtonTapped(_:)), for: .touchUpInside)

            stackView.addArrangedSubview(button)

            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
    }

    @objc private func capsuleButtonTapped(_ sender: UIButton) {
        guard let type = CreateCapsulesViewModel.CapsuleType(rawValue: sender.tag) else { return }

        let cardViewModel: CardViewModel

        switch type {
        case .selfToSelf:
            cardViewModel = CardViewModel( recipient: userId)
            navigateToCapsuleContent(capsuleViewModel: cardViewModel)

        case .selfToOther:
            cardViewModel = CardViewModel()
            navigateToCapsuleContent(capsuleViewModel: cardViewModel)

        case .withFriends:
            showCreateOrJoinAlert()
        }
    }

    private func navigateToCapsuleContent(capsuleViewModel: CardViewModel) {
        let capsuleContentVC = CapsuleCardViewController(viewModel: capsuleViewModel)
        navigationController?.pushViewController(capsuleContentVC, animated: true)
    }

    private func showCreateOrJoinAlert() {
        let alert = UIAlertController(title: "是否已經有膠囊的ID編號？",
                                      message: "您可以選擇創建新的膠囊或加入已有的膠囊",
                                      preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "沒有，我要創建新的膠囊並生成ID", style: .default, handler: { [weak self] _ in
            self?.createWithFriendsCapsule()
        }))

        alert.addAction(UIAlertAction(title: "有，我要輸入現有的膠囊ID加入", style: .default, handler: { [weak self] _ in
            self?.enterExistingCapsuleId()
        }))

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))

        present(alert, animated: true)
    }

    private func createWithFriendsCapsule() {
        FirebaseManager.shared.createCapsule { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let capsuleId):
                    self?.showCapsuleIdAlert(capsuleId: capsuleId)
                case .failure(let error):
                let alert = UIAlertController(title: "錯誤",
                                              message: "創建膠囊失敗：\(error.localizedDescription)",
                                              preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "確定", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }

    private func enterExistingCapsuleId() {
        let alert = UIAlertController(title: "請輸入膠囊ID（20碼）", message: "請輸入或貼上好友創建的膠囊ID", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "ex: 5x40NTlljij4Jiz75ogY"
            textField.keyboardType = .asciiCapable
        }

        alert.addAction(UIAlertAction(title: "確認", style: .default, handler: { [weak self, weak alert] _ in
            guard let capsuleId = alert?.textFields?.first?.text, !capsuleId.isEmpty else {
                self?.showErrorAlert(message: "膠囊ID不能為空")
                return
            }
            self?.checkCapsuleIdExists(capsuleId: capsuleId)
        }))

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))

        present(alert, animated: true)
    }

    private func checkCapsuleIdExists(capsuleId: String) {
        FirebaseManager.shared.checkCapsuleExists(capsuleId: capsuleId) { [weak self] exists in
            DispatchQueue.main.async {
                if exists {
                    self?.joinExistingCapsule(capsuleId: capsuleId)
                } else {
                    self?.showErrorAlert(message: "膠囊ID不存在，請確認並重新輸入。")
                }
            }
        }
    }

    private func joinExistingCapsule(capsuleId: String) {
        print(">>>> Received capsuleId in joinExistingCapsule: \(capsuleId)")

        let viewModel = CardViewModel(capsuleId: capsuleId, recipient: userId)
        viewModel.isShared = true

        print(">>>> Initialized CardViewModel with capsuleId: \(viewModel.capsuleId ?? "nil")")

        let capsuleContentVC = CapsuleCardViewController(viewModel: viewModel)
        print(">>>> Navigating to CapsuleCardViewController with capsuleId: \(viewModel.capsuleId ?? "nil")")

        navigationController?.pushViewController(capsuleContentVC, animated: true)
    }

    private func showCapsuleIdAlert(capsuleId: String) {
        let alert = UIAlertController(title: "膠囊 ID 已創建完成！",
                                      message: "請將此膠囊 ID 分享給您的好友，讓他們可以加入此膠囊：\n\n\(capsuleId)",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "複製 ID 並繼續", style: .default, handler: { [weak self] _ in

            UIPasteboard.general.string = capsuleId

            let viewModel = CardViewModel(capsuleId: capsuleId, recipient: self?.userId ?? "")
            viewModel.isShared = true
            let capsuleContentVC = CapsuleCardViewController(viewModel: viewModel)
            self?.navigationController?.pushViewController(capsuleContentVC, animated: true)
        }))

        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

        present(alert, animated: true)
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "錯誤", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
}
