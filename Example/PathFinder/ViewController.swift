import UIKit
import PathFinder

struct TestCaseData {
    var title: String
    var matrix: [[Int]]
    var start: CGPoint
    var end: CGPoint
}

class ViewController: UIViewController {
    
    let testViewTop: CGFloat = 30
    let testViewLeft: CGFloat = 10
    let testViewGridWidth: CGFloat = 30
    let testViewGridSpan: CGFloat = 2
    
    @IBOutlet weak var testCaseNameLabel: UILabel!
    @IBOutlet weak var testCaseContainer: UIView!
    
    var testView: UIView!
    
    var testCases = [TestCaseData]()
    var currentTestCaseIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initAllTestCases()
        showTestCase()
    }

    @IBAction func showNextTestCase(_ sender: AnyObject) {
        currentTestCaseIndex += 1
        currentTestCaseIndex %= testCases.count
        
        showTestCase()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func showTestCase() {
        for subView in testCaseContainer.subviews {
            subView.removeFromSuperview()
        }
        
        let testData = testCases[currentTestCaseIndex]

        testCaseNameLabel.text = testData.title
        
        let map = Map(matrix: testData.matrix)
        initTestView(map)
        drawMap(map);
        
        let pf = PathFinder(map: map)
        let stepList = pf.findShortestSteps(testData.start, toTileCoord: testData.end)
        drawSteps(stepList)
        
        drawMark(testData.start, mark: "s")
        drawMark(testData.end, mark: "e")
    }
    
    fileprivate func initAllTestCases() {
        testCases.append(TestCaseData(
            title: "Basic",
            matrix: [
                [0, 1, 0, 1],
                [0, 0, 0, 0],
                [1, 0, 1, 0],
                [1, 0, 1, 0]
            ],
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: 3, y: 3)
            ))
        
        testCases.append(TestCaseData(
            title: "No Path",
            matrix: [
                [0, 1, 0, 1],
                [0, 0, 1, 0],
                [1, 0, 1, 0],
                [1, 0, 1, 0]
            ],
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: 3, y: 3)
            ))
        
        testCases.append(TestCaseData(
            title: "Long Path with branch",
            matrix: [
                [0, 1, 0, 0, 0, 1, 0, 0, 0],
                [0, 1, 0, 1, 0, 1, 0, 1, 0],
                [0, 1, 0, 1, 0, 1, 0, 1, 0],
                [0, 1, 0, 1, 0, 1, 0, 1, 0],
                [0, 1, 0, 1, 0, 1, 0, 1, 0],
                [0, 1, 0, 0, 0, 0, 0, 1, 0],
                [0, 1, 0, 1, 1, 1, 0, 1, 0],
                [0, 1, 0, 0, 0, 1, 0, 1, 0],
                [0, 0, 0, 1, 0, 1, 0, 0, 0],
            ],
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: 8, y: 8)
            ))
        
        testCases.append(TestCaseData(
            title: "All open, path with fewest turn",
            matrix: [
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0],
            ],
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: 8, y: 8)
            ))
    }

    fileprivate func initTestView(_ map: Map){
        let viewWidth: CGFloat = testViewGridWidth * CGFloat(map.width) + testViewGridSpan * (CGFloat(map.width) + 1)
        let size = CGSize(width: viewWidth, height: viewWidth)
        testView = UIView(frame: CGRect(origin: CGPoint(x: testViewLeft, y: testViewTop), size: size))
        testView.backgroundColor = UIColor.lightGray
        testCaseContainer.addSubview(testView)
    }
    
    fileprivate func drawMap(_ map: Map) {
        // draw map
        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                let view = UIView(frame: CGRect(origin: CGPoint(x: CGFloat(x) * testViewCellWidthWithSpan + testViewGridSpan, y: CGFloat(y) * testViewCellWidthWithSpan + testViewGridSpan), size: testViewCellSize))
                testView.addSubview(view)
                if map.matrix[y][x] == Map.WALL {
                    view.backgroundColor = UIColor.black
                } else {
                    view.backgroundColor = UIColor.white
                }
            }
        }
    }
    
    fileprivate func drawSteps(_ steps: [Step]) {
        for step in steps {
            let position = step.position
            
            let cellRect = CGRect(origin: CGPoint(x: position.x * testViewCellWidthWithSpan + testViewGridSpan, y: position.y * testViewCellWidthWithSpan + testViewGridSpan), size: testViewCellSize)
            let view = UIView(frame: cellRect)

            view.backgroundColor = UIColor.green
            testView.addSubview(view)
            
            let labelRect = CGRect(x: view.bounds.origin.x + testViewMarkSize.width * 0.5,
                                   y: view.bounds.origin.y + testViewMarkSize.height * 0.5,
                               width: testViewMarkSize.width * 0.8,
                               height: testViewMarkSize.height * 0.8)
            
            let directionLabel = UILabel(frame: labelRect)
            directionLabel.textAlignment = .center
            directionLabel.adjustsFontSizeToFitWidth = true;
            view.addSubview(directionLabel)
            directionLabel.text = step.inDirection?.symbol
        }
    }
    
    fileprivate func drawMark(_ position: CGPoint, mark: String) {
        let cellRect = CGRect(origin: CGPoint(x: position.x * testViewCellWidthWithSpan + testViewGridSpan, y: position.y * testViewCellWidthWithSpan + testViewGridSpan), size: testViewMarkSize)
        let view = UIView(frame: cellRect)
        testView.addSubview(view)
        
        let labelRect = CGRect(x: view.bounds.origin.x, y: view.bounds.origin.y,
                               width: testViewMarkSize.width * 0.8, height: testViewMarkSize.height * 0.8)
        
        let directionLabel = UILabel(frame: labelRect)
        directionLabel.textAlignment = .center
        view.addSubview(directionLabel)
        directionLabel.text = mark
    }
    
    fileprivate var testViewCellSize: CGSize {
        return CGSize(width: testViewGridWidth, height: testViewGridWidth)
    }
    
    fileprivate var testViewMarkSize: CGSize {
        return CGSize(width: testViewCellSize.width * 0.5, height: testViewCellSize.height * 0.5)
    }
    
    fileprivate var testViewCellWidthWithSpan: CGFloat {
        return testViewGridWidth + testViewGridSpan
    }
    
    fileprivate func resizeRect(rect: CGRect, scale: CGFloat) -> CGRect {
        return CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width * scale, height: rect.size.height * scale)
    }

}

