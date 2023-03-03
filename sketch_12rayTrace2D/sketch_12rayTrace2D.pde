//-----------------------------------------
// Draw shapes with click and drag.
// change shapes with 'q' key.
//-----------------------------------------
import java.awt.geom.Ellipse2D;
import java.awt.geom.Rectangle2D;
import java.awt.geom.RectangularShape;


ArrayList<RectangularShape> shapesOpen = new ArrayList<RectangularShape>();
ArrayList<Class<?>> shapeTypes = new ArrayList<Class<?>>();

RectangularShape myShape;
boolean started;
int shapeType=0; 


void setup() {
  size(800,800);
  shapeTypes.add(Rectangle2D.Float.class);
  shapeTypes.add(Ellipse2D.Float.class);
}


void draw() {
  background(128);
  moveShape();
  drawAllShapes();
}

void drawAllShapes() {
  for(RectangularShape s : shapesOpen) {
    drawOneShape(s);
  }
  
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
    ellipse(r.x,r.y,r.width,r.height);
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
    f.width = (mouseX-f.x)*2;
    f.height = (mouseY-f.y)*2;
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
}
