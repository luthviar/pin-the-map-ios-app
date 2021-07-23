//
//  UserProfile.swift
//  Pin the Map
//
//  Created by Luthfi Abdurrahim on 21/07/21.
//

import Foundation

struct UserProfile: Codable {
    let firstName: String
    let lastName: String
    let nickname: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case nickname
    }
 
}
