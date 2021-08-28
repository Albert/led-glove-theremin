import processing.video.*;
Capture cam;
ArrayList<Blob> blobs = new ArrayList<Blob>();
color t;

void setup() {
  size(640,480);
  cam = new Capture(this);
  //cam = new Capture(this, "pipeline:autovideosrc");
  cam.start();
  colorMode(HSB,1);
}

void draw() {
  clear();
  if (cam.available()) { cam.read(); cam.loadPixels(); }
  // TODO test if cam.loadPixels() is necessary

  if (mousePressed){
    t = cam.get(mouseX,mouseY);
  }
  
  blobs.clear();
  for(int x=0;x<width;x+=1){
    for(int y=0;y<height;y+=1){ // TODO consider optimizing to single: for int i<width*height
      color c = cam.pixels[x + y * cam.width];
      if (dist(hue(c),saturation(c),brightness(c),hue(t),saturation(t),brightness(t))<0.1) {
        Blob previousMatch = null;
        for(int i=0;i<blobs.size();i++){
          Blob b = blobs.get(i);
          if (b.isNear(x,y)) {
            b.add(x,y);
            if (previousMatch != null) {
              b.mergeWith(previousMatch);
            }
            previousMatch = b;
          }
        }
        if (previousMatch == null) {
          blobs.add(new Blob(x,y));
        }
      }
    }
  }
  image(cam,0,0);
  for(int i=0;i<blobs.size();i++){
    blobs.get(i).display();
  }
}
