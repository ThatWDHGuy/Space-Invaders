//commander which tells the space invaders when to move down and change direction
import java.util.*;
public class Commander {

  HashSet<Spacie> spacies = new HashSet<Spacie>(); // make set of spacies
  HashSet<SpacieBullet> sBuls = new HashSet<SpacieBullet>(); // make set of bullets from spacies
  double left = (double) (width/scale) / (double) 6; //spacie x, y start point
  double top = (double) (height/scale) / (double) 8; 
  int moveDir = 1; // -1 = left, 1 = right
  boolean changeDir = false; // should they change direction
  int spaciesLeft = 0;
  int difficulty;

  public Commander(int rows, int cols, int hardness) {
    int type = 0;
    difficulty = hardness;
    for (int row = 0; row < rows; row++) { // change model depending on row they were drawn in
      if (row == 0) { // small
        type = 3;
      } else if (row <= 2) { // normal
        type = 2;
      } else { // big
        type = 1;
      }
      for (int col = 0; col < cols; col++) { // initalise all spacies
        boolean firing = false;
        if (row == rows - 1) { // make buttom row be the ones initally firing
          firing = true;
        }
        spacies.add(new Spacie(left + col * (width/scale) * ((double) 2 / (double) 33), 
          top + row * (height/scale) * ((double) 1.5 / (double) 30), type, row, col, firing, difficulty)); // make new spacie
      }
    }
  }

  public void addBullet(double x, double y) { // add a bullet at x,y of spacie who fired it
    sBuls.add(new SpacieBullet(x, y));
  }

  public void checkFiring() { // update which space invaders are firing
    for (Spacie s1 : spacies) {
      for (Spacie s2 : spacies) {
        if (s1 != s2 && !s2.active) { //could change to count from bottom of each row. check for first active
          if (s1.col == s2.col && s1.row == s2.row - 1) { //if there is no spacie below make it able to fire
            s1.firing = true;
          }
        }
      }
    }
  }

  public void moveAll() {
    spaciesLeft = 0;
    for (Spacie s : spacies) {
      if (s.active) {
        if (s.y > (height/scale) * ((double) 3.75 / (double) 6)) {
          gameOver = true;
          pause = true;
        }
        spaciesLeft++; // count all active spacies
        s.x += moveDir * 2; // move by 2 pixels in move direction
        s.toggleMove(); // change spacie model
        if (s.x >= (width/scale) - s.shapeD[0].length + (-moveDir * 2) - bumper
          || s.x <= s.shapeD[0].length + (-moveDir * 2) + bumper) {
          changeDir = true; // if any spacies reach the end make them all move dwn
        }
      } else {
        if (s.blocks.size() == 0) { // when spacie death has timed out remove the spacies objects
          s.blocks.clear();
        }
      }
    }
    if (changeDir) { //if spacie reached the end, move spacie down and change dir
      swapDir();
      changeDir = false;
    }
  }

  public void moveDebris() {
    for (Spacie s : spacies) { // for all spacies that arent alive, move their debris
      HashSet<Block> toRemove = new HashSet<Block>(); // set that will store bullets to delete
      if (!s.active) {
        s.drawSpacie();
        for (Block b : s.blocks) {
          if (b.y > (height/scale)-23) {
            toRemove.add(b);
          }
        }
        for (Block b : toRemove) { // remove bullets specified above
          s.blocks.remove(b);
        }
      }
    }
  }

  public void checkHit() {
    HashSet<SpacieBullet> toRemove = new HashSet<SpacieBullet>(); // set that will store bullets to delete
    for (SpacieBullet sBul : sBuls) {
      s.checkHit(sBul);
      if (sBul.y > (height/scale) - 25) { // hit bottom
        toRemove.add(sBul);
      } else if (!sBul.active && sBul.blocks.size() == 0) { // bullet exploded and all blocks are off screen
        toRemove.add(sBul);
      }
    }
    for (SpacieBullet sBul : toRemove) { // remove bullets specified above
      sBuls.remove(sBul);
    }
    for (Bullet b : s.bullets) {
      for (Spacie sp : spacies) { 
        if (b.hit(sp.x, sp.y, sp.shapeD[0].length, sp.shapeD.length) && sp.active) { // check if bullet has hit space invader        
          sp.gotHit();
          b.explode();
          waitCount += 20; // wait before moving spacies again
        }
      }
    }
  }

  public void swapDir() {
    moveDir = -1 * moveDir; // change moving left -> right and vise versa
    for (Spacie s : spacies) { // move down a row and move one to new direction
      s.x += moveDir * 2;
      s.y += 8;
    }
  }

  public void paintAll() {
    checkFiring();//update which spacies are firing
    for (SpacieBullet s : sBuls) {
      if (!pause) { // if paused dont move bullets
        s.move();
      }
      s.drawBullet(); // draw bullet
    }
    for (Spacie s : spacies) {
      if (!pause) { // if paused dont fire new bullets
        s.fire();
      }
      s.drawSpacie(); // draw spacie
    }
  }
}
