class Field {
  int side;
  Indices loc;
  PVector pos;
  int travelCost = 5;
  boolean[] walls = new boolean[6];
  /*
   0 - top            3 - bottom
   1 - top right      4 - bottom left
   2 - bottom right   5 - top left
   */
  ArrayList<Path> paths = new ArrayList();
  ArrayList<Field> neighbours = new ArrayList();

  boolean visited = false; // maze carving variable

  // pathfinding using A*
  float gScore = 99999.9;
  float hScore = 99999.9;
  float fScore = 99999.9;
  Field cameFrom = null;

  Field(float x, float y, int c, int r, int s, int tC) {
    loc = new Indices(c, r);
    pos = new PVector(x, y);
    side = s;
    travelCost = tC;
    for (int i = 0; i < 6; i++) {
      walls[i] = true;
    }
  }

  void addPath(Field dest) {
    int len = travelCost + dest.travelCost;
    if (loc.col == dest.loc.col && abs(loc.row - dest.loc.row) == 1) {
      // top - bottom path
      if (loc.row < dest.loc.row) {
        walls[3] = false;
        dest.walls[0] = false;
      } else {
        walls[0] = false;
        dest.walls[3] = false;
      }

      paths.add(new Path(this, dest, len));
      dest.paths.add(new Path(dest, this, len));
    } else if (abs(loc.col - dest.loc.col) == 1) {
      // diagonal paths
      if (dest.loc.col - loc.col == 1 &&
        loc.row - dest.loc.row + (loc.col % 2) == 1) {
        // bottom right - top left path
        walls[5] = false;
        dest.walls[2] = false;

        paths.add(new Path(this, dest, len));
        dest.paths.add(new Path(dest, this, len));
      } else if (dest.loc.col - loc.col == -1 &&
        loc.row - dest.loc.row + (loc.col % 2) == 0) {
        walls[2] = false;
        dest.walls[5] = false;

        paths.add(new Path(this, dest, len));
        dest.paths.add(new Path(dest, this, len));
      } else if (dest.loc.col - loc.col == 1 &&
        loc.row - dest.loc.row + (loc.col % 2) == 0) {
        // top right - bottom left path
        walls[4] = false;
        dest.walls[1] = false;

        paths.add(new Path(this, dest, len));
        dest.paths.add(new Path(dest, this, len));
      } else if (dest.loc.col - loc.col == -1 &&
        loc.row - dest.loc.row + (loc.col % 2) == 1) {
        walls[1] = false;
        dest.walls[4] = false;

        paths.add(new Path(this, dest, len));
        dest.paths.add(new Path(dest, this, len));
      }
    }
  }

  void drawWalls() {
    pushMatrix();
    translate(pos.x, pos.y);

    strokeWeight(3);
    stroke(0);
    for (int i = 0; i < 6; i++) {      
      if (walls[i]) {
        // draw a line for each wall if it exists
        pushMatrix();
        rotate(-(i+1)*PI/3);
        translate(side, 0);
        rotate(5*PI/6);
        line(0, 0, 0, side);
        popMatrix();
      }
    }

    popMatrix();
  }

  void drawField(int state) {
    pushMatrix();
    translate(pos.x, pos.y);

    noStroke();
    switch(state) {
      case 0: // default
        fill(255 - travelCost * 5, 255 - travelCost * 5, 0);
        break;
      case 1: // open
        fill(0, 0, 150);
        break;
      case 2: // closed
        fill(150, 10, 50);
        break;
      case 3: // path
        fill(100, 200, 50);
        break;
      case 4: // start & end
        fill(0, 230, 0);
        break;
    }
    beginShape();
    for (float a = 0; a < TWO_PI; a += TWO_PI/6) {
      vertex(side * cos(a), side * sin(a));
    }
    endShape(CLOSE);

    popMatrix();
  };

  float heuristicCostEstimate(Field dest) {
    float xDist = pos.x - dest.pos.x;
    xDist *= 2;

    float yDist = pos.y - dest.pos.y;
    yDist *= 2;

    return xDist + yDist; // distance squared
  }

  ArrayList<Field> reconstructPath() {
    ArrayList<Field> currentPath = new ArrayList();
    currentPath.add(this);
    if (cameFrom != null) {
      currentPath.addAll(cameFrom.reconstructPath());
    }
    return currentPath;
  }
};