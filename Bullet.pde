//bullet fired from ship
public class Bullet {

  double x, y;
  int[][] shape = bulletModel; // shape of bullet
  HashSet<Block> blocks = new HashSet<Block>(); // blocks used in bullet
  boolean active = true;

  public Bullet(double x, double y) { // start bullet at x,y
    this.x = x;
    this.y = y;

    color c = color(128);
    blocks.clear();
    for (int i = 0; i < shape[0].length; i++) {
      for (int ii = 0; ii < shape.length; ii++) { // move new set of blocks to new x,y
        // could make it move the blocks x,y instead of clearing and making new blocks
        if (shape[ii][i] == 1) {
          Block b = new Block((int) (x - 1 + i), (int) (y - 3 + ii)); // make block at position of model
          blocks.add(b);
          b.drawBlock(c);
        }
      }
    }
  }

  public void move() { // move bullet and blocks forwards
    y -= 3;
    for (Block b : blocks) {
      b.y -= 3;
    }
  }

  public boolean hit(double tx, double ty, int wid, int hei) { // did something it the bullet? and was the bullet active
   if (active) {
      if ((y < ty + hei/2 && y > ty - hei/2) && (x < tx + wid/2 && x> tx - wid/2)) {
        return true;
      } else {
        return Math.hypot(tx - x, ty - y) < Math.min(wid, hei);
      }
    } 
    return false;
  }

  public void explode() { // when bullet explodes make it inactive and make the blocks explode
    active = false;
    for (Block b : blocks) {
      b.initFall();
    }
  }

  public void drawBullet() {
    color c = color(128); // grey bullet
    if (active) {
      for (Block b : blocks) { //draw each block
        b.drawBlock(c);
      }
    } else {
      HashSet<Block> toRemove = new HashSet<Block>();
      for (Block b : blocks) {
        if (b.y > (height/scale) -25) {
          toRemove.add(b);
        } else {
          b.drawBlock(c);
        }
      }
      for (Block b : toRemove) {
        blocks.remove(b);
      }
    }
  }
}
