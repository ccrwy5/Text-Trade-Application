//
//  ScanResultViewController.swift
//  Text-Trade
//
//  Created by Chris Rehagen on 3/28/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit
import WebKit

class ScanResultViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    var web: WKWebView!
    var loadingSpinner: UIActivityIndicatorView = UIActivityIndicatorView()
    var qrData: QRData?
    var scanResultViewController: ScanResultViewController?
    var printable: String = ""
    
    @IBOutlet weak var lookUpButton: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.text = qrData?.codeString
        lookUpButton.layer.cornerRadius = 12
        
    }
    
    @IBAction func findBookButtonPressed(_ sender: Any) {
        loadingSpinner.center = self.view.center
        loadingSpinner.hidesWhenStopped = true
        loadingSpinner.style = UIActivityIndicatorView.Style.large
        view.addSubview(loadingSpinner)
        
        loadingSpinner.startAnimating()
        
        
        web = WKWebView(frame: .zero)
            web.navigationDelegate = self
            let scannedCode = resultLabel.text!

            let url = URL(string: "https://www.abebooks.com/servlet/SearchResults?sts=t&isbn=" + scannedCode)
            let myRequest = URLRequest(url: url!)
            web.load(myRequest)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            web.evaluateJavaScript("document.getElementsByTagName('h1')[0].innerHTML") {(result, error) in
                guard error == nil else {
                    //print(error!)
                    return
                }

                print(type(of: String(describing: result)))
                self.printable = String(describing: result!)
                self.printable = String(self.printable.dropFirst(16))

                //self.showToast(message: printable)
                
                self.showAlertAction(title: "Found Book", message: self.printable)
                self.loadingSpinner.stopAnimating()
                
                print("\n\n\n\n\n" + self.printable + "\n\n\n\n\n")
                
        }
    }
    
    func showAlertAction(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Use this book", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
            //print("Action")
            self.performSegue(withIdentifier: "choseUseBook", sender: self)
            
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "choseUseBook") {
            let vc = segue.destination as! NewPostViewController
            vc.verificationId = printable
        }
    }
    
    



}
