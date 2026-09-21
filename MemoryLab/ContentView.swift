import SwiftUI

struct ContentView: View {
    @State private var snapshot = MemorySnapshot.capture()
    @State private var allocations: [Data] = []
    @State private var warningCount = 0

    private let chunkSize = 32 * 1024 * 1024
    private let maxTestAllocation = 256 * 1024 * 1024

    var body: some View {
        NavigationStack {
            List {
                Section("Device") {
                    metric("Installed physical memory", snapshot.physicalDeviceMemory.memoryString)
                    metric("Thermal state", snapshot.thermalState.label)
                }

                Section("This app") {
                    metric("Current footprint", snapshot.processFootprint.memoryString)
                    metric("Peak footprint", snapshot.peakFootprint.memoryString)
                    metric("Available headroom", snapshot.availableHeadroom.memoryString)
                    metric("Estimated process ceiling", snapshot.estimatedProcessLimit.memoryString)
                    metric("Memory warnings", "\(warningCount)")
                }

                Section("Controlled memory test") {
                    metric("Allocated by test", UInt64(allocations.count * chunkSize).memoryString)

                    Button("Allocate 32 MB") {
                        allocateChunk()
                    }
                    .disabled(allocations.count * chunkSize >= maxTestAllocation)

                    Button("Release test memory", role: .destructive) {
                        allocations.removeAll(keepingCapacity: false)
                        refreshSoon()
                    }

                    Text("The test is capped at 256 MB. It measures headroom changes; it does not create physical RAM.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Entitlements requested") {
                    Text("Increased Memory Limit")
                    Text("Extended Virtual Addressing")
                    Text("Apple may grant extra headroom only on supported device models. The runtime values above are the evidence that matters.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Memory Lab")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Refresh") {
                        snapshot = .capture()
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
                warningCount += 1
                snapshot = .capture()
            }
            .onReceive(NotificationCenter.default.publisher(for: ProcessInfo.thermalStateDidChangeNotification)) { _ in
                snapshot = .capture()
            }
        }
    }

    @ViewBuilder
    private func metric(_ name: String, _ value: String) -> some View {
        HStack {
            Text(name)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }

    private func allocateChunk() {
        guard allocations.count * chunkSize < maxTestAllocation else { return }
        var block = Data(count: chunkSize)
        block.withUnsafeMutableBytes { raw in
            guard let base = raw.baseAddress else { return }
            let page = 4096
            for offset in stride(from: 0, to: chunkSize, by: page) {
                base.storeBytes(of: UInt8(1), toByteOffset: offset, as: UInt8.self)
            }
        }
        allocations.append(block)
        refreshSoon()
    }

    private func refreshSoon() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            snapshot = .capture()
        }
    }
}
