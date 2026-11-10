//
//  FavoriteCell.swift
//  assignment10
//
//  Created by Kalybay Nurdaulet  on 10.11.2026.
//

import UIKit

// В этой лабе ячейка показывает только фото и название.
final class FavoriteCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    func configure(with item: FavoriteItem) {
        itemImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
    }
}
