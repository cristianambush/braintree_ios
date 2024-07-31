import Foundation

public extension Date {
    
    var utcTimestampMilliseconds: Int {
        Int(round(timeIntervalSince1970 * 1000))
    }
}
