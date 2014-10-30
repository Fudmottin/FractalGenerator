//
//  GCDThreading.swift
//  FractalGenerator

import Foundation

// I would like this to be a singleton class.
final class GCDThreading {

    private struct S {
        static let computationQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
        static let computationGroup = dispatch_group_create()
        static let serialGroup = dispatch_group_create()
        static let serialQueue = dispatch_queue_create("com.Fudmottin.serial.queue", DISPATCH_QUEUE_SERIAL)
        static let singletonInstance = GCDThreading()
    }

    internal class var instance: GCDThreading { get { return S.singletonInstance } }
    private init() {}

    class func runOnComputationThread(process: dispatch_block_t) {
        dispatch_group_async(S.computationGroup, S.computationQueue, process)
    }

    class func runTimes(iterations: UInt, block: ((count: UInt) -> Void)) {
        dispatch_apply(iterations, S.computationQueue!, block)
    }

    class func runOnSerialThread(process: dispatch_block_t) {
        dispatch_group_async(S.serialGroup, S.serialQueue, process)
    }

    class func runOnMainThread(process: dispatch_block_t) {
        dispatch_async(dispatch_get_main_queue(), process)
    }

    class func waitAll() {
        dispatch_group_wait(S.computationGroup, DISPATCH_TIME_FOREVER)
        dispatch_group_wait(S.serialGroup, DISPATCH_TIME_FOREVER)
    }

    class func run() {
        dispatch_main()
    }
}

let threads = GCDThreading.self

