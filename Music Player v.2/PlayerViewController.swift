//
//  PlayerViewController.swift
//  Music Player v.2
//
//  Created by Mac on 20.11.2022.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

    public var position: Int = 0
    public var songs: [Song] = []
    
    var player: AVAudioPlayer?
    var timer: Timer?
    var timeSong: Double = Double()
    
    
    // MARK: - user interface elements
    
    private let albumImageView: UIImageView =  {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let songNameLabel: UILabel =  {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0 // line wrap
        return label
    }()
    
    private let artistNameLabel: UILabel =  {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0 // line wrap
        return label
    }()
    
    private let albumNameLabel: UILabel =  {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0 // line wrap
        return label
    }()
    
    private var labelTimeStart: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private var labelTimeFinish: UILabel = {
        let label = UILabel()
        return label
    }()
    
    let playPauseButton = UIButton()
    let sliderDuration = UISlider()
    
    @IBOutlet var holder: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if holder.subviews.count == 0 {
            configure()
        }
    }
    
    func configure() {
        // MARK: - set up player
        let song = songs[position]
        
        let urlString = Bundle.main.path(forResource: song.trackName, ofType: "mp3")
        
        do
        {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            guard let urlString = urlString else { return }
            
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlString))
            
            guard let player = player else { return }
            
            player.volume = 0.5
            
            player.play()
        }
        catch
        {
            print("Error occurred!")
        }
        // MARK: - set up user interface elements
        
        // album cover
        albumImageView.frame = CGRect(x: 10,
                                      y: 10,
                                      width: holder.frame.size.width-20,
                                      height: holder.frame.size.height-400)
        albumImageView.image = UIImage(named: song.imageName)
        holder.addSubview(albumImageView)
        
        // label: song name, album, artist
        songNameLabel.frame = CGRect(x: 10,
                                     y: albumImageView.frame.size.height + 10,
                                     width: holder.frame.size.width-20,
                                     height: 70)
        albumNameLabel.frame = CGRect(x: 10,
                                      y: albumImageView.frame.size.height + 10 + 70,
                                      width: holder.frame.size.width-20,
                                      height: 70)
        artistNameLabel.frame = CGRect(x: 10,
                                       y: albumImageView.frame.size.height + 10 + 140,
                                       width: holder.frame.size.width-20,
                                       height: 70)
        
        songNameLabel.text = song.name
        albumNameLabel.text = song.albumName
        artistNameLabel.text = song.artistName
        
        holder.addSubview(songNameLabel)
        holder.addSubview(albumNameLabel)
        holder.addSubview(artistNameLabel)
        
        // time label
        
        labelTimeStart.frame = CGRect(x: 20,
                                      y: holder.frame.size.height-80,
                                      width: 80,
                                      height: 25)
        
        labelTimeFinish.frame = CGRect(x: holder.frame.size.width-70,
                                       y: holder.frame.size.height-80,
                                       width: 80,
                                       height: 25)
        
        holder.addSubview(labelTimeStart)
        holder.addSubview(labelTimeFinish)
        // player controls
        
        let nextButton = UIButton()
        let backButton = UIButton()
        
        // frame
        
        let yPosition = artistNameLabel.frame.origin.y + 70 + 20
        let size: CGFloat = 70
        
        playPauseButton.frame = CGRect(x: (holder.frame.size.width - size) / 2.0,
                                       y: yPosition,
                                       width: size,
                                       height: size)
        
        nextButton.frame = CGRect(x: holder.frame.size.width - size - 20,
                                       y: yPosition,
                                       width: size,
                                       height: size)
        
        backButton.frame = CGRect(x: 20,
                                       y: yPosition,
                                       width: size,
                                       height: size)
        
        // add actions
        
        playPauseButton.addTarget(self, action: #selector(didTapPlayPauseButton), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapnNextButton), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        // stylng
        
        playPauseButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
        nextButton.setBackgroundImage(UIImage(systemName: "forward.fill"), for: .normal)
        backButton.setBackgroundImage(UIImage(systemName: "backward.fill"), for: .normal)
        
        playPauseButton.tintColor = .black
        nextButton.tintColor = .black
        backButton.tintColor = .black
        
        
        holder.addSubview(playPauseButton)
        holder.addSubview(nextButton)
        holder.addSubview(backButton)
        
        // slider volume
        
        let slider = UISlider(frame: CGRect(x: 20,
                                            y: holder.frame.size.height-30,
                                            width: holder.frame.size.width-40,
                                            height: 50))
        slider.value = 0.5
        slider.addTarget(self, action: #selector(checkSliderVolume), for: .valueChanged)
        holder.addSubview(slider)
        
        // slider duration
        
        sliderDuration.frame = CGRect(x: 20,
                                            y: holder.frame.size.height-60,
                                            width: holder.frame.size.width-40,
                                            height: 50)
        sliderDuration.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        sliderDuration.tintColor = .systemGreen
        sliderDuration.minimumValue = 0.0
        sliderDuration.maximumValue = Float((player?.duration)!)
        holder.addSubview(sliderDuration)
        
        sliderDuration.addTarget(self, action: #selector(checkSliderDuration), for: .valueChanged)
        
        // make a timer interval for 1 second
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let player = player {
            player.stop()
        }
    }
    
    // MARK: - Function
    
    @objc func didTapBackButton() {
        if position > 0 {
            position = position - 1
            player?.stop()
            for subview in holder.subviews {
                subview.removeFromSuperview()
            }
            configure()
        }
    }
    
    @objc func didTapnNextButton() {
        if position < songs.count - 1 {
            position = position + 1
            player?.stop()
            for subview in holder.subviews {
                subview.removeFromSuperview()
            }
            configure()
        }
    }
    
    @objc func didTapPlayPauseButton() {
        if player?.isPlaying == true {
            // pause
            player?.pause()
            playPauseButton.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
            
            // shrink image
            
            UIView.animate(withDuration: 0.2, animations: {
                self.albumImageView.frame = CGRect(x: 30,
                                                   y: 30,
                                                   width: self.holder.frame.size.width-60,
                                                   height: self.holder.frame.size.height-460)
                
            })
        } else {
            // play
            player?.play()
            playPauseButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            
            // increase image size
            UIView.animate(withDuration: 0.2, animations: {
                self.albumImageView.frame = CGRect(x: 10,
                                                   y: 10,
                                                   width: self.holder.frame.size.width-20,
                                                   height: self.holder.frame.size.height-400)
            })
        }
    }
    
    @objc func checkSliderVolume(_ slider: UISlider) {
        let value = slider.value
        player?.volume = value
        // adjust player volume
        
    }
    
    @objc func checkSliderDuration(_ slider: UISlider) {
        player?.currentTime = TimeInterval(slider.value)
    }
    
    @objc func updateTime() {
        
        let timePlayed = player?.currentTime
            let minutes = Int(timePlayed! / 60)
            let seconds = Int(timePlayed!.truncatingRemainder(dividingBy: 60) )
            labelTimeStart.text = NSString(format: "%02d:%02d", minutes, seconds) as String
        
        timeSong = (player?.duration)!
        let diffTime = (player?.currentTime)! - timeSong
            let minutes1 = Int(diffTime / 60)
            let seconds1 = Int(-diffTime.truncatingRemainder(dividingBy: 60))
            labelTimeFinish.text = NSString(format: "%02d:%02d", minutes1, seconds1) as String
        
        sliderDuration.setValue(Float((player?.currentTime)!), animated: true)
    }
}
