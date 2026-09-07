//
//  SecureKeyValueStorageDebugViewController.swift
//  Muun
//

import UIKit

class SecureKeyValueStorageDebugViewController: MUViewController {
    private lazy var presenter = instancePresenter(
        SecureKeyValueStorageDebugPresenter.init,
        delegate: self
    )

    private let stackView = UIStackView()

    override var screenLoggingName: String {
        return "debug_secure_key_value_storage"
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = MuunTheme.Color.Surface.background

        setUpStackView()
        addButton(title: "PUT", action: #selector(onPutTapped))
        addButton(title: "GET", action: #selector(onGetTapped))
        addButton(title: "DELETE", action: #selector(onDeleteTapped))
        addButton(title: "WIPE", action: #selector(onWipeTapped))
        // WIPE is destructive; the tap opens a confirmation dialog so it is
        // never one-tap accessible from the debug surface.
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 32
            ),
            stackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 24
            ),
            stackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -24
            )
        ])
    }

    private func addButton(title: String, action: Selector) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = MuunTheme.Color.Surface.field
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        stackView.addArrangedSubview(button)
    }

    @objc private func onPutTapped() { presenter.onPutTapped() }
    @objc private func onGetTapped() { presenter.onGetTapped() }
    @objc private func onDeleteTapped() { presenter.onDeleteTapped() }

    @objc private func onWipeTapped() {
        let alert = UIAlertController(
            title: "Wipe secure storage?",
            message: "Deletes ALL keys in the native secure storage. Cannot be undone.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Wipe", style: .destructive) { [weak self] _ in
            self?.presenter.onWipeConfirmed()
        })
        present(alert, animated: true)
    }
}

extension SecureKeyValueStorageDebugViewController: SecureKeyValueStorageDebugPresenterDelegate {
    func showAlert(title: String?, message: String?) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "Accept", style: .default))
            self.present(alertController, animated: true)
        }
    }
}
