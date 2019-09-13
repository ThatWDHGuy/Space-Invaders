//class of one of the shields

import java.util.*;

public class Shield {

  // initalise variables for shield
  int x, y;
  int[][] shape = shieldModel;
  HashSet<Block> blocks = new HashSet<Block>();
  boolean active = true;

  public Shield(double x, double y) {
    this.x = (int) x;
    this.y = (int) y;
    for (int i = 0; i < shape[0].length; i++) {  
      for (int ii = 0; ii < shape.length; ii++) {
        if (shape[ii][i] == 1) {
          blocks.add(new Block((int) (x - 12 + i), (int) (y - 9 + ii))); // add a block at each x,y in its model
        }
      }
    }
  }

  public void checkHit() { // fix removing sBuls from hashSet after amount of time;
    //println(c.sBuls.size() + " " + s.bullets.size());
    for (SpacieBullet sBul : c.sBuls) {
      boolean delBul = false;
      if (sBul.active) { // if bullet hasnt exploded
        for (Block blo : blocks) {
          if (Math.hypot(sBul.x - blo.x, sBul.y - blo.y) < 2 && !blo.falling) { // check if bullet hit another block that is still active
            delBul = true;
            for (Block bloc : blocks) {
              if (Math.hypot(sBul.x - bloc.x, sBul.y - bloc.y) < 3) { // check blocks in 3 block radius for explosion
                bloc.initFall();
              }
            }
            break;
          }
        }
        if (delBul) { // if bullet hit something, explode
          sBul.explode();
        }
      }
    }
    for (Bullet bul : s.bullets) {
      boolean delBul = false;
      if (bul.active) {
        for (Block blo : blocks) {
          if (Math.hypot(bul.x - blo.x, bul.y - blo.y) < 2 && !blo.falling) { // check if bullet hit another block that is still active
            delBul = true;
            for (Block bloc : blocks) {
              if (Math.hypot(bul.x - bloc.x, bul.y - bloc.y) < 3) {// check blocks in 3 block radius for explosion
                bloc.initFall();
              }
            }
          }
        }
        if (delBul) { // if bullet hit something, explode
          bul.explode();
        }
      }
    }
    /*for (Spacie s : c.spacies){
     if (s.active){
     for (Block blo : blocks) {
     if (Math.hypot((s.x - blo.x),(s.y - blo.y)) < min(s.shapeU.length, s.shapeU[0].length)){
     blo.initFall();
     }
     }
     }
     }*/
  }

  public void drawShield() {
    if (blocks.size() == 0) { // if shield had no blocks left, make it inactive
      active = false;
    }
    HashSet<Block> toRemove = new HashSet<Block>(); // set of blocks to remove
    for (Block b : blocks) {
      if (b.y < (height/scale) - 25) { // if block is above above bottom of screen
        b.drawBlock(color(0, 255, 0));
      } else {
        toRemove.add(b); //if below bottom of screen add to set to be removed
      }
    }
    for (Block b : toRemove) { // remove blocks in set
      blocks.remove(b);
    }
    //println(blocks.size());
  }
}
