//
//  FavoriteCell.swift
//  FavoriteList
//
//  Created by Kalybay Nurdaulet  on 02.11.2026.
//

import UIKit

final class FavoriteCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var starsStackView: UIStackView!

    
    func configure(with item: FavoriteItem) {
        itemImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle

        // 5 звёзд слева направо: первые rating — закрашенные, остальные пустые
        for (index, view) in starsStackView.arrangedSubviews.enumerated() {
            guard let star = view as? UIImageView else { continue }
            let symbol = index < item.rating ? "star.fill" : "star"
            star.image = UIImage(systemName: symbol)
        }
    }
}
