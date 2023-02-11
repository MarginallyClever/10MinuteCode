import java.util.TreeMap;
import java.util.Iterator;

class Palette {
  TreeMap<Double, PVector> colors = new TreeMap<Double, PVector>();
  
  double bound(double t) {
    if(t<0) t=0;
    if(t>1) t=1;
    return t;
  }
  
  void addColor(double t,color c) {
    t = bound(t);
    colors.put(t,new PVector(red(c),green(c),blue(c)));
  }
  
  color getColor(double t) {
    t = bound(t);
    
    if(colors.isEmpty()) {
      // palatte empty
      return color(0,0,0);
    }
    
    Iterator<Double> i = colors.keySet().iterator();
    double next = i.next();
    
    if(colors.size()==1) {
      // one color
      PVector prevColor = colors.get(next);
      float r = prevColor.x;
      float g = prevColor.y;
      float b = prevColor.z;
      return color(r,g,b);
    }
    
    double prev;
    do {
      prev = next;
      next = i.next();
      if(next>=t) break;
    } while(i.hasNext());
    
    PVector prevColor = colors.get(prev);
    PVector nextColor = colors.get(next);
    // range prev....t...next -> 0..t..1
    float scale = (float)((t-prev)/(next-prev));
    float r = lerp( prevColor.x,nextColor.x, scale );
    float g = lerp( prevColor.y,nextColor.y, scale );
    float b = lerp( prevColor.z,nextColor.z, scale );
    return color(r,g,b);
  }
};
