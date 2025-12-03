//
//  Models.swift
//  Smoking
//
//  Created by Raffaele Barra on 03/12/25.
//

import Foundation

struct SpaceMock: Identifiable {
    let id: String
    let name: String
    let type: String // "collab" or "balcony"
    let status: SpaceStatus
    let description: String
}

enum SpaceStatus {
    case free
    case occupied
}
