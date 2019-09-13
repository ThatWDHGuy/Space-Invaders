//class of space invaders

import java.util.*;
class Spacie {
  double x, y;
  boolean active = true;
  int using = 1; // 1 = up, 0 = down
  int[][] shapeD;
  int[][] shapeU;
  HashSet<Block> blocks = new HashSet<Block>();
  boolean firing;
  int row, col;
  int fireMin = 150;
  int fireMax = 450;
  int fireWait = (int) random(fireMin, fireMax);
  int type;
  int diff = 1;

  public Spacie(double x, double y, int type, int rowNo, int colNo, boolean fire, int difficulty) {
    this.x = x;
    this.y = y;
    this.type = type;
    diff = difficulty;
    row = rowNo;
    col = colNo;
    firing = fire;
    

    if (type == 1) {//depending on type of spacie change space invader model
      shapeD = spacieModelD1;
      shapeU = spacieModelU1;
    } else if (type == 2) {
      shapeD = spacieModelD2;
      shapeU = spacieModelU2;
    } else if (type == 3) {
      shapeD = spacieModelD3;
      shapeU = spacieModelU3;
    }
    using = 1; // use arms down at start
  }

  public void toggleMove() {
    //change model using to swap between arms up and down
    if (using == 1) {
      using = 2;
    } else {
      using = 1;
    }
  }

  public void gotHit() { // when spacie inader is hit
    color c = color(255);
    blocks.clear(); //ensure blocks is empty
    for (int i = 0; i < shapeU[0].length; i++) {
      for (int ii = 0; ii < shapeU.length; ii++) {//make space invader out of blocks when it gets hit
        if (using == 1) { //arms down
          if (shapeU[ii][i] == 1) {
            Block b = new Block((int) (x - 6 + i), (int) (y - 4 + ii));
            blocks.add(b);
            b.drawBlock(c);
          }
        } else { //arms up
          if (shapeD[ii][i] == 1) { 
            Block b = new Block((int) (x - 6 + i), (int) (y - 4 + ii));
            blocks.add(b);
            b.drawBlock(c);
          }
        }
      }
    }
    for (Block b : blocks) { // make all block fly off as debris
      b.initFall();
    }
    sc.addScore(type*100);
    active = false; // spacie is inactive
    //System.out.println("Spacie should die");
  }

  public void fire() {
    if (active && firing) { // if spacie is active. fire off a bullet occasionally
      fireWait--; // count down time till fire
      if (fireWait <= 0) { // time to fire
        fireWait = (int) random(fireMin/diff, fireMax/diff); //reset firewait to random time
        c.addBullet( x, y + 10); // fire
      }
    }
  }

  public void drawSpacie() {
    //have more health for higher levels
    color c = color(255); // draw spacie in white
    fill(c);
    if (active) {
      for (int i = 0; i < shapeU[0].length; i++) {
        for (int ii = 0; ii < shapeU.length; ii++) {
          if (using == 1) { // arms down
            if (shapeU[ii][i] == 1) {
              rect((int) (x - 6 + i), (int) (y - 4 + ii), 1, 1); //draw spacie as rectangles and not blocks to reduce lag
            }
          } else {// arms down
            if (shapeD[ii][i] == 1) {
              rect((int) (x - 6 + i), (int) (y - 4 + ii), 1, 1); //draw spacie as rectangles and not blocks to reduce lag
            }
          }
        }
      }
    } else { // spacie isnt active
      for (Block b : blocks) { // move debris
        b.drawBlock(c);
      }
    }
  }
}
