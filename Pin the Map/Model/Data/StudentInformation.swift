//
//  StudentInformation.swift
//  Pin the Map
//
//  Created by Luthfi Abdurrahim on 21/07/21.
//

import Foundation

struct StudentInformation: Codable {
    let createdAt: String?
    let firstName: String
    let lastName: String
    let latitude: Double?
    let longitude: Double?
    let mapString: String?
    let mediaURL: String?
    let objectId: String?
    let uniqueKey: String?
    let updatedAt: String?
    
    init(_ data: [String: AnyObject]) {
        self.createdAt = data["createdAt"] as? String
        self.uniqueKey = data["uniqueKey"] as? String ?? ""
        self.firstName = data["firstName"] as? String ?? ""
        self.lastName = data["lastName"] as? String ?? ""
        self.mapString = data["mapString"] as? String ?? ""
        self.mediaURL = data["mediaURL"] as? String ?? ""
        self.latitude = data["latitude"] as? Double ?? 0.0
        self.longitude = data["longitude"] as? Double ?? 0.0
        self.objectId = data["objectId"] as? String
        self.updatedAt = data["updatedAt"] as? String
    }
}
