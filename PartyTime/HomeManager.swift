//
//  LightsCollection.swift
//  PartyTime
//
//  Created by Kevin Finn on 1/6/22.
//

import Foundation
import HomeKit

class HomeManager: NSObject, ObservableObject {
    static var instance = HomeManager()
    
    @Published var loaded = false
    @Published var homes: [HMHome] = []
    @Published var rooms: [HMRoom] = []
    @Published var lights: [HMService] = []
    
    private var homeManager: HMHomeManager;
    
    override init() {
        homeManager = HMHomeManager()
        super.init()
        homeManager.delegate = self
    }
}

extension HomeManager: HMHomeManagerDelegate {
    static let REQUIRED_LIGHT_CHARACTERISTICS = [
        HMCharacteristicTypeHue,
        HMCharacteristicTypeSaturation
    ]
    
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        homes = manager.homes
        if let primaryHome = manager.primaryHome {
            rooms = primaryHome.rooms
            if let allLights = primaryHome.servicesWithTypes([HMServiceTypeLightbulb]) {
                lights = allLights.filter { service in
                    let serviceCharacteristics = service.characteristics.map { $0.characteristicType }
                    return HomeManager.REQUIRED_LIGHT_CHARACTERISTICS.allSatisfy { requiredCharacteristic in
                        serviceCharacteristics.contains(requiredCharacteristic)
                    }
                }
            }
        }
        loaded = true
    }
}

extension HMService: Identifiable {
    public typealias ID = UUID
    public var id: UUID {
        get {
            return uniqueIdentifier
        }
    }
}
