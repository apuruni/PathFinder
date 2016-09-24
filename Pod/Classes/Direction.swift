import Foundation

public enum Direction{
    case top
    case right
    case bottom
    case left
    
    public var symbol: String {
        switch self {
        case .top:
            return "↑"
        case .right:
            return "→"
        case .bottom:
            return "↓"
        case .left:
            return "←"
        }
    }
}
