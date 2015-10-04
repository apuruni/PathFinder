import Foundation

public class Step : CustomStringConvertible {
    public var position:CGPoint
    var cost:CGFloat
    var parent:Step?
    public var inDirection: Direction?
    
    public init(position: CGPoint){
        self.position = position
        cost = 0
        parent = nil
        inDirection = nil
    }
    
    public var description :String {
        return "Step, pos=\(position), cost=\(cost), dir=\(inDirection)"
    }
}

func == (left: Step, right: Step) -> Bool {
    return left.position == right.position
}