import processing.sound.*;
import deadpixel.keystone.*;

PImage background;
boolean showInstructions = true;
boolean drawBackground = false;

// Audio
AudioIn input;
Amplitude analyzer;
float maxVolume = 0.5;
boolean isCalibratingAudio = false;

// Projection mapping
int numSurfaces = 3;
Keystone keystone;
ArrayList<CornerPinSurface> surfaces = new ArrayList();
ArrayList<PGraphics> surfaceGraphics = new ArrayList();
color[] colors = {
  color(171, 47, 82), 
  color(229, 93, 74), 
  color(232, 133, 84)
};


public void setup() {
  size(1920, 1080, P3D);
  background(0);
  background = loadImage("assets/cube.jpg");
  setupProjectionSurfaces(numSurfaces);
  setupAudio();
}


public void draw() {
  if (drawBackground) {
    image(background, 0, 0, width, height);
  } else {
    clear();
  }
  if (showInstructions) {
    printInstructions();
  }
  if (isCalibratingAudio) {
    calibrateAudio();
  }
  for (int i = 0; i < numSurfaces; i++) {
    float opacity = keystone.isCalibrating() && drawBackground ? 150 : 255;
    drawFace(surfaceGraphics.get(i), colors[i % 3], opacity);
    surfaces.get(i).render(surfaceGraphics.get(i));
  }
  delay(100);
}


public void drawFace(PGraphics offscreen, color faceColor, float opacity) {
  offscreen.beginDraw();
  offscreen.background(faceColor, opacity);
  offscreen.noStroke();
  offscreen.fill(0, 0, 0);
  float eyesSize = getEyesSize();
  float mouthSize = getMouthSize();
  offscreen.ellipse(150, 100, 15, eyesSize);
  offscreen.ellipse(250, 100, 15, eyesSize);
  offscreen.ellipse(200, 200, 125 - mouthSize/2.0, mouthSize);
  offscreen.endDraw();
}


public void keyPressed() {
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    keystone.toggleCalibration();
    break;
  case 'l':
    // loads the saved layout
    keystone.load();
    break;
  case 's':
    // saves the layout
    keystone.save();
    break;
  case 'a':
    // calibrate audio (keep pressed)
    maxVolume = 0.01;
    isCalibratingAudio = true;
    break;
  case 'b':
    // toggle background
    drawBackground = !drawBackground;
    break;
  case 'i':
    // toggle background
    showInstructions = !showInstructions;
    break;
  }
}


public void keyReleased() {
  switch(key) {
  case 'a':
    // stop audio calibration
    isCalibratingAudio = false;
    break;
  }
}


public void setupAudio() {
  input = new AudioIn(this, 0);
  input.start();
  analyzer = new Amplitude(this);
  analyzer.input(input);
}


public void setupProjectionSurfaces(int numSurfaces) {
  keystone = new Keystone(this);
  for (int i = 0; i < numSurfaces; i++) {
    surfaces.add(keystone.createCornerPinSurface(400, 300, 20));
    surfaceGraphics.add(createGraphics(400, 300, P3D));
  }
  keystone.load();
  keystone.toggleCalibration();
}


public float getMouthSize() {
  int range = min(round(3 * getVolume() / maxVolume), 3);
  float[] size = {5, 20, 85, 100};
  return size[range];
}


public float getEyesSize() {
  return getVolume() > 0.75 * maxVolume ? 2 : 15;
}


public float getVolume() {
  return analyzer.analyze();
}


public void calibrateAudio() {
  float volume = getVolume();
  maxVolume = max(volume * 1.2, maxVolume);
  textSize(28);
  fill(255, 255, 255);
  text(String.format("Volume: %f\nAdjusted max volume: %f", volume, maxVolume), 50, height - 100);
}


public void printInstructions() {
  textSize(28);
  fill(255, 255, 255);
  text(
    "Press 'i' to toggle instructions\n" +
    "Press 'b' to toggle sample background\n" + 
    "Press 'c' to toggle surface calibration\n" + 
    "Keep 'a' pressed to calibrate audio", 
    50, 100
    );
}
