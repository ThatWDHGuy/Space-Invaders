//commander which tells the space invaders when to move down and change direction
public class Commander {

  HashSet<Spacie> spacies = new HashSet<Spacie>(); // make set of spacies
  HashSet<SpacieBullet> sBuls = new HashSet<SpacieBullet>(); // make set of bullets from spacies
  double left = (double) (width/scale) / (double) 6; //spacie x, y start point
  double top = (double) (height/scale) / (double) 8; 
  int moveDir = 1; // -1 = left, 1 = right
  boolean changeDir = false; // should they change direction
  int spaciesLeft = 0;
  int bossesLeft = 0;
  int difficulty;
  Set<SpacieBoss> bosses = new HashSet<SpacieBoss>();

  public Commander(int rows, int cols, int hardness) {
    int type = 0;
    difficulty = hardness;
    if (level % 2 != 0) {
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
      spaciesLeft = spacies.size();
    } else { // BOSS
      bossesLeft = 1;
      bosses.add(new SpacieBoss((width/scale)/2, (height/scale)*0.2, level));
    }
  }

  public void addBullet(double x, double y, int rad) { // add a bullet at x,y of spacie who fired it
    sBuls.add(new SpacieBullet(x, y, rad));
  }

  public void addBullet(double x, double y, int rad, float angle) { // add a bullet at x,y of spacie who fired it
    sBuls.add(new SpacieBullet(x, y, rad, angle));
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
        spaciesLeft++; // count all active spacies
        if (!s.bombing) {
          if (s.y > (height/scale) * ((double) 3.75 / (double) 6)) {
            gameOver = true;
            pause = true;
          }
          s.x += moveDir * 2; // move by 2 pixels in move direction
          s.toggleMove(); // change spacie model
          if (s.x >= (width/scale) - s.shapeD[0].length + (-moveDir * 2) - bumper
            || s.x <= s.shapeD[0].length + (-moveDir * 2) + bumper) {
            changeDir = true; // if any spacies reach the end make them all move dwn
          }
        } else { //spacie is doing a bombing run
          s.bombX += moveDir * 2;
          s.toggleMove();
        }
      } else {
        if (s.blocks.size() != 0) { // when spacie death has timed out remove the spacies objects
          // s.blocks.clear();
          spaciesLeft++;
        }
      }
    }
    bossesLeft = 0;
    for (SpacieBoss sb : bosses) {
      if (sb.active) {
        bossesLeft++; // count all active spacies
        if (sb.y > (height/scale) * ((double) 3.75 / (double) 6)) {
          gameOver = true;
          pause = true;
        }
        sb.x += moveDir * 8; // move by 2 pixels in move direction
        sb.toggleMove(); // change spacie model
        if (sb.x >= (width/scale) - sb.shapeD[0].length + (-moveDir * 8) - bumper
          || sb.x <= sb.shapeD[0].length + (-moveDir * 8) + bumper) {
          changeDir = true; // if any spacies reach the end make them all move dwn
        }
      } else {
        if (sb.blocks.size() != 0) { // when spacie death has timed out remove the spacies objects
          //println(sb.blocks.size());
          bossesLeft++;
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
      if (!s.active) {
        HashSet<Block> toRemove = new HashSet<Block>(); // set that will store bullets to delete
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
    for (SpacieBoss sb : bosses) {
      if (!sb.active) {
        HashSet<Block> toRemove = new HashSet<Block>(); // set that will store bullets to delete
        sb.drawSpacie();
        for (Block b : sb.blocks) {
          if (b.y > (height/scale)-23) {
            toRemove.add(b);
          }
        }
        for (Block b : toRemove) { // remove bullets specified above
          sb.blocks.remove(b);
        }
      }
    }
  }

  public void checkHit() {
    HashSet<SpacieBullet> toRemove = new HashSet<SpacieBullet>(); // set that will store bullets to delete
    for (SpacieBullet sBul : sBuls) {
      if (sBul.active) {
        s.checkHit(sBul);
        for (Bullet b : s.bullets) {
          if (b.active) {
            if (b.hit(sBul.x, sBul.y, 3, 8)) {
              sBul.explode();
              b.explode();
            }
          }
        }
      }
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
      if (b.active) {
        for (Spacie sp : spacies) { 
          if (b.hit(sp.x, sp.y, sp.shapeD[0].length, sp.shapeD.length) && sp.active) { // check if bullet has hit space invader        
            sp.gotHit();
            b.explode();
            waitCount = 20/level; // wait before moving spacies again
          }
        }

        for (SpacieBoss sb : bosses) {
          if (b.hit(sb.x, sb.y, sb.shapeD[0].length*3, sb.shapeD.length*3) && sb.active) {
            sb.gotHit();
            b.explode();
          }
        }
      }
    }
  }

  public void swapDir() {
    moveDir = -1 * moveDir; // change moving left -> right and vise versa
    for (Spacie s : spacies) { // move down a row and move one to new direction
      if (!s.bombing) {
        s.x += moveDir * 2;
        s.y += 8;
      } else {
        s.bombX += moveDir * 2;
        s.bombY += 8;
      }
    }
    for (SpacieBoss sb : bosses) {
      sb.x += moveDir * 8;
      sb.y += 12;
    }
  }

  public void paintPaused() {
    for (SpacieBullet s : sBuls) {
      s.drawBullet(); // draw bullet
    }
    for (Spacie s : spacies) {
      s.drawSpacie(); // draw spacie
    }
    for (SpacieBoss sb : bosses) {
      sb.drawSpacie(); // draw spacie
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
      if (s.active) {
        s.drawSpacie(); // draw spacie
      }
    }
    for (SpacieBoss sb : bosses) {
      if (!pause) { // if paused dont fire new bullets
        sb.fire();
      }
      if (s.active) {
        sb.drawSpacie(); // draw spacie
        //println("draw boss, "+ sb.x + ", "+ sb.y);
      }
    }
  }
}
