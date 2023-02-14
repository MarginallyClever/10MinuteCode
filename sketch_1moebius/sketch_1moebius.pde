cessing 4.0b1
// moebius is built around a circle.  the circle has this radius.
float radius = 150;
// the strip has this thickness.
float thickness = 50;

// click a mouse button to change mode and see each step of development.
int mode=0;

void setup() {
  size(500,500,P3D);
}

void mouseReleased() {
  mode = (mode+1)%3;
}

void draw() {
  background(0,0,0);
  // move to center of screen
  translate(width/2,height/2,0);
  // rotate shape based on mouse movements
  rotateX(mouseX*0.05f);
  rotateY(mouseY*0.05f);
  
  switch(mode) {
    default: drawPointsInACircle();  break;
    case 1: drawLinesAroundACircle();  break;
    case 2: drawMoebiusStrip();  break;
  }
}

void drawPointsInACircle() {
  for(float a=0;a<360;a+=10) {
    // c is unit vector from center to point on circle
    float x = cos(radians(a));
    float y = sin(radians(a));
    float z = 0;
    // color and draw
    stroke(abs(x)*255f,abs(y)*255f,a*255f/360f);
    point(x * radius,y * radius,z);
  }
}

void drawLinesAroundACircle() {
  for(float a=0;a<360;a+=10) {
    // c is unit vector from center to point on circle
    float cx = cos(radians(a));
    float cy = sin(radians(a));
    float cz = 0;
    PVector c0 = new PVector(cx,cy,cz);
    PVector c1 = new PVector(0,0,1);
    // a unit vector along the plane of the strip
    PVector d = PVector.add(
      PVector.mult(c0,cos(radians(a/2))),
      PVector.mult(c1,sin(radians(a/2)))
      );
    // scale vectors
    PVector e = PVector.mult(c0,radius);
    PVector f = PVector.mult(d,thickness/2f);
    // put it all together
    PVector p0 = PVector.add(e,f);
    PVector p1 = PVector.sub(e,f);
    // color and draw
    stroke(abs(cx)*255f,abs(cy)*255f,a*255f/360f);
    line(
      p0.x,p0.y,p0.z,
      p1.x,p1.y,p1.z);
  }
}

void drawMoebiusStrip() {
  beginShape(TRIANGLE_STRIP);
  
  for(float a=0;a<=360;a+=10) {
    // c is unit vector from center to point on circle
    float cx = cos(radians(a));
    float cy = sin(radians(a));
    float cz = 0;
    PVector c0 = new PVector(cx,cy,cz);
    PVector c1 = new PVector(0,0,1);
    // a unit vector along the plane of the strip
    PVector d = PVector.add(
      PVector.mult(c0,cos(radians(a/2))),
      PVector.mult(c1,sin(radians(a/2)))
      );
    // scale vectors
    PVector e = PVector.mult(c0,radius);
    PVector f = PVector.mult(d,thickness/2f);
    // put it all together
    PVector p0 = PVector.add(e,f);
    PVector p1 = PVector.sub(e,f);
    // color and draw
    stroke(255,255,255);
    fill(abs(cx)*255f,abs(cy)*255f,a*255f/360f);
    vertex(p0.x,p0.y,p0.z);
    vertex(p1.x,p1.y,p1.z);
  }
  
  endShape();
}
