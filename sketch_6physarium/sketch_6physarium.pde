// an implementation of https://github.com/aschinchon/abstractions in Processing

// an agent is a fungus, moving over a terrain.  it is affected by and changing the terrain, creating
// mostly random generative patterns.
class Agent {
  PVector pos = new PVector();
  float h;
  
  Agent() {}
  
  Agent(float x,float y,float h) {
    pos.set(x,y);
    this.h=h;
  }  
}

// fungal agents moving about
Agent [] agents;
// effect left on terrain by fungus
float [] magneticField;

Palette palette = new Palette();

// store resulting image
PImage img;

// how fast the magnetic field decays
float decay = 0.005f;
// how far each agent looks for magnetic field
float sensorOffset = 6;
float frontLeft = radians(22.5);
float frontRight = radians(-22.5);
// how far agents turn per step
float turnPerStep = radians(45);
// how far they walk per step
float stepSize = 1;
// how much they poop per step
float depositionPerStep = 15;
// how many agents, total?
int numAgents = 1000;

// mouse paintbrush tool
boolean drawNow = false;
boolean eraseNow = false;
float drawRadius = 10;

void setup() {
  size(800,600);
  setupPalette();
  createMagneticField();
  createAgents();
}

void setupPalette() {
  palette.addColor(0,color(0,0,0));
  palette.addColor(0.25,color(0,0,255));
  palette.addColor(0.5,color(255,0,255));
  palette.addColor(0.8,color(255,0,0));
  palette.addColor(1,color(255,255,255));
}

void createAgents() {
  agents = new Agent[numAgents];
  //createAgentsInACircle();
  createAgentsRandomlyDistributed();
}

void createAgentsInACircle() {
  float w = width / 20f;
  float h = height / 20f;
  float v = min(w,h);
  for(int i=0;i<numAgents;++i) {
    float r = 2.0 * PI * (float)i / (float)numAgents;
    float x = v * cos(r) + width /2f;
    float y = v * sin(r) + height/2f;
    float r2 = r + random(-PI/2,PI/2);
    agents[i] = new Agent(x,y,r2);
  }
}

void createAgentsRandomlyDistributed() {
  for(int i=0;i<numAgents;++i) {
    float x = random(width);
    float y = random(height);
    float r2 = random(-PI,PI);
    agents[i] = new Agent(x,y,r2);
  }
}


void createMagneticField() {
  img = createImage(width, height, RGB);
  magneticField = new float[width*height];
  
  //createMagneticFieldRing();
  //createMagneticFieldRectangle();
}

void createMagneticFieldRectangle() {
  fillBox((int)(width*0.20),(int)(height*0.40),(int)(width*0.60),(int)(height*0.80),5);
  fillBox((int)(width*0.25),(int)(height*0.45),(int)(width*0.50),(int)(height*0.70),0);
}

int bound(int v,int top, int bottom) {
  v = max(v,bottom);
  v = min(v,top);
  return v;
}

void fillBox(int x0,int y0,int x1,int y1,float v) {
  x0 = bound(x0,width,0);
  x1 = bound(x1,width,0);
  y0 = bound(y0,height,0);
  y1 = bound(y1,height,0);
  
  for(int y=y0;y<y1;++y) {
    for(int x=x0;x<x1;++x) {
      magneticField[y*width+x] = v;
    }
  }
}

void createMagneticFieldRing() {
  // create a ring
  int i=0;
  for(int y=0;y<height;++y) {
    for(int x=0;x<width;++x) {
      float x2 = x-width/2;
      float y2 = y-height/2;
      float d = sqrt(y2*y2 + x2*x2);
      if( d > height/6 && d < height/4 ) {
        magneticField[i] = 5;
      }
      ++i;
    }
  }
}

void draw() {
  walk();
  evaporation();
  
  background(0);
  drawField();
  drawAgents();
  
  if(drawNow) {
    fillBoxRadius(mouseX,mouseY,20,drawRadius);
  }
  if(eraseNow) {
    fillBoxRadius(mouseX,mouseY,drawRadius,0);
  }
}

void mousePressed() {
  if(mouseButton == LEFT) drawNow=true;
  if(mouseButton == RIGHT) eraseNow=true;
}

void mouseReleased() {
  if(mouseButton == LEFT) drawNow=false;
  if(mouseButton == RIGHT) eraseNow=false;
}


void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  drawRadius += e;
  drawRadius = max(drawRadius,0);
  drawRadius = min(drawRadius,100);
}


void fillBoxRadius(float x,float y,float radius,float value) {
  fillBox((int)(x-radius),
          (int)(y-radius),
          (int)(x+radius),
          (int)(y+radius),
          (int)(value));
}


float getAddress(float lim,float v) {
  return (v + lim) % lim;
}

float sense(Agent a,float offset) {
  int x = (int)getAddress(width ,a.pos.x + sensorOffset * cos(a.h + offset));
  int y = (int)getAddress(height,a.pos.y + sensorOffset * sin(a.h + offset));
  return magneticField[y*width+x];
}


void walk() {
  for(Agent a : agents) {
    float front = sense(a,0);
    float left  = sense(a,frontLeft);
    float right = sense(a,frontRight);
    
    if( front>left && front>right ) {
      // no turn
    } else if(front<left && front<right) {
      a.h += ( (random(-1,1)>=0) ? turnPerStep : -turnPerStep );
    } else if(left < right) {
      a.h -= turnPerStep;
    } else if(left > right) {
      a.h += turnPerStep;
    } else {
      // no turn
    }
    
    // move
    a.pos.x = getAddress(width ,a.pos.x + stepSize * cos(a.h));
    a.pos.y = getAddress(height,a.pos.y + stepSize * sin(a.h));

    // deposit sediment
    int x = (int)a.pos.x;
    int y = (int)a.pos.y;
    int i = y*width+x;
    float v = magneticField[i] + depositionPerStep;
    v = min(100,v);
    magneticField[i] = v;
  }
}

void evaporation() {
  int i=0;
  for(int y=0;y<height;++y) {
    for(int x=0;x<width;++x) {
      magneticField[i++] *= 1.0-decay;
    }
  }
}

void drawAgents() {
  stroke(255,255,255);
  strokeWeight(3);
  for(Agent a : agents) {
    point(a.pos.x,a.pos.y);
  }
}

void drawField() {
  float largest = 0;
  int i=0;
  for(int y=0;y<height;++y) {
    for(int x=0;x<width;++x) {
      largest = max( largest, log10(magneticField[i++]) );
    }
  }
  
  i=0;
  img.loadPixels();
  for(int y=0;y<height;++y) {
    for(int x=0;x<width;++x) {
      img.pixels[i] = palette.getColor( log10(magneticField[i]) / largest );
      i++;
    }
  }
  img.updatePixels();
  image(img,0,0);
}


// Calculates the base-10 logarithm of a number
float log10(float x) {
  return (log(x) / log(10));
}
