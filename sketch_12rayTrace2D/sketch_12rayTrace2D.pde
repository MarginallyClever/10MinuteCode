//-----------------------------------------
// Draw shapes with click and drag.
// change shapes with 'q' key.
//-----------------------------------------
import java.awt.geom.Ellipse2D;
import java.awt.geom.Rectangle2D;
import java.awt.geom.RectangularShape;


class RayHit {
  RectangularShape target;
  PVector hitPoint;
  
  public RayHit(RectangularShape target,PVector hitPoint) {
    this.target = target;
    this.hitPoint = hitPoint;
  }
};

class Ray {
  PVector from = new PVector();
  PVector dir = new PVector();
  ArrayList<RayHit> hitList = new ArrayList<RayHit>();
  
  void draw() {
    stroke(0,0,255);
    line(from.x,
         from.y,
         from.x + dir.x*100,
         from.y + dir.y*100);
  }
};


ArrayList<RectangularShape> shapesOpen = new ArrayList<RectangularShape>();
ArrayList<Class<?>> shapeTypes = new ArrayList<Class<?>>();

RectangularShape myShape;
boolean started;
int shapeType=0;
PVector startPoint = new PVector();

Ray ray = new Ray();
PImage background;
PGraphics filterLive;
PGraphics filterHistorical;
PGraphics filterHistorical2;


void setup() {
  size(800,800);
  shapeTypes.add(Rectangle2D.Float.class);
  shapeTypes.add(Ellipse2D.Float.class);
  
  background = loadImage("map.png");
  filterHistorical = createGraphics(width,height);
  filterHistorical2 = createGraphics(width,height);
  filterLive = createGraphics(width,height);
  
  filterHistorical.beginDraw();
  filterHistorical.background(0);
  filterHistorical.endDraw();

  filterHistorical2.beginDraw();
  filterHistorical2.background(0);
  filterHistorical2.endDraw();
  
  shapesOpen.add(new Rectangle2D.Float(     -10,      -10,       0,height+10));
  shapesOpen.add(new Rectangle2D.Float(width   ,      -10,width+10,height+10));
  shapesOpen.add(new Rectangle2D.Float(     -10,      -10,width+10,        0));
  shapesOpen.add(new Rectangle2D.Float(     -10,height   ,width+10,height+10));
}


void draw() {
  background(0);
  //image(background,0,0);
  moveShape();
  drawAndTraceAllShapes();
}

void drawAndTraceAllShapes() {
  rayTrace();
  updateLiveFilter();
  addLiveFilterToHistory();
  drawMapRememberedInGray();
  drawMapInSight();
  drawStartedShape();
}

void addLiveFilterToHistory() {
  filterHistorical.beginDraw();
  filterHistorical.blend(filterLive,
        0,0,width,height,
        0,0,width,height,
        LIGHTEST);
  filterHistorical.endDraw();
}

void drawMapInSight() {
  filterHistorical2.beginDraw();
  filterHistorical2.copy(background,0,0,width,height,0,0,width,height);
  filterHistorical2.mask(filterLive);
  filterHistorical2.endDraw();
  image(filterHistorical2,0,0);
}


void drawMapRememberedInGray() {
  filterHistorical2.beginDraw();
  filterHistorical2.copy(background,0,0,width,height,0,0,width,height);
  filterHistorical2.filter(GRAY);
  filterHistorical2.mask(filterHistorical);
  filterHistorical2.endDraw();
  image(filterHistorical2,0,0);
}


void rayTrace() {
  if(pointInsideAnyShape(mouseX,mouseY)) return;
  
  ray.hitList.clear();
  
  for(int i=0;i<360;++i) {
    float r = radians(i);
    ray.dir.set(cos(r),sin(r));
    ray.from.set(mouseX,mouseY);
    intersect(ray);
  }
}


void updateLiveFilter() {
  filterLive.beginDraw();
  filterLive.background(0);
  
  if(!ray.hitList.isEmpty()) {
    filterLive.fill(255);
    filterLive.noStroke();
    RayHit prev = null;
    for(RayHit curr : ray.hitList) {
      if(prev!=null) {
        filterLive.triangle(ray.from.x,ray.from.y,
                            prev.hitPoint.x,prev.hitPoint.y,
                            curr.hitPoint.x,curr.hitPoint.y);
      }
      prev = curr;
    }
    RayHit curr = ray.hitList.get(0);
    filterLive.triangle(ray.from.x,ray.from.y,
                      prev.hitPoint.x,prev.hitPoint.y,
                      curr.hitPoint.x,curr.hitPoint.y);
  
    filterLive.endDraw();
  } //<>//
}


boolean pointInsideAnyShape(float x,float y) {
  for(RectangularShape s : shapesOpen) {
    if(s.contains(x,y)) return true;
  }
  return false;
}


// collect all shapes that intersect the ray
void intersect(Ray ray) {
  float minD = Float.MAX_VALUE;
  RectangularShape bestFind = null;
  
  for(RectangularShape s : shapesOpen) {
    float d=0;
    if(s instanceof Rectangle2D.Float) {
      d = rayRectangleIntersection(ray,(Rectangle2D.Float)s);
    } else if(s instanceof Ellipse2D.Float) {
      d = rayCircleIntersection(ray,(Ellipse2D.Float)s);
    }
    if(d<=0) continue;
    
    if(minD>d) {
      minD=d;
      bestFind=s;
    }  
  }
  
  if(minD==Float.MAX_VALUE) return;
  
  PVector hitPoint = new PVector(
       ray.from.x+ray.dir.x*minD,
       ray.from.y+ray.dir.y*minD);
  ray.hitList.add(new RayHit(bestFind,hitPoint));
}


float rayRectangleIntersection(Ray ray,Rectangle2D.Float rectangle) {
  // r.dir is unit direction vector of ray
  PVector dirfrac = new PVector( 1.0f / ray.dir.x, 1.0f / ray.dir.y);
  // lb is the corner of AABB with minimal coordinates - left bottom, rt is maximal corner
  // r.org is origin of ray
  float t1 = ((float)rectangle.getMinX() - ray.from.x)*dirfrac.x;
  float t2 = ((float)rectangle.getMaxX() - ray.from.x)*dirfrac.x;
  float t3 = ((float)rectangle.getMinY() - ray.from.y)*dirfrac.y;
  float t4 = ((float)rectangle.getMaxY() - ray.from.y)*dirfrac.y;
  
  float tmin = max(min(t1, t2), min(t3, t4));
  float tmax = min(max(t1, t2), max(t3, t4));
  
  // if tmax < 0, ray (line) is intersecting AABB, but the whole AABB is behind us
  if (tmax < 0) {
    return -1;
  }
  
  // if tmin > tmax, ray doesn't intersect AABB
  if (tmin > tmax) {
      return -1;
  }
  
  return tmin;
}


float rayCircleIntersection(Ray ray,Ellipse2D.Float ellipse) {
  PVector center = new PVector( (float)ellipse.getCenterX(), (float)ellipse.getCenterY() );
  float radius = (float)ellipse.getWidth()/2;
  
  PVector centerDiff = PVector.sub(ray.from,center);
  float a = ray.dir.magSq();
  float halfB = centerDiff.dot(ray.dir);
  float c = centerDiff.dot(centerDiff) - radius*radius;
  float discriminant = halfB*halfB - a*c;
  if(discriminant<0) return -1;
  
  float sqrtD = sqrt(discriminant);
  
  return (-halfB - sqrtD) / a;
}


void drawAllShapes() {
  fill(255,192,192);
  stroke(255,0,0);
  for(RectangularShape s : shapesOpen) {
    drawOneShape(s);
  }
}

void drawStartedShape() {
  if(started) {
    drawOneShape(myShape);
  }
}


void drawOneShape(RectangularShape s) {
  if(s instanceof Rectangle2D.Float) {
    Rectangle2D.Float r = (Rectangle2D.Float)s;
    rect(r.x,r.y,r.width,r.height);
  } else if(s instanceof Ellipse2D.Float) {
    Ellipse2D.Float r = (Ellipse2D.Float)s;
    ellipse((float)r.getCenterX(),
            (float)r.getCenterY(),
            r.width,
            r.height);
  } else {
    println("unknown");
  }
}


void mousePressed() {
  if(!started) {
    println("start");
    try {
      myShape = (RectangularShape)(shapeTypes.get(shapeType).getConstructor().newInstance());
    }
    catch(Exception e) {
      e.printStackTrace();
      return;
    }
    
    started=true;
    startPoint.set(mouseX,mouseY);
    println("start = "+startPoint);
    
    if(myShape instanceof Rectangle2D.Float) {
      Rectangle2D.Float f = (Rectangle2D.Float)myShape;
      f.x=mouseX;
      f.y=mouseY;
    } else if(myShape instanceof Ellipse2D.Float) {
      Ellipse2D.Float f = (Ellipse2D.Float)myShape;
      f.x=mouseX;
      f.y=mouseY;
    }
  }
}


void moveShape() {
  if(!started) return;
  
  println("edit");
  if(myShape instanceof Rectangle2D.Float) {
    Rectangle2D.Float f = (Rectangle2D.Float)myShape;
    f.width = mouseX-f.x;
    f.height = mouseY-f.y;
  } else if(myShape instanceof Ellipse2D.Float) {
    Ellipse2D.Float f = (Ellipse2D.Float)myShape;
    PVector mousePoint = new PVector(mouseX,mouseY);
    float r = (PVector.sub(startPoint,mousePoint)).mag();
    
    f.x = startPoint.x - r;
    f.y = startPoint.y - r;
    f.width = r*2;
    f.height = r*2;
    println(r+"->"+f.getCenterX()+","+f.getCenterY());
  }
}


void mouseReleased() {
  println("done");
  shapesOpen.add(myShape);
  started=false;
}


void keyReleased() {
  if(keyCode=='q'||keyCode=='Q') {
    println("next");
    shapeType = (shapeType+1) % shapeTypes.size();
  }
  if(keyCode=='w'||keyCode=='W') {
    println("wipe");
    filterHistorical.beginDraw();
    filterHistorical.background(0);
    filterHistorical.endDraw();
  }
}
