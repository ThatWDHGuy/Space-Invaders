import java.util.*;

//All code written by William Hollywood in Processing

//initalize + set variables
boolean running; //when true allows game to run
int rows = 5; // rows and cols of spacie invaders
int cols = 11; 
int waitTime = rows * cols;// wait time between moving
long loopCount = 0;
Commander c; // commander to controll all spacie invaders
Ship s; // ship
UFO ufo;
Scoreboard sc;
HashSet<PowerUp> powerUps = new HashSet<PowerUp>(); //set of shields
Background bg; // paralax background
HashSet<Shield> shields = new HashSet<Shield>(); //set of shields
int noShields = 4; // how many shields
int waitCount = 0;
int lives = 3; 
int bumper = 4; //side of screen bumper
boolean pause = false; // temp pause game
boolean gameOver = false;
int level = 1;
boolean doNextLevel = false;
Set<Integer> unlockedPow = new HashSet<Integer>();

long lastTime = System.nanoTime(); // used for making ensuring game tick time is accurate
long currentTime = System.nanoTime();

int scale = 3;
int canX = 224*scale;
int canY = 256*scale;

//debugging what takes so long
long beforeTime = System.nanoTime();

PFont font;

ArrayList<PopUp> popUps = new ArrayList<PopUp>();

void settings() {
  size(canX, canY);
}


void setup() {
  font = createFont("minecraft_font.ttf", 32);
  textFont(font);
  frameRate(1000); // try to call draw as frequently as possible
  ellipseMode(CENTER);
  textMode(MODEL); 
  noStroke();
  textSize(20);
  sc = new Scoreboard();
  s = new Ship((width/scale) / 2, (height/scale) * ((double) 5 / (double) 6));
}

void draw() {
  scale(scale);
  currentTime = System.nanoTime();

  if (currentTime - lastTime > 1000000000.0/60.0) { // is time since last frame 1/60th of a second
    //println("Tick time: " + (currentTime - lastTime) + ", Expected: " + (1000000000.0/60.0));
    lastTime = currentTime;
    background(0); //make canvas block
    if (lives == 0) {
      pause = true; // stop game when run out of lives
      gameOver = true;
    }

    if (running) { // if runnning (not at menu)
      bg.drawBackGround(s.x);
      if (!pause) { // if game isnt paused run through and draw and move everything
        gameRunning();
        drawHUD();
      } else { //if game is paused\
        drawHUD();
        gamePaused("Paused");
      }
      doPopUp();
    } else {//menu screen
      menu();
    }
  }
}

public color getPowerUpCol(int state) {
  if (state == 0) {
    return color(0, 255, 0);
  } else if (state == 1) {
    return color(0, 0, 255);
  } else if (state == 2) {
    return color(255, 255, 0);
  } else if (state == 3) {
    return color(255, 0, 0);
  } else if (state == 4) {
    return color(128, 128, 128);
  } else if (state == 5) {
    return color(255, 255, 255);
  } else {
    return color(255);
  }
}

public void drawHUD() {
  fill(0);
  rect(0, (height/scale) - 23, (width/scale), 23);
  fill(255); // draw bottom line and life counter
  rect(0, (height/scale) - 23, (width/scale), 1);
  fill(getPowerUpCol(s.powerUpState));
  for (int lifeNo = 0; lifeNo < lives; lifeNo++) { // draw lives
    int x = lifeNo*15 + 3;
    int y = (height/scale) - 15;
    for (int i = 0; i < shipModel[0].length; i++) {
      for (int ii = 0; ii < shipModel.length; ii++) {
        if (shipModel[ii][i] == 1) {
          rect((int) (x + i), (int) (y + ii), 1, 1);
        }
      }
    }
  }
  // draw unlocked powerups
  textAlign(CENTER);
  textSize(6);
  fill(255);
  text("Unlocked Power Ups", (width/scale)/2 - 14, (height/scale) - 15);
  fill(getPowerUpCol(0));
  text("0", (width/scale)/2 - 28, (height/scale) - 5);
  if (unlockedPow.contains(1)) {
    fill(getPowerUpCol(1));
    text("1", (width/scale)/2 - 21, (height/scale) - 5);
  }
  if (unlockedPow.contains(2)) {
    fill(getPowerUpCol(2));
    text("2", (width/scale)/2 - 14, (height/scale) - 5);
  }
  if (unlockedPow.contains(3)) {
    fill(getPowerUpCol(3));
    text("3", (width/scale)/2 - 7, (height/scale) - 5);
  }
  if (unlockedPow.contains(4)) {
    fill(getPowerUpCol(4));
    text("4", (width/scale)/2, (height/scale) - 5);
  }
  if (unlockedPow.contains(5)) {
    fill(getPowerUpCol(5));
    text("5", (width/scale)/2 + 7, (height/scale) - 5);
  }
  textAlign(CORNER);
  textSize(8);
  sc.drawScore();
}

public void gameRunning() {
  c.paintAll();
  if (c.spaciesLeft != 0|| !c.bosses.isEmpty()) {
    waitTime = ((c.spaciesLeft + c.bossesLeft*50)/c.difficulty) + 1;// set time between spacie moving, less spacies more speed
    if (waitCount != 0) {// is its not time to move the spacies
      waitCount--;
      loopCount--;
    }
    if (waitCount == 0) { //when true its time to move the spacies along
      if (loopCount % waitTime == 0) {
        c.moveAll();
      }
    }
    for (Shield shield : shields) { // for each shield if active
      if (shield.active) {
        //beforeTime = System.nanoTime();
        shield.checkHit(); //did anything hit?
        //println("Shield Check Tick time: " + (System.nanoTime() - beforeTime));
        shield.drawShield(); //draw the shield
      }
    }
    if (ufo.flyWait > 0) {
      ufo.flyWait--;
    } else {
      ufo.move();
    }
    if (ufo.x < -50 && ufo.blocks.size() == 0) {
      ufo = new UFO(width/scale + 50, 7);
    }

    c.moveDebris(); // move all debris from spacies
    c.checkHit(); // check if anything hit the spacie invaders
    c.paintAll(); // draw all spacie invaders
    HashSet<PowerUp> toRemove = new HashSet<PowerUp>();
    for (PowerUp p : powerUps) {
      p.move();
      p.drawPowerUp();
      p.checkPickup();
      if (!p.active || p.y > (height/scale) - 28) {
        toRemove.add(p);
      }
    }
    for (PowerUp p : toRemove) {
      powerUps.remove(p);
    }
    if (s.firing) {
      s.fire();
    }

    s.move(); // move ship in current direction then draw
    s.drawShip();
    loopCount++;
    if (c.spaciesLeft == 0 && c.bossesLeft == 0) {
      nextLevel();
    }
  }
}

public void gamePaused(String str) {
  //c.paintAll(); //draw all spacies, ship and shields
  c.paintPaused();
  s.drawShip();
  for (Shield s : shields) {
    s.drawShield();
  }
  for (PowerUp p : powerUps) {
    p.drawPowerUp();
  }
  ufo.drawUFO();
  //draw Game over
  if (gameOver) {
    fill(26, 128);
    rect(0, 0, width/scale, height/scale);
    textAlign(CENTER);
    fill(255);
    text("GAME OVER", (width/scale)/2, (height/scale)/2);
    text("PRESS 'R' TO RESTART", (width/scale)/2, (height/scale)/2 + 20);
    textAlign(CORNER);
  } else {
    fill(26, 128);
    rect(0, 0, width/scale, height/scale);
    textAlign(CENTER);
    fill(255);
    text(str, (width/scale)/2, (height/scale)/2);
    textAlign(CORNER);
  }
}

public void menu() {
  fill(192);
  textSize(17);
  textAlign(CENTER);
  text("EMPTINESS ITRUDERS", (width/scale)/2, 20);
  textSize(8);
  textAlign(CORNER);
  text("Controls: ", 20, 40);
  text(" 'Arrow Keys' - Move Ship", 20, 50);
  text(" 'Space' - Fire", 20, 60);
  text(" 'P' - Pause game", 20, 70);
  text(" 'R' - Quick restart", 20, 80);
  text("Enemies: ", 20, 100);
  text("Smol Boi - 300P", 30, 110);
  text("Medium Boi - 200P", 30, 120);
  text("Big Boi - 100P", 30, 130);
  text("UFO - ????P - Drops power up on kill", 35, 140);
  textAlign(CENTER);
  text("Aim: Kill Intruders", (width/scale)/2, 180);
  text("Press 'R' to Start", (width/scale)/2, 200);
  textSize(3);
  text("By William Hollywood", 20, height/scale - 2);
  textAlign(CORNER);
  Spacie sb = new Spacie (22, 106, 3, 0, 0, false, 0);
  Spacie mb = new Spacie (22, 116, 2, 0, 0, false, 0);
  Spacie bb = new Spacie (22, 126, 1, 0, 0, false, 0);
  sb.drawSpacie();
  mb.drawSpacie();
  bb.drawSpacie();
  UFO u = new UFO(15, 136);
  u.drawUFO();
  s.drawShip();
  s.move();
  popUps.clear();
}

public void doPopUp() {
  ArrayList<PopUp> toRemove = new ArrayList<PopUp>();
  for (PopUp p : popUps) {
    p.drawPop();
    if (p.y > 40) {
      toRemove.add(p);
    }
  }
  for (PopUp p : toRemove) {
    popUps.remove(p);
  }
}

public void setupGame(int diff) {
  powerUps.clear();
  level = diff;
  doNextLevel = false;
  running = true; // start game
  pause = false;
  gameOver = false;
  s = new Ship((width/scale) / 2, (height/scale) * ((double) 5 / (double) 6));
  ufo = new UFO(width/scale + 50, 7);
  bg = new Background();
  sc.score = 0;
  shields.clear();
  lives = 3;
  for (int i = 0; i < noShields; i++) { // add shields
    shields.add(new Shield((double) (i + 1) / (double) (noShields + 1) * (double) (width/scale) + 3, (double) (height/scale) * ((double) 4.25 / (double) 6)));
  }
  unlockedPow.clear();
  c = new Commander(rows, cols, diff); // initalize commander and ship
}

public void nextLevel() {
  shields.clear();
  s.bullets.clear();
  c.sBuls.clear();
  for (int i = 0; i < noShields; i++) { // add shields
    shields.add(new Shield((double) (i + 1) / (double) (noShields + 1) * (double) (width/scale) + 3, (double) (height/scale) * ((double) 4.25 / (double) 6)));
  }
  c = new Commander(rows, cols, ++level); // initalize commander and ship
}

int state = 0;

//FSM for god mode cheat
void doFSM() {
  if (keyCode == UP && state == 0) {
    state = 1;
  } else if (keyCode == UP && state == 1) {
    state = 2;
  } else if (keyCode == DOWN && state == 2) {
    state = 3;
  } else if (keyCode == DOWN && state == 3) {
    state = 4;
  } else if (keyCode == LEFT && state == 4) {
    state = 5;
  } else if (keyCode == RIGHT && state == 5) {
    state = 6;
  } else if (keyCode == LEFT && state == 6) {
    state = 7;
  } else if (keyCode == RIGHT && state == 7) {
    state = 8;
  } else if ((key == 'b' || key == 'B') && state == 8) {
    state = 9;
  } else if ((key == 'a' || key == 'A') && state == 9) {
    state = 10;
  } else if (keyCode == ENTER && state == 10) {
    unlockedPow.add(1);
    unlockedPow.add(2);
    unlockedPow.add(3);
    unlockedPow.add(4);
    unlockedPow.add(5);
    popUps.add(new PopUp("Code Accepted", getPowerUpCol(5)));
    s.powerUpState = 5;
    s.invinsible = true;
    s.overrideTimer = true;
    s.drawShip();
    state = 0;
  } else {
    state = 0;
  }
  //println(state)
}

void keyPressed() {
  if ((keyCode == LEFT || key == 'a') && !pause) { // if the game isnt paused and left, right or space are pressed
    if (s.moveQueue.indexOf(0) != -1) {
      s.moveQueue.remove(s.moveQueue.indexOf(0));
    }
    if (!s.moveQueue.contains(-1)) {
      s.moveQueue.add(-1);
    }
  } else if ((keyCode == RIGHT || key == 'd') && !pause) {
    if (s.moveQueue.indexOf(0) != -1) {
      s.moveQueue.remove(s.moveQueue.indexOf(0));
    }
    if (!s.moveQueue.contains(1)) {
      s.moveQueue.add(1);
    }
  } else if (key == ' ' && !pause) {
    if (!running) {
      //setupGame();
    } else {
      s.firing = true;
    }
  } else if ( key == 'r' || key == 'R') {
    setupGame(1);
  } else if (key == 'p' || key == 'P') {
    if (pause && !gameOver) {
      pause = false;
    } else  if (!pause && !gameOver) {
      pause = true;
    }
  }
}
//add width var in for longer txt,
//add y var in for 2 consecutive msgs
class PopUp {
  color c;
  String s;
  float y = 0;
  public PopUp(String str, color col) {
    s = str;
    c = col;
  }

  public void drawPop() {
    rectMode(CENTER);
    fill(255);
    rect((width/scale)/2, 20 - y, 80, 20);
    fill(0);
    rect((width/scale)/2, 20 - y, 78, 18);
    fill(255);
    textAlign(CENTER);
    fill(c);
    text(s, (width/scale)/2, 20 - y, 100, 15);
    rectMode(CORNER);
    y+= 0.25;
  }
}


void keyReleased() { // when key released stop moving ship
  doFSM();
  if (key == '0') {
    popUps.add(new PopUp("Default", getPowerUpCol(0)));
    s.powerUpState = 0;
    s.powerUpTimer = 0;
    s.overrideTimer = false;
  } else if (key == '1' && unlockedPow.contains(1)) {
    popUps.add(new PopUp("Invinsibility", getPowerUpCol(1)));
    s.powerUpState = 1;
    s.invinsible = true;
    s.overrideTimer = true;
  } else if (key == '2' && unlockedPow.contains(2)) {
    popUps.add(new PopUp("Multi-Shot", getPowerUpCol(2)));
    s.powerUpState = 2;
    s.invinsible = false;
    s.overrideTimer = true;
  } else if (key == '3' && unlockedPow.contains(3)) {
    popUps.add(new PopUp("Rapid-Fire", getPowerUpCol(3)));
    s.powerUpState = 3;
    s.invinsible = false;
    s.overrideTimer = true;
  } else if (key == '4' && unlockedPow.contains(4)) {
    popUps.add(new PopUp("Semi-God", getPowerUpCol(4)));
    s.powerUpState = 4;
    s.invinsible = false;
    s.overrideTimer = true;
  } else if (key == '5' && unlockedPow.contains(5)) {
    popUps.add(new PopUp("God", getPowerUpCol(5)));
    s.powerUpState = 5;
    s.invinsible = true;
    s.overrideTimer = true;
  } else if ((keyCode == LEFT || key == 'a') && !pause) {
    if (s.moveQueue.indexOf(-1) != -1) {
      s.moveQueue.remove(s.moveQueue.indexOf(-1));
    }
  } else if ((keyCode == RIGHT || key == 'd') && !pause) {
    if (s.moveQueue.indexOf(1) != -1) {
      s.moveQueue.remove(s.moveQueue.indexOf(1));
    }
  } else if (key == ' ') {
    s.firing = false;
  }
}
