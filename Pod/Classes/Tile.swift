import Foundation

public class Tile {
    var location: CGPoint
    var direction: TileDirection
    
    public init(location: CGPoint) {
        self.location = location
        direction = .Top
    }
}