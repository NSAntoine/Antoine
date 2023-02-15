//
//  CreditsPerson.swift
//  Antoine
//
//  Created by Serena on 04/02/2023.
//

import Foundation

struct CreditsPerson: Codable, Hashable {
    // Note: If you ever want to add someone new to credits, do so here
    static let allContributors: [CreditsPerson] = [
        CreditsPerson(name: "Serena", role: "Developer, created app",
                      pfpURL: "https://github.com/SerenaKit.png",
                      socialLink: "https://twitter.com/CoreSerena"),
        CreditsPerson(name: "saagarjha", role: "Help with OSLog",
                      pfpURL: "https://github.com/saagarjha.png",
                      socialLink: "https://federated.saagarjha.com/users/saagar"),
        CreditsPerson(name: "Flower", role: "Icon designer",
                      pfpURL: "https://github.com/flowerible.png",
                      socialLink: "https://twitter.com/flowerible")
    ]
    
    let name: String
    let role: String
    let pfpURL: URL
    let socialLink: URL
}
