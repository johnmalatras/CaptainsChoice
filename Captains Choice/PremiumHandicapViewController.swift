//
//  PremiumHandicapViewController.swift
//  Captains Choice
//
//  Created by John Malatras on 6/6/18.
//  Copyright © 2018 John Malatras. All rights reserved.
//


import Foundation
import UIKit
import GoogleMobileAds
import Firebase
import CoreData

class PremiumHandicapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PassPlayerProtocol {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var HandicapTextField: UITextField!
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var TeamSizeControl: UISegmentedControl!
    @IBOutlet weak var TeamTypeControl: UISegmentedControl!
    
    var bannerView: GADBannerView!
    var handicaps = [String: Int]()
    var players = [String]()
    var valueFromPlayerBook : [Player]?
    var clicked = [Int]()
    
    //todo: consolidate so logic only uses this map instead of handicaps and players
    var playerMap = [String: Player]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Enter Players"
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.layer.borderWidth = 0.5
        tableView.layer.borderColor = UIColor.gray.cgColor
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let playersToAdd = valueFromPlayerBook {
            for player in playersToAdd {
                insertNewPerson(player: player)
            }
        }
        valueFromPlayerBook = nil
    }
    
    @IBAction func AddButton(_ sender: Any) {
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
        
        if let name = NameTextField.text, let handicap = Int(HandicapTextField.text!) {
            insertNewPerson(player: Player(name: name, flight: nil, phoneNumber: nil, handicap: Int16(handicap)))
        } else {
            createAlert(title: "Error", message: "Invalid input.")
        }
    }
    
    func insertNewPerson(player: Player) {
        if (handicaps[player.name] != nil) {
            createAlert(title: "Error", message: "Name already exists.")
            return
        }
        
        players.append(player.name)
        handicaps[player.name] = Int(player.handicap)
        playerMap[player.name] = player
        
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
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
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
        generateTeams()
    }
    
    func generateTeams() {
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
        var genType: String
        if TeamTypeControl.selectedSegmentIndex == 0 {
            genType = "Fairest"
            teams = TeamsHelper.generateFairestTeams(handicaps: handicaps, unsortedPlayers: players, teamSize: teamSize)
        }
        else if TeamTypeControl.selectedSegmentIndex == 1 {
            genType = "Flight"
            teams = TeamsHelper.generateFlightTeams(handicaps: handicaps, unsortedPlayers: players, teamSize: teamSize)
        } else {
            genType = "Random"
            teams = TeamsHelper.generateRandomTeams(handicaps: handicaps, origPlayers: players, teamSize: teamSize)
        }
        
        let svc = storyboard?.instantiateViewController(withIdentifier: "PremiumTeamsViewController") as! PremiumTeamsViewController
        svc.teams = teams
        svc.averageHandicaps = calculateAverageHandicaps(teams: teams)
        svc.genType = genType
        svc.players = playerMap
        navigationController?.pushViewController(svc, animated: true)
    }
    
    func calculateAverageHandicaps(teams : [[(String, Int)]]) -> [Int] {
        var averageHandicaps = [Int]()
        for i in 0..<teams.count {
            var total = 0
            for player in teams[i] {
                total += player.1
            }
            averageHandicaps.append(total/teams[i].count)
        }
        
        return averageHandicaps
    }
    
    @IBAction func SaveButton(_ sender: Any) {
        savePlayer()
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
                self.insertNewPerson(player: Player(name: name, flight: flight, phoneNumber: phoneNumber, handicap: Int16(handicap)))
            } else {
                self.createAlert(title: "Error", message: "Invalid input.")
            }
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            if self.NameTextField.text == nil || self.NameTextField.text == "" {
                textField.placeholder = "Name"
            } else {
                textField.text = self.NameTextField.text
            }
        }
        alertController.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "Phone Number"
        }
        alertController.addTextField { (textField) in
            textField.keyboardType = .numberPad
            if self.HandicapTextField.text == nil || self.HandicapTextField.text == "" {
                textField.placeholder = "Handicap"
            } else {
                textField.text = self.HandicapTextField.text
            }
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
    
    func addNewPlayerFromBook(player: Player) {
        if valueFromPlayerBook == nil {
            valueFromPlayerBook = [Player]()
        }
        self.valueFromPlayerBook!.append(player)
    }
    
    @IBAction func PlayerBookClicked(_ sender: Any) {
        let playerBookController = self.storyboard?.instantiateViewController(withIdentifier: "PlayerBookViewController") as! PlayerBookViewController
        playerBookController.delegate = self
        playerBookController.clicked = clicked
        self.navigationController?.pushViewController(playerBookController, animated: true)
    }
}
