//test1
Map map;
// Position of player center in level coordinates
float playerX, playerY;
// Velocity of player
float playerVX, playerVY;
//acceleration along x-axis
float aX;
//color of player
color pC;
// Speed at which the player moves
float playerSpeed = 150;
// The player is a circle and this is its radius
float playerR = 10;
// Position of the goal center
// Will be set by restart
float goalX=0, goalY=0;
//give gravity
float gravity = 0.5;
//define the height of the floor
int floorHeight;
// Whether to illustrate special functions of class Map
boolean showSpecialFunctions=false;

// left / top border of the screen in map coordinates
// used for scrolling
float screenLeftX, screenTopY;

float levitationTimer=0;

float time;
//int GAMEWAIT=0, GAMERUNNING=1, GAMEOVER=2, GAMEWON=3;
//int gameState;

PImage backgroundImg;
PImage P;

//test2

////// Loads a set of numbered images
// filenames is a relative filename with TWO 00s
// e.g. images/fox-00.png. The function then tries
// to load images/fox-00.png, images/fox-01.png, ..
// as long as these files exist.
ArrayList<PImage> loadImages (String filePattern) {
  // Count number of question marks
  String qmString="";
  while (filePattern.indexOf (qmString+"?")>=0) qmString += "?";
  // The largest sequence of question marks is qmString
  ArrayList<PImage> images = new ArrayList<PImage>();
  int ctr=0;
  do {
    String fname = filePattern.replace(qmString, nf(ctr, qmString.length()));
    InputStream input = createInput(fname);
    if (input==null) break; 
    PImage img = loadImage (fname);
    if (img==null) break;
    images.add(img);
    ctr++;
  } while (true); 
  return images;
}

// Images of the player animation for different phases
ArrayList<PImage> playerImgs;
// phase of the animation (see finite state machine in slides)
int playerPhase;
void setup() {
  size( 500, 500 );
  backgroundImg = loadImage ("images/background.png"); // load the backgroundimage
  newGame ();
}

void newGame () {
  map = new Map( "demo.map");
  for ( int x = 0; x < map.w; ++x ) {
    for ( int y = 0; y < map.h; ++y ) {
      // put player at 'S' tile and replace with 'F'  
      if ( map.at(x, y) == 'S' ) {
        playerX = map.centerXOfTile (x);
        playerY = map.centerYOfTile (y);
        map.set(x, y, 'F');
      }
      // put goal at 'E' tile  
      if ( map.at(x, y) == 'E' ) {
        goalX = map.centerXOfTile (x);
        goalY = map.centerYOfTile (y);
      }
    }
  }
  time=0;
  playerVX = 0;
  playerVY = 0;
  //gameState = GAMEWAIT;
}

void keyPressed() {
  if ( keyCode == UP) {
    playerVY=-200.0;
  }
  if ( keyCode == LEFT ) {
    playerVX = -playerSpeed;
  }
 if ( keyCode == RIGHT ) {
    playerVX = playerSpeed;
  } else if ( keyCode == 'S' ) showSpecialFunctions = !showSpecialFunctions;
}
//void keyReleased() {
//  if(playerVY < -6) playerVY = -6;
//  playerVX = 0;
//}

void updatePlayer() {
  // update player
  float nextX = playerX + playerVX/frameRate, 
    nextY = playerY + playerVY/frameRate;
    playerVY += gravity*time;
  if ( map.testTileInRect( nextX-playerR, nextY-playerR, 2*playerR, 2*playerR, "W" ) && playerVX !=0){
playerVX=0;
  }
  
    if ( map.testTileInRect( nextX-playerR, nextY, 2*playerR, 2*playerR, "W" ))
playerVY=0;
  
  
  //if ( map.testTileFullyInsideRect (nextX-playerR, nextY-playerR, 2*playerR, 2*playerR, "H_") && levitationTimer==0 ) {
  //  gameState=GAMEOVER;
  //}
  //if ( map.testTileFullyInsideRect (nextX-playerR, nextY-playerR, 2*playerR, 2*playerR, "E" ) ) {
  //  gameState=GAMEWON;
  //}
  Map.TileReference tile =map.findTileInRect(nextX-playerR, nextY-playerR, 2*playerR, 2*playerR, "P");
  if(tile!=null){
    levitationTimer=5;
    map.set(tile.x,tile.y,'F');
  }

    if (map.testTileInRect(nextX-playerR, nextY-playerR, 2*playerR, 2*playerR, "P")) {
    levitationTimer=5;
    //map.set(,,,, "F");
  }



  levitationTimer-=1/frameRate;

  fill(255);
  text("Bonus time ; "+levitationTimer, 50, 50);
  if (levitationTimer<0) {
    levitationTimer=0;
  }

  playerX = nextX;
  playerY = nextY;
}

// Maps x to an output y = map(x,xRef,yRef,factor), such that
//     - x0 is mapped to y0
//     - increasing x by 1 increases y by factor
float map (float x, float xRef, float yRef, float factor) {
  return factor*(x-xRef)+yRef;
}

void drawBackground() {
  // Explanation to the computation of x and y:
  // If screenLeftX increases by 1, i.e. the main level moves 1 to the left on screen,
  // we want the background map to move 0.5 to the left, i.e. x decrease by 0.5
  // Further, imagine the center of the screen (width/2) corresponds to the center of the level
  // (map.widthPixel), i.e. screenLeftX=map.widthPixel()/2-width/2. Then we want
  // the center of the background image (backgroundImg.width/2) also correspond to the screen
  // center (width/2), i.e. x=-backgroundImg.width/2+width/2.
  float x = map (screenLeftX, map.widthPixel()/2-width/2, -backgroundImg.width/2+width/2, -0.5);
  float y = map (screenTopY, map.heightPixel()/2-height/2, -backgroundImg.height/2+height/2, -0.5);
  image (backgroundImg, x, y);
}


void drawMap() {   
  // The left border of the screen is at screenLeftX in map coordinates
  // so we draw the left border of the map at -screenLeftX in screen coordinates
  // Same for screenTopY.
  map.draw( -screenLeftX, -screenTopY );
}


//void drawPlayer() {
//  // draw player
//  noStroke();
//  fill(0, 255, 255);
//  ellipseMode(CENTER);
//  ellipse( playerX - screenLeftX, playerY - screenTopY, 2*playerR, 2*playerR );

//  // understanding this is optional, skip at first sight
//  if (showSpecialFunctions) {
//    // draw a line to the next hole   
//    Map.TileReference nextHole = map.findClosestTileInRect (playerX-100, playerY-100, 200, 200, "H");
//    stroke(255, 0, 255);
//    if (nextHole!=null) line (playerX-screenLeftX, playerY-screenTopY, 
//      nextHole.centerX-screenLeftX, nextHole.centerY-screenTopY);

//    // draw line of sight to goal (until next wall) (understanding this is optional)
//    stroke(0, 255, 255);  
//    Map.TileReference nextWall = map.findTileOnLine (playerX, playerY, goalX, goalY, "W");
//    if (nextWall!=null) 
//      line (playerX-screenLeftX, playerY-screenTopY, nextWall.xPixel-screenLeftX, nextWall.yPixel-screenTopY);
//    else
//      line (playerX-screenLeftX, playerY-screenTopY, goalX-screenLeftX, goalY-screenTopY);
//  }
//}


void drawText() { 
  textAlign(CENTER, CENTER);
  fill(0, 255, 0);  
  textSize(40);  
  //if (gameState==GAMEWAIT) text ("press space to start", width/2, height/2);
  //else if (gameState==GAMEOVER) text ("game over", width/2, height/2);
  //else if (gameState==GAMEWON) text ("won in "+ round(time) + " seconds", width/2, height/2);
}


void draw() {
  //if (gameState==GAMERUNNING) {
    time+=1/frameRate;
    updatePlayer();
  //} else if (keyPressed && key==' ') {
    //if (gameState==GAMEWAIT) gameState=GAMERUNNING;
    //else if (gameState==GAMEOVER || gameState==GAMEWON) newGame();
  //}
  screenLeftX = playerX - width/2;
  screenTopY  = playerY - height/2;

  drawBackground();
  drawMap();
  movePlayer();
  drawText();
}