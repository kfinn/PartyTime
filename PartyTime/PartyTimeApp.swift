//
//  PartyTimeApp.swift
//  PartyTime
//
//  Created by Kevin Finn on 1/5/22.
//

import SwiftUI

@main
struct PartyTimeApp: App {
    @ObservedObject var homeManager = HomeManager.instance
    @StateObject private var partyTimer = PartyTimer()
    
    var body: some Scene {
        WindowGroup {
            List(homeManager.lights, selection: $partyTimer.selectedUUIDs) {
                Text($0.name)
            }
            .environment(\.editMode, .constant(.active))
        }
    }
}
