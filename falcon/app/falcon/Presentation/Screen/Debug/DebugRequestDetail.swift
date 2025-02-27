//
//  DebugRequestDetail.swift
//  Muun
//
//  Created by Lucas Serruya on 21/09/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import UIKit


class DebugRequestDetail: MUViewController {
    private let closeButton = UIButton()
    private let stack = UIStackView()
    private let scrollView = UIScrollView()

    let request: DebugRequest

    override var screenLoggingName: String {
        "debug_request_detail"
    }

    init(request: DebugRequest) {
        self.request = request
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        setupCloseButton()
        setupScrollView()
        addStackToScrollView()

        customizeStackContent()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func customizeStackContent() {
        addData(title: "Instructions", data: "- Tap to copy \n- Long tap to share")
        addData(title: "URL", data: request.url)
        addData(title: "Method", data: request.method)
        addData(title: "Request Headers", data: headersToString(dictionary: request.headers))
        addData(title: "Request Body", data: request.body)

        addData(title: "Response Status Code",
                data: "\(String(describing: request.response.statusCode))")
        addData(title: "Response Headers",
                data: headersToString(dictionary: request.response.headers))
        addData(title: "Response Body", data: request.response.responseBody)
        addData(title: "Response Error",
                data: request.response.error?.localizedDescription)
    }

    func addData(title: String, data: String?) {
        let titleLabel = UILabel()
        titleLabel.font = Constant.Fonts.system(size: .h2, weight: .semibold)
        titleLabel.text = title
        titleLabel.backgroundColor = .blue
        stack.addArrangedSubview(titleLabel)
        if let data = data {
            let valueLabel = UILabel()
            valueLabel.numberOfLines = 0
            valueLabel.text = data
            valueLabel.backgroundColor = .white
            valueLabel.textColor = .black
            let tapGesture = UITapGestureRecognizer(target: self,
                                                    action: #selector(didTapLabel(sender:)))
            let longTapGesture = UILongPressGestureRecognizer(target: self,
                                                              action: #selector(didLongTapLabel(sender:)))
            valueLabel.isUserInteractionEnabled = true
            valueLabel.addGestureRecognizer(tapGesture)
            valueLabel.addGestureRecognizer(longTapGesture)

            stack.addArrangedSubview(valueLabel)
        }
    }

    private func addStackToScrollView() {
        stack.distribution = .equalSpacing
        stack.alignment = .leading
        stack.axis = .vertical
        stack.spacing = .spacing

        stack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: closeButton.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupCloseButton() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                             constant: 16).isActive = true
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                         constant: 16).isActive = true
    }

    @objc func closeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func headersToString<T>(dictionary: [T: Any]?) -> String? {
        guard let dictionary = dictionary else {
            return nil
        }

        var formattedHeaders = ""

        dictionary.forEach {
            formattedHeaders += "[\($0.key): \($0.value)]\n"
        }

        return formattedHeaders
    }

    @objc
    func didTapLabel(sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else {
            return
        }

        UIPasteboard.general.string = label.text
        showToast(message: "Text copied")
    }

    @objc
    func didLongTapLabel(sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else {
            return
        }

        let activityViewController = UIActivityViewController(activityItems: [label.text!],
                                                              applicationActivities: nil)

        self.present(activityViewController, animated: true, completion: nil)
    }
}
