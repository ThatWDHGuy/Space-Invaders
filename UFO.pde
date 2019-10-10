class UFO { //make ufo drop power up

  int[][] shape1 = UFOmodel1;
  int[][] shape2 = UFOmodel2;
  float x, y;
  boolean active = true;
  int using = 1; 
  HashSet<Block> blocks = new HashSet<Block>();
  int flyMin = 500;
  int flyMax = 1000;
  int flyWait = (int) random(flyMin, flyMax);
  int changeCount = 0;

  public UFO(float x, float y) {
    this.x = x;
    this.y = y;
  }

  public void toggleLook() {
    //change model using to swap between arms up and down
    if (using == 1) {
      using = 2;
    } else {
      using = 1;
    }
  }

  public void gotHit() { // when UFO is hit
    color c = color(255);
    blocks.clear(); //ensure blocks is empty
    for (int i = 0; i < shape1[0].length; i++) {
      for (int ii = 0; ii < shape1.length; ii++) {//make space invader out of blocks when it gets hit
        if (using == 1) { //arms down
          if (shape1[ii][i] == 1) {
            Block b = new Block((int) (x - 12 + i), (int) (y - 4 + ii));
            blocks.add(b);
            b.drawBlock(c);
          }
        } else { //arms up
          if (shape2[ii][i] == 1) { 
            Block b = new Block((int) (x - 12 + i), (int) (y - 4 + ii));
            blocks.add(b);
            b.drawBlock(c);
          }
        }
      }
    }
    for (Block b : blocks) { // make all block fly off as debris
      b.initFall();
    }
    active = false; // spacie is inactive
    //System.out.println("Spacie should die");
  }

  public void dropPowerUp() {
    powerUps.add(new PowerUp(x, y));
  }

  public void checkHit() {
    if (active) {
      for (Bullet b : s.bullets) {
        if (b.hit(x, y, shape1[0].length, shape1.length)) { // check if bullet has hit     
          gotHit();
          b.explode();
          dropPowerUp();
          sc.addScore(3000);
        }
      }
    }
  }

  public void move() {
    HashSet<Block> toRemove = new HashSet<Block>();
    x -= 1;
    checkHit();
    changeCount++;
    if (changeCount % 5 == 0) {
      toggleLook();
    }
    for (Block b : blocks) {
      if (b.y > (height/scale)-23) {
        toRemove.add(b);
      }
    }
    for (Block b : toRemove) { // remove bullets specified above
      blocks.remove(b);
    }
    drawUFO();
  }

  public void drawUFO() {
    color c = color(255); // draw spacie in white
    fill(c);
    if (active) {
      for (int i = 0; i < shape1[0].length; i++) {
        for (int ii = 0; ii < shape1.length; ii++) {
          if (using == 1) { // arms down
            if (shape1[ii][i] == 1) {
              rect((int) (x - 12 + i), (int) (y - 4 + ii), 1, 1); //draw spacie as rectangles and not blocks to reduce lag
            }
          } else {// arms down
            if (shape2[ii][i] == 1) {
              rect((int) (x - 12 + i), (int) (y - 4 + ii), 1, 1); //draw spacie as rectangles and not blocks to reduce lag
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
