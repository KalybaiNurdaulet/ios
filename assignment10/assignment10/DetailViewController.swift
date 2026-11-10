//
//  DetailViewController.swift
//  assignment10
//
//  Created by Kalybay Nurdaulet  on 10.11.2026.
//


import UIKit

class DetailViewController: UIViewController {

    // Сюда список кладёт выбранный город в prepare(for:sender:).
    var item: FavoriteItem?

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var starsStackView: UIStackView!
    @IBOutlet weak var descriptionLabel: UILabel!

    // Экран сам заполняет свои outlets из item.
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let item = item else { return }

        title = item.title
        itemImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        descriptionLabel.text = item.description

        for (index, view) in starsStackView.arrangedSubviews.enumerated() {
            guard let star = view as? UIImageView else { continue }
            let symbol = index < item.rating ? "star.fill" : "star"
            star.image = UIImage(systemName: symbol)
        }
    }
}
