final float TRIH = 0.866025404;

Grid maze;

void setup() {
  size(800, 800);
  background(255);
  //frameRate(30);
  maze = new Grid(30);
  maze.addNeighbours();
  maze.carveMazeRecursiveBacktrack(); // carve maze once so the stack isn't empty when the draw loop starts
}

void draw() {
  background(0);
  maze.displayGrid();
  if (!maze.stack.isEmpty()) {
    maze.carveMazeRecursiveBacktrack();
  } else if (!maze.solved) {
    maze.pathFindAStar();
  } else {
    maze.drawPath();
    fill(255);
    stroke(0);
    rect(width/3, 50, width/3, 50);
    textSize(20);
    fill(0);
    text("Total path length: " + maze.calcPathLength(), width/3 + 10, 80);
  }
}

void mousePressed() {
  noLoop();
}

void mouseReleased() {
  loop();
};