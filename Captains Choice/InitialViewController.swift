//
//  ViewController.swift
//  Captains Choice
//
//  Created by John Malatras on 1/30/17.
//  Copyright © 2017 John Malatras. All rights reserved.
//o

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var PlayersTextField: UITextField!
    @IBOutlet weak var TeamsTextField: UITextField!
    
    @IBAction func NextButton(_ sender: Any) {
        if self.PlayersTextField.text == nil || self.TeamsTextField.text == nil || self.PlayersTextField.text == "" || self.TeamsTextField.text == "" {
            let alertController = UIAlertController(title: "Enter all values", message: "Please enter both the number of players and number of teams", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            let svc = storyboard?.instantiateViewController(withIdentifier: "HandicapViewController") as! HandicapViewController
            svc.playerCount = Int(self.PlayersTextField.text!)!
            svc.playersPerTeam = Int(self.TeamsTextField.text!)!
            navigationController?.pushViewController(svc, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Captains Choice"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

