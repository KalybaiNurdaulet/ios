//
//  ViewController.swift
//  assignment10
//
//  Created by Kalybay Nurdaulet  on 10.11.2026.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let items = FavoriteData.items

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
    }

    // Вернулись со второго экрана — снимаем выделение с нажатой строки.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: animated)
        }
    }

    // Вызывается прямо перед переходом по segue. Передаём только данные.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showDetail",
              let detail = segue.destination as? DetailViewController,
              let indexPath = tableView.indexPathForSelectedRow else { return }
        detail.item = items[indexPath.row]
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell",
                                                 for: indexPath) as! FavoriteCell
        cell.configure(with: items[indexPath.row])
        cell.backgroundConfiguration = .clear()
        return cell
    }
}

extension ViewController: UITableViewDelegate {

    // Палец нажал на строку — карточка чуть уменьшается.
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        UIView.animate(withDuration: 0.15) {
            cell.contentView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            cell.contentView.alpha = 0.85
        }
    }

    // Палец отпустил — карточка пружинисто возвращается.
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        UIView.animate(withDuration: 0.4, delay: 0,
                       usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8) {
            cell.contentView.transform = .identity
            cell.contentView.alpha = 1
        }
    }
}

