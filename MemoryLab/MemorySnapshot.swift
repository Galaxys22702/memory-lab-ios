import Foundation
import SwiftUI

struct MemorySnapshot {
    let physicalDeviceMemory: UInt64
    let processFootprint: UInt64
    let peakFootprint: UInt64
    let availableHeadroom: UInt64
    let estimatedProcessLimit: UInt64
    let thermalState: ProcessInfo.ThermalState

    static func capture() -> MemorySnapshot {
        let physical = ProcessInfo.processInfo.physicalMemory
        let footprint = ml_phys_footprint()
        let peak = ml_peak_footprint()
        let available = ml_available_memory()
        let estimatedLimit = footprint &+ available

        return MemorySnapshot(
            physicalDeviceMemory: physical,
            processFootprint: footprint,
            peakFootprint: peak,
            availableHeadroom: available,
            estimatedProcessLimit: estimatedLimit,
            thermalState: ProcessInfo.processInfo.thermalState
        )
    }
}

extension UInt64 {
    var memoryString: String {
        ByteCountFormatter.string(fromByteCount: Int64(clamping: self), countStyle: .memory)
    }
}

extension ProcessInfo.ThermalState {
    var label: String {
        switch self {
        case .nominal: return "Nominal"
        case .fair: return "Fair"
        case .serious: return "Serious"
        case .critical: return "Critical"
        @unknown default: return "Unknown"
        }
    }
}
