import Foundation

public enum TileDirection{
    case Top
    case Right
    case Bottom
    case Left
    
    public var symbol: String {
        switch self {
        case .Top:
            return "↑"
        case .Right:
            return "→"
        case .Bottom:
            return "↓"
        case .Left:
            return "←"
        }
    }
}
