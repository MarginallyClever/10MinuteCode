// an agent is an ant moving over a terrain.  
// it is affected by and changing the terrain, creating
// mostly random generative patterns.
class Agent {
  PVector pos = new PVector();
  float h;
  long dieAt;
  
  Agent() {
    dieAt = millis() + (long)random(2500,5500);
  }
  
  Agent(float x,float y,float h) {
    this();
    pos.set(x,y);
    this.h=h;
  }  
}


// fungal agents moving about
Agent [] agents;
// effect left on terrain by fungus
float [] magneticField;

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
    agents[i] = createRandomAgent();
  }
}

Agent createRandomAgent() {
  float x = random(width);
  float y = random(height);
  float r2 = random(-PI,PI);
  return new Agent(x,y,r2);
}


float getAddress(float lim,float v) {
  return (v + lim) % lim;
}

float sense(Agent a,float offset) {
  int x = (int)getAddress(width ,a.pos.x + sensorOffset * cos(a.h + offset));
  int y = (int)getAddress(height,a.pos.y + sensorOffset * sin(a.h + offset));
  return (float)grid[y*width+x];
}


void walk() {
  long time = millis();
  
  for(int i=0;i<agents.length;++i) {
    Agent a = agents[i];
    if(a.dieAt <= time) {
      println("wow");
      a = createRandomAgent();
      agents[i] = a;
    }
    
    float front = -sense(a,0);
    float left  = -sense(a,frontLeft);
    float right = -sense(a,frontRight);
    
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
    int j = y*width+x;
    float v = magneticField[j] + depositionPerStep;
    v = min(100,v);
    magneticField[j] = v;
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
