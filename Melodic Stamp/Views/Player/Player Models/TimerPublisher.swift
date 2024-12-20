//
//  TimerPublisher.swift
//  Melodic Stamp
//
//  Created by Xinshao_Air on 2024/12/19.
//

import Combine
import SFBAudioEngine
import SwiftUI

struct TimerPublisher: Publisher {
    let interval: TimeInterval
    let queue: DispatchQueue

    init(interval: TimeInterval, queue: DispatchQueue = .main) {
        self.interval = interval
        self.queue = queue
    }

    class Subscription<S>: Combine.Subscription where S: Subscriber, Never == S.Failure, CFTimeInterval == S.Input {
        private var timer: Timer?
        private let subscriber: S
        private let interval: TimeInterval

        fileprivate init(subscriber: S, interval: TimeInterval) {
            self.subscriber = subscriber
            self.interval = interval
        }

        func request(_ demand: Subscribers.Demand) {
            guard demand > .none else { return }
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                _ = self.subscriber.receive(Date().timeIntervalSince1970)
            }
        }

        func cancel() {
            timer?.invalidate()
            timer = nil
        }
    }

    func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, CFTimeInterval == S.Input {
        let subscription = Subscription(subscriber: subscriber, interval: interval)
        subscriber.receive(subscription: subscription)
    }

    typealias Output = CFTimeInterval
    typealias Failure = Never
}
