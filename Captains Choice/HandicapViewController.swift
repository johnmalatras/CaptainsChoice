//
//  HandicapViewController.swift
//  Captains Choice
//
//  Created by John Malatras on 1/30/17.
//  Copyright © 2017 John Malatras. All rights reserved.
//

import Foundation
import UIKit

class HandicapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var playerCount: Int!
    var playersPerTeam: Int!
    var handicaps = [String: Int]()
    var cellInputs = [Int: [String]]()
    var playerList = [String]()
    var cellCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Captains Choice"
        print(playerCount)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerCount
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextInputCell") as! TextInputTableViewCell
        cell.NameTF.tag = cellCount
        cell.HandicapTF.tag = cellCount
        cellCount += 1
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    @IBAction func GenerateButton(_ sender: Any) {
        let success = getTeamData()
        
        
        if success {
            let teams = generateTeams()
            
            let svc = storyboard?.instantiateViewController(withIdentifier: "TeamsViewController") as! TeamsViewController
            svc.teams = teams
            navigationController?.pushViewController(svc, animated: true)
        }
    }
    
    //--- generate teams by quicksorting and then picking from opposite ends of pivot to create fairest teams ---//
    func generateTeams() -> [[(String, Int)]] {
        
        // Find Total Mean Handicap
        var totalHandicap = 0
        for (player, handicap) in handicaps {
            totalHandicap += handicap
            playerList.append(player)
        }
        
        // perform a quick sort on the handicap values
        quickSort(low: 0, high: playerList.count - 1)
        
        // choose teams
        var select = true
        var teams = [[(String, Int)]]()
        var high = playerCount!
        var i = 0
        
        while i < high {
            var currentTeam = [(String, Int)]()
            for j in 0...playersPerTeam-1 {
                if select {
                    let person = (playerList[i + j], handicaps[playerList[i + j]]!)
                    currentTeam.append(person)
                    i += 1
                    select = false
                } else {
                    let person = (playerList[high - j], handicaps[playerList[high - j]]!)
                    currentTeam.append(person)
                    high -= 1
                    select = true
                }
            }
            teams.append(currentTeam)
        }
        
        
        return teams
    }
    
    func quickSort(low: Int, high: Int) {
        var i = low, j = high
        let pivot = handicaps[playerList[low + (high-low)/2]]
        
        while i <= j {
            while handicaps[playerList[i]]! < pivot! {
                i += 1
            }
            while handicaps[playerList[j]]! > pivot! {
                j -= 1
            }
            if i <= j {
                exchange(i: i, j: j)
                i += 1
                j -= 1
            }
        }
        
        // Recursion
        if low < j {
            quickSort(low: low, high: j)
        }
        if i < high {
            quickSort(low: i, high: high)
        }
    }
    
    func exchange (i: Int, j: Int) {
        let temp = playerList[i]
        playerList[i] = playerList[j]
        playerList[j] = temp
    }
    
    func getTeamData() -> Bool {
        var result = false
        for i in 0...tableView.numberOfRows(inSection: 0)-1 {
            let index = IndexPath(row: i, section: 0)
            let cell: TextInputTableViewCell = self.tableView.cellForRow(at: index) as! TextInputTableViewCell
            if let name = cell.NameTF.text, let playerHandicap = Int(cell.HandicapTF.text!), name != "" {
                result = true
                handicaps[name] = playerHandicap
           } else {
                let alertController = UIAlertController(title: "Enter all values", message: "Please enter a name (text) and handicap (number) for each player", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        return result
    }
    
    func nameEntered(tag: Int, text: String) {
        
    }
    
    func handicapEntered(tag: Int, text: String) {
        
    }
    
}
