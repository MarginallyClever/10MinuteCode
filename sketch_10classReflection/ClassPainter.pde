class ClassPainter {
  private Rectangle2D.Float size = new Rectangle2D.Float();
  private boolean onlyCalculateSize;
  private int myTextHeight=12;
  private int myTextWidth=8;
  private int myTextLeading = myTextHeight+2;
  private int cursorX,cursorY;
  
  public ClassPainter() {
    super();
  }
  
  
  public void paint(String name) {
    Class<?> subject = tryToGetClass(name);
    if(subject==null) return;
    
    textFont(createFont("Courier",myTextHeight,true));
    
    size = new Rectangle2D.Float();
    
    onlyCalculateSize = true;
    drawEverything(subject);
    
    drawBorder();
    
    onlyCalculateSize = false;
    drawEverything(subject);
  }
  
  private void drawEverything(Class<?> subject) {
    cursorX = 0;
    cursorY = 0;
    drawNL();
    
    drawClassBasics(subject);
    drawInterfaces(subject);
    drawFields(subject);
    drawConstructors(subject);
    drawMethods(subject);
    size.height+=myTextLeading/2;
  }
  
  private void drawBorder() {
    fill(64,64,64);
    rect(size.x,size.y,size.width,size.height,5,5,5,5);
    
    fill(255,255,255);
    rect(size.x,size.y,size.width,myTextLeading+2,5,5,0,0);
    
    stroke(255,255,255);
    noFill();
    rect(size.x,size.y,size.width,size.height,5,5,5,5);
  }
  
  
  private void drawText(String str) {
    for(int i=0;i<str.length();++i) {
      if(!onlyCalculateSize) {
        text(str.charAt(i),cursorX,cursorY);
      }
      cursorX += myTextWidth;
    }
    size.add(cursorX,cursorY);
  }
  
  private void drawNL() {
    cursorY += myTextLeading;
    cursorX = myTextWidth/2;
  }
  
  private void drawClassBasics(Class<?> subject) {
    Class<?> sup = subject.getSuperclass();
    String supName = (sup==null)? "" : " extends "+subject.getSuperclass().getSimpleName();
    cursorY-=2;
    
    fill(0,128,0);
    drawText(getModifiersAsString(subject.getModifiers()));
    fill(0,0,0);
    drawText(subject.getSimpleName());
    fill(255,0,0);
    drawText(supName);
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
      fill(255,0,128);
      drawText(str);
      drawNL();
    }
  }
  
  
  private void drawFields(Class<?> subject) {
    fill(128,128,255);
    for(Field field : subject.getFields()) {
      fill(0,128,0);
      drawText(getModifiersAsString(field.getModifiers()));
      fill(0,0,0);
      drawText(field.getName());
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
      drawText(getModifiersAsString(method.getModifiers()));
      fill(0,0,128);
      drawText(retName + " ");
      fill(255,255,0);
      drawText(method.getName());
      fill(0,0,0);
      drawText("(");
      drawParameters(method);
      fill(0,0,0);
      drawText(")");
      drawNL();
    }
  }
  
  
  private void drawConstructors(Class<?> subject) {
    fill(255,128,128);
    for(Constructor method : subject.getDeclaredConstructors()) {
      fill(128,255,128);
      drawText(getModifiersAsString(method.getModifiers()));
      fill(255,128,0);
      drawText(method.getName());
      fill(0,0,0);
      drawText("(");
      drawParameters(method);
      fill(0,0,0);
      drawText(")");
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
    String add = "";
    for(Parameter parameter : subject.getParameters()) {
      String retName = parameter.getType().getSimpleName()+" ";
      String mods = getModifiersAsString(parameter.getModifiers());
    
      fill(0,0,0);
      drawText(add);
      add=", ";
      fill(128,255,128);
      drawText(mods);
      fill(0,0,128);
      drawText(retName);
      fill(0,255,255);
      drawText(parameter.getName());
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
