//
//  SecondViewController.swift
//  OtogramApp
//
//  Created by Takahiro.Kawakami on 2016/03/08.
//  Copyright © 2016年 Takahiro.Kawakami. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, EZMicrophoneDelegate, EZAudioFFTDelegate {
    //------------------------------------------------------------------------------
    //------------------------------------------------------------------------------
    //
    // EZAudioPlot for frequency plot
    //
    @IBOutlet weak var audioPlotFreq: EZAudioPlot!
    //
    // EZAudioPlot for time plot
    //
    @IBOutlet weak var audioPlotTime: EZAudioPlot!
    //
    // A label used to display the maximum frequency (i.e. the frequency with the
    // highest energy) calculated from the FFT.
    //
    @IBOutlet weak var maxFrequencyLabel: UILabel!
    //
    // The microphone used to get input.
    //
    var microphone: EZMicrophone {
        get {
            //
            // Calculate the FFT, will trigger EZAudioFFTDelegate
            //
            self.fft.computeFFTWithBuffer(buffer[0], withBufferSize: bufferSize)
            weak var weakSelf = self
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                weakSelf.audioPlotTime.updateBuffer(buffer[0], withBufferSize: bufferSize)
            })
        }
    }
    
    //
    // Used to calculate a rolling FFT of the incoming audio data.
    //
    var fft: EZAudioFFTRolling {
        get {
            var maxFrequency: CGFloat = fft.maxFrequency()
            var noteName: String = EZAudioUtilities.noteNameStringForFrequency(maxFrequency, includeOctave: true)
            weak var weakSelf = self
            dispatch_async(dispatch_get_main_queue(), {() -> Void in
                weakSelf.maxFrequencyLabel.text = "Highest Note: \(noteName),\nFrequency: %.2f"
                weakSelf.audioPlotFreq.updateBuffer(fftData, withBufferSize: UInt32(bufferSize))
            })
        }
    }
    
    //------------------------------------------------------------------------------
    //------------------------------------------------------------------------------
    func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    //------------------------------------------------------------------------------
    //------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        // Setup the AVAudioSession. EZMicrophone will not work properly on iOS
        // if you don't do this!
        //
        var session: AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError
        session.setCategory(.PlayAndRecord, error: error)
        if error != nil {
            NSLog("Error setting up audio session category: %@", error.localizedDescription)
        }
        session.setActive(true, error: error)
        if error != nil {
            NSLog("Error setting up audio session active: %@", error.localizedDescription)
        }
        //
        // Setup time domain audio plot
        //
        self.audioPlotTime.plotType = .Buffer
        self.maxFrequencyLabel.numberOfLines = 0
        //
        // Setup frequency domain audio plot
        //
        self.audioPlotFreq.shouldFill = true
        self.audioPlotFreq.plotType = .Buffer
        self.audioPlotFreq.shouldCenterYAxis = false
        //
        // Create an instance of the microphone and tell it to use this view controller instance as the delegate
        //
        self.microphone = EZMicrophone.microphoneWithDelegate(self)
        //
        // Create an instance of the EZAudioFFTRolling to keep a history of the incoming audio data and calculate the FFT.
        //
        self.fft = EZAudioFFTRolling.fftWithWindowSize(FFTViewControllerFFTWindowSize, sampleRate: self.microphone.audioStreamBasicDescription.mSampleRate, delegate: self)
        //
        // Start the mic
        //
        self.microphone.startFetchingAudio()
    }
    //------------------------------------------------------------------------------
    //------------------------------------------------------------------------------
    //------------------------------------------------------------------------------
    //------------------------------------------------------------------------------
}
//
//  ViewController.m
//  FFT
//
//  Created by Syed Haris Ali on 12/1/13.
//  Updated by Syed Haris Ali on 1/23/16.
//  Copyright (c) 2013 Syed Haris Ali. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

let FFTViewControllerFFTWindowSize: vDSP_Length = 4096