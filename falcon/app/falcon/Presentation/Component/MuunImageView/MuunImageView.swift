//
//  MuunImageView.swift
//  falcon
//
//  Created by Manu Herrera on 25/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

class MuunImageView: UIImageView {

    private var dataTask: URLSessionDataTask?
    private var activityIndicator: UIActivityIndicatorView?
    private var url: URL?

    func downloadImage(link: String) {
        guard let url = URL(string: link) else { return }
        downloadImage(url: url)
    }

    func cancelDownload() {
        activityIndicator?.stopAnimating()
        dataTask?.cancel()
    }

    private func downloadImage(url: URL) {
        self.url = url
        addActivityIndicator()

        dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    DispatchQueue.main.async {
                        self.activityIndicator?.stopAnimating()
                    }
                    return
            }
            DispatchQueue.main.async {
                if self.url != url {
                    return
                }
                UIView.animate(withDuration: 1, delay: 0, options: .transitionCrossDissolve, animations: {
                    self.activityIndicator?.stopAnimating()
                    self.backgroundColor = .clear
                    self.image = image
                }, completion: nil)
            }
        }

        dataTask?.resume()
    }

    private func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .white)
        if let activityIndicator = activityIndicator {
            let spinnerView = UIView(frame: bounds)
            spinnerView.backgroundColor = .clear

            activityIndicator.startAnimating()
            activityIndicator.center = spinnerView.center
            activityIndicator.hidesWhenStopped = true

            DispatchQueue.main.async {
                spinnerView.addSubview(activityIndicator)
                self.addSubview(spinnerView)
            }
        }
    }

}
