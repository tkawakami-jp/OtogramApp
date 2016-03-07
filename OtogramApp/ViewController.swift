//
//  ViewController.swift
//  OtogramApp
//
//  Created by Takahiro.Kawakami on 2016/03/07.
//  Copyright © 2016年 Takahiro.Kawakami. All rights reserved.
//

import UIKit


class ViewController: UIViewController, EZMicrophoneDelegate {
    
    //------------------------------------------------------------------------------
    // MARK: Properties
    //------------------------------------------------------------------------------
    
    @IBOutlet weak var plot: EZAudioPlotGL?;
    var microphone: EZMicrophone!;
    
    //------------------------------------------------------------------------------
    // MARK: Status Bar Style
    //------------------------------------------------------------------------------
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent;
    }
    
    //------------------------------------------------------------------------------
    // MARK: View Lifecycle
    //------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        microphone = EZMicrophone(delegate: self, startsImmediately: true);
    }
    
    
    //------------------------------------------------------------------------------
    // MARK: EZMicrophoneDelegate
    //------------------------------------------------------------------------------
    
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.plot?.updateBuffer(buffer[0], withBufferSize: bufferSize);
        });
    }
    
}

