//
//  HandicapViewController.swift
//  Captains Choice
//
//  Created by John Malatras on 1/30/17.
//  Copyright © 2017 John Malatras. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class HandicapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var playerCount: Int!
    var playersPerTeam: Int!
    var handicaps = [String: Int]()
    var cellInputs = [Int: [String]]()
    var playerList = [String]()
    var cellCount = 0
    var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Captains Choice"
        
        bannerView.adUnitID = "ca-app-pub-9379925034367531/8566277200"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        createAndLoadInterstitial()
    }

    
    func showAd() {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
        // Give user the option to start the next game.
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
        cell.delegate = self
        cellCount += 1
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    @IBAction func GenerateButton(_ sender: Any) {
        showAd()
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
        
        while playerList.count > 1 {
            var currentTeam = [(String, Int)]()
            for j in 0...playersPerTeam-1 {
                if playerList.count == 1 {
                    let person = (playerList[0], handicaps[playerList[0]]!)
                    currentTeam.append(person)
                } else {
                    if select {
                        let person = (playerList[0], handicaps[playerList[0]]!)
                        currentTeam.append(person)
                        playerList.remove(at: 0)
                        select = false
                    } else {
                        let person = (playerList[playerList.count - 1], handicaps[playerList[playerList.count - 1]]!)
                        currentTeam.append(person)
                        playerList.remove(at: playerList.count - 1)
                        select = true
                    }
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
        if cellInputs.count == playerCount {
            for (tag, values) in cellInputs {
                handicaps[values[0]] = Int(values[1])
            }
            return true
        }
        
        let alertController = UIAlertController(title: "Missing Values", message: "Please enter a name and handicap for each player.", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        return false
    }
    
    func nameEntered(tag: Int, text: String) {
        if var cellInfo = cellInputs[tag] {
            cellInfo[0] = text
            cellInputs[tag] = cellInfo
        } else  {
            let cellInfo = [text, ""]
            cellInputs[tag] = cellInfo
        }
    }
    
    func handicapEntered(tag: Int, text: String) {
        if let handicapInt = Int(text) {
            if var cellInfo = cellInputs[tag] {
                cellInfo[1] = text
                cellInputs[tag] = cellInfo
            } else  {
                let cellInfo = ["", text]
                cellInputs[tag] = cellInfo
            }
        } else {
            let alertController = UIAlertController(title: "Invalid Value", message: "Please enter only whole numbers as your handicap.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func createAndLoadInterstitial() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-9379925034367531/3717275202")
        let request = GADRequest()
        // Request test ads on devices you specify. Your test device ID is printed to the console when
        // an ad request is made.
        //request.testDevices = [ kGADSimulatorID, "2077ef9a63d2b398840261c8221a0c9b" ]
        interstitial.load(request)
    }
    
}
