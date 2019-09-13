//class of spacie bullet
import java.util.*;
public class SpacieBullet {

  double x, y;
  int[][] shapeL = spacieBulletModelL; // models of bullet
  int[][] shapeR = spacieBulletModelR;
  HashSet<Block> blocks = new HashSet<Block>(); // set of blocks in bullet
  boolean active = true;
  int shapeNo = 0;
  int[][] shape = shapeL;

  public SpacieBullet(double x, double y) { //make bullet at x,y
    this.x = x;
    this.y = y;
  }

  public void move() { // move down when active
    if (active) {
      y += 2;
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
    if (shapeNo == 1 && !pause) { //swap bullet from L to R model
      shapeNo = 0;
      shape = shapeL;
    } else {
      if (!pause) {
        shapeNo = 1;
        shape = shapeR;
      }
    }
    color c = color(128); // grey bullets
    fill(c);
    if (active) {
      for (int i = 0; i < shape[0].length; i++) {
        for (int ii = 0; ii < shape.length; ii++) { //draw rectangles where bullet model shows
          if (shape[ii][i] == 1) {
            rect((int) (x - 1 + i), (int) (y - 3 + ii), 1, 1);
          }
        }
      }
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
