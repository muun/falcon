//
//  HardwareCapabilitiesProvider.swift
//  core-all
//
//  Created by Lucas Serruya on 01/02/2023.
//

import Foundation

public class HardwareCapabilitiesProvider {
    public static let shared = HardwareCapabilitiesProvider()

    private var timer: Timer?
    private var freeStorage: Int64?
    private var totalStorage: Int64?

    private let totalStorageRefreshTimeInSeconds = 10

    public func startRefreshingCacheableValues() {
        refreshFreeStorage()
        refreshTotalStorageAsync()
        startKeepingTotalStorageUpToDate()
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

    @discardableResult
    public func refreshFreeStorage() -> Int64 {
        let freeStorage = getDiskValue(resourceKey: .volumeAvailableCapacityForImportantUsageKey)
        self.freeStorage = freeStorage
        return freeStorage;
    }
    
    func getFreeStorage() -> Int64 {
        return freeStorage ?? refreshFreeStorage()
    }
    
    func getTotalStorage() -> Int64 {
        return totalStorage ?? refreshTotalStorage()
    }
    
    private func getDiskValue(resourceKey: URLResourceKey) -> Int64 {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let values = try? url.resourceValues(forKeys:
                                                [.volumeTotalCapacityKey,
                                                 .volumeAvailableCapacityForImportantUsageKey])
        if let capacity = values?.volumeTotalCapacity,
            resourceKey == .volumeTotalCapacityKey {
            return Int64(capacity)
        }
        if let capacity = values?.volumeAvailableCapacityForImportantUsage,
            resourceKey == .volumeAvailableCapacityForImportantUsageKey {
            return capacity
        }
        return -1
    }

    // thanks to https://stackoverflow.com/questions/5012886/determining-the-available-amount-of-ram-on-an-ios-device
    func getFreeRam() -> Int64 {
        let host_port: mach_port_t = mach_host_self()

        var pagesize: vm_size_t = 0
        host_page_size(host_port, &pagesize)
        
        var vm_stat: vm_statistics = vm_statistics_data_t()
        load(vm_stat: &vm_stat, host_port: host_port)

        let mem_free: Int64 = Int64(vm_stat.free_count) * Int64(pagesize)

        return mem_free
    }
    
    public func getTotalRam() -> UInt64 {
        return ProcessInfo.processInfo.physicalMemory;
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

    private func startKeepingTotalStorageUpToDate() {
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.totalStorageRefreshTimeInSeconds),
                                         target: self,
                                         selector: #selector(self.refreshTotalStorageAsync),
                                         userInfo: nil,
                                         repeats: true)
        }
    }

    @objc
    private func refreshTotalStorageAsync() {
        DispatchQueue.global().async {
            self.refreshTotalStorage()
        }
    }

    @discardableResult
    private func refreshTotalStorage() -> Int64 {
        let totalStorage = getDiskValue(resourceKey: .volumeTotalCapacityKey)
        self.totalStorage = totalStorage
        return totalStorage
    }
}
