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
import Firebase

class HandicapViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var HandicapTextField: UITextField!
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var TeamSizeControl: UISegmentedControl!
    @IBOutlet weak var TeamTypeControl: UISegmentedControl!
    
    var bannerView: GADBannerView!
    var handicaps = [String: Int]()
    var players = [String]()
    let premiumIdentifier = "com.malatras.CaptainsChoice.premium"
    typealias FinishedPurchase = () -> ()
    
    //todo: consolidate so logic only uses this map instead of handicaps and players
    var playerMap = [String: Player]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Enter Players"
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.layer.borderWidth = 0.5
        tableView.layer.borderColor = UIColor.gray.cgColor
        
        self.extendedLayoutIncludesOpaqueBars = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor(red: 10, green: 129, blue: 22)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "SFProText-Regular", size: 18)!]
        
        TeamSizeControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProText-Regular", size: 13)!], for: .normal)
        TeamTypeControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SFProText-Regular", size: 13)!], for: .normal)
        
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-9379925034367531/8566277200"
        //bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //test ad
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        self.HandicapTextField.delegate = self
        self.NameTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(HandicapViewController.handlePurchaseNotification(_:)),
                                               name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
                                               object: nil)
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        } else {
            genType = "Flight"
            teams = TeamsHelper.generateRandomTeams(handicaps: handicaps, origPlayers: players, teamSize: teamSize)
        }
        
        let svc = storyboard?.instantiateViewController(withIdentifier: "TeamsViewController") as! TeamsViewController
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
    
    @IBAction func BuyPremiumButton(_ sender: Any) {
        buyPremium()
    }
    
    func buyPremium() {
        PremiumProduct.store.requestProducts{success, products in
            if success {
                let product = products![0]
                PremiumProduct.store.buyProduct(product)
            }
        }
    }

    func segueToPremium() {
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nav = mainStoryboard.instantiateViewController(withIdentifier: "PremiumNavigationController") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = nav
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        segueToPremium()
    }
}

extension HandicapViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
