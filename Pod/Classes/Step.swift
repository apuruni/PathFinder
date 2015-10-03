import Foundation

public class Step : CustomStringConvertible {
    public var position:CGPoint
    var gScore:Int
    var hScore:Int
    var parent:Step?
    public var direction: TileDirection
    
    public init(position: CGPoint){
        self.position = position
        gScore = 0
        hScore = 0
        parent = nil
        direction = TileDirection.Top
    }
    
    var fScore: Int {
        return gScore + hScore
    }
    
    public var description :String {
        return "Step, pos=\(position), g=\(gScore), h=\(hScore) f=\(fScore)"
    }
}

func == (left: Step, right: Step) -> Bool {
    return left.position == right.position
}