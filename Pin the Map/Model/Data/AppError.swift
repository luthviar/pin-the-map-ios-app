//
//  AppError.swift
//  Pin the Map
//
//  Created by Luthfi Abdurrahim on 24/07/21.
//

import Foundation

public enum AppError: Error {
    case networkError
}

extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .networkError:
            return NSLocalizedString("No network is connected.", comment: "")
        }
    }
}
