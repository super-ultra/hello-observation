import Foundation
import ConcurrencyToolbox



actor ColorManager {
    
    @Atomic
    private(set) nonisolated var color: String = "red"
    
    init() {
    }
    
    func updateColor(with color: String) {
        self.color = color
    }
    
}


let manager = ColorManager()
await manager.updateColor(with: "blue")
print(manager.color)
