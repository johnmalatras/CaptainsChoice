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
    
    var players: [(String, Int)] = []
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
    
    func refreshPlayerData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Players")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            players.removeAll()
            for data in result as! [NSManagedObject] {
                players.append((data.value(forKey: "name") as! String, data.value(forKey: "handicap") as! Int))
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
        cell.NameLabel.text = players[indexPath.row].0
        cell.HandicapLabel.text = String(players[indexPath.row].1)
        cell.AddButton.isEnabled = true
        if clicked.contains(indexPath.row) {
            cell.AddButton.isEnabled = false
            cell.AddButton.backgroundColor = UIColor.gray
        }
        cell.AddButton.tag = indexPath.row
        cell.AddButton.addTarget(self, action: #selector(PlayerBookViewController.addPlayerToCurrent(sender:)), for: .touchUpInside)
        return cell
    }
    
    func addPlayerToCurrent(sender: UIButton) {
        delegate?.addNewPlayerFromBook(player: (players[sender.tag].0, players[sender.tag].1))
        
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
