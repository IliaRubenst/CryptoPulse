//
//  DataLoader.swift
//  ShareProject
//
//  Created by Vitaly on 12.09.2023.
//

import Foundation
import LightweightCharts

struct DataLoader {
    
    var userDefaults = UserDefaults.standard
    var keys = String()
    
    func loadUserSymbols() {
        if keys == "savedSymbols" {
            if let savedSymbols = userDefaults.object(forKey: keys) as? Data {
                let jsonDecoder = JSONDecoder()
                do {
                    UserSymbols.savedSymbols = try jsonDecoder.decode([Symbol].self, from: savedSymbols)
                } catch {
                    print("Failed to load symbols")
                }
            }
        } else if keys == "savedAlarms" {
            if let savedSymbols = userDefaults.object(forKey: keys) as? Data {
                let jsonDecoder = JSONDecoder()
                do {
                    AlarmModelsArray.alarms = try jsonDecoder.decode([AlarmModel].self, from: savedSymbols)
                } catch {
                    print("Failed to load symbols")
                }
            }
        } /*else if keys == "savedLines" {
            if let savedSymbols = userDefaults.object(forKey: keys) as? Data {
                let jsonDecoder = JSONDecoder()
                do {
                    AlarmModelsArray.alarmaLine = try jsonDecoder.decode([PriceLine].self, from: savedSymbols)
                } catch {
                    print("Failed to load symbols")
                }
            }
        }*/
        
    }
    
    func saveData() {
        let jsonEncoder = JSONEncoder()
        if keys == "savedSymbols" {
            if let dataToSave = try? jsonEncoder.encode(UserSymbols.savedSymbols) {
                userDefaults.set(dataToSave, forKey: keys)
            } else {
                print("Failed to save symbols")
            }
        } else if keys == "savedAlarms" {
            if let dataToSave = try? jsonEncoder.encode(AlarmModelsArray.alarms) {
                userDefaults.set(dataToSave, forKey: keys)
            } else {
                print("Failed to save symbols")
            }
        } /*else if keys == "savedLines" {
            if let dataToSave = try? jsonEncoder.encode(AlarmModelsArray.alarmaLine) {
                userDefaults.set(dataToSave, forKey: keys)
            } else {
                print("Failed to save symbols")
            }
        }*/
        
    }
}
