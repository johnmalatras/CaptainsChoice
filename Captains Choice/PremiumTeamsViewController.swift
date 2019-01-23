//
//  PremiumTeamsViewController.swift
//  Captains Choice
//
//  Created by John Malatras on 6/8/18.
//  Copyright © 2018 John Malatras. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class PremiumTeamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var teams = [[(String, Int)]]()
    var averageHandicaps = [Int]()
    var genType: String!
    var players: [String: Player]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = genType + " Generation Result"
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    @IBAction func ShareButton(_ sender: Any) {
        shareTeams()
    }
    
    func shareTeams() {
        //Set the default sharing message.
        let message = generateTeamsMessage()
        
        var phoneNumbers = [String]()
        for (_, player) in players {
            if let phoneNumber = player.phoneNumber {
                phoneNumbers.append(phoneNumber)
            }
        }
        
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.recipients = phoneNumbers
        composeVC.body = message
        
        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    
    func generateTeamsMessage() -> String{
        var message = String()
        for i in 0..<teams.count {
            message += ("Team " + String(i+1) + " (Avg Handicap = " + String(averageHandicaps[i]) + ")" + ":\n")
            for person in teams[i] {
                message += ("\t - " + person.0 + ", " + String(person.1) + "\n")
            }
        }

        return String(message.dropLast(1))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return teams.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Team " + String(section+1) + " (avg handicap = " + String(averageHandicaps[section]) + "):"
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams[section].count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamsCell")! as UITableViewCell
        let name = teams[indexPath.section][indexPath.row].0
        let handicap = String(teams[indexPath.section][indexPath.row].1)
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = handicap
        
        
        
        return cell
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }
}
