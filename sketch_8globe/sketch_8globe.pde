Sphere ball = new Sphere(200);
  
void setup() {
  size(800,800,P3D);
  lights();
}

void draw() {
  background(0);
  translate(width/2,height/2);
  rotateX(mouseY*-0.01);
  rotateY(mouseX*-0.01);
  
  float t = millis()*0.001;
  ball.updateSun(new PVector(sin(t),0,cos(t)));
  
  ball.draw();
}
