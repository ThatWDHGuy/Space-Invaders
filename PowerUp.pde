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
    if (unlockedPow.size() < 3) {
      powerUpType = (int) random(1, 4);
      while (unlockedPow.contains(powerUpType)) {
        powerUpType = (int) random(1, 4);
      }
    } else {
      powerUpType = 4;
    }
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
    } else if (powerUpType == 4) {
      fill(128, 128, 128, 128);
    }
    ellipse(x, y, 2*powerUpRad, 2* powerUpRad);
  }

  public void checkPickup() {
    for (Block b : s.blocks) {
      if (!b.falling && powerUpRad >= dist(b.x, b.y, this.x, this.y)) {
        s.powerUpState = powerUpType;
        if (powerUpType == 1) {
          s.invinsible = true;
        } else {
          s.invinsible = false;
        }
        s.powerUpTimer = 1000;
        active = false;
        if (powerUpType == 0) {
          popUps.add(new PopUp("Default", getPowerUpCol(0)));
        } else if (powerUpType == 1) {
          popUps.add(new PopUp("Invinsibility", getPowerUpCol(1)));
        } else if (powerUpType == 2) {
          popUps.add(new PopUp("Multi-Shot", getPowerUpCol(2)));
        } else if (powerUpType == 3) {
          popUps.add(new PopUp("Rapid-Fire", getPowerUpCol(3)));
        } else if (powerUpType == 4) {
          popUps.add(new PopUp("Semi-God", getPowerUpCol(4)));
        } 
        if (unlockedPow.contains(powerUpType)) {
          sc.addScore(1500);
        } else {
          unlockedPow.add(powerUpType);
        }
      }
    }
  }
}
