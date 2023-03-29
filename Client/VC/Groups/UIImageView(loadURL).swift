//
//  UIImageView.swift
//  Client
//
//  Created by Jane Z. on 31.01.2023.
//

import Foundation
import UIKit

// загурзка картинок по урлу
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
