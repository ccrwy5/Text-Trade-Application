//
//  ScannerViewController.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/28/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit

class ScannerViewController: UIViewController {

    @IBOutlet weak var scannerView: QRScannerView! {
        didSet {
            scannerView.delegate = self
        }
    }
    @IBOutlet weak var scanButton: UIButton!{
        didSet{
            scanButton.setTitle("STOP", for: .normal)
            scanButton.layer.cornerRadius = 12
        }
    }
    
    var qrData: QRData? = nil {
        didSet {
            if qrData != nil {
                self.performSegue(withIdentifier: "detail", sender: self)
            } else {
                print("error")
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !scannerView.isRunning {
            scannerView.startScanning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !scannerView.isRunning {
            scannerView.stopScanning()
        }
    }
    
    @IBAction func scanBookButtonPressed(_ sender: Any) {
        scannerView.isRunning ? scannerView.stopScanning() : scannerView.startScanning()
            let buttonTitle = scannerView.isRunning ? "STOP" : "SCAN"
            (sender as AnyObject).setTitle(buttonTitle, for: .normal)
    }
    
}

extension ScannerViewController: QRScannerViewDelegate {
    func qrScanningDidStop() {
        let buttonTitle = scannerView.isRunning ? "STOP" : "SCAN"
        scanButton.setTitle(buttonTitle, for: .normal)
    }
    
    func qrScanningDidFail() {
        presentAlert(withTitle: "Error", message: "Scanning Failed. Please try again")
    }
    
    func qrScanningSucceededWithCode(_ str: String?) {
        self.qrData = QRData(codeString: str)
    }
}

extension ScannerViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail", let viewController = segue.destination
            as? ScanResultViewController {
            viewController.qrData = self.qrData
            print("Segue started")
        }
    }
}
