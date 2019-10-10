public class Scoreboard {

  int score = 0;

  public Scoreboard() {
    score = 0;
  }

  public void addScore(int amount) {
    score += amount;
  }

  public void drawScore() {
    int x = (width/scale) - 80;
    int y = (height/scale) - 5;
    textMode(MODEL); 
    fill(255);
    text("Score: " + score, x, y);
  }
}
