//
//  DIContainer.swift
//  EUMMEYO
//
//  Created by 김동현 on 12/22/24.
//

import Foundation

class DIContainer: ObservableObject {
    var services: ServiceType
    
    init(services: ServiceType) {
        self.services = services
    }
}

extension DIContainer {
    static var stub: DIContainer {
        .init(services: StubService())
    }
}
