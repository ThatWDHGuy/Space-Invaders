class PowerUp {

  float x, y;
  int powerUpRad = 3;
  int powerUpType;
  boolean active = true;
  //1 = invinsibility
  //2 = multishot
  //3 = rapidfire

  public PowerUp(float x, float y) {
    this.x = x;
    this.y = y;
    powerUpType = (int) random(1, 4);
  }

  public void move() {
    y += 1;
  }

  public void drawPowerUp() {
    if (powerUpType == 1) {
      fill(0, 0, 255, 128);
    } else if (powerUpType == 2) {
      fill(255, 255, 0, 128);
    } else if (powerUpType == 3) {
      fill(255, 0, 0, 128);
    }
    ellipse(x, y, 2*powerUpRad, 2* powerUpRad);
  }

  public void checkPickup() {
    for (Block b : s.blocks) {
      if (!b.falling && powerUpRad >= dist(b.x, b.y, this.x, this.y)) {
        s.powerUpState = powerUpType;
        s.powerUpTimer = 1000;
        active = false;
      }
    }
  }
}
