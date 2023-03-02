SimplexNoise simplex = new SimplexNoise();

double [] grid;
PVector [] forces;
PImage noiseImage;
float maxMag=0;

float xOff=0;
float yOff=0;
long redoTime=1000;
float xVel=0.00;
float yVel=0.00;

int state=0;

// store resulting image
PImage img;

Palette palette = new Palette();


void setup() {
  size(800,600);
  setupPalette();
  setupGrid();
  createMagneticField();
  createAgents();
}

void setupPalette() {
  palette.addColor(0,color(0,0,0));
  palette.addColor(0.45,color(0,0,255));
  palette.addColor(0.5,color(0,255,255));
  palette.addColor(0.8,color(0,255,0));
  palette.addColor(1,color(255,255,255));
}


void createMagneticField() {
  img = createImage(width, height, RGB);
  magneticField = new float[width*height];
}

void setupGrid() {
  grid = new double[width*height];
  noiseImage = createImage(width,height,RGB);
  updateGrid();
}

void updateGrid() {
  int i=0;

  double xScale = 2.0/(double)width;
  double yScale = 1.5/(double)height;
  
  for(int y=0;y<height;++y) {
    for(int x=0;x<width;++x) {
      double c = simplex.noise(
        xOff+(double)x*xScale,
        yOff+(double)y*yScale);
      int d = (int)(c*255);
      grid[i] = c;
      noiseImage.pixels[i] = color(d,d,d);
      ++i;
    }
  }
  noiseImage.updatePixels();
  
  calculateForces();
}


void calculateForces() {
  forces = new PVector[width*height];
  for(int y=0;y<height;++y) {
    for(int x=0;x<width;++x) {
      calculateForceAt(x,y);
    }
  }
}

void calculateForceAt(int x,int y) {
  float xMag,yMag;
  float center = getGrid(x,y);
  
  if(x<width-1) {
    xMag = getGrid(x+1,y) - center;
  } else {
    xMag = center - getGrid(x-1,y);
  }
  
  if(y<height-1) {
    yMag = getGrid(x,y+1) - center;
  } else {
    yMag = center - getGrid(x,y-1);
  }
  
  PVector v = new PVector(xMag,yMag,0f);
  float z = v.mag();
  v.normalize();
  v.z = z;
  maxMag = max(maxMag,z);
  
  forces[y*width+x] = v;
}


float getGrid(int x,int y) {
  x = min(x,width-1);
  x = max(x,0);
  y = min(y,height-1);
  y = max(y,0);
  
  return (float)grid[y*width+x];
}

void mouseClicked() {
  state = (state+1)%3;
}


void draw() {
  background(0);
  walk();
  evaporation();
  
  moveGrid();
  
  drawNoise();
  if(state==1) drawForces();
  if(state==2) {
    drawAgents();
    drawField();
  }
}


void moveGrid() {
  if(xVel!=0 && yVel!=0 && millis()>redoTime) {
    redoTime = millis() + 1000;
    xOff+=xVel;
    yOff+=yVel;
    updateGrid();
  }
}

void drawNoise() {
  drawNoiseFast();
  //drawNoiseSlow();
}

void drawNoiseFast() {
  image(noiseImage,0,0);
}

void drawNoiseSlow() {
  int i=0;
  for(int y=0;y<height;++y) {
    for(int x=0;x<width;++x) {
      float c = (float)grid[i++];
      int d = (int)(c*255);
      stroke(d,d,d);
      point(x,y);
    }
  }
}

void drawForces() {
  int stepSize = 10;
  float mag = 10;
  
  beginShape(LINES);
  stroke(255,255,255);
  for(int y=0;y<height;y+=stepSize) {
    for(int x=0;x<width;x+=stepSize) {
      PVector v = forces[y*width+x];
      float mag2 = mag * v.z/maxMag;
      vertex(x,y);
      vertex(x + v.x*mag2, y + v.y*mag2);
    }
  }
  endShape();
}
