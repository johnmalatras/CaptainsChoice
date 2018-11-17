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
    
    var players: [Player] = []
    var clicked = [Int]()
    var delegate : PremiumHandicapViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Player Book"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Player", style: .done, target: self, action: #selector(savePlayer))
        
        refreshPlayerData()
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController {
            delegate?.clicked = clicked
        }
    }
    
    func updatePlayerData(player: Player, newName: String, newHandicap: Int, newFlight: String, newPhone: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Players")
        fetchRequest.predicate = NSPredicate(format: "name = %@", player.name)
        do
        {
            let res = try context.fetch(fetchRequest)
            
            let objectUpdate = res[0] as! NSManagedObject
            objectUpdate.setValue(newName, forKey: "name")
            objectUpdate.setValue(newPhone, forKey: "phone")
            objectUpdate.setValue(newHandicap, forKey: "handicap")
            objectUpdate.setValue(newFlight, forKey: "flight")
            do{
                try context.save()
            }
            catch
            {
                print(error)
            }
        }
        catch
        {
            print(error)
        }
    }
    
    func refreshPlayerData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Players")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            players.removeAll()
            for data in result as! [NSManagedObject] {
                players.append(Player(name: data.value(forKey: "name") as! String, flight: data.value(forKey: "flight") as! String, phoneNumber: data.value(forKey: "phone") as! String, handicap: Int16(data.value(forKey: "handicap") as! Int)))
            }
            
        } catch {
            print("Failed")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerBookCell", for: indexPath) as! PlayerBookCell
        cell.selectionStyle = .none
        cell.NameLabel.text = players[indexPath.row].name
        cell.HandicapLabel.text = String(players[indexPath.row].handicap)
        cell.AddButton.isEnabled = true
        if clicked.contains(indexPath.row) {
            cell.AddButton.isEnabled = false
            cell.AddButton.backgroundColor = UIColor.gray
        }
        cell.AddButton.tag = indexPath.row
        cell.AddButton.addTarget(self, action: #selector(PlayerBookViewController.addPlayerToCurrent(sender:)), for: .touchUpInside)
        cell.EditButton.tag = indexPath.row
        cell.EditButton.addTarget(self, action: #selector(PlayerBookViewController.editPlayer(sender:)), for: .touchUpInside)
        return cell
    }
    
    func editPlayer(sender: UIButton) {
        let alertController = UIAlertController(title: "Update Player Information", message: "Enter player name, phone number, handicap and flight.", preferredStyle: .alert)
        
        let selectedPlayer = players[sender.tag]
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            var name: String
            if alertController.textFields?[0].text != "", let nameInput = alertController.textFields?[0].text {
                name = nameInput
            } else {
                if alertController.textFields?[0].text != nil, alertController.textFields?[0].text != "" {
                    print("name flag")
                    self.createAlert(title: "Error", message: "Invalid input.")
                }
                name = selectedPlayer.name
            }
            
            var phoneNumber: String
            if alertController.textFields?[1].text != "", let phoneInput = alertController.textFields?[1].text {
                phoneNumber = phoneInput
            } else {
                if alertController.textFields?[1].text != nil, alertController.textFields?[1].text != "" {
                    print("phone flag")
                    self.createAlert(title: "Error", message: "Invalid input.")
                }
                phoneNumber = selectedPlayer.phoneNumber
            }
            
            var handicap: Int
            if alertController.textFields?[2].text != "", let handicapInput = Int((alertController.textFields?[2].text)!) {
                handicap = handicapInput
            } else {
                if alertController.textFields?[2].text != nil, alertController.textFields?[2].text != "" {
                    print("handicap flag")
                    self.createAlert(title: "Error", message: "Invalid input.")
                }
                handicap = Int(selectedPlayer.handicap)
            }
            
            var flight: String
            if alertController.textFields?[3].text != "", let flightInput = alertController.textFields?[3].text {
                flight = flightInput
            } else {
                if alertController.textFields?[3].text != nil, alertController.textFields?[3].text != "" {
                    print("flight flag")
                    self.createAlert(title: "Error", message: "Invalid input.")
                }
                flight = selectedPlayer.flight
            }
            
            self.updatePlayerData(player: selectedPlayer, newName: name, newHandicap: handicap, newFlight: flight, newPhone: phoneNumber)
            self.refreshPlayerData()
            self.tableView.reloadData()
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = selectedPlayer.name
        }
        alertController.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = selectedPlayer.phoneNumber
        }
        alertController.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "Handicap: " + String(selectedPlayer.handicap)
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Flight: " + selectedPlayer.flight
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addPlayerToCurrent(sender: UIButton) {
        delegate?.addNewPlayerFromBook(player: (players[sender.tag].name, Int(players[sender.tag].handicap)))
        
        clicked.append(sender.tag)
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
    
    func savePlayer() {
        let alertController = UIAlertController(title: "Enter Player Information", message: "Enter player name, phone number, handicap and flight.", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            //getting the input values from user
            if let name = alertController.textFields?[0].text, let phoneNumber = alertController.textFields?[1].text, let handicap = Int((alertController.textFields?[2].text)!), let flight = alertController.textFields?[3].text {
                self.saveToDB(name: name, phoneNumber: phoneNumber, handicap: handicap, flight: flight)
                self.refreshPlayerData()
                self.tableView.reloadData()
            } else {
                self.createAlert(title: "Error", message: "Invalid input.")
            }
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
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
    func addNewPlayerFromBook(player: (String, Int))
}
