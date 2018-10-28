//
//  TeamsHelper.swift
//  Captains Choice
//
//  Created by John Malatras on 5/19/18.
//  Copyright © 2018 John Malatras. All rights reserved.
//

import Foundation

class TeamsHelper{
    
    static func generateRandomTeams(handicaps: [String: Int], origPlayers: [String], teamSize: Int) -> [[(String, Int)]] {
        var teams = [[(String, Int)]]()
        var players = origPlayers
        
        var k = 0
        while (players.count % teamSize != 0) {
            players.append(players[k])
            k += 1
        }
        
        let randomizedPlayers = players.shuffled()
        let teamCount = players.count/teamSize
        for i in 0..<teamCount {
            var team = [(String, Int)]()
            for j in 0..<teamSize {
                let currentPlayer = randomizedPlayers[i*teamSize+j]
                team.append((currentPlayer, handicaps[currentPlayer]!))
            }
            teams.append(team)
        }
        
        return teams
    }
    
    static func generateFairestTeams(handicaps: [String: Int], unsortedPlayers: [String], teamSize: Int) -> [[(String, Int)]] {
        let customSort = CustomSort(handicaps: handicaps, players: unsortedPlayers)
        var players = customSort.sortPlayers()
        
        var teams = [[(String, Int)]]()
        
        var k = 0
        while (players.count % teamSize != 0) {
            players.append(players[k])
            k += 1
        }
        
        let numberOfTeams = (players.count / teamSize == 1) ? players.count : players.count / teamSize
        var i = 0
        while i < players.count && i < numberOfTeams {
            teams.append([(String, Int)]())
            teams[i].append((players[i], handicaps[players[i]]!))
            i += 1
        }
        
        var j = players.count - 1
        while i <= j {
            let addPosition = (numberOfTeams-1)-(j%numberOfTeams)
            teams[addPosition].append((players[j], handicaps[players[j]]!))
            j -= 1
        }
        
        return teams
    }
    
    //--
    static func generateFlightTeams(handicaps: [String: Int], unsortedPlayers: [String], teamSize: Int) -> [[(String, Int)]] {
        
        // sort handicap values
        let customSort = CustomSort(handicaps: handicaps, players: unsortedPlayers)
        var players = customSort.sortPlayers()

        var teams = [[(String, Int)]]()

        var k = 0
        while (players.count % teamSize != 0) {
            players.append(players[k])
            k += 1
        }
        
        let teamCount = players.count/teamSize
        let subgroups = generateSubgroups(players: players, teamSize: teamSize, teamCount: teamCount)
        let randomizedSubgroups = randomizeSubgroups(subgroups: subgroups, teamSize: teamSize)
        
        for i in 0..<teamSize {
            var currentTeam = 0
            for j in 0..<teamCount {
                let currentPlayer = randomizedSubgroups[i][j]
                if teams.count-1 < currentTeam {
                    teams.append([(String, Int)]())
                }
                teams[currentTeam].append((currentPlayer, handicaps[currentPlayer]!))
                
                currentTeam = currentTeam + 1
            }
            currentTeam = 0
        }
        
        return teams
    }
    
    static func generateSubgroups(players: [String], teamSize: Int, teamCount: Int) -> [[String]] {
        var subgroups = [[String]]()
        for i in 0..<teamSize {
            var group = [String]()
            for j in 0..<teamCount {
                group.append(players[i*teamCount+j])
            }
            subgroups.append(group)
        }
        
        return subgroups
    }
    
    static func randomizeSubgroups(subgroups: [[String]] , teamSize: Int) -> [[String]] {
        var randomizedSubgroups = [[String]]()
        for i in 0..<teamSize {
            randomizedSubgroups.append(subgroups[i].shuffled())
        }
        
        return randomizedSubgroups
    }
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
