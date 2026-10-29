//
//  PlayerViewController.swift
//  MusicPlayer
//
//  Верстка полностью в Main.storyboard (stack views),
//  тут только логика плеера
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!

    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!

    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    private let tracks = TrackLibrary.tracks

    // состояние экрана - все в одном месте
    private var currentIndex = 0
    private var isPlaying = false

    // храним плеер в свойстве, иначе он удалится сразу после play()
    private var player: AVAudioPlayer?

    // таймер двигает ползунок пока играет трек
    private var progressTimer: Timer?
    // пока пользователь тащит ползунок, таймер его не трогает
    private var isSeeking = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioSession()
        setupButtons()
        loadTrack(at: currentIndex)
        updateUI()
        startProgressTimer()
    }

    deinit {
        progressTimer?.invalidate()
    }

    // MARK: - Setup

    private func setupAudioSession() {
        do {
            // чтобы звук играл даже если на телефоне беззвучный режим
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    private func setupButtons() {
        let small = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
        let big = UIImage.SymbolConfiguration(pointSize: 52, weight: .regular)
        previousButton.setPreferredSymbolConfiguration(small, forImageIn: .normal)
        nextButton.setPreferredSymbolConfiguration(small, forImageIn: .normal)
        playPauseButton.setPreferredSymbolConfiguration(big, forImageIn: .normal)

        // цифры одинаковой ширины, чтобы время не "прыгало"
        currentTimeLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        durationLabel.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
    }

    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }

    // MARK: - Player

    private func loadTrack(at index: Int) {
        currentIndex = index
        let track = tracks[index]

        guard let url = Bundle.main.url(forResource: track.fileName, withExtension: track.fileExtension) else {
            print("Файл не найден: \(track.fileName).\(track.fileExtension)")
            player = nil
            showError("Не удалось найти файл «\(track.title)»")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
        } catch {
            print("Не удалось открыть \(track.fileName): \(error)")
            player = nil
            showError("Файл «\(track.title)» поврежден")
        }
    }

    private func play() {
        guard let player = player else {
            isPlaying = false
            return
        }
        isPlaying = player.play()
    }

    private func pause() {
        player?.pause()
        isPlaying = false
    }

    // step = 1 вперед, -1 назад
    private func switchTrack(by step: Int) {
        let wasPlaying = isPlaying
        player?.stop()

        // по кругу: после последнего первый, перед первым последний
        let newIndex = (currentIndex + step + tracks.count) % tracks.count
        loadTrack(at: newIndex)

        if wasPlaying {
            play()
        } else {
            isPlaying = false
        }
        updateUI()
    }

    // MARK: - UI

    private func updateUI() {
        let track = tracks[currentIndex]
        coverImageView.image = UIImage(named: track.coverImageName) ?? UIImage(systemName: "music.note")
        titleLabel.text = track.title
        artistLabel.text = track.artist

        let iconName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: iconName), for: .normal)

        progressSlider.maximumValue = Float(player?.duration ?? 0)
        progressSlider.isEnabled = player != nil
        durationLabel.text = formatTime(player?.duration ?? 0)
        updateProgress()
    }

    private func updateProgress() {
        guard !isSeeking else { return }
        let current = player?.currentTime ?? 0
        progressSlider.value = Float(current)
        currentTimeLabel.text = formatTime(current)
    }

    // 125 -> "2:05"
    private func formatTime(_ time: TimeInterval) -> String {
        let total = Int(time)
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    private func showError(_ message: String) {
        // если экран еще не показан, алерт не появится - тогда хватит print выше
        guard viewIfLoaded?.window != nil else { return }
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Actions

    @IBAction func playPauseTapped(_ sender: UIButton) {
        if isPlaying {
            pause()
        } else {
            play()
        }
        updateUI()
    }

    @IBAction func sliderTouchDown(_ sender: UISlider) {
        isSeeking = true
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        // пока тащим, показываем время под пальцем
        currentTimeLabel.text = formatTime(TimeInterval(sender.value))
    }

    @IBAction func sliderReleased(_ sender: UISlider) {
        player?.currentTime = TimeInterval(sender.value)
        isSeeking = false
        updateProgress()
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        switchTrack(by: 1)
    }

    @IBAction func previousTapped(_ sender: UIButton) {
        switchTrack(by: -1)
    }
}

// MARK: - AVAudioPlayerDelegate

extension PlayerViewController: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // трек закончился - включаем следующий
        // isPlaying тут еще true, поэтому switchTrack сразу его запустит
        switchTrack(by: 1)
    }
}
