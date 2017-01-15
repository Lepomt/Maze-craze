class Grid {
  int size;
  int cols;
  int rows;
  ArrayList<ArrayList<Field>> fields = new ArrayList();
  
  // maze carving
  ArrayList<Field> stack = new ArrayList();
  Field current; // later used in pathfinding too
  
  // pathfinding
  ArrayList<Field> closedSet = new ArrayList();
  ArrayList<Field> openSet = new ArrayList();
  ArrayList<Field> path = new ArrayList();
  Field start;
  Field end;
  boolean solved = false;
  
  Grid(int s) {
    size = s;
    int intHeight = ceil(size * TRIH);
    float fHeight = size * TRIH;
    float xDst = 3*size/2;
    cols = width / ceil(xDst);
    rows = height / (intHeight * 2);
    for(int col = 0; col < cols; col++) {
      // list within list
      fields.add(new ArrayList());
      for(int row = 0; row < rows; row++) {
        // fields within the list
        // randomize travel cost through field using perlin noise
        float xOff = col / 2.5;
        float yOff = row / 2.5;
        int travelCost = floor(noise(xOff, yOff) * 25);
        // calculate x and y coordinates of the field
        float xPos = col * xDst + size;
        float yPos = row * fHeight * 2 + fHeight * (col % 2) + intHeight;
        // create the field
        fields.get(col).add(new Field(xPos, yPos, col, row, size, travelCost));
      }
    }
    
    // starting point for maze carving
    current = fields.get(floor(random(0, cols))).get(floor(random(0, rows)));
    
    // pathfinding fields (start and end points)
    start  = fields.get(0).get(floor(random(0, rows)));
    start.gScore = 0;
    end  = fields.get(cols - 1).get(floor(random(0, rows)));
    start.fScore = start.heuristicCostEstimate(end);
    openSet.add(start);
  }
  
  void displayGrid() {
    for(ArrayList<Field> col : fields) {
      for(Field f : col) {
        f.drawField(0);
        f.drawWalls();
      }
    }
  }
  
  void addNeighbours() {
    for(int col = 0; col < cols; col++) {
      for(int row = 0; row < rows; row++) {
        // top
        if(row > 0) {
          fields.get(col).get(row).neighbours.add(fields.get(col).get(row - 1));
        }
        
        // right
        if(col < cols - 1) {
          // top right
          if(row == 0 && col % 2 == 1) {
            fields.get(col).get(row).neighbours.add(fields.get(col+1).get(row - 1 + col % 2));
          } else if(row > 0) {
            fields.get(col).get(row).neighbours.add(fields.get(col+1).get(row - 1 + col % 2));
          }
          // bottom right
          if(row == rows - 1 && col % 2 == 0) {
            fields.get(col).get(row).neighbours.add(fields.get(col+1).get(row + col % 2));
          } else if(row < rows - 1) {
            fields.get(col).get(row).neighbours.add(fields.get(col+1).get(row + col % 2));
          }
        }
        // bottom
        if(row < rows - 1) {
          fields.get(col).get(row).neighbours.add(fields.get(col).get(row + 1));
        }
        
        // left
        if(col > 0) {
          // bottom left
          if(row == rows - 1 && col % 2 == 0) {
            fields.get(col).get(row).neighbours.add(fields.get(col-1).get(row + col % 2));
          } else if(row < rows - 1) {
            fields.get(col).get(row).neighbours.add(fields.get(col-1).get(row + col % 2));
          }
          // top left
          if(row == 0 && col % 2 == 1) {
            fields.get(col).get(row).neighbours.add(fields.get(col-1).get(row - 1 + col % 2));
          } else if(row > 0) {
            fields.get(col).get(row).neighbours.add(fields.get(col-1).get(row - 1 + col % 2));
          }
        }
      }
    }
  }
  
  boolean carveMazeRecursiveBacktrack() {
    current.visited = true;
    IntList toVisit = new IntList();
    for(int i = 0; i < current.neighbours.size(); i++) {
      if(!(current.neighbours.get(i).visited)) {
        toVisit.append(i);
      }
    }
    
    if(random(1) < 0.1) {
      int n = floor(random(current.neighbours.size()));
      current.addPath(current.neighbours.get(n));
    }
    
    if(toVisit.size() > 0) {
      int next = floor(random(0, toVisit.size()));
      stack.add(current);
      current.addPath(current.neighbours.get(toVisit.get(next)));
      current = current.neighbours.get(toVisit.get(next));
    } else if(stack.size() > 0) {
      stack.remove(stack.size() - 1);
      if(stack.size() > 0) {
        current = stack.get(stack.size() - 1);
      }
    } else {
      frameRate(1);
      return false;
    }
    
    strokeWeight(3);
    noFill();
    beginShape();
    stroke(255, 0, 0);
    for(Field path : stack) {
      vertex(path.pos.x, path.pos.y);
    }
    endShape();
    
    return true;
  }
  
  void pathFindAStar() {
    /* colour debugging */
    start.drawField(4);
    end.drawField(4);
    
    for(Field f : openSet) {
      f.drawField(1);
    }
    
    for(Field f : closedSet) {
      f.drawField(2);
    }
    
    for(Field f : path) {
      f.drawField(3);
    }
    
    for(ArrayList<Field> col : fields) {
      for(Field f : col) {
        f.drawWalls();
      }
    }
    
    path = new ArrayList(current.reconstructPath());
    
    if(!openSet.isEmpty()) {
      float minF = 99999.9;
      for(int i = 0; i < openSet.size(); i++) {
        
        if(openSet.get(i).hScore > 90000) {
          openSet.get(i).hScore = openSet.get(i).heuristicCostEstimate(end);
        }
        
        if(openSet.get(i).fScore < minF) {
          minF = openSet.get(i).fScore;
          current = openSet.get(i);
        }
        
        if(current == end) {
          path = new ArrayList(current.reconstructPath());
          solved = true;
        }
        
        openSet.remove(current);
        closedSet.add(current);
        
        for(Path neighbour : current.paths) {
          if(closedSet.contains(neighbour.end)) {
            continue;
          }
          
          float tempG = current.gScore + neighbour.len;
          if(!openSet.contains(neighbour.end)) {
            openSet.add(neighbour.end);
          } else if(tempG >= neighbour.end.gScore) {
            continue;
          }
          neighbour.end.cameFrom = neighbour.start;
          neighbour.end.gScore = tempG;
          neighbour.end.fScore = neighbour.end.gScore + neighbour.end.heuristicCostEstimate(end);
        }
      }
    } else {
      println("Path not found - FAILURE");
      noLoop();
    }
  }
  
  void drawPath() {
    start.drawField(1);
    start.drawWalls();
    end.drawField(4);
    end.drawWalls();
    strokeWeight(5);
    stroke(50, 100, 250);
    noFill();
    beginShape();
    for(Field f : path) {
      vertex(f.pos.x, f.pos.y);
    }
    endShape();
  }
  
  float calcPathLength() {
    float total = 0;
    for(Field f : path) {
      for(int i = 0; i < f.paths.size(); i++) {
        if(f.paths.get(i).end == f.cameFrom) {
          total += f.paths.get(i).len;
        }
      }
    }
    return total;
  }
};