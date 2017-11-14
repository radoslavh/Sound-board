//
//  SoundViewController.swift
//  Sound board
//
//  Created by Radoslav Hlinka on 14/11/2017.
//  Copyright © 2017 Radoslav Hlinka. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var soundNameLabel: UITextField!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var audioRecored : AVAudioRecorder?
    var audioPlayer : AVAudioPlayer?
    var audioURL : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRecorder()
        playButton.isEnabled = false;
        addButton.isEnabled = false;
    }
    
    func setupRecorder(){
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            let basePath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents  = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            var settings : [String:Any] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC)
            settings[AVSampleRateKey] = 44100.00
            settings[AVNumberOfChannelsKey] = 2
            
            audioRecored = try AVAudioRecorder(url: audioURL!, settings: settings)
            audioRecored?.prepareToRecord()
        } catch let error as NSError {
            print(error)
        }
    }
    
    @IBAction func onRecordAction(_ sender: Any) {
        if audioRecored!.isRecording {
            audioRecored!.stop()
            recordButton.setTitle("Record", for: .normal)
            playButton.isEnabled = true
            addButton.isEnabled = true
        } else{
            audioRecored!.record()
            recordButton.setTitle("Stop", for: .normal)
        }
    }
    
    @IBAction func onPlayAction(_ sender: Any) {
        do{
            try audioPlayer = AVAudioPlayer(contentsOf: audioURL!)
            audioPlayer!.play()
        } catch{}
    }
    
    @IBAction func onAddAction(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let sound = Sound(context: context)
        sound.name = soundNameLabel.text
        sound.audio = NSData(contentsOf: audioURL!) as Data?
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
}
