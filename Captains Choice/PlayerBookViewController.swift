//
//  PlayerBookViewController.swift
//  Captains Choice
//
//  Created by John Malatras on 6/8/18.
//  Copyright © 2018 John Malatras. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PlayerBookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var players: [Players] = []
    var clicked = Set<Players>()
    var delegate : PremiumHandicapViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Player Book"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Player", style: .done, target: self, action: #selector(savePlayer))
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "SFProText-Regular", size: 15)!], for: .normal)
        
        refreshPlayerData()
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            delegate?.clicked = clicked
        }
    }
    
    func updatePlayerData(player: Players, newName: String, newHandicap: Int16, newFlight: String, newPhone: String) {
        player.name = newName
        player.handicap = newHandicap
        player.flight = newFlight
        player.phone = newPhone
        
        self.refreshPlayerData()
    }
    
    func refreshPlayerData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Players")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            players.removeAll()
            for player in result as! [Players] {
                players.append(player)
            }
            
        } catch {
            print("Failed")
        }
        
        self.tableView.reloadData()
    }
    
    func deletePlayer(player: Players) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        context.delete(player)
        
        do {
            try context.save()
        } catch {
            createAlert(title: "An error occured", message: "Couldn't delete player")
        }
        refreshPlayerData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            deletePlayer(player: players[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerBookCell", for: indexPath) as! PlayerBookCell
        cell.selectionStyle = .none
        cell.NameLabel.text = players[indexPath.row].name
        cell.HandicapLabel.text = String(players[indexPath.row].handicap)
        cell.AddButton.isEnabled = true
        if clicked.contains(players[indexPath.row]) {
            cell.AddButton.isEnabled = false
            cell.AddButton.backgroundColor = UIColor.gray
        }
        cell.AddButton.tag = indexPath.row
        cell.AddButton.addTarget(self, action: #selector(PlayerBookViewController.addPlayerToCurrent(sender:)), for: .touchUpInside)
        cell.EditButton.tag = indexPath.row
        cell.EditButton.addTarget(self, action: #selector(PlayerBookViewController.editPlayer(sender:)), for: .touchUpInside)
        return cell
    }
    
    @objc func editPlayer(sender: UIButton) {
        let alertController = UIAlertController(title: "Update Player Information", message: "Enter player name, phone number, handicap and flight.", preferredStyle: .alert)
        
        let selectedPlayer = players[sender.tag]
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            var name: String
            if alertController.textFields?[0].text != "", let nameInput = alertController.textFields?[0].text {
                name = nameInput
            } else {
                if alertController.textFields?[0].text != nil, alertController.textFields?[0].text != "" {
                    self.createAlert(title: "Error", message: "Invalid input.")
                }
                name = selectedPlayer.name!
            }
            
            var phoneNumber: String
            if alertController.textFields?[1].text != "", let phoneInput = alertController.textFields?[1].text {
                phoneNumber = phoneInput
            } else {
                if alertController.textFields?[1].text != nil, alertController.textFields?[1].text != "" {
                    print("phone flag")
                    self.createAlert(title: "Error", message: "Invalid input.")
                }
                phoneNumber = selectedPlayer.phone!
            }
            
            var handicap: Int16
            if alertController.textFields?[2].text != "", let handicapInput = Int16((alertController.textFields?[2].text)!) {
                handicap = handicapInput
            } else {
                if alertController.textFields?[2].text != nil, alertController.textFields?[2].text != "" {
                    print("handicap flag")
                    self.createAlert(title: "Error", message: "Invalid input.")
                }
                handicap = selectedPlayer.handicap
            }
            
            var flight: String
            if alertController.textFields?[3].text != "", let flightInput = alertController.textFields?[3].text {
                flight = flightInput
            } else {
                if alertController.textFields?[3].text != nil, alertController.textFields?[3].text != "" {
                    print("flight flag")
                    self.createAlert(title: "Error", message: "Invalid input.")
                }
                flight = selectedPlayer.flight!
            }
            
            self.updatePlayerData(player: selectedPlayer, newName: name, newHandicap: handicap, newFlight: flight, newPhone: phoneNumber)
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = selectedPlayer.name
        }
        alertController.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = selectedPlayer.phone
        }
        alertController.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "Handicap: " + String(selectedPlayer.handicap)
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Flight: " + selectedPlayer.flight!
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func addPlayerToCurrent(sender: UIButton) {
        let player = Player(name: players[sender.tag].name!, flight: players[sender.tag].flight, phoneNumber: players[sender.tag].phone, handicap: players[sender.tag].handicap)
        delegate?.addNewPlayerFromBook(player: player)
        
        clicked.insert(players[sender.tag])
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! HeaderCell
        cell.NameLabel.text = "Name"
        cell.HandicapLabel.text = "Handicap"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func saveToDB(name: String, phoneNumber: String, handicap : Int, flight : String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Players", in: context)
        let player = NSManagedObject(entity: entity!, insertInto: context)
        
        player.setValue(name, forKey: "name")
        player.setValue(handicap, forKey: "handicap")
        player.setValue(phoneNumber, forKey: "phone")
        player.setValue(flight, forKey: "flight")
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
            createAlert(title: "Error", message: "Couldn't save player information.")
        }
    }
    
    @objc func savePlayer() {
        let alertController = UIAlertController(title: "Enter Player Information", message: "Enter player name, phone number, handicap and flight.", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            //getting the input values from user
            if let name = alertController.textFields?[0].text, let phoneNumber = alertController.textFields?[1].text, let handicap = Int((alertController.textFields?[2].text)!), let flight = alertController.textFields?[3].text {
                self.saveToDB(name: name, phoneNumber: phoneNumber, handicap: handicap, flight: flight)
                self.refreshPlayerData()
            } else {
                self.createAlert(title: "Error", message: "Invalid input.")
            }
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.autocapitalizationType = UITextAutocapitalizationType.words
            textField.placeholder = "Name"
        }
        alertController.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "Phone Number"
        }
        alertController.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "Handicap"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Flight"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    func createAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

protocol PassPlayerProtocol {
    func addNewPlayerFromBook(player: Player)
}
