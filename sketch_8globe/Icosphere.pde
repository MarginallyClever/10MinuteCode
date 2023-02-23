// see http://blog.andreaskahler.com/2009/06/creating-icosphere-mesh-in-code.html
class Icosphere {
  class TriangleIndices {
    int a,b,c;
    
    public TriangleIndices(int a,int b,int c) {
      this.a=a;
      this.b=b;
      this.c=c;
    }
  }
  
  int radius;
  ArrayList<EarthPoint> points = new ArrayList<EarthPoint>();
  ArrayList<TriangleIndices> faces = new ArrayList<TriangleIndices>();
  
  
  public Icosphere(int radius) {
    this.radius = radius;
    createIcosahedronPoints();
    createIcosahedronFaces();
    refine();
    refine();
    refine();
    refine();
  }
  
  
  // split every triangle face into 4 new faces.
  public void refine() {
    ArrayList<TriangleIndices> faces2 = new ArrayList<TriangleIndices>();
    for(TriangleIndices tri : faces) {
        // replace triangle by 4 triangles
        int a = getMiddlePoint(tri.a, tri.b);
        int b = getMiddlePoint(tri.b, tri.c);
        int c = getMiddlePoint(tri.c, tri.a);
  
        faces2.add(new TriangleIndices(tri.a, a, c));
        faces2.add(new TriangleIndices(tri.b, b, a));
        faces2.add(new TriangleIndices(tri.c, c, b));
        faces2.add(new TriangleIndices(a, b, c));
    }
    faces = faces2;
  }
  
  /**
   * Find the midpoint, normalize it, and add it to the point list.
   * @param a index of first point.
   * @param b index of second point.
   * @return the index of the new point.
   */
  private int getMiddlePoint(int a,int b) {
    PVector pa = points.get(a).p;
    PVector pb = points.get(b).p;
    PVector c = PVector.mult(PVector.add(pa,pb),0.5f);
    c.normalize();
    points.add(new EarthPoint(c));
    return points.size()-1;
  }
  
  
  private void createIcosahedronPoints() {
    // create 12 vertices of a icosahedron
    float t = (1.0f + (float)Math.sqrt(5.0)) / 2.0f;
    
    points.add(new EarthPoint(-1,  t,  0));
    points.add(new EarthPoint( 1,  t,  0));
    points.add(new EarthPoint(-1, -t,  0));
    points.add(new EarthPoint( 1, -t,  0));
    
    points.add(new EarthPoint( 0, -1,  t));
    points.add(new EarthPoint( 0,  1,  t));
    points.add(new EarthPoint( 0, -1, -t));
    points.add(new EarthPoint( 0,  1, -t));
    
    points.add(new EarthPoint( t,  0, -1));
    points.add(new EarthPoint( t,  0,  1));
    points.add(new EarthPoint(-t,  0, -1));
    points.add(new EarthPoint(-t,  0,  1));
    
    for(EarthPoint p : points) {
      p.p.normalize();
    }
  }
  
  private void createIcosahedronFaces() {
    // create 20 triangles of the icosahedron    
    // 5 faces around point 0
    faces.add(new TriangleIndices(0, 11, 5));
    faces.add(new TriangleIndices(0, 5, 1));
    faces.add(new TriangleIndices(0, 1, 7));
    faces.add(new TriangleIndices(0, 7, 10));
    faces.add(new TriangleIndices(0, 10, 11));
    
    // 5 adjacent faces
    faces.add(new TriangleIndices(1, 5, 9));
    faces.add(new TriangleIndices(5, 11, 4));
    faces.add(new TriangleIndices(11, 10, 2));
    faces.add(new TriangleIndices(10, 7, 6));
    faces.add(new TriangleIndices(7, 1, 8));
    
    // 5 faces around point 3
    faces.add(new TriangleIndices(3, 9, 4));
    faces.add(new TriangleIndices(3, 4, 2));
    faces.add(new TriangleIndices(3, 2, 6));
    faces.add(new TriangleIndices(3, 6, 8));
    faces.add(new TriangleIndices(3, 8, 9));
    
    // 5 adjacent faces
    faces.add(new TriangleIndices(4, 9, 5));
    faces.add(new TriangleIndices(2, 4, 11));
    faces.add(new TriangleIndices(6, 2, 10));
    faces.add(new TriangleIndices(8, 6, 7));
    faces.add(new TriangleIndices(9, 8, 1));
  }
  
  public void draw() {
    stroke(255);
    fill(64);
    beginShape(TRIANGLES);
    for(TriangleIndices tri : faces ) {
      spherePoint(points.get(tri.a));
      spherePoint(points.get(tri.b));
      spherePoint(points.get(tri.c));
    }
    endShape();
  }
  
  private void spherePoint(EarthPoint earthPoint) {
    PVector p = earthPoint.p;
    normal(p.x,p.y,p.z);
    fill(earthPoint.c);
    vertex(p.x*radius,
           p.y*radius,
           p.z*radius);
  }
  
  public void updateSun(PVector sunDirection) {
    for(EarthPoint p : points) {
      float f = 255f * p.p.dot(sunDirection);
      p.c = color(f,f,f);
    }
  }
}
