import java.awt.geom.Rectangle2D;
import java.lang.reflect.*;

ClassPainter classPainter = new ClassPainter();
  
void setup() {
  size(800,800);
}

void draw() {
  background(0);
  translate(30,20);
  classPainter.paint("java.awt.geom.Rectangle2D");
  noLoop();
}
