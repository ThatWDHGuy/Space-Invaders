//ship that fires and is conrolled by player
public class Ship {

  double x, y;
  //int moveDir = 0; // which way is ship moving
  ArrayList<Integer> moveQueue = new ArrayList<Integer>();
  HashSet<Bullet> bullets = new HashSet<Bullet>(); // set of bullets
  long bulletWaitCount = 0;
  long bulletWaitNum = 75; // time between firing shots
  int[][] shape = shipModel; // shape of ship
  boolean active = true;
  HashSet<Block> blocks = new HashSet<Block>(); // blocks in ship model
  int invincibleTime = 0; // invinsibility frame counter
  boolean heal = false;
  int powerUpState = 0;
  int powerUpTimer = 0;
  boolean overrideTimer = false;
  boolean firing = false;
  boolean invinsible = false;

  public Ship(double x, double y) {
    this.x = x;
    this.y = y;
    color c = color(0, 255, 0);
    for (int i = 0; i < shape[0].length; i++) {
      for (int ii = 0; ii < shape.length; ii++) {
        if (shape[ii][i] == 1) {
          Block b = new Block((int) (x - 6 + i), (int) (y - 4 + ii));
          blocks.add(b);
          b.drawBlock(c);
        }
      }
    }
  }

  public void move() {
    if (moveQueue.size() != 0) {
      int moveDir = moveQueue.get(0);
      if (x + moveDir < (width/scale) - 2*bumper && x + moveDir > 2*bumper) { // as long as ship is within the bumper region
        x += moveDir; // move it and move blocks
        for (Block b : blocks) {
          if (!b.falling) {
            b.x += moveDir;
          }
        }
      }
    }
    HashSet<Bullet> toRemoveBul = new HashSet<Bullet>(); // set of bullets to be removed
    for (Bullet b : s.bullets) { //move bullet and check if bullet has no debris left
      b.move();
      if ( b.blocks.size() == 0 || b.y < -50) { // if no debris add bullet to be removed to set
        toRemoveBul.add(b);
      }
    }
    for (Bullet b : toRemoveBul) { // remove all bullets in the set
      s.bullets.remove(b);
    }
    bulletWaitCount++; // add to counter between bullet firing
  }

  public void fire() { //fire bullet
    if (bulletWaitCount > bulletWaitNum) { // has it waited long enough
      if (powerUpState == 0 || powerUpState == 1) {
        bulletWaitCount = 0; // reset wait counter and add new bullet.
        bullets.add(new Bullet(x, y));
      } else if (powerUpState == 2) { // multishot
        bulletWaitCount = 0; // reset wait counter and add new bullet.
        bullets.add(new Bullet(x, y + 3));
        bullets.add(new Bullet(x - 5, y));
        bullets.add(new Bullet(x + 5, y));
      } else if (powerUpState == 3) { //rapid fire
        bulletWaitCount = 45;
        bullets.add(new Bullet(x, y));
      } else if (powerUpState == 4) { // Semi-God
        bulletWaitCount = 45;
        bullets.add(new Bullet(x, y + 3));
        bullets.add(new Bullet(x - 5, y));
        bullets.add(new Bullet(x + 5, y));
      } else if (powerUpState == 5) { // God
        bulletWaitCount = 70;
        bullets.add(new Bullet(x, y + 3));
        bullets.add(new Bullet(x - 5, y));
        bullets.add(new Bullet(x + 5, y));
      }
    }
  }

  public void checkHit(SpacieBullet sBul) { // check if spacie bullet hit the ship
    if (sBul.y > (height/scale) * ((double) 4 / (double) 6) && sBul.active) { //only check hit towards bottom of screen
      for (Block b : blocks) {
        if (Math.hypot(sBul.x - b.x, sBul.y + 3 - y) < 2  && sBul.active) { // is the bullet hitting the ship blocks.
          sBul.explode(); // explode bullet
          if (invincibleTime <= 0) { // if its not in the invinsibilty time. add time to the invinsibility counter and -1 from lives
            invincibleTime = 120;
            if (!invinsible) {
              lives--;
            }
            //println(invinsible + " " + powerUpState);
          }
          explodeShipParts();
        }
      }
    }
  }

  public void explodeShipParts() { // when ship is hit. throw off random block to seem like an explosion
    for (Block b : blocks) {
      if ((int) random(0, 3) == 2) {
        b.initFall();
      }
    }
    heal = true;
  }

  public void drawShip() {
    /*if (!overrideTimer) {
      if (powerUpTimer == 0) {
        powerUpState = 0;
        s.invinsible = false;
      } else {
        powerUpTimer--;
      }
    }*/
    if (invincibleTime >= 0 && !pause) { // if ship is invinsible, -1 from timer
      invincibleTime--;
    }
    if (invincibleTime == 0 && heal) { // if ship is out of of invincible time and it has just recovered from being hit 
      heal = false;
      blocks.clear();
      for (int i = 0; i < shape[0].length; i++) {
        for (int ii = 0; ii < shape.length; ii++) { //reset Ship sprite
          if (shape[ii][i] == 1) {
            Block b = new Block((int) (x - 6 + i), (int) (y - 4 + ii));
            blocks.add(b);
          }
        }
      }
    }


    for (Bullet b : bullets) { // draw all bullets
      b.drawBullet();
    }
    color c = color(getPowerUpCol(powerUpState));

    HashSet<Block> toRemove = new HashSet<Block>(); // blocks to remove if it goes off screen
    for (Block b : blocks) {
      if (b.y > (height/scale) - 25) { // add block to be removed if off screen
        toRemove.add(b);
      }
      b.drawBlock(c); //draw all blocks
    }
    for (Block b : toRemove) { // remove blocks
      blocks.remove(b);
    }
  }
}
