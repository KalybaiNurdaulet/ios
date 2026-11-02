//
//  ViewController.swift
//  FavoriteList
//
//  Created by Kalybay Nurdaulet  on 02.11.2026.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let items: [FavoriteItem] = [
        FavoriteItem(title: "Алматы", subtitle: "Южная столица, горы и Медеу", imageName: "almaty", rating: 5),
        FavoriteItem(title: "Астана", subtitle: "Столица Казахстана, Байтерек", imageName: "astana", rating: 5),
        FavoriteItem(title: "Кордай", subtitle: "Село у границы с Кыргызстаном, трасса Алматы — Бишкек", imageName: "korday", rating: 5),
        FavoriteItem(title: "Шымкент", subtitle: "Третий по величине город, юг страны", imageName: "shymkent", rating: 4),
        FavoriteItem(title: "Туркестан", subtitle: "Мавзолей Ходжи Ахмеда Ясави", imageName: "turkestan", rating: 5),
        FavoriteItem(title: "Тараз", subtitle: "Один из древнейших городов, более 2000 лет", imageName: "taraz", rating: 4),
        FavoriteItem(title: "Конаев", subtitle: "Капшагайское водохранилище", imageName: "konaev", rating: 4),
        FavoriteItem(title: "Талдыкорган", subtitle: "Центр области Жетысу", imageName: "taldyk", rating: 3),
        FavoriteItem(title: "Караганда", subtitle: "Шахтёрская столица", imageName: "karaganda", rating: 3),
        FavoriteItem(title: "Актау", subtitle: "Город на Каспии, вместо улиц — микрорайоны", imageName: "aktau", rating: 4),
        FavoriteItem(title: "Атырау", subtitle: "Нефтяная столица на реке Урал", imageName: "atyrau", rating: 3),
        FavoriteItem(title: "Уральск", subtitle: "Один из старейших городов, здесь бывал Пушкин", imageName: "uralsk", rating: 3),
        FavoriteItem(title: "Актобе", subtitle: "Крупнейший город запада страны", imageName: "aktobe", rating: 3),
        FavoriteItem(title: "Усть-Каменогорск", subtitle: "Иртыш и ворота на Алтай", imageName: "ustkamen", rating: 4),
        FavoriteItem(title: "Семей", subtitle: "Город Абая, здесь жил Достоевский", imageName: "semey", rating: 4),
        FavoriteItem(title: "Павлодар", subtitle: "Город на берегу Иртыша", imageName: "pavlodar", rating: 3),
        FavoriteItem(title: "Петропавловск", subtitle: "Самый северный областной центр", imageName: "petropavlsk", rating: 2),
        FavoriteItem(title: "Кокшетау", subtitle: "Ворота в Бурабай", imageName: "kokshetau", rating: 4),
        FavoriteItem(title: "Костанай", subtitle: "Северная степь, центр Костанайской области", imageName: "kostanay", rating: 2),
        FavoriteItem(title: "Кызылорда", subtitle: "Город на Сырдарье", imageName: "kyzylorda", rating: 3)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.backgroundColor = .clear
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
        cell.backgroundConfiguration = .clear()         // ← добавить
        return cell
    }
    
}


