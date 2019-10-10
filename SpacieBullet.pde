//class of spacie bullet
public class SpacieBullet {

  double x, y;
  float angle = 0;
  HashSet<Block> blocks = new HashSet<Block>(); // set of blocks in bullet
  boolean active = true;
  int[][] shape = spacieBulletModel;
  int rad;

  public SpacieBullet(double x, double y, int rad) { //make bullet at x,y
    this.x = x;
    this.y = y;
    this.rad = rad;
  }

  public SpacieBullet(double x, double y, int rad, float angle) { //make bullet at x,y
    this.x = x;
    this.y = y;
    this.rad = rad;
    this.angle = angle;
  }

  public void move() { // move down when active
    if (active) {
      if (angle == -1) {
        y += 1.5;
      } else {
        x += sin(angle);
        y += cos(angle);
      }
    }
  }

  public boolean hit(double tx, double ty, int wid, int hei) { //has the bullet hit something
    if ((Math.hypot(tx - x, ty - y) < Math.min(wid, hei)) && active) {
      return true;
    } else {
      return false;
    }
  }


  public void explode() { //bullet hit something and will explode
    active = false; //make inactive
    color c = color(128);
    blocks.clear(); // ensure blocks is empty
    for (int i = 0; i < shape[0].length; i++) {
      for (int ii = 0; ii < shape.length; ii++) { // add blocks to position of model
        if (shape[ii][i] == 1) {
          Block b = new Block((int) (x - 1 + i), (int) (y - 3 + ii));
          blocks.add(b);
          b.drawBlock(c);
          b.initFall(); // make blocks fall
        }
      }
    }
  }

  public void drawBullet() {
    color c = color(128); // grey bullets
    fill(c);
    if (active) {
      pushMatrix();
      translate((float)x, (float)y);
      rotate(-angle);
      for (int i = 0; i < shape[0].length; i++) {
        for (int ii = 0; ii < shape.length; ii++) { //draw rectangles where bullet model shows
          if (shape[ii][i] == 1) {
            rect((int) (- 1 + i), (int) (- 3 + ii), 1, 1);
          }
        }
      }
      popMatrix();
    } else {
      HashSet<Block> toRemove = new HashSet<Block>(); // set to add blocks to remove to
      for (Block b : blocks) {
        if (b.y > (height/scale) -25) { // remove block is it is below the line on the screen
          toRemove.add(b);
        } else {
          b.drawBlock(c);
        }
      }
      for (Block b : toRemove) { // remove blocks in toRemove set
        blocks.remove(b);
      }
      //println(blocks.size());
    }
  }
}
