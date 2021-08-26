import processing.video.*;
Capture cam;
ArrayList<PVector> vecs = new ArrayList<PVector>();
color t;

void setup() {
  size(640,480);
  cam = new Capture(this);
  cam.start();
  colorMode(HSB,1);
}

void draw() {
  clear();
  if (cam.available()) { cam.read(); }
  if (mousePressed){
    t = cam.get(mouseX,mouseY);
  }
  
  vecs.clear();
  
  for(int x=0;x<width;x+=1){
    for(int y=0;y<height;y+=1){
      color c = cam.get(x,y);
      if (dist(hue(c),saturation(c),brightness(c),hue(t),saturation(t),brightness(t))<0.1) {
        vecs.add(new PVector(x,y));
      }
    }
  }
  image(cam,0,0);
  
  for(int i=0; i<vecs.size(); i++){
    stroke(1,1,1);
    point(vecs.get(i).x, vecs.get(i).y);
  }
}
