class Camera {
  PVector position = new PVector();
  PVector velocity = new PVector();
  float panDegrees;
  float tiltDegrees;

  Camera() {
    tiltDegrees=90;
  }
  
  void update(float dt) {
    panDegrees = 360f * mouseX/width;
    tiltDegrees = 180 * -mouseY/height -90;
    
    dolly(-velocity.y * dt);
    truck(-velocity.x * dt);
    pedestal(-velocity.z * dt);
    
    PVector towards = PVector.add(position,getForward());
    
    camera(position.x,position.y,position.z,
          towards.x,towards.y,towards.z,
          0,0,-1);
  }
  
  PVector getUnitVector(float pan,float tilt) {
    float radPan = radians(pan);
    float radTilt = radians(tilt);
    
    float x = cos(radTilt) * cos(radPan);
    float y = cos(radTilt) * sin(radPan);
    float z = sin(radTilt);
    
    PVector vec = new PVector(x, y, z);
    vec.normalize();
    
    return vec;
  }
  
  PVector getForward() {
    return getUnitVector(panDegrees,tiltDegrees);
  }
  
  PVector getRight() {
    return getUnitVector(panDegrees+90,0);
  }
  
  PVector getUp() {
    return getForward().cross(getRight());
  }
  
  // forward and back relative to camera's point of view, not world X
  void dolly(float distance) {
    PVector f = getForward();
    f.mult(distance);
    position.add(f);
  }
  
  // strafe left/right, not world Y
  void truck(float distance) {
    PVector f = getRight();
    f.mult(distance);
    position.add(f);
  }
  
  // strafe up/down relative to camera's point of view, not world Z
  void pedestal(float distance) {
    PVector f = getUp();
    f.mult(distance);
    position.add(f);
  }
}
