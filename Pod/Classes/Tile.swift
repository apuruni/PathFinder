import Foundation

open class Tile {
    var location: CGPoint
    var direction: Direction
    
    public init(location: CGPoint) {
        self.location = location
        direction = .top
    }
}
