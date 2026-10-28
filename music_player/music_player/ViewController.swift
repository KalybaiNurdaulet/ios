//
//  ViewController.swift
//  music_player
//
//  Created by Kalybay Nurdaulet  on 28.10.2026.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    // MARK: - Types
    private enum Direction {
        case forward, backward, none
    }

    // MARK: - State
    private let tracks = TrackLibrary.tracks
    private var currentIndex = 0
    private var isPlaying = false
    private var player: AVAudioPlayer?
    private let haptic = UIImpactFeedbackGenerator(style: .light)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        setupButtons()

        guard !tracks.isEmpty else {
            print("⚠️ TrackLibrary пуст — добавь треки")
            return
        }
        loadTrack(at: currentIndex)
        updateUI(direction: .none, animated: false)
    }

    // MARK: - Appearance
    private func setupButtons() {
        let smallSymbol = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let bigSymbol = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)

        previousButton.configuration = glassConfiguration(prominent: false)
        previousButton.configuration?.image = UIImage(systemName: "backward.fill")
        previousButton.configuration?.preferredSymbolConfigurationForImage = smallSymbol

        nextButton.configuration = glassConfiguration(prominent: false)
        nextButton.configuration?.image = UIImage(systemName: "forward.fill")
        nextButton.configuration?.preferredSymbolConfigurationForImage = smallSymbol

        playPauseButton.configuration = glassConfiguration(prominent: true)
        playPauseButton.configuration?.preferredSymbolConfigurationForImage = bigSymbol
        playPauseButton.tintColor = .systemPink
    }

    private func glassConfiguration(prominent: Bool) -> UIButton.Configuration {
        var config: UIButton.Configuration
        if #available(iOS 26.0, *) {
            config = prominent ? .prominentClearGlass() : .glass()
        } else {
            config = prominent ? .plain() : .tinted()
        }
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 18, bottom: 18, trailing: 18)
        return config
    }

    // MARK: - Actions
    @IBAction func playPauseTapped(_ sender: UIButton) {
        guard let player = player else {
            print("⚠️ Трек не загружен — нечего играть")
            return
        }
        haptic.impactOccurred()
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
        updatePlayState(animated: true)
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        haptic.impactOccurred()
        switchTrack(to: (currentIndex + 1) % tracks.count, direction: .forward)
    }

    @IBAction func previousTapped(_ sender: UIButton) {
        haptic.impactOccurred()
        switchTrack(to: (currentIndex - 1 + tracks.count) % tracks.count, direction: .backward)
    }

    // MARK: - Player
    private func loadTrack(at index: Int) {
        player?.stop()
        player = nil

        let track = tracks[index]
        guard let url = Bundle.main.url(forResource: track.fileName,
                                        withExtension: TrackLibrary.audioExtension) else {
            print("❌ Не найден файл \(track.fileName).\(TrackLibrary.audioExtension). Проверь имя и Target Membership.")
            return
        }

        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.delegate = self
            newPlayer.prepareToPlay()
            player = newPlayer
        } catch {
            print("❌ Не удалось открыть \(track.fileName): \(error.localizedDescription)")
        }
    }

    private func switchTrack(to index: Int, direction: Direction) {
        currentIndex = index
        loadTrack(at: index)
        if isPlaying {
            isPlaying = player?.play() ?? false
        }
        updateUI(direction: direction, animated: true)
    }

    // MARK: - UI
    private func updateUI(direction: Direction, animated: Bool) {
        let track = tracks[currentIndex]
        let cover = UIImage(named: track.coverImageName)

        if animated {
            // Обложка въезжает справа или слева
            let push = CATransition()
            push.type = .push
            push.subtype = (direction == .backward) ? .fromLeft : .fromRight
            push.duration = 0.35
            push.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            coverImageView.layer.add(push, forKey: "trackChange")

            // Тексты плавно растворяются
            let fade = CATransition()
            fade.type = .fade
            fade.duration = 0.25
            titleLabel.layer.add(fade, forKey: "trackChange")
            artistLabel.layer.add(fade, forKey: "trackChange")

            // Фон медленно перетекает
            UIView.transition(with: backgroundImageView,
                              duration: 0.6,
                              options: .transitionCrossDissolve) {
                self.backgroundImageView.image = cover
            }
        } else {
            backgroundImageView.image = cover
        }

        coverImageView.image = cover
        titleLabel.text = track.title
        artistLabel.text = track.artist
        updatePlayState(animated: animated)
    }

    private func updatePlayState(animated: Bool) {
        let iconName = isPlaying ? "pause.fill" : "play.fill"
        let scale: CGFloat = isPlaying ? 1.0 : 0.88

        guard animated else {
            playPauseButton.configuration?.image = UIImage(systemName: iconName)
            coverImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
            return
        }

        UIView.transition(with: playPauseButton,
                          duration: 0.2,
                          options: .transitionCrossDissolve) {
            self.playPauseButton.configuration?.image = UIImage(systemName: iconName)
        }

        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0,
                       options: [.beginFromCurrentState, .allowUserInteraction]) {
            self.coverImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension ViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        switchTrack(to: (currentIndex + 1) % tracks.count, direction: .forward)
    }
}
