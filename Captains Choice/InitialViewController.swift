//
//  ViewController.swift
//  Captains Choice
//
//  Created by John Malatras on 1/30/17.
//  Copyright © 2017 John Malatras. All rights reserved.
//o

import UIKit
import GoogleMobileAds

class InitialViewController: UIViewController {

    @IBOutlet weak var PlayersTextField: UITextField!
    @IBOutlet weak var TeamsTextField: UITextField!
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBAction func NextButton(_ sender: Any) { 
        
        if let playerCount = Int(self.PlayersTextField.text!), let playersPerTeam = Int(self.TeamsTextField.text!) {
            if playersPerTeam != 2 && playersPerTeam != 3 && playersPerTeam != 4 {
                let alertController = UIAlertController(title: "Invalid Players Per Team", message: "Please enter only 2, 3 or 4 for the Players per Team field. ", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            } else {
                let svc = storyboard?.instantiateViewController(withIdentifier: "HandicapViewController") as! HandicapViewController
                svc.playerCount = playerCount
                svc.playersPerTeam = playersPerTeam
                navigationController?.pushViewController(svc, animated: true)
            }
        } else {
            let alertController = UIAlertController(title: "Enter all values", message: "Please enter both the number of players and number of teams", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Captains Choice"
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        bannerView.adUnitID = "ca-app-pub-9379925034367531/7089544002"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }

}

