//
//  DataLoader.swift
//  ShareProject
//
//  Created by Vitaly on 12.09.2023.
//

import Foundation

struct DataLoader {
    static private var userDefaults = UserDefaults.standard
    
    /*var keys: String
    
    init(keys: String) {
        self.keys = keys
    }*/
    
    static func loadUserData(for keys: String) {
        guard let savedData = userDefaults.object(forKey: keys) as? Data else {
            print("Failed to load data for key: \(keys)")
            return
            }
        let jsonDecoder = JSONDecoder()
        
        do {
            switch keys {
            case "savedSymbols":
                UserSymbols.savedSymbols = try jsonDecoder.decode([Symbol].self, from: savedData)
            case "savedFullSymbolsData":
                SymbolsArray.symbols = try jsonDecoder.decode([Symbol].self, from: savedData)
            case "AuthToken":
                AuthToken.authToken = try jsonDecoder.decode(String.self, from: savedData)
            case "CurrentUser":
                SavedCurrentUser.user = try jsonDecoder.decode(CurrentUser.self, from: savedData)
            default:
                print("Unknown key: \(keys)")
            }
        } catch {
            print("Error decoding data for key: \(keys)")
        }
    }
    
    static func saveData(for keys: String) {
        let jsonEncoder = JSONEncoder()
        var dataToSave: Data?
        do {
            switch keys {
            case "savedSymbols":
                dataToSave = try? jsonEncoder.encode(UserSymbols.savedSymbols)
            case "savedAlarms":
                dataToSave = try? jsonEncoder.encode(AlarmModelsArray.alarms)
            case "savedFullSymbolsData":
                dataToSave = try? jsonEncoder.encode(SymbolsArray.symbols)
            case "AuthToken":
                dataToSave = try? jsonEncoder.encode(AuthToken.authToken)
            case "CurrentUser":
                dataToSave = try? jsonEncoder.encode(SavedCurrentUser.user)
            default:
                print("Error encoding data for key: \(keys)")
            }
        }
        
        guard let data = dataToSave else {
            print("Failed to save data for key: \(keys)")
            return
        }
        userDefaults.set(data, forKey: keys)
    }
}
