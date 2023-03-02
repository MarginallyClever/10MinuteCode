UVSphere balla = new UVSphere(200);
Icosphere ballb = new Icosphere(200);
int state=0;
  
void setup() {
  size(800,800,P3D);
  lights();
}

void mouseClicked() {
  state=(state+1)%2;
}

void draw() {
  background(0);
  translate(width/2,height/2);
  rotateX(mouseY*-0.01);
  rotateY(mouseX*-0.01);
  
  float t = millis()*0.001;
  
  if(state==0) {
    balla.updateSun(new PVector(sin(t),0,cos(t)));
    balla.draw();
  } else {
    ballb.updateSun(new PVector(sin(t),0,cos(t)));
    ballb.draw();
  }
}
