//class of space invaders

class SpacieBoss {
  double x, y;
  boolean active = true;
  int using = 1; // 1 = up, 0 = down
  int[][] shapeD;
  int[][] shapeU;
  HashSet<Block> blocks = new HashSet<Block>();
  int row, col;
  int fireMin = 150;
  int fireMax = 450;
  int fireWait = (int) random(fireMin, fireMax);
  int diff = 1;
  int hp = 30;
  int maxHp;

  public SpacieBoss(double x, double y, int difficulty) {
    this.x = x;
    this.y = y;
    diff = difficulty;
    hp += 5*difficulty;
    maxHp = hp;
    shapeD = spacieBossModelD;
    shapeU = spacieBossModelU;
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
    if (hp == 0) {
      color c = color(255);
      blocks.clear(); //ensure blocks is empty
      for (int i = 0; i < shapeU[0].length; i++) {
        for (int ii = 0; ii < shapeU.length; ii++) {//make space invader out of blocks when it gets hit
          if (using == 1) { //arms down
            if (shapeU[ii][i] == 1) {
              Block b = new Block((int) (x - 4*8 + 4*i), (int) (y - 4*6 + 4*ii), 4, 4);
              blocks.add(b);
              b.drawBlock(c);
            }
          } else { //arms up
            if (shapeD[ii][i] == 1) { 
              Block b = new Block((int) (x - 4*8 + 4*i), (int) (y - 4*6 + 4*ii), 4, 4);
              blocks.add(b);
              b.drawBlock(c);
            }
          }
        }
      }
      for (Block b : blocks) { // make all block fly off as debris
        b.initFall();
      }
      sc.addScore(10000);
      active = false; // spacie is inactive
    } else {
      sc.addScore(150);
      hp --;
    }
    //System.out.println("Spacie should die");
  }

  public void fire() {
    if (active) { // if spacie is active. fire off a bullet occasionally
      fireWait--; // count down time till fire
      if (fireWait <= 0) { // time to fire
        fireWait = (int) random(fireMin/diff, fireMax/diff); //reset firewait to random time
        float angle = atan((float)((s.x - x)/(s.y - (y + 40))));
        c.addBullet( x, y + 40, 10 + diff, angle); // fire
      }
    }
  }

  public void drawSpacie() {
    //have more health for higher levels
    fill(128);
    rect((width/scale)/2 - 80, 15, 160, 5);
    fill(20, 0, 33);
    rect((width/scale)/2 - 78, 16, 156, 3);
    fill(155, 0, 255);
    rect((width/scale)/2 - 78, 16, 156 * ((float)hp/(float)maxHp), 3);
    color c = color(255); // draw spacie in white
    fill(c);
    if (active) {
      for (int i = 0; i < shapeU[0].length; i++) {
        for (int ii = 0; ii < shapeU.length; ii++) {
          if (using == 1) { // arms down
            if (shapeU[ii][i] == 1) {
              rect((int) (x - 4*8 + 4*i), (int) (y - 4*6 + 4*ii), 4, 4); //draw spacie as rectangles and not blocks to reduce lag
            }
          } else {// arms down
            if (shapeD[ii][i] == 1) {
              rect((int) (x - 4*8 + 4*i), (int) (y - 4*6 + 4*ii), 4, 4); //draw spacie as rectangles and not blocks to reduce lag
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
