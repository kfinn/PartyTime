//
//  PartyTimer.swift
//  PartyTime
//
//  Created by Kevin Finn on 1/6/22.
//

import Foundation
import HomeKit
import SwiftUI

class PartyTimer: NSObject, ObservableObject {
    @Published var selectedUUIDs = Set<UUID>() {
        didSet {
            selectedUUIDs.forEach { uuid in
                hueOffsetByUUID[uuid] = Int.random(in: 0...359)
            }
            
            let deselectedUUIDs = hueOffsetByUUID.keys.filter { key in !selectedUUIDs.contains(key) }
            deselectedUUIDs.forEach { key in hueOffsetByUUID.removeValue(forKey: key) }
        }
    }
    var hueOffsetByUUID = [UUID: Int]()
    var timer: Timer?
    
    override init() {
        super.init()
        timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(timerDidFire), userInfo: nil, repeats: true)
    }

    deinit {
        timer?.invalidate()
    }
    
    @objc func timerDidFire() {
        let baseHue = Int(Date.now.timeIntervalSinceReferenceDate * 60) % 360
        
        hueOffsetByUUID.forEach { uuid, hueOffset in
            guard let light = HomeManager.instance.lights.first(where: { light in light.uniqueIdentifier == uuid }) else { return }
            guard let hueCharacteristic = light.characteristics.first(where: { $0.characteristicType == HMCharacteristicTypeHue }) else { return }
            guard let brightnessCharacteristic = light.characteristics.first(where: { $0.characteristicType == HMCharacteristicTypeBrightness }) else { return }
            brightnessCharacteristic.writeValue(100) { maybeError in
                if let error = maybeError {
                    print("error setting brightness: \(error.localizedDescription)")
                }
            }
            let hue = Float((baseHue + hueOffset) % 360)
            print("setting \(light.name) hue to \(hue)\n")
            hueCharacteristic.writeValue(hue) { maybeError in
                if let error = maybeError {
                    print("error setting hue: \(error.localizedDescription)")
                }
            }
        }
    }
}
