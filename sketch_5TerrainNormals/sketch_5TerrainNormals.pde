// how big is the terrain
int mapSizeX = 256;  // # of dots
int mapSizeY = 256;  // # of dots
int mapHeight = 300;  // scale
float mapScale = 5;

// perlin noise values
// larger scale makes the terrain more bumpy
float noiseScaleX = 0.01;
float noiseScaleY = 0.01;

// where to store the terrain data
PVector [] points;
PVector [] normals;

Palette palette = new Palette();
Camera camera = new Camera();
float cameraSpeed = 15;

void setup() {
  size(800,800,P3D);
  
  setupMapPalette();
  createMap();
  generateMap();
}

/**
 * Use keys to fly around world
 */
void keyPressed() {
  switch(key) {
    case 'w': case 'W': camera.velocity.y -= cameraSpeed;  break;
    case 's': case 'S': camera.velocity.y += cameraSpeed;  break;
    case 'a': case 'A': camera.velocity.x -= cameraSpeed;  break;
    case 'd': case 'D': camera.velocity.x += cameraSpeed;  break;
    case 'q': case 'Q': camera.velocity.z += cameraSpeed;  break;
    case 'e': case 'E': camera.velocity.z -= cameraSpeed;  break;
  }
}

/**
 * Use keys to fly around world
 */
void keyReleased() {
  switch(key) {
    case 'w': case 'W': camera.velocity.y += cameraSpeed;  break;
    case 's': case 'S': camera.velocity.y -= cameraSpeed;  break;
    case 'a': case 'A': camera.velocity.x += cameraSpeed;  break;
    case 'd': case 'D': camera.velocity.x -= cameraSpeed;  break;
    case 'q': case 'Q': camera.velocity.z -= cameraSpeed;  break;
    case 'e': case 'E': camera.velocity.z += cameraSpeed;  break;
  }
}


void createMap() {
  points = new PVector[mapSizeX*mapSizeY];
  normals = new PVector[mapSizeX*mapSizeY];
  int i=0;
  
  for(int y=0;y<mapSizeY;++y) {
    for(int x=0;x<mapSizeX;++x) {
      points[i] = new PVector();
      normals[i] = new PVector();
      i++;
    }
  }
}


void generateMap() {
  generateMapHeightfield();
  generateMapNormals();
}


void generateMapHeightfield() {
  int i=0;
  for(int y=0;y<mapSizeY;++y) {
    for(int x=0;x<mapSizeX;++x) {
      float z = noise(x*noiseScaleX,
                      y*noiseScaleY);
      points[i++].set((x-mapSizeX/2f)*mapScale,
                      (y-mapSizeY/2f)*mapScale,
                      z);
    }
  }
}

void generateMapNormals() {
  PVector a = new PVector();
  PVector b = new PVector();
  PVector c = new PVector();
  PVector d = new PVector();
  PVector e = new PVector();
  
  int i=mapSizeX;
  
  for(int y=1;y<mapSizeY-1;++y) {
    for(int x=0;x<mapSizeX-1;++x) {
      PVector p0 = points[mapAddr(x  ,y  )];
      PVector p1 = points[mapAddr(x  ,y+1)];
      PVector p2 = points[mapAddr(x+1,y  )];
      PVector p3 = points[mapAddr(x  ,y-1)];
      a.set(PVector.sub(p1,p0).normalize());
      b.set(PVector.sub(p2,p0).normalize());
      c.set(PVector.sub(p3,p0).normalize());
      
      d.cross(a,b);
      e.cross(a,c);
      
      normals[i]=PVector.add(d,e).normalize();
      i++;
    }
    normals[i] = normals[i-1];
    i++;
  }
  for(int x=0;x<mapSizeX-1;++x) {
    normals[x] = normals[x+mapSizeX];
    normals[i] = normals[i-mapSizeX];
    i++;
  }
}

void draw() {
  float dt = 0.030;  // assumed 30 fps
  
  background(0);
  camera();
  drawPalatte();
  lights();
  
  camera.update(dt);

  generateMap();
  
  drawTerrain();
  drawWater();
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
  vertex(mapScale * -mapSizeX/2,mapScale * -mapSizeY/2,-mapHeight/4 * 0.2);
  vertex(mapScale *  mapSizeX/2,mapScale * -mapSizeY/2,-mapHeight/4 * 0.2);
  vertex(mapScale * -mapSizeX/2,mapScale *  mapSizeY/2,-mapHeight/4 * 0.2);
  vertex(mapScale *  mapSizeX/2,mapScale *  mapSizeY/2,-mapHeight/4 * 0.2);
  endShape();
}

void drawTerrain() {
  noStroke();
  for(int y=0;y<mapSizeY-1;++y) {
    beginShape(TRIANGLE_STRIP);
    for(int x=0;x<mapSizeX;++x) {
      mapPoint(mapAddr(x,y));
      mapPoint(mapAddr(x,y+1));
    }
    endShape();
  }
}

void mapPoint(int mapAddress) {
  PVector p = points[mapAddress];
  PVector n = normals[mapAddress];
  
  fill(wheel(p.z*255f));
  normal(n.x,n.y,n.z);
  vertex(p.x,  // bigger for show
         p.y,  // bigger for show
         p.z*mapHeight-mapHeight/2);
}

int mapAddr(int x,int y) {
  return y * mapSizeX + x;
}

color wheel(float WheelPos) {
  return palette.getColor(WheelPos/255f); 
}

void setupMapPalette() {
  palette.addColor(0.00,color( 64, 64,255));
  palette.addColor(0.30,color( 64, 64,255));
  palette.addColor(0.40,color(255,255,  0));
  palette.addColor(0.65,color(  0,255,  0));
  palette.addColor(0.80,color(255,192,  0));
  palette.addColor(0.90,color(255,255,255));
  palette.addColor(1.00,color(255,255,255));
}
