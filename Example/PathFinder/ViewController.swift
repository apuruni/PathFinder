//
//  ViewController.swift
//  PathFinder
//
//  Created by Kun Wang on 10/03/2015.
//  Copyright (c) 2015 Kun Wang. All rights reserved.
//

import UIKit
import PathFinder

struct TestCaseData {
    var title: String
    var matrix: [[Int]]
    var start: CGPoint
    var end: CGPoint
}

class ViewController: UIViewController {
    
    let testViewTop = 30
    let testViewLeft = 10
    let testViewGridWidth = 20
    let testViewGridSpan = 2
    
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
        let stepList = pf.move(testData.start, toTileCoord: testData.end)
        drawSteps(stepList)
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
        let viewWidth = testViewGridWidth * map.width + testViewGridSpan * (map.width + 1)
        let size = CGSize(width: viewWidth, height: viewWidth)
        testView = UIView(frame: CGRect(origin: CGPoint(x: testViewLeft, y: testViewTop), size: size))
        testView.backgroundColor = UIColor.lightGrayColor()
        testCaseContainer.addSubview(testView)
    }
    
    private func drawMap(map: Map) {
        // draw map
        let gridSize = CGSize(width: testViewGridWidth, height: testViewGridWidth)
        for (var y = 0; y < map.height; y++) {
            for (var x = 0; x < map.width; x++) {
                let viewWidth = testViewGridWidth + testViewGridSpan
                let view = UIView(frame: CGRect(origin: CGPoint(x: x * viewWidth + testViewGridSpan, y: y * viewWidth + testViewGridSpan), size: gridSize))
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
        let gridSize = CGSize(width: testViewGridWidth, height: testViewGridWidth)
        for step in steps {
            let position = step.position
            let viewWidth = testViewGridWidth + testViewGridSpan
            let view = UIView(frame: CGRect(origin: CGPoint(x: Int(position.x) * viewWidth + testViewGridSpan, y: Int(position.y) * viewWidth + testViewGridSpan), size: gridSize))
            view.backgroundColor = UIColor.greenColor()
            testView.addSubview(view)
        }
    }

}

