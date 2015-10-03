import Foundation

public class Map {
    public static let WALL = 1
    public var matrix:[[Int]]
    
    public init(matrix: [[Int]]) {
        self.matrix = matrix
    }
    
    public var width: Int {
        return matrix[0].count
    }
    
    public var height: Int {
        return matrix.count
    }
    
    public func isWallAt(position: CGPoint) -> Bool {
        return matrix[Int(position.y)][Int(position.x)] == Map.WALL
    }
}
