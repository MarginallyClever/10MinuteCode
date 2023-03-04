sketch 11 draws circles and boxes on screen.

sketch 12 adds to sketch 11 with raytracing in 2D.  It sends 360 rays around the cursor to the nearest object.  two rays + cursor is a triangle.  the fan of triangles is painted to a "live view" texture.  the live view texture is copied into a "history view".  the history view is then drawn in grayscale and the live view drawn on top in color.
this makes a nice fog-of-war system and a colorful interactive line-of-sight system.

press q to toggle between circles and boxes.

press w to wipe the "memory" and redraw the line of sight stuff.

map image from https://www.thearcanelibrary.com/blogs/news/how-to-design-dnd-maps