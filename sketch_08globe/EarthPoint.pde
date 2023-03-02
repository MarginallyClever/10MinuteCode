
class EarthPoint {
  PVector p;
  color c;
  
  public EarthPoint(float x,float y,float z) {
    this.p = new PVector(x,y,z);
  }
  
  public EarthPoint(PVector p) {
    this.p = p;
  }
}
