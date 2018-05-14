import processing.sound.*;
import deadpixel.keystone.*;

PImage background;
boolean drawBackground = true;

// Audio
FFT fft;
AudioIn input;
Amplitude analyzer;
int bands = 16;
float[] spectrum = new float[bands];

// Projection mapping
Keystone keystone;
CornerPinSurface surface;
PGraphics offscreen;
CornerPinSurface surface2;
PGraphics offscreen2;
CornerPinSurface surface3;
PGraphics offscreen3;

float maxVolume = 0.5;
boolean isCalibratingAudio = false;

public void setup() {
  //size(800, 600, P3D);
  fullScreen(P3D);
  background(0);
  background = loadImage("assets/cube.jpg");
  setupKeystone();
  setupAudio();
}

public void draw() {

  if (drawBackground) {
    image(background, 0, 0, width, height);
  } else {
    clear();
  }

  if (isCalibratingAudio) {
    calibrateAudio();
  }

  //PVector surfaceMouse = surface.getTransformedMouse();

  drawFace(offscreen, color(171, 47, 82));
  surface.render(offscreen);

  drawFace(offscreen2, color(229, 93, 74));
  surface2.render(offscreen2);

  //drawFace(offscreen3, color(82, 36, 82));
  drawFace(offscreen3, color(232, 133, 84));
  surface3.render(offscreen3);

  //drawSpectrum(offscreen3);
  //surface3.render(offscreen3);

  delay(100);
}
public void setupAudio() {
  fft = new FFT(this, bands);
  input = new AudioIn(this, 0);
  input.start();
  analyzer = new Amplitude(this);
  //fft.input(input);
  analyzer.input(input);
}

public void setupKeystone() {
  keystone = new Keystone(this);
  surface = keystone.createCornerPinSurface(400, 300, 20);
  offscreen = createGraphics(400, 300, P3D);

  surface2 = keystone.createCornerPinSurface(400, 300, 20);
  offscreen2 = createGraphics(400, 300, P3D);

  surface3 = keystone.createCornerPinSurface(400, 300, 20);
  offscreen3 = createGraphics(400, 300, P3D);
}

public void drawFace(PGraphics offscreen, color faceColor) {
  offscreen.beginDraw();
  offscreen.background(faceColor);
  offscreen.noStroke();
  offscreen.fill(0, 0, 0);
  //float eyesSize = random(1) > 0.99 ? 4 : 20;
  float eyesSize = getVolume() > 0.75 * maxVolume ? 2 : 15;
  float mouthSize = getMouthSize();
  offscreen.ellipse(150, 100, 15, eyesSize);
  offscreen.ellipse(250, 100, 15, eyesSize);
  offscreen.ellipse(200, 200, 125 - mouthSize/2.0, mouthSize);
  offscreen.endDraw();
}

public void drawSpectrum(PGraphics offscreen) {
  offscreen.beginDraw();
  //offscreen3.colorMode(HSB, bands, 1, 1);
  //offscreen3.background(0, 0, 0);
  //offscreen3.noStroke();
  offscreen.clear();
  fft.analyze(spectrum);
  for (int i = 0; i < bands/2; i++) {
    offscreen.fill(color(82, 36, 82));
    float rectWidth = offscreen3.width / bands * 2;
    offscreen.rect(i*rectWidth, offscreen3.height - spectrum[i]*offscreen3.height, rectWidth, spectrum[i]*offscreen3.height);
  } 
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
    // calibrate audio
    maxVolume = 0.01;
    isCalibratingAudio = true;
    break;

  case 'b':
    // toggle background
    drawBackground = !drawBackground;
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

public float getVolume(int band) {
  if (band < bands) {
    fft.analyze(spectrum);
    return spectrum[band];
  } else {
    return getVolume();
  }
}

public float getMouthSize() {
  int range = min(round(3 * getVolume() / maxVolume), 3);
  //float[] size = {5, 100, 130, 150};
  float[] size = {5, 20, 85, 100};
  return size[range];
}

public float getVolume() {
  return analyzer.analyze();
  /*
  float max = 0;
   for (int i = 0; i < bands; i++) {
   max = spectrum[i] > max ? spectrum[i] : max;
   }
   return max;
   */
}

public void calibrateAudio() {
  float volume = getVolume();
  maxVolume = max(volume * 1.2, maxVolume);
  textSize(32);
  fill(255, 255, 255);
  text(String.format("Volume: %f\nMax volume: %f", volume, maxVolume), 100, 100);
}

public void printMousePosition() {
  textSize(32);
  text(String.format("Mouse position (%d, %d)", mouseX, mouseY), 100, 100);
}
