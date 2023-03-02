class ClassPainter {
  private Rectangle2D.Float size = new Rectangle2D.Float();
  private boolean onlyCalculateSize;
  private int myTextHeight=11;
  private int myTextWidth=9;
  private int myLineSpacing=2;
  private int cursorX,cursorY;
  
  public ClassPainter() {
    super();
  }
  
  
  public void paint(String name) {
    Class<?> subject = tryToGetClass(name);
    if(subject==null) return;
    
    textFont(createFont("Arial",myTextHeight,true));
    
    size = new Rectangle2D.Float();
    
    onlyCalculateSize = true;
    drawEverything(subject);
    
    onlyCalculateSize = false;
    drawEverything(subject);
    
    drawBorder();
  }
  
  private void drawEverything(Class<?> subject) {
    cursorX = 0;
    cursorY = myTextHeight+myLineSpacing;
    
    drawClassBasics(subject);
    drawInterfaces(subject);
    drawFields(subject);
    drawConstructors(subject);
    drawMethods(subject);
  }
  
  private void drawBorder() {
    stroke(255,255,255);
    noFill();
    rect(size.x,size.y,size.width,size.height);
  }
  
  
  private void drawText(String str) {
    for(int i=0;i<str.length();++i) {
      if(!onlyCalculateSize) {
        text(str.charAt(i),cursorX,cursorY);
      }
      cursorX += myTextWidth;
    }
    cursorY += myTextHeight+myLineSpacing;
    size.add(cursorX,cursorY);
  }
  
  private void drawNL() {
    cursorX=0;
  }
  
  private void drawClassBasics(Class<?> subject) {
    Class<?> sup = subject.getSuperclass();
    String supName = (sup==null)? "" : " extends "+subject.getSuperclass().getName();
    
    fill(255,255,255);
    stroke(0,0,0);
    rect(size.x,size.y,size.width,myTextHeight+2);
    
    fill(255,255,255);
    drawText(getModifiersAsString(subject.getModifiers()) 
      + subject.getName() 
      + supName);
    drawNL();
  }
  
  
  private void drawInterfaces(Class<?> subject) {
    String str = "";
    String add = "implements ";
    for(Class<?> interfaceClass : subject.getInterfaces() ) {
      str+=add+interfaceClass.getName();
      add=", ";
    }
    if(!str.isEmpty()) {
      fill(255,128,0);
      drawText(str);
      drawNL();
    }
  }
  
  
  private void drawFields(Class<?> subject) {
    fill(128,128,255);
    for(Field field : subject.getFields()) {
      drawText(getModifiersAsString(field.getModifiers()) + field.getName());
      //drawText("  value="+field.get(instance));
      drawNL();
    }
  }
  
  
  private void drawMethods(Class<?> subject) {
    for(Method method : subject.getDeclaredMethods()) {
      Class<?> ret = method.getReturnType();
      String retName;
      if(ret==null) {
        retName = "void";
      } else {
        retName = ret.getSimpleName();
      }
      fill(128,255,128);
      drawText(getModifiersAsString(method.getModifiers())+retName + " " + method.getName()+"("+getParametersAsString(method)+")");
      //drawParameters(method);
      drawNL();
    }
  }
  
  
  private void drawConstructors(Class<?> subject) {
    fill(255,128,128);
    for(Constructor method : subject.getDeclaredConstructors()) {
      drawText(getModifiersAsString(method.getModifiers())+method.getName()+"("+getParametersAsString(method)+")");
      //drawParameters(constructor);
      drawNL();
    }
  }
  
  
  private String getModifiersAsString(int modifiers) {
    String str = Modifier.toString(modifiers); 
    if(!str.isEmpty()) str+=" ";
    return str;
  }
  
  
  private String getParametersAsString(java.lang.reflect.Executable subject) {
    StringBuilder sb = new StringBuilder();
    String add = "";
    for(Parameter parameter : subject.getParameters()) {
      String retName = parameter.getType().getSimpleName()+" ";
      String mods = getModifiersAsString(parameter.getModifiers());
      sb.append(add+mods+retName+parameter.getName());
      add=", ";
    }
    return sb.toString();
  }
  
  
  private void drawParameters(java.lang.reflect.Executable subject) {
    //drawText("    parameters="+subject.getParameterCount());
    int i=0;
    for(Parameter parameter : subject.getParameters()) {
      drawText("    parameter "+i+"="+(parameter.getType().getSimpleName())+" "+parameter.getName());
      if(parameter.getModifiers()!=0) {
        drawText("      modifier="+Modifier.toString(parameter.getModifiers()));
      }
      i++;
    }
  }
  
  
  private Class tryToGetClass(String name) {
    Class c=null;
    try {
      c = Class.forName(name);
    }
    catch(ClassNotFoundException e) {
      println("could not find class.");
    }
    return c;
  }
}
