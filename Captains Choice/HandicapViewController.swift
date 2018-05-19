//
//  HandicapViewController.swift
//  Captains Choice
//
//  Created by John Malatras on 1/30/17.
//  Copyright © 2017 John Malatras. All rights reserved.
//

import Foundation
import UIKit
//import GoogleMobileAds

class HandicapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var HandicapTextField: UITextField!
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var TeamSizeControl: UISegmentedControl!
    @IBOutlet weak var TeamTypeControl: UISegmentedControl!
    
    var handicaps = [String: Int]()
    var players = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Captains Choice"
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        /*
        bannerView.adUnitID = "ca-app-pub-9379925034367531/8566277200"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())*/
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func AddButton(_ sender: Any) {
        insertNewPerson()
    }
    
    func insertNewPerson() {
        if NameTextField.text!.isEmpty && HandicapTextField.text!.isEmpty {
            createAlert(title: "Error", message: "Please enter a name and handicap.")
            return
            
        }
        else if NameTextField.text!.isEmpty {
            createAlert(title: "Error", message: "Please enter a name.")
            return
        }
        else if HandicapTextField.text!.isEmpty {
            createAlert(title: "Error", message: "Please enter a handicap.")
            return
        }
        
        players.append(NameTextField.text!)
        handicaps[NameTextField.text!] = Int(HandicapTextField.text!)!
        
        let indexPath = IndexPath(row: players.count - 1, section: 0)
        
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        NameTextField.text = ""
        HandicapTextField.text = ""
        view.endEditing(true)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return handicaps.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell") as! PersonTableViewCell
        cell.NameLabel.text = players[indexPath.row]
        cell.HandicapLabel.text = String(handicaps[players[indexPath.row]]!)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            handicaps.removeValue(forKey: players[indexPath.row])
            players.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    func createAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    
    @IBAction func GenerateButton(_ sender: Any) {
        var teamSize : Int
        switch TeamSizeControl.selectedSegmentIndex {
        case 0:
            teamSize = 2
        case 1:
            teamSize = 3
        case 2:
            teamSize = 4
        default:
            teamSize = 2
        }
        
        if players.count < teamSize {
            createAlert(title: "Error", message: "Can't create teams of " + String(teamSize) + " with " + String(players.count) + " players")
            return
        }
        
        var teams : [[(String, Int)]]
        if TeamTypeControl.selectedSegmentIndex == 0 {
            teams = TeamsHelper.generateFairestTeams(handicaps: handicaps, unsortedPlayers: players, teamSize: teamSize)
        } else {
            teams = TeamsHelper.generateRandomTeams(handicaps: handicaps, players: players, teamSize: teamSize)
        }
        
        let svc = storyboard?.instantiateViewController(withIdentifier: "TeamsViewController") as! TeamsViewController
        svc.teams = teams
        navigationController?.pushViewController(svc, animated: true)

    }
    
   
}
