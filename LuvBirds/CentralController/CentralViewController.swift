//
//  CentralViewController.swift
//  LuvBirds
//
//  Created by Laurence Wingo on 8/29/18.
//  Copyright © 2018 Cosmic Arrows, LLC. All rights reserved.
//

import UIKit
import AVFoundation
import EstimoteProximitySDK
import Alamofire

class CentralViewController: UIViewController, TransferServiceScannerDelegateProtocol {
    @IBOutlet var heartImage: UIImageView!
    @IBOutlet var scanButton: CustomButton!
    @IBOutlet var textView: UITextView!
    var transferServiceScanner: TransferServiceScanner!
    var isScanning: Bool = false
    var player: AVAudioPlayer?

    // MARK: TransferServiceScannerDelegateProtocol methods
    func didStartScan() {
        if !isScanning {
            textView.text = "Scanning..."
            isScanning = true
            let redHeartImage = UIImage.init(named: "heart")
            heartImage.image = redHeartImage
            playHeartBeatSound()
            pulsateHeart()
        }
    }
    
    func didStopScan() {
        textView.text = ""
        isScanning = false
        let pinkHeartImage = UIImage.init(named: "heartpink")
        heartImage.image = pinkHeartImage
        stopHeartBeatSound()
        //heartImage.layer.removeAllAnimations()
        stopPulsatingHeart()
    }
    
    func didTransferData(data: NSData?) {
        //
    }
    //end of TransferServiceScannerDelegateProtocol methods
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !ESTConfig.isAuthorized() {
            let appID = "luvbirds-iie"
            let appToken = "36cb9c96f3aa67d5c248ec78d3be9894"
            ESTConfig.setupAppID(appID, andAppToken: appToken)
        }
        transferServiceScanner = TransferServiceScanner.init(delegate: self)
        getDevices()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func scanButtonTapped(_ sender: CustomButton) {
        isScanning ? transferServiceScanner.stopScan() : transferServiceScanner.startScan()
        /*
        if isScanning{
            transferServiceScanner.stopScan()
        } else {
            transferServiceScanner.startScan()
        }
 */
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func playHeartBeatSound() {
        guard let url = Bundle.main.url(forResource: "heartbeatspeedup", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stopHeartBeatSound(){
        player?.stop()
    }
    
    func pulsateHeart(){
        let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 0
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        heartImage.layer.add(pulseAnimation, forKey: "animateOpacity")
    }
    
    func stopPulsatingHeart(){
        let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        pulseAnimation.duration = 1
        pulseAnimation.fromValue = 0
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = 1
        heartImage.layer.add(pulseAnimation, forKey: "animateOpacity")
    }
    
    
    func getDevices(){
        Alamofire.request("https://cloud.estimote.com/v3/devices", method: .get, parameters: nil, encoding: URLEncoding.default).authenticate(user: "luvbirds-iie", password: "36cb9c96f3aa67d5c248ec78d3be9894").response {response in
            print(response)
        }
    }

}
