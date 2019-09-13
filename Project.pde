import java.util.*;
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

long lastTime = System.nanoTime(); // used for making ensuring game tick time is accurate
long currentTime = System.nanoTime();

int scale = 3;
int canX = 224*scale;
int canY = 256*scale;

void settings() {
  size(canX, canY,OPENGL);
}


void setup() {
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

  if (currentTime - lastTime > 1000000000.0/65.0) { // is time since last frame 1/60th of a second
    println("Tick time: " + (currentTime - lastTime) + ", Expected: " + (1000000000.0/60.0));
    lastTime = currentTime;
    background(0); //make canvas block
    if (lives == 0) {
      pause = true; // stop game when run out of lives
      gameOver = true;
    }

    if (running) { // if runnning (not at menu)
      drawHUD();

      if (!pause) { // if game isnt paused run through and draw and move everything
        gameRunning();
      } else { //if game is paused
        gamePaused();
      }
    } else {//menu screen
      menu();
    }
  }
}

public void drawHUD() {
  bg.drawBackGround(s.x);
  fill(255); // draw bottom line and life counter
  rect(0, (height/scale) - 23, (width/scale), 1);
  if (s.powerUpState == 0) {
    fill(0, 255, 0);
  } else if (s.powerUpState == 1) {
    fill(0, 0, 255);
  } else if (s.powerUpState == 2) {
    fill(255, 255, 0);
  } else if (s.powerUpState == 3) {
    fill(255, 0, 0);
  }
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
  sc.drawScore();
}

public void gameRunning() {
  //println(c.spaciesLeft);
  if (c.spaciesLeft != 0) { // set time between spacie moving, less spacies more speed
    waitTime = c.spaciesLeft/c.difficulty;
    doNextLevel = true;
  } else {
    waitTime = (rows * cols/c.difficulty);
  }
  if (waitCount != 0) {// is its not time to move the spacies
    waitCount--;
    loopCount--;
  }
  if (loopCount % waitTime == 0 && waitCount == 0) { //when true its time to move the spacies along
    c.moveAll();
  }
  c.moveDebris(); // move all debris from spacies
  for (Shield shield : shields) { // for each shield if active
    if (shield.active) {
      shield.checkHit(); //did anything hit?
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

  s.move(); // move ship in current direction then draw
  s.drawShip();
  loopCount++;
  println(level);
  if (c.spaciesLeft == 0 && doNextLevel) {
    nextLevel();
  }
}

public void gamePaused() {
  c.paintAll(); //draw all spacies, ship and shields
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
    text("GAME OVER", (width/scale)/2 - 40, (height/scale)/2 - 25, 80, 50);
  } else {
    text("Paused", (width/scale)/2 - 10, (height/scale)/2 - 25, 80, 50);
  }
}

public void menu() {
  fill(192);
  textSize(20);
  text("EMPTINESS ITRUDERS", 10, 20);
  textSize(10);
  text("Controls: ", 20, 40);
  text(" 'Arrows' - Move Ship", 20, 50);
  text(" 'Space' - Fire", 20, 60);
  text(" 'P' - Pause game", 20, 70);
  text(" 'R' - Quick restart", 20, 80);
  text("Enemies: ", 20, 100);
  text("Smol Boi - 300P", 30, 110);
  text("Medium Boi - 200P", 30, 120);
  text("Big Boi - 100P", 30, 130);
  text("UFO - ????P - Drops power up on kill", 35, 140);
  text("Aim: Kill Intruders", 70, 180);
  text("Press 'R' to Start", 70, 200);
  Spacie sb = new Spacie (22, 106, 3, 0, 0, false, 0);
  Spacie mb = new Spacie (22, 116, 2, 0, 0, false, 0);
  Spacie bb = new Spacie (22, 126, 1, 0, 0, false, 0);
  sb.drawSpacie();
  mb.drawSpacie();
  bb.drawSpacie();
  UFO u = new UFO(15, 136);
  u.drawUFO();
  s.drawShip();
}

public void setupGame(int diff) {
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
  c = new Commander(rows, cols, diff); // initalize commander and ship
}

public void nextLevel() {
  if (doNextLevel) {
    shields.clear();
    for (int i = 0; i < noShields; i++) { // add shields
      shields.add(new Shield((double) (i + 1) / (double) (noShields + 1) * (double) (width/scale) + 3, (double) (height/scale) * ((double) 4.25 / (double) 6)));
    }
    c = new Commander(rows, cols, ++level); // initalize commander and ship
  }
}

void keyPressed() {
  if (keyCode == LEFT && !pause) { // if the game isnt paused and left, right or space are pressed
    //if (running){
    s.moveDir = -1;
    s.move();
    //}
  } else if (keyCode == RIGHT && !pause) {
    //if (running){
    s.moveDir = 1;
    s.move();
    //}
  } else if (key == ' ' && !pause) {
    if (!running) {
      //setupGame();
    } else {
      s.fire();
    }
  } else if (key == 'r') {
    setupGame(1);
  } else if (key == 'p') {
    if (pause && !gameOver) {
      pause = false;
    } else  if (!pause && !gameOver) {
      pause = true;
    }
  }
}

void keyReleased() { // when key released stop moving ship
  if ((keyCode == LEFT || keyCode == RIGHT) && running) {
    s.moveDir = 0;
  }
}

/*void mouseReleased(){
 s.fire();
 }*/
