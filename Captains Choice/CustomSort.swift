//
//  CustomSort.swift
//  Captains Choice
//
//  Created by John Malatras on 5/19/18.
//  Copyright © 2018 John Malatras. All rights reserved.
//

import Foundation

class CustomSort {
    
    var handicaps = [String: Int]()
    var players = [String]()
    
    init(handicaps: [String: Int], players: [String]) {
        self.handicaps = handicaps
        self.players = players
    }
    
    func sortPlayers() -> [String] {
        quickSort(low: 0, high: players.count-1)
        return players
    }
    
    // custom quick sort
    func quickSort(low: Int, high: Int) {
        var i = low, j = high
        let pivot = handicaps[players[low + (high-low)/2]]
        
        while i <= j {
            while handicaps[players[i]]! < pivot! {
                i += 1
            }
            while handicaps[players[j]]! > pivot! {
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
        let temp = players[i]
        players[i] = players[j]
        players[j] = temp
    }
}
