import processing.video.*;
Capture cam;
ArrayList<Blob> blobs = new ArrayList<Blob>();
color t;
String[] cameras = Capture.list();


void setup() {
  size(640,480);
  cam = new Capture(this, cameras[1]);
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
      if (dist(hue(c),saturation(c),brightness(c),hue(t),saturation(t),brightness(t))<0.05) {
        int previousMatch = -1;
        int toMerge = -1;
        for(int i=0;i<blobs.size();i++){
          Blob b = blobs.get(i);
          if (b.isNear(x,y)) {
            b.add(x,y);
            if (previousMatch != -1) {
              toMerge = i;
            }
            previousMatch = i;
          }
        }
        if (previousMatch == -1) {
          blobs.add(new Blob(x,y));
        } else if (toMerge != -1) {
          blobs.get(toMerge).engulf(blobs.get(previousMatch));
          blobs.remove(previousMatch);
        }
      }
    }
  }
  image(cam,0,0);
  int biggestIndex = -1;
  float biggestArea = 0;
  for(int i=0;i<blobs.size();i++){
    if(biggestArea < blobs.get(i).area()) {
      biggestIndex = i;
      biggestArea = blobs.get(i).area();
    }
  }
  if (biggestIndex != -1) {
    blobs.get(biggestIndex).display();
  }
}
  
