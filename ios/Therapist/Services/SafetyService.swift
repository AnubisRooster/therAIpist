import Foundation

class SafetyService {
    static let shared = SafetyService()

    func checkCrisis(_ message: String) -> (isCrisis: Bool, level: String, pattern: String?) {
        let lower = message.lowercased()
        for cp in crisisPatterns {
            for pattern in cp.patterns {
                if lower.contains(pattern) {
                    return (true, cp.level, pattern)
                }
            }
        }
        return (false, "", nil)
    }

    func checkBoundaryViolation(_ text: String) -> (isViolation: Bool, pattern: String?) {
        let lower = text.lowercased()
        for pattern in boundaryPatterns {
            if lower.contains(pattern) {
                return (true, pattern)
            }
        }
        return (false, nil)
    }
}
