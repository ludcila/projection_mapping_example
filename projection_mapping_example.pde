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
Keystone keystone;
int numFaces = 3;
ArrayList<Face> faces = new ArrayList();
color[] colors = {
  color(171, 47, 82), 
  color(229, 93, 74), 
  color(232, 133, 84)
};

public void setup() {
  size(1920, 1080, P3D);
  background(0);
  background = loadImage("assets/cube.jpg");
  setupProjectionSurfaces(numFaces);
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
  for (int i = 0; i < numFaces; i++) {
    float opacity = keystone.isCalibrating() && drawBackground ? 150 : 255;
    faces.get(i).setVolume(getVolume() / maxVolume);
    faces.get(i).draw(opacity);
  }
  delay(100);
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

public void setupProjectionSurfaces(int numFaces) {
  keystone = new Keystone(this);
  for (int i = 0; i < numFaces; i++) {
    this.faces.add(new Face(keystone, colors[i % 3]));
  }
  keystone.load();
  keystone.toggleCalibration();
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

public float getVolume() {
  return analyzer.analyze();
}



class Face {

  private color faceColor;
  private CornerPinSurface surface;
  private PGraphics surfaceGraphics;
  private float volume = 0.5;
  private float eyesSeparation;
  private float eyesOffset;

  public Face(Keystone keystone, color faceColor) {
    this.faceColor = faceColor;
    this.surface = keystone.createCornerPinSurface(400, 300, 20);
    this.surfaceGraphics = createGraphics(400, 300, P3D);
    this.eyesSeparation = random(120, 200);
    this.eyesOffset = random(-20, 20);
  }

  public void draw() {
    draw(255);
  }

  public void draw(float opacity) {
    this.surfaceGraphics.beginDraw();
    this.surfaceGraphics.background(faceColor, opacity);
    this.surfaceGraphics.noStroke();
    this.surfaceGraphics.fill(0, 0, 0);
    float eyesSize = getEyesSize(); 
    float mouthSize = getMouthSize(); 
    this.surfaceGraphics.ellipse(200 - eyesSeparation/2, 110 + eyesOffset, 15, eyesSize);
    this.surfaceGraphics.ellipse(200 + eyesSeparation/2, 110 + eyesOffset, 15, eyesSize);
    this.surfaceGraphics.ellipse(200, 200, 125 - mouthSize/2.0, mouthSize);
    this.surfaceGraphics.endDraw();
    this.surface.render(this.surfaceGraphics);
  }

  public void setVolume(float volume) {
    this.volume = volume;
  }

  private float getMouthSize() {
    int range = min(round(3 * volume), 3);
    float[] size = {5, 20, 85, 100};
    return size[range];
  }

  private float getEyesSize() {
    return volume > 0.75 ? 2 : 15;
  }
}
