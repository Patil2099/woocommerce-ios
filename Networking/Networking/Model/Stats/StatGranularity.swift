import Foundation


/// Represents data granularity for stats (e.g. day, week, month, year)
///
public enum StatGranularity: String, Decodable, GeneratedFakeable {
    case day
    case week
    case month
    case year
}
