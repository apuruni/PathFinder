import Foundation

open class Map {
    open static let WALL = 1
    open var matrix:[[Int]]
    
    public init(matrix: [[Int]]) {
        self.matrix = matrix
    }
    
    open var width: Int {
        return matrix[0].count
    }
    
    open var height: Int {
        return matrix.count
    }
    
    open func isWallAt(_ position: CGPoint) -> Bool {
        return matrix[Int(position.y)][Int(position.x)] == Map.WALL
    }
}
