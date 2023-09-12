//
//  DataLoader.swift
//  ShareProject
//
//  Created by Vitaly on 12.09.2023.
//

import Foundation

struct DataLoader {
    
    var userDefaults = UserDefaults.standard
    var keys = "savedSymbols"
    
    func loadUserSymbols() {
        if let savedSymbols = userDefaults.object(forKey: keys) as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                UserSymbols.savedSymbols = try jsonDecoder.decode([Symbol].self, from: savedSymbols)
            } catch {
                print("Failed to load symbols")
            }
        }
    }
    
    func saveData() {
        let jsonEncoder = JSONEncoder()
        if let dataToSave = try? jsonEncoder.encode(UserSymbols.savedSymbols) {
            userDefaults.set(dataToSave, forKey: keys)
        } else {
            print("Failed to save symbols")
        }
    }
    
    
}
