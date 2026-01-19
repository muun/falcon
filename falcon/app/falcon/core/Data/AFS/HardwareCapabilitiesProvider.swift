//
//  HardwareCapabilitiesProvider.swift
//
//  Created by Lucas Serruya on 01/02/2023.
//

import UIKit
import CoreMotion

public class HardwareCapabilitiesProvider {

    init() {
        /// isBatteryMonitoringEnabled is required in order to get battery metrics.
        UIDevice.current.isBatteryMonitoringEnabled = true
    }

    func getBatterylevel() -> Float {
        return UIDevice.current.batteryLevel
    }

    func getBatteryState() -> String {
        switch (UIDevice.current.batteryState) {
        case .unknown: return "UNKNOWN"
        case .charging: return "CHARGING"
        case .full: return "FULL"
        case .unplugged: return "UNPLUGGED"
        }
    }

    public func isSoftDevice() -> Bool {
        #if targetEnvironment(simulator)
                return true
        #else
                return false
        #endif
    }

    public func getSoftDeviceName() -> String? {
        guard let name = ProcessInfo().environment["SIMULATOR_DEVICE_NAME"] else {
            return nil
        }
        return String(name.prefix(100))
    }

    public func hasGyro() -> Bool {
        let motionManager = CMMotionManager()
        return  motionManager.isGyroAvailable
     }

    private func load(vm_stat: inout vm_statistics, host_port: mach_port_t) {
        withUnsafeMutablePointer(to: &vm_stat) { (vmStatPointer) -> Void in
            // swiftlint:disable line_length
            var host_size: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<vm_statistics_data_t>.stride / MemoryLayout<integer_t>.stride)

            vmStatPointer.withMemoryRebound(to: integer_t.self, capacity: Int(host_size)) {
                // swiftlint:disable control_statement
                if (host_statistics(host_port, HOST_VM_INFO, $0, &host_size) != KERN_SUCCESS) {
                    NSLog("Error: Failed to fetch vm statistics")
                }
            }
        }
    }
}
