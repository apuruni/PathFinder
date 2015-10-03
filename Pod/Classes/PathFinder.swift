import Foundation

public class PathFinder{
    var map: Map
    var lastTileDirection: TileDirection
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
    
    public func move(fromTileCoord: CGPoint, toTileCoord: CGPoint) -> [Step] {
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
            // Get the lowest F cost step
            // Because the list is ordered, the first step is always the one with the lowest F cost
            let currentStep: Step = self.spOpenSteps[0]

            // Add the current step to the closed set
            self.spClosedSteps.append(currentStep)

            // Remove it from the open list
            // Note that if we wanted to first removing from the open list, care should be taken to the memory
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
            let adjSteps: [Tile] = self.walkableAdjacentTilesCoordForTileCoord(currentStep.position)
            for v in adjSteps {
                var step = Step(position: v.location)
                step.direction = v.direction;

                // Check if the step isn't already in the closed set
                if self.spClosedSteps.contains({ $0 == step }) {
                    continue; // Ignore it
                }

                // Compute the cost from the current step to that step
                let moveCost = self.costToMove(currentStep, toAdjacentStep:step)

                // Check if the step is already in the open list
                let index: Int? = self.spOpenSteps.indexOf({ $0 == step})

                if (index == nil) { // Not on the open list, so add it
                    // Set the current step as the parent
                    step.parent = currentStep;

                    // The G score is equal to the parent G score + the cost to move from the parent to it
                    step.gScore = currentStep.gScore + moveCost;

                    // Compute the H score which is the estimated movement cost to move from that step to the desired tile coordinate
                    step.hScore = self.computeHScoreFromCoord(step.position, toCoord:toTileCoord)

                    // Adding it with the function which is preserving the list ordered by F score
                    self.insertInOpenSteps(step)

                    // Done, now release the step
                    //[step release];
                } else { // Already in the open list
                    step = self.spOpenSteps[index!]; // To retrieve the old one (which has its scores already computed ;-)

                    // Check to see if the G score for that step is lower if we use the current step to get there
                    if ((currentStep.gScore + moveCost) < step.gScore) {
                        // The G score is equal to the parent G score + the cost to move from the parent to it
                        step.gScore = currentStep.gScore + moveCost;

                        // Because the G Score has changed, the F score may have changed too
                        // So to keep the open list ordered we have to remove the step, and re-insert it with
                        // the insert function which is preserving the list ordered by F score

                        // Now we can removing it from the list without be afraid that it can be released
                        self.spOpenSteps.removeAtIndex(index!)

                        // Re-insert it with the function which is preserving the list ordered by F score
                        self.insertInOpenSteps(step)
                    }
                }
            }
        } while self.spOpenSteps.count > 0
        
        return self.shortestPath;
    }
    
    // Insert a path step (ShortestPathStep) in the ordered open steps list (spOpenSteps)
    private func insertInOpenSteps(step: Step) {
        let stepFScore: Int = step.fScore // Compute the step's F score
        let count: Int = self.spOpenSteps.count
        var i = 0
        for (; i < count; i++) {
            if stepFScore <= self.spOpenSteps[i].fScore { // If the step's F score is lower or equals to the step at index i
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
            if currentStep!.parent != nil { // Don't add the last step which is the start position (remember we go backward, so the last one is the origin position ;-)
                self.shortestPath.insert(currentStep!, atIndex: 0) // Always insert at index 0 to reverse the path
            }
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
            tile.direction = TileDirection.Top
            tempWalkableList.append(tile)
        }

        // Left
        p = CGPoint(x: tileCoord.x - 1, y: tileCoord.y)
        if self.isValidTileCoord(p) && !self.isWallAtTileCoord(p) {
            let tile = Tile(location: p)
            tile.direction = TileDirection.Left
            tempWalkableList.append(tile)
        }

        // Bottom
        p = CGPoint(x: tileCoord.x, y: tileCoord.y + 1);
        if self.isValidTileCoord(p) && !self.isWallAtTileCoord(p) {
            let tile = Tile(location: p)
            tile.direction = TileDirection.Bottom
            tempWalkableList.append(tile)
        }

        // Right
        p = CGPoint(x: tileCoord.x + 1, y: tileCoord.y);
        if self.isValidTileCoord(p) && !self.isWallAtTileCoord(p) {
            let tile = Tile(location: p)
            tile.direction = TileDirection.Right
            tempWalkableList.append(tile)
        }

        return tempWalkableList
    }
    
    
    private func isValidTileCoord(p: CGPoint) -> Bool{
        if (p.x >= 0 && Int(p.x) < map.width
            && p.y >= 0 && Int(p.y) < map.height) {
            return true;
        } else {
            return false;
        }
    }

    private func isWallAtTileCoord(p: CGPoint) -> Bool {
        return map.isWallAt(p)
    }
    
    // Compute the cost of moving from a step to an adjacent one
    private func costToMove(fromStep: Step, toAdjacentStep: Step) -> Int {
        // Because we can't move diagonally and because terrain is just walkable or unwalkable the cost is always the same.
        // But it have to be different if we can move diagonally and/or if there is swamps, hills, etc...
        return 1;
    }
    
    // Compute the H score from a position to another (from the current position to the final desired position
    private func computeHScoreFromCoord(fromCoord: CGPoint, toCoord: CGPoint) -> Int{
        // Here we use the Manhattan method, which calculates the total number of step moved horizontally and vertically to reach the
        // final desired step from the current step, ignoring any obstacles that may be in the way
        //return abs(toCoord.x - fromCoord.x) + abs(toCoord.y - fromCoord.y);
        return 0;
    }

}
