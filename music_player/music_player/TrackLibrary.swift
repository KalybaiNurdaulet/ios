//
//  TrackLibrary.swift
//  music_player
//
//  Created by Kalybay Nurdaulet  on 28.10.2026.
//


enum TrackLibrary {
    static let audioExtension = "mp3"

    static let tracks: [Track] = [
        Track(title: "Moldirep (Мөлдіреп snippet)", artist: "V $ X V Prince",
              fileName: "track1", coverImageName: "cover1"),
        Track(title: "Taxi",   artist: "Sadraddin",   fileName: "track2", coverImageName: "cover2"),
        Track(title: "Жаным-ау, Сен",  artist: "Raim", fileName: "track3", coverImageName: "cover3"),
        Track(title: "Quralai",   artist: "Серік Ибрагимов",  fileName: "track4", coverImageName: "cover4"),
        Track(title: "Sheker",    artist: "Darkhan Juzz",  fileName: "track5", coverImageName: "cover5"),
        Track(title: "ЛАЙФ",    artist: "JUNIOR (GHETTO DOGS)",  fileName: "track6", coverImageName: "cover6"),
        Track(title: "Біз қалағандай",    artist: "Адлет Асанов",  fileName: "track7", coverImageName: "cover7"),
        Track(title: "Жүрегімді",    artist: "De Lacure • V $ X V Prince",  fileName: "track8", coverImageName: "cover8"),
        Track(title: "Ойлаш",    artist: "Taspay • V $ X V Prince",  fileName: "track9", coverImageName: "cover9"),
        Track(title: "Сенесің бе",    artist: "Мирас Жугунусов",  fileName: "track10", coverImageName: "cover10")
    ]
}
