import UIKit
import PathFinder
import CGRectExtensions

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

    @IBAction func showNextTestCase(sender: AnyObject) {
        currentTestCaseIndex++
        currentTestCaseIndex %= testCases.count
        
        showTestCase()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func showTestCase() {
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
    
    private func initAllTestCases() {
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

    private func initTestView(map: Map){
        let viewWidth: CGFloat = testViewGridWidth * CGFloat(map.width) + testViewGridSpan * (CGFloat(map.width) + 1)
        let size = CGSize(width: viewWidth, height: viewWidth)
        testView = UIView(frame: CGRect(origin: CGPoint(x: testViewLeft, y: testViewTop), size: size))
        testView.backgroundColor = UIColor.lightGrayColor()
        testCaseContainer.addSubview(testView)
    }
    
    private func drawMap(map: Map) {
        // draw map
        for (var y = 0; y < map.height; y++) {
            for (var x = 0; x < map.width; x++) {
                let view = UIView(frame: CGRect(origin: CGPoint(x: CGFloat(x) * testViewCellWidthWithSpan + testViewGridSpan, y: CGFloat(y) * testViewCellWidthWithSpan + testViewGridSpan), size: testViewCellSize))
                testView.addSubview(view)
                if map.matrix[y][x] == Map.WALL {
                    view.backgroundColor = UIColor.blackColor()
                } else {
                    view.backgroundColor = UIColor.whiteColor()
                }
            }
        }
    }
    
    private func drawSteps(steps: [Step]) {
        for step in steps {
            let position = step.position
            
            let cellRect = CGRect(origin: CGPoint(x: position.x * testViewCellWidthWithSpan + testViewGridSpan, y: position.y * testViewCellWidthWithSpan + testViewGridSpan), size: testViewCellSize)
            let view = UIView(frame: cellRect)

            view.backgroundColor = UIColor.greenColor()
            testView.addSubview(view)
            
            var labelRect = view.bounds
            labelRect.size = testViewMarkSize * 0.8
            
            let directionLabel = UILabel(frame: labelRect.offsetBy(testViewMarkSize * 0.5))
            directionLabel.textAlignment = .Center
            directionLabel.adjustsFontSizeToFitWidth = true;
            view.addSubview(directionLabel)
            directionLabel.text = step.inDirection?.symbol
        }
    }
    
    private func drawMark(position: CGPoint, mark: String) {
        let cellRect = CGRect(origin: CGPoint(x: position.x * testViewCellWidthWithSpan + testViewGridSpan, y: position.y * testViewCellWidthWithSpan + testViewGridSpan), size: testViewMarkSize)
        let view = UIView(frame: cellRect)
        testView.addSubview(view)
        
        var labelRect = view.bounds
        labelRect.size = testViewMarkSize * 0.8
        
        let directionLabel = UILabel(frame: labelRect)
        directionLabel.textAlignment = .Center
        view.addSubview(directionLabel)
        directionLabel.text = mark
    }
    
    private var testViewCellSize: CGSize {
        return CGSize(width: testViewGridWidth, height: testViewGridWidth)
    }
    
    private var testViewMarkSize: CGSize {
        return testViewCellSize * 0.5
    }
    
    private var testViewCellWidthWithSpan: CGFloat {
        return testViewGridWidth + testViewGridSpan
    }

}

