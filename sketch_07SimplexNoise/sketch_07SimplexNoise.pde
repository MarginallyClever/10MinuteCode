SimplexNoise simplex = new SimplexNoise();

double [] grid;
PVector [] forces;
PImage noiseImage;
float maxMag=0;

int state=0;

// store resulting image
PImage img;


void setup() {
  size(800,600);
  setupGrid();
  calculateForces();
}


void setupGrid() {
  grid = new double[width*height];
  noiseImage = createImage(width,height,RGB);
  int i=0;

  double xScale = 4.0/(double)width;
  double yScale = 3.0/(double)height;
  for(int y=0;y<height;++y) {
    for(int x=0;x<width;++x) {
      double c = simplex.noise((double)x*xScale,(double)y*yScale);
      int d = (int)(c*255);
      grid[i] = c;
      noiseImage.pixels[i] = color(d,d,d);
      ++i;
    }
  }
  noiseImage.updatePixels();
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
  drawNoise();
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
