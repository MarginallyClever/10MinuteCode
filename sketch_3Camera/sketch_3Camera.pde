// how big is the terrain
int mapSizeX = 256;  // # of dots
int mapSizeY = 256;  // # of dots
int mapHeight = 300;  // scale

// perlin noise values
// larger scale makes the terrain more bumpy
float xScale = 0.01;
float yScale = 0.01;
// adj moves the terrain
float xAdj = 0;
float yAdj = 0.005;
float speedX = 0.0;
float speedY = 0.0;

// where to store the terrain data
PVector [] points;

Palette palette = new Palette();

void setup() {
  size(800,800,P3D);
  palette.addColor(0.00,color( 64, 64,255));
  palette.addColor(0.50,color( 64, 64,255));
  palette.addColor(0.60,color(255,255,  0));
  palette.addColor(0.65,color(  0,255,  0));
  palette.addColor(0.80,color(255,192,  0));
  palette.addColor(0.90,color(255,255,255));
  palette.addColor(1.00,color(255,255,255));
  
  createMap();
  generateMap();
}

/**
 * Use keys to fly around world
 */
void keyPressed() {
  switch(key) {
    case 'w': case 'W': speedY = -0.05;  break;
    case 's': case 'S': speedY =  0.05;  break;
    case 'a': case 'A': speedX = -0.05;  break;
    case 'd': case 'D': speedX =  0.05;  break;
  }
}

/**
 * Use keys to fly around world
 */
void keyReleased() {
  switch(key) {
    case 'w': case 'W': 
    case 's': case 'S': speedY = 0.0;  break;
    case 'a': case 'A': 
    case 'd': case 'D': speedX = 0.0;  break;
  }
}


void createMap() {
  points = new PVector[mapSizeX*mapSizeY];
  int i=0;
  
  for(int y=0;y<mapSizeY;++y) {
    for(int x=0;x<mapSizeX;++x) {
      points[i++] = new PVector();
    }
  }
}

void generateMap() {
  int i=0;
  
  for(int y=0;y<mapSizeY;++y) {
    for(int x=0;x<mapSizeX;++x) {
      float z = noise(x*xScale + xAdj,
                      y*yScale + yAdj);
      points[i++].set(x-mapSizeX/2,
                      y-mapSizeY/2,
                      z);
    }
  }
}

void draw() {
  background(0);
  camera();
  drawPalatte();
  lights();
  moveCamera();
  
  xAdj+=speedX;
  yAdj+=speedY;
  generateMap();
  
  drawTerrain();
  drawWater();
}


void moveCamera() {
  float mx = 2* PI * mouseX/width;
  float my = PI * mouseY/height;
  float x = cos(mx) - sin(mx);
  float y = sin(mx) + cos(mx);
  float z = cos(my);
  PVector n = new PVector(x,y,z);
  n.setMag(200);

  camera(n.x,n.y,n.z,
        0,0,0,
        0,0,-1);
}

void drawPalatte() {
  beginShape(TRIANGLE_STRIP);
  for(int x=0;x<width;++x) {
    fill(wheel(255f*(float)x/(float)width));
    vertex(x,0);
    vertex(x,20);
  }
  endShape();
}

void drawWater() {
  fill(0,0,255);
  noStroke();
  beginShape(TRIANGLE_STRIP);
  vertex(-mapSizeX/2,-mapSizeY/2,-mapHeight/4 * 0.2);
  vertex( mapSizeX/2,-mapSizeY/2,-mapHeight/4 * 0.2);
  vertex(-mapSizeX/2, mapSizeY/2,-mapHeight/4 * 0.2);
  vertex( mapSizeX/2, mapSizeY/2,-mapHeight/4 * 0.2);
  endShape();
}

void drawTerrain() {
  noStroke();
  for(int y=0;y<mapSizeY-1;++y) {
    beginShape(TRIANGLE_STRIP);
    for(int x=0;x<mapSizeX;++x) {
      PVector p0 = points[mapAddr(x,y)];
      PVector p3 = points[mapAddr(x,y+1)];
      mapPoint(p0);
      mapPoint(p3);
    }
    endShape();
  }
}

void mapPoint(PVector p) {
  fill(wheel(p.z*255f));
  vertex(p.x,  // bigger for show
         p.y,  // bigger for show
         p.z*mapHeight-mapHeight/2);
}

int mapAddr(int x,int y) {
  return y * mapSizeX + x;
}

// Input a value 0 to 255 to get a color value.
// The colours are a transition r - g - b - back to r.
// thanks, adafruit!
color wheel(float WheelPos) {
  /*
  float r,g,b;
  (WheelPos < 85) {
    r=255 - WheelPos * 3;
    g=0;
    b=WheelPos * 3;
  } else if(WheelPos < 170) {
    WheelPos -= 85;
    r=0;
    g=WheelPos * 3;
    b=255 - WheelPos * 3;
  } else {
    WheelPos -= 170;
    r=WheelPos * 3;
    g=255 - WheelPos * 3;
    b=0;
  }

  fill(r,g,b);
  stroke(r,g,b);
  */
  return palette.getColor(WheelPos/255f); 
}
