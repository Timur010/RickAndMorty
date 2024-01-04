//
//  ViewController.swift
//  RickAndMorty
//
//  Created by Timur Kadiev on 22.11.2023.
//

import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTab()
    }

    private func setUpTab() {
        let charactersVC = CharacterViewController()
        let locationVC = LocationViewController()
        let episodesVC = EpisodeViewController()
        let settingsVC = SettingsViewController()
        
        let navCharacter = UINavigationController(rootViewController: charactersVC)
        let navLocation = UINavigationController(rootViewController: locationVC)
        let navEpisode = UINavigationController(rootViewController: episodesVC)
        let navSettings = UINavigationController(rootViewController: settingsVC)
        
        navCharacter.tabBarItem = UITabBarItem(title: "Character", image: UIImage(systemName: "person"), tag: 1)
        navLocation.tabBarItem = UITabBarItem(title: "Location", image: UIImage(systemName: "globe"), tag: 2)
        navEpisode.tabBarItem = UITabBarItem(title: "Episode", image: UIImage(systemName: "tv"), tag: 3)
        navSettings.tabBarItem = UITabBarItem(title: "Setting", image: UIImage(systemName: "gear"), tag: 4)

        setViewControllers([navCharacter, navLocation, navEpisode, navSettings], animated: true)
    }

}

