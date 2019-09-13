//Block is used to draw things and acts as debris
public class Block {

  float x, y; // initalise variables
  double dx, dy;
  double moveDir;
  int fallSpeed = 1;
  double grav = 2;
  boolean falling = false;

  public Block(double x, double y) { // make block at x,y
    this.x = (int) x;
    this.y = (int) y;
    //System.out.println("Block made");
  }

  public void initFall() { // when block has been hit make it fly off in a random direction
    moveDir = Math.random() * 2 * Math.PI;
    dx = (double) fallSpeed * (double) Math.cos(moveDir);
    dy = (double) fallSpeed * (double) Math.sin(moveDir);
    falling = true;
  }

  public void drawBlock(color c) {
    fill(c);
    if (!falling) { // draw block at x,y if its not fallinf
      rect((int) x, (int) y, 1, 1);
    } else { // block is falling, move the block and redraw
      if (y < (height/scale)) {
        if (!pause || gameOver) {
          dy += 0.01 * grav;
          x += dx;
          y += dy;
        }
        rect((int) x, (int) y, 1, 1);
      }
    }
  }
}
