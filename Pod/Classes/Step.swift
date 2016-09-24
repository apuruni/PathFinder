import Foundation

open class Step : CustomStringConvertible {
    open var position:CGPoint
    var cost:CGFloat
    var parent:Step?
    open var inDirection: Direction?
    
    public init(position: CGPoint){
        self.position = position
        cost = 0
        parent = nil
        inDirection = nil
    }
    
    open var description :String {
        return "Step, pos=\(position), cost=\(cost), dir=\(inDirection)"
    }
}

func == (left: Step, right: Step) -> Bool {
    return left.position == right.position
}
