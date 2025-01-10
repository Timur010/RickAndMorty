//
//  RickAndMortyApp.swift
//  RickAndMorty
//
//  Created by Timur Kadiev on 09.01.2025.
//

import SwiftUI

@main
struct RickAndMortyApp: App {
    @StateObject private var viewModel = CharactersViewModel()

    var body: some Scene {
        WindowGroup {
            CharacterListView()
                .environmentObject(viewModel)
        }
    }
}
