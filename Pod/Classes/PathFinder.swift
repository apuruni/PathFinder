import Foundation

public class PathFinder{
    let TurnPenalty: CGFloat = 0.001
    
    var map: Map
    var lastTileDirection: Direction
    var spOpenSteps: [Step] = [Step]()
    var spClosedSteps: [Step] = [Step]()
    var shortestPath: [Step] = [Step]()
    
    public init(map: Map) {
        self.map = map
        lastTileDirection = .Top
    }
    
    public func getName() -> String{
        return "PathFinder"
    }
    
    public func findShortestSteps(fromTileCoord: CGPoint, toTileCoord: CGPoint) -> [Step] {
        self.shortestPath.removeAll()
        
        // Check that there is a path to compute ;-)
        if fromTileCoord == toTileCoord {
            //NSLog(@"You're already there! :P");
            return self.shortestPath
        }

        spOpenSteps.removeAll()
        spClosedSteps.removeAll()

        // Start by adding the from position to the open list
        self.insertInOpenSteps(Step(position: fromTileCoord))

        repeat {
            // print("==== loop for open list ====")
            // print("open list=\(self.spOpenSteps)")
            // Get the lowest F cost step
            // Because the list is ordered, the first step is always the one with the lowest F cost
            let currentStep: Step = self.spOpenSteps[0]

            // Add the current step to the closed set
            self.spClosedSteps.append(currentStep)

            // Remove it from the open list
            self.spOpenSteps.removeAtIndex(0)

            // If the currentStep is the desired tile coordinate, we are done!
            if (currentStep.position == toTileCoord) {
                //pathFound = YES;
                self.constructPathFromStep(currentStep)

                self.spOpenSteps.removeAll()
                self.spClosedSteps.removeAll()
                break;
            }

            // Get the adjacent tiles coord of the current step
            let adjacentTiles: [Tile] = self.walkableAdjacentTilesCoordForTileCoord(currentStep.position)
            for adjacentTile in adjacentTiles {
                // print("==== loop for adjacent tile ====")
                var nextStep = Step(position: adjacentTile.location)
                let nextDirection = adjacentTile.direction;

                // Check if the step isn't already in the closed set
                if self.spClosedSteps.contains({ $0 == nextStep }) {
                    continue; // Ignore it
                }

                // Compute the cost from the current step to that step
                let moveCost = self.costToMove(currentStep, toAdjacentStep:nextStep, nextDirection: nextDirection)

                // Check if the step is already in the open list
                let index: Int? = self.spOpenSteps.indexOf({ $0 == nextStep})

                if (index == nil) { // Not on the open list, so add it
                    // print("Not on the open list, so add it")
                    // Set the current step as the parent
                    nextStep.parent = currentStep
                    nextStep.inDirection = nextDirection

                    // The G score is equal to the parent G score + the cost to move from the parent to it
                    nextStep.cost = currentStep.cost + moveCost;

                    // Adding it with the function which is preserving the list ordered by F score
                    self.insertInOpenSteps(nextStep)
                } else { // Already in the open list
                    // print("Already in the open list")
                    nextStep = self.spOpenSteps[index!] // To retrieve the old one (which has its scores already computed ;-)

                    // Check to see if the G score for that step is lower if we use the current step to get there
                    if ((currentStep.cost + moveCost) < nextStep.cost) {
                        // print("has lower cost, update old step")
                        nextStep.parent = currentStep
                        nextStep.inDirection = nextDirection

                        nextStep.cost = currentStep.cost + moveCost

                        // Because the G Score has changed, the F score may have changed too
                        // So to keep the open list ordered we have to remove the step, and re-insert it with
                        // the insert function which is preserving the list ordered by F score

                        // Now we can removing it from the list without be afraid that it can be released
                        self.spOpenSteps.removeAtIndex(index!)

                        // Re-insert it with the function which is preserving the list ordered by F score
                        self.insertInOpenSteps(nextStep)
                    }
                }
            }
        } while self.spOpenSteps.count > 0
        
        return self.shortestPath;
    }
    
    // Insert a path step (ShortestPathStep) in the ordered open steps list (spOpenSteps)
    private func insertInOpenSteps(step: Step) {
        let cost: CGFloat = step.cost // Compute the step's F score
        let count: Int = self.spOpenSteps.count
        var i = 0
        for (; i < count; i++) {
            if cost <= self.spOpenSteps[i].cost { // If the step's F score is lower or equals to the step at index i
                // Then we found the index at which we have to insert the new step
                // Basically we want the list sorted by F score
                break
            }
        }
        // Insert the new step at the determined index to preserve the F score ordering
        self.spOpenSteps.insert(step, atIndex: i)
    }

    // Go backward from a step (the final one) to reconstruct the shortest computed path
    private func constructPathFromStep(step: Step) {
        self.shortestPath.removeAll()
        
        var currentStep: Step? = step

        repeat {
            self.shortestPath.insert(currentStep!, atIndex: 0) // Always insert at index 0 to reverse the path
            currentStep = currentStep!.parent // Go backward
        }
        while (currentStep != nil);   // Until there is no more parents
    }
    
    private func walkableAdjacentTilesCoordForTileCoord(tileCoord: CGPoint) -> [Tile] {
        var tempWalkableList = [Tile]()

        // Top
        var p = CGPoint(x: tileCoord.x, y: tileCoord.y - 1)
        if self.isValidTileCoord(p) && !self.isWallAtTileCoord(p) {
            let tile = Tile(location: p)
            tile.direction = Direction.Top
            tempWalkableList.append(tile)
        }

        // Left
        p = CGPoint(x: tileCoord.x - 1, y: tileCoord.y)
        if self.isValidTileCoord(p) && !self.isWallAtTileCoord(p) {
            let tile = Tile(location: p)
            tile.direction = Direction.Left
            tempWalkableList.append(tile)
        }

        // Bottom
        p = CGPoint(x: tileCoord.x, y: tileCoord.y + 1);
        if self.isValidTileCoord(p) && !self.isWallAtTileCoord(p) {
            let tile = Tile(location: p)
            tile.direction = Direction.Bottom
            tempWalkableList.append(tile)
        }

        // Right
        p = CGPoint(x: tileCoord.x + 1, y: tileCoord.y);
        if self.isValidTileCoord(p) && !self.isWallAtTileCoord(p) {
            let tile = Tile(location: p)
            tile.direction = Direction.Right
            tempWalkableList.append(tile)
        }

        return tempWalkableList
    }
    
    private func isValidTileCoord(p: CGPoint) -> Bool{
        if (p.x >= 0 && Int(p.x) < map.width
            && p.y >= 0 && Int(p.y) < map.height) {
            return true
        } else {
            return false
        }
    }

    private func isWallAtTileCoord(p: CGPoint) -> Bool {
        return map.isWallAt(p)
    }
    
    // Compute the cost of moving from a step to an adjacent one
    private func costToMove(fromStep: Step, toAdjacentStep: Step, nextDirection: Direction) -> CGFloat {
        // Because we can't move diagonally and because terrain is just walkable or unwalkable the cost is always the same.
        // But it have to be different if we can move diagonally and/or if there is swamps, hills, etc...
        var cost: CGFloat = 1        
        // print("fromStep=\(fromStep), toStep=\(toAdjacentStep)")
//        print("fromStep.parent=\(fromStep.parent)")
        // print("nextDirection=\(nextDirection)")
        
        // if fromStep.direction != toAdjacentStep.direction {
        if fromStep.inDirection != nil && fromStep.inDirection != nextDirection {
            cost += TurnPenalty
        }
        
        // print("cost=\(cost)")
        
        return cost
    }

}
