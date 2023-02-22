import java.util.TreeMap;
import java.util.Iterator;

/**
 * Palette will blend between colors in one dimension.  
 * Use <code>addColor(t,color)</code> to add keyframes.  
 * Use <code>getColor(t)</code> to get the blended color.
 */
class Palette {
  private TreeMap<Double, PVector> colors = new TreeMap<Double, PVector>();
    
  private double bound(double t) {
    if(t<0) t=0;
    if(t>1) t=1;
    return t;
  }
  
  /**
   * add a color to the palette at time t
   * @param t 0...1
   * @param c a color
   */
  public void addColor(double t,color c) {
    t = bound(t);
    colors.put(t,new PVector(red(c),green(c),blue(c)));
  }
  
  public color getColor(double t) {
    if(colors.isEmpty()) {
      return color(0,0,0);
    }

    // get first color
    Iterator<Double> i = colors.keySet().iterator();
    double next = i.next();
    
    if(colors.size()==1) {
      return getColorFromPVector(colors.get(next));
    }
    
    // find the two colors on either side of t
    t = bound(t);
    double prev;
    do {
      prev = next;
      next = i.next();
      if(next>=t) break;
    } while(i.hasNext());
    
    PVector prevColor = colors.get(prev);
    PVector nextColor = colors.get(next);
    
    // range prev....t...next -> 0..t..1 for lerp
    float scale = (float)((t-prev)/(next-prev));
    PVector newColor = PVector.lerp(prevColor,nextColor,scale);
    return getColorFromPVector(newColor);
  }
  
  private color getColorFromPVector(PVector newColor) {
    float r = newColor.x;
    float g = newColor.y;
    float b = newColor.z;
    return color(r,g,b);
  }
};
