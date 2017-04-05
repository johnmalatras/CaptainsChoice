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

class TeamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var bannerView: GADBannerView!
    
    var teams = [[(String, Int)]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Captains Choice"
        
        bannerView.adUnitID = "ca-app-pub-9379925034367531/1043010402"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return teams.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Team: " + String(section+1)
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
