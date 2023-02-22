


/**
 * draw a sphere with a given radius.
 * TODO expose quality parameters?
 * TODO generate a sphere once as a shape, return that.
 * See https://www.gamedev.net/forums/topic/537269-procedural-sphere-creation/4469427/
 * @param gl2
 * @param radius
 */
class Sphere {
  int width = 64;
  int height = 32;
  float radius;
  
  EarthPoint [] vertices;
  int [] indexes;
  
  public Sphere(int radius) {
    this.radius = radius;
    
    int i, j, t;
    int nvec = (height-2)* width + 2;
    int ntri = (height-2)*(width-1)*2;
  
    vertices = new EarthPoint[nvec];
    indexes = new int[ntri*3];
  
    for( t=0, j=1; j<height-1; j++ ) {
      for(i=0; i<width; i++ )  {
        float theta = (float)(j)/(float)(height-1) * (float)Math.PI;
        float phi   = (float)(i)/(float)(width-1 ) * (float)Math.PI*2;
  
        EarthPoint p = new EarthPoint(
          (float)( Math.sin(theta) * Math.cos(phi) ),
          (float)( Math.cos(theta)                 ),
          (float)(-Math.sin(theta) * Math.sin(phi) )
        );
        vertices[t++] = p;
      }
    }
    vertices[t++] = new EarthPoint(0,1,0);
    vertices[t++] = new EarthPoint(0,-1,0);
    
    for( t=0, j=0; j<height-3; j++ ) {
      for(      i=0; i<width-1; i++ )  {
        indexes[t++] = (j  )*width + i  ;
        indexes[t++] = (j+1)*width + i+1;
        indexes[t++] = (j  )*width + i+1;
        indexes[t++] = (j  )*width + i  ;
        indexes[t++] = (j+1)*width + i  ;
        indexes[t++] = (j+1)*width + i+1;
      }
    }
    for( i=0; i<width-1; i++ )  {
      indexes[t++] = (height-2)*width;
      indexes[t++] = i;
      indexes[t++] = i+1;
      indexes[t++] = (height-2)*width+1;
      indexes[t++] = (height-3)*width + i+1;
      indexes[t++] = (height-3)*width + i;
    }
  }
  
  public void draw() {
    if(indexes==null) return;
    if(vertices==null) return;
    
    beginShape(TRIANGLES);
    for(int i=0;i<indexes.length;++i) {
      spherePoint(vertices[indexes[i]]);
    }
    endShape();
  }
  
  private void spherePoint(EarthPoint earthPoint) {
    PVector p = earthPoint.p;
    normal(p.x,p.y,p.z);
    stroke(1,1,1);
    fill(earthPoint.c);
    vertex(p.x*radius,
           p.y*radius,
           p.z*radius);
  }
  
  public void updateSun(PVector sunDirection) {
    for(EarthPoint p : vertices) {
      float f = 255f * p.p.dot(sunDirection);
      p.c = color(f,f,f);
    }
  }
}
