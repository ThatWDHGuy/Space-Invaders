class Background {

  HashSet<Star> backStars = new HashSet<Star>();
  HashSet<Star> frontStars = new HashSet<Star>();
  int numStars = 300;
  int radMin = 0;
  int radMax = 2;
  int maxRed = 64;
  int maxGreen = 128;
  int maxBlue = 128;

  public Background() {
    for (int i = 0; i < numStars; i++) {
      backStars.add(new Star(random(0, (width/scale)+50), random(0, (height/scale) - 25), random(radMin, radMax), (int) random(0, maxRed), (int) random(0, maxGreen), (int) random(0, maxBlue)));
      frontStars.add(new Star(random(0, (width/scale)+50), random(0, (height/scale) - 25), random(radMin, radMax), (int) random(0, maxRed + 128), (int) random(0, maxGreen), (int) random(0, maxBlue)));
    }
  }

  public void drawBackGround(double x) {
    drawFront(x);
    drawBack(x);
  }

  public void drawFront(double x) {
    for (Star s : frontStars) {
      s.drawStar(((float)x)/10);
    }
  }

  public void drawBack(double x) {
    for (Star s : backStars) {
      s.drawStar(((float)x)/20);
    }
  }
}

class Star {

  float x, y, rad;
  int r, g, b;

  public Star(double x, double y, double rad, int r, int g, int b) {
    this.x = (float) x;
    this.y = (float) y;
    this.rad = (float) rad;
    this.r = r;
    this.g = g;
    this.b = b;
  }

  public void drawStar(float offset) {
    fill(r, g, b, 64);
    ellipse(x + offset, y, 2*rad, 2*rad);
    fill(r, g, b, 128);
    ellipse(x + offset, y, (2.0/3.0)*rad, (2.0/3.0)*rad);
    fill(r, g, b, 192);
    ellipse(x + offset, y, (2.0/3.0)*rad, (1.0/1.0)*rad);
  }
}
