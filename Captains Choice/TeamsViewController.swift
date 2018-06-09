//
//  TeamsViewController.swift
//  Captains Choice
//
//  Created by John Malatras on 1/31/17.
//  Copyright © 2017 John Malatras. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
import Firebase

class TeamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var bannerView: GADBannerView!
    var teams = [[(String, Int)]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Result"
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // In this case, we instantiate the banner with desired ad size.
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-9379925034367531/1043010402"
        //bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //test ad
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    @IBAction func ShareButton(_ sender: Any) {
        shareTeams()
    }
    
    func shareTeams() {
        //Set the default sharing message.
        let message = generateTeamsMessage()

        let objectsToShare = [message]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        self.present(activityVC, animated: true, completion: nil)
    }
    
    func generateTeamsMessage() -> String{
        var message = String()
        for i in 0..<teams.count {
            message += ("Team " + String(i+1) + ":\n")
            for person in teams[i] {
                message += ("\t - " + person.0 + ", " + String(person.1) + "\n")
            }
        }
        
        return message
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return teams.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Team " + String(section+1) + ":"
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
    
    
}
