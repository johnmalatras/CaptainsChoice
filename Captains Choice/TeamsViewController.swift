//
//  TeamsViewController.swift
//  Captains Choice
//
//  Created by John Malatras on 1/31/17.
//  Copyright © 2017 John Malatras. All rights reserved.
//

import Foundation
import UIKit

class TeamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var teams = [[(String, Int)]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Captains Choice"
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
