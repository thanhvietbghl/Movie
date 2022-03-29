//
//  NetworkMonitor.swift
//  Base_Movie
//
//  Created by Viet Phan on 24/03/2022.
//

import Foundation
import Network
import RxSwift

class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    var networkStatus = PublishSubject<NWPath.Status>()

    private let monitor = NWPathMonitor()
    
    private init() { }
    
    func startListen() {
        monitor.pathUpdateHandler = { [weak self] path in
            let status = path.status
            self?.networkStatus.onNext(status)
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}
