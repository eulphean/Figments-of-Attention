// Natural food. 
class Flower {
  PVector position;
  PVector aniPosition; // Postion to use when it's animating
  int rot;
  int flowerHeight; int flowerWidth; 
  float scale; 
  PImage headBW, headCol, body; 
  Icon icon; 
  PVector centerHead, base;
  boolean isEaten, isReady; 
  Shade shader; int idxShader;
  
  // Animating stuff.
  Ani xPosAni, yPosAni;
  boolean xDoneAnimating, yDoneAnimating; 

  Flower(PVector pos, float s) {
    rot = 0; 
    scale = s; 
    position = pos; 
    aniPosition = new PVector(0, 0); // Used during animation.
    flowerHeight = int(70*s);
    flowerWidth = int(50*s);
    centerHead = new PVector(flowerWidth/2, flowerHeight/3); 
    base = new PVector(centerHead.x, flowerHeight);
    
    // Icon (PGraphics)
    createHead();
    createBody(); 
    
    // Shader 
    assignShader();
    
    // Eaten and ready to be evaluated? 
    isEaten = true;
    isReady = true;
  }
  
  void createHead() {
    icon = iconFactory.getRandomIcon(); 
    PGraphics h = createGraphics(flowerWidth, flowerWidth); 
    h.beginDraw();
    h.fill(0); 
    h.shape(icon.ic,0, 0, flowerWidth, flowerWidth);  
    h.endDraw();
    
    // Store the image. 
    headCol = h.copy();
    headBW = h.copy();
    headBW.filter(GRAY);
  }
  
  void createBody() {
    PGraphics b = createGraphics(flowerWidth, flowerHeight); 
    b.beginDraw(); 
    b.background(0, 0); 
    b.pushStyle(); 
      //// Smooth flower face. 
      b.noStroke();
      b.ellipseMode(CORNER);
      // Left leaf.
      b.pushMatrix(); 
      b.translate(base.x, base.y); 
        b.rotate(radians(200)); 
        b.fill(96, 96, 96);
        b.ellipse(0, 0, flowerWidth/2, flowerHeight/9);
      b.popMatrix();
      
      // Right leaf. 
      b.pushMatrix(); 
      b.translate(base.x, base.y); 
        b.rotate(radians(-20));
        b.fill(96, 96, 96);
        b.ellipse(0, -flowerHeight/9, flowerWidth/2, flowerHeight/9);
      b.popMatrix();
      
      // Stem.
      b.pushStyle();
        b.stroke(32, 32, 32);
        b.strokeWeight(6);
        b.strokeCap(SQUARE);
        b.line(centerHead.x, centerHead.y, base.x, base.y); 
      b.popStyle();
    b.popStyle();
    b.endDraw();
    
    // Store the image. 
    body = b.copy(); 
  }
  
  void run() {    
    updateShaderParams();
    
    pushStyle();
    pushMatrix();
      if (isReady) {
        translate(position.x, position.y);
      } else {
        translate(aniPosition.x, aniPosition.y); 
      }
      scale(scale, scale);
      // When actually drawing
      
      //// Draw the bounding box
      if (debug) { 
        color c = color(255, 255, 255, 0); 
        fill(c);
        stroke(0);
        rect(0, 0, flowerWidth, flowerHeight); 
      } else {
        // Draw Body
        pushMatrix();
         translate(centerHead.x - flowerWidth/2, centerHead.y - flowerHeight/3); 
         image(body, 0, 0);
        popMatrix();
        
        pushMatrix(); 
         translate(centerHead.x - flowerWidth/2, centerHead.y - flowerHeight/3);
         if (this.isThere()) {
          shader(shader.shade); // Begin Shader
          image(headCol, 0, 0); 
          resetShader(); // End Shader
         } else {
          image(headBW, 0, 0); 
         }
        popMatrix();
      }
     popMatrix();
     popStyle();
  } 
  
  boolean isThere() {
   return isReady && !isEaten;  
  }
  
  void fly (PVector target, Easing easing) {
   xPosAni = new Ani(aniPosition, 10.0f, "x", target.x); 
   xPosAni.setEasing(easing); 
   xPosAni.setCallbackObject(this); 
   xPosAni.setCallback("onEnd:xDoneAnimating");
   
   yPosAni = new Ani(aniPosition, 10.0f, "y", target.y); 
   yPosAni.setEasing(easing); 
   yPosAni.setCallbackObject(this); 
   yPosAni.setCallback("onEnd:yDoneAnimating");
  }
  
  void xDoneAnimating() {
   xDoneAnimating = true; 
   isReady = yDoneAnimating; 
  }
  
  void yDoneAnimating() {
   yDoneAnimating = true;
   isReady = xDoneAnimating;
  }
  
  void assignShader() {
    int idx = floor(random(shaderFactory.selectedIndices.length));
    idxShader = shaderFactory.selectedIndices[idx];  
    shader = shaderFactory.getShaderAtIdx(idxShader);
  }
  
  void updateShaderParams() 
  {
    // Store a local copy of the shader from the object to modify.
    PShader shade = shader.shade; 
    
    float offset = 2*PI; 
    float x = cos(frameCount/offset); float y = sin(frameCount/offset); 
    // brcosa
    if (idxShader == 0) {
      shade.set("brightness", 1.0);
      shade.set("contrast", map(x, -1, 1, -5, 5));
      shade.set("saturation", map(y, -1, 1, -5, 5));
    }
  
    // hue
    else if (idxShader == 1) {
      shade.set("hue", map(x, -1, 1, 0, TWO_PI));
    } 
  
    // pixelate
    else if (idxShader == 2) {
      shade.set("pixels", 0.1 * x * width/5, 0.1 * y * height/5);
    } 
  
    // blur
    else if (idxShader == 3) {
      shade.set("sigma", map(x, -1, 1, 0, 10.0));
      shade.set("blurSize", (int) map(y, -1, 1, 0, 30.0));
      shade.set("texOffset", 1.0, 1.0);
    } 
  
    // channels
    else if (idxShader == 4) {
      shade.set("rbias", 0.0, 0.0);
      shade.set("gbias", map(y, -1, 1, -0.2, 0.2), 0.0);
      shade.set("bbias", 0.0, 0.0);
      shade.set("rmult", map(x, -1, 1, 0.8, 1.5), 1.0);
      shade.set("gmult", 1.0, 1.0);
      shade.set("bmult", 1.0, 1.0);
    } 
    
    // threshold
    else if (idxShader == 5) {
      shade.set("threshold", map(x, -1, 1, 0, 1));
    } 
  
    // neon
    else if (idxShader == 6) {
      shade.set("brt", map(x, -1, 1, 0, 0.5));
      shade.set("rad", (int) map(y, -1, 1, 0, 3));
    } 
  
    // edges (no parameters)
    else if (idxShader == 7) {
    }
   
    // pixelRolls
    else if (idxShader == 8) {
      shade.set("time", (float) millis()/1000.0);
      shade.set("pixels", x*width, 250.0);
      shade.set("rollRate", map(y, -1, 1, 0, 2.0));
      shade.set("rollAmount", 0.15);
    }
  
    // modcolor
    else if (idxShader == 9) {
      shade.set("modr", map(x, -1, 1, 0, 0.5));
      shade.set("modg", 0.3);
      shade.set("modb", map(y, -1, 1, 0, 0.5));
    }
  
    // halftone
    else if (idxShader == 10) {
      shade.set("pixelsPerRow", (int) map(x, -1, 1, 20, 60));
    }
    
    // halftone cmyk
    else if (idxShader == 11) {
      shade.set("density", map(x, -1, 1, 0.5, 1));
      shade.set("frequency", map(y, -1, 1, 30, 100));
    }
  
    // inversion (no parameters)
    else if (idxShader == 12) {
    }  
  }
}
