//
//  NetworkUtils.swift
//  MoodTracker
//
//  Created by Paul on 4/23/25.
//

import Network

class NetworkUtils {
    static let shared = NetworkUtils()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    private(set) var isConnected: Bool = false

    private init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
        monitor.start(queue: queue)
    }
}
