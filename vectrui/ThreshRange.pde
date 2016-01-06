import java.util.ArrayList;
import java.util.logging.Level;

import processing.core.PApplet;
import processing.core.PGraphics;
import processing.core.PVector;

import controlP5.*;


public class ThreshRange extends Controller<ThreshRange> {
  protected static final String MANY_SPACES = "                    ";
  protected static final int MODE_OFF = -1;
  protected static final int MODE_MINA = 0;
  protected static final int MODE_MIDA = 1;
  protected static final int MODE_MAXA = 2;
  protected static final int MODE_MINB = 3;
  protected static final int MODE_MIDB = 4;
  protected static final int MODE_MAXB = 5;

  protected static final int HORIZONTAL = 0;
  protected static final int VERTICAL = 1;

  public int alignValueLabel = CENTER;
  private int mode = -1;

  protected int handleSize = 6;
  protected int handleSize2 = 3;
  public int autoWidth = 99;
  public int autoHeight = 9;
  public  PVector autoSpacing = new PVector(0, 5, 0);

  protected float _myValuePosition;
  protected float _myValueRange;

  protected boolean isDragging;
  protected boolean isDraggable = true;
  protected boolean isFirstClick;

  //protected Label _myValueLabel;  // For low value
  protected Label _myMidValueLabel;
  protected Label _myHighValueLabel;

  protected int minAHandle = 0;
  protected int maxAHandle = 0;
  protected int minBHandle = 0;
  protected int maxBHandle = 0;

  int dA = 0;
  int dB = 0;


  public ThreshRange(ControlP5 theControlP5, String theName) {
    this(theControlP5, theControlP5.getDefaultTab(), theName, 0, 32, 4, 14, 18, 28, 0, 0, 792, 20);
    theControlP5.register(theControlP5.papplet, theName, this);
  }

  public ThreshRange(
      ControlP5 theControlP5,
      ControllerGroup<?> theParent,
      String theName,
      float theMin,
      float theMax,
      float theDefaultMinAValue,
      float theDefaultMaxAValue,
      float theDefaultMinBValue,
      float theDefaultMaxBValue,
      int theX,
      int theY,
      int theWidth,
      int theHeight) {

    super(theControlP5, theParent, theName, theX, theY, theWidth, theHeight);

    _myArrayValue = new float[] {theDefaultMinAValue , theDefaultMaxAValue, theDefaultMinBValue, theDefaultMaxBValue};

    _myMin = theMin;
    _myMax = theMax;
    _myValueRange = _myMax - _myMin;

    minAHandle = (int)(_myArrayValue[0] * 24) + 3;
    maxAHandle = (int)(_myArrayValue[1] * 24) + 9;
    minBHandle = (int)(_myArrayValue[2] * 24) + 15;
    maxBHandle = (int)(_myArrayValue[3] * 24) + 21;
    dA = maxAHandle - minAHandle;
    dB = maxBHandle - minBHandle;

    _myCaptionLabel = new controlP5.Label(cp5, theName)
      .setColor(0)
      .align(CENTER, TOP_OUTSIDE);

    _myValueLabel = new controlP5.Label(cp5, theName + "LowLabel")
      .setColor(0)
      .set("" + (int)theDefaultMinAValue)
      .setFont(createFont("Arial", 10))
      .align(LEFT, BOTTOM_OUTSIDE);

    _myMidValueLabel = new controlP5.Label(cp5, theName + "MidLabel")
      .setColor(0)
      .set("" + (int)theDefaultMaxAValue + MANY_SPACES + (int)theDefaultMinBValue)
      .setFont(createFont("Arial", 10))
      .align(CENTER, BOTTOM_OUTSIDE);

    _myHighValueLabel = new controlP5.Label(cp5, theName + "HighLabel")
      .setColor(0)
      .set("" + (int)theDefaultMaxBValue)
      .setFont(createFont("Arial", 10))
      .align(RIGHT, BOTTOM_OUTSIDE);

    _myValue = theDefaultMinAValue;
    update();
  }

  @Override public ThreshRange setColorValueLabel(int theColor) {
    _myValueLabel.setColor(theColor);
    _myMidValueLabel.setColor(theColor);
    _myHighValueLabel.setColor(theColor);
    return this;
  }

  @Override public ThreshRange setColorCaptionLabel(int theColor) {
    _myCaptionLabel.setColor(theColor);
    return this;
  }

  public ThreshRange setLowValueLabel(final String theLabel) {
    _myValueLabel.set(theLabel);
    return this;
  }

  public ThreshRange setMidValueLabel(final String theLabel) {
    _myMidValueLabel.set(theLabel);
    return this;
  }

  public ThreshRange setHighValueLabel(final String theLabel) {
    _myHighValueLabel.set(theLabel);
    return this;
  }

  public ThreshRange setSliderMode(int theMode) {
    return this;
  }

  public ThreshRange setHandleSize(int theSize) {
    handleSize = theSize;
    handleSize2 = theSize / 2;
    setMinA(_myArrayValue[0], false);
    setMaxA(_myArrayValue[1], false);
    setMinB(_myArrayValue[2], false);
    setMaxB(_myArrayValue[3], false);
    return this;
  }

  int getMode() {
    final float posX = x(_myParent.getAbsolutePosition()) + x(position);
    final float posY = y(_myParent.getAbsolutePosition()) + y(position);
    final float mX = mouseX;
    final float mY = mouseY;

    if (mY < posY || mY > posY + getHeight()) {
      // Not inside
      return MODE_OFF;
    }

    int x0 = (int)(posX + minAHandle);
    int x1 = (int)(posX + maxAHandle);
    int x2 = (int)(posX + minBHandle);
    int x3 = (int)(posX + maxBHandle);

    if (mX >= x0 - handleSize2 && mX < x0 + handleSize2) {
      return MODE_MINA;
    } else if (mX >= x0 + handleSize2 && mX < x1 - handleSize2) {
      return MODE_MIDA;
    } else if (mX >= x1 - handleSize2 && mX < x1 + handleSize2) {
      return MODE_MAXA;
    } else if (mX >= x2 - handleSize2 && mX < x2 + handleSize2) {
      return MODE_MINB;
    } else if (mX >= x2 + handleSize2 && mX < x3 - handleSize2) {
      return MODE_MIDB;
    } else if (mX >= x3 - handleSize2 && mX < x3 + handleSize2) {
      return MODE_MAXB;
    }
    return MODE_OFF;
  }

  @Override public void mousePressed() {
    mode = getMode();
  }

  public ThreshRange updateInternalEvents(PApplet theApplet) {
    if (isVisible) {
      int c = mouseX - pmouseX;
      if (c == 0) {
        return this;
      }
      if (isMousePressed && !cp5.isAltDown()) {
        switch (mode) {
          case MODE_MINA:
            // 0 - (MaxA
            minAHandle = PApplet.max(3, PApplet.min(maxAHandle - 6, minAHandle + c));
            break;
          case MODE_MAXA:
            // MinA) - (MinB
            maxAHandle = PApplet.max(minAHandle + 6, PApplet.min(minBHandle - 6, maxAHandle + c));
            break;
          case MODE_MINB:
            // MaxA) - (MaxB
            minBHandle = PApplet.max(maxAHandle + 6, PApplet.min(maxBHandle - 6, minBHandle + c));
            break;
          case MODE_MAXB:
            // MinB) - width
            maxBHandle = PApplet.max(minBHandle + 6, PApplet.min(getWidth() - 3, maxBHandle + c));
            break;

          case MODE_MIDA:
            minAHandle = PApplet.max(3, PApplet.min(minBHandle - dA - 6, minAHandle + c));
            maxAHandle = PApplet.max(minAHandle + 6, PApplet.min(minBHandle - 6, minAHandle + dA));
            break;
          case MODE_MIDB:
            minBHandle = PApplet.max(maxAHandle + 6, PApplet.min(getWidth() - dB - 3, minBHandle + c));
            maxBHandle = PApplet.max(minBHandle + 6, PApplet.min(getWidth() - 3, minBHandle + dB));
            break;
        }
        update();
        dA = maxAHandle - minAHandle;
        dB = maxBHandle - minBHandle;
      }
    }
    return this;
  }

  @Override public ThreshRange setValue(float theValue) {
    _myValue = theValue;
    broadcast(ARRAY);
    return this;
  }

  @Override public ThreshRange update() {
    _myArrayValue[0] = min((minAHandle - 3) / 24, 32);
    _myArrayValue[1] = min((maxAHandle - 9) / 24, 32);
    _myArrayValue[2] = min((minBHandle - 15) / 24, 32);
    _myArrayValue[3] = min((maxBHandle - 21) / 24, 32);

    _myValueLabel.set("" + (int)_myArrayValue[0]);
    _myMidValueLabel.set("" + (int)_myArrayValue[1] + MANY_SPACES + (int)_myArrayValue[2]);
    _myHighValueLabel.set("" + (int)_myArrayValue[3]);
    return setValue(_myValue);
  }

  public ThreshRange setDraggable(boolean theFlag) {
    isDraggable = theFlag;
    isDragging = (theFlag == false) ? false : isDragging;
    return this;
  }

  public float[] getArrayValue() {
    return _myArrayValue;
  }

  protected float snapValue(float theValue) {
    return (float)(int)theValue;
  }

  private ThreshRange setMinA(float theValue, boolean isUpdate) {
    _myArrayValue[0] = PApplet.max(_myMin, snapValue(theValue));
    minAHandle = (int)(_myArrayValue[0] * 24) + 3;
    dA = maxAHandle - minAHandle;
    return (isUpdate) ? update() : this;
  }

  public ThreshRange setMinA(float theValue) {
    return setMinA(theValue, true);
  }

  private ThreshRange setMaxA(float theValue, boolean isUpdate) {
    _myArrayValue[1] = PApplet.max(_myMin, snapValue(theValue));
    maxAHandle = (int)(_myArrayValue[1] * 24) + 9;
    dA = maxAHandle - minAHandle;
    return (isUpdate) ? update() : this;
  }

  public ThreshRange setMaxA(float theValue) {
    return setMaxA(theValue, true);
  }

  private ThreshRange setMinB(float theValue, boolean isUpdate) {
    _myArrayValue[2] = PApplet.max(_myMin, snapValue(theValue));
    minBHandle = (int)(_myArrayValue[2] * 24) + 15;
    dB = maxBHandle - minBHandle;
    return (isUpdate) ? update() : this;
  }

  public ThreshRange setMinB(float theValue) {
    return setMinB(theValue, true);
  }

  private ThreshRange setMaxB(float theValue, boolean isUpdate) {
    _myArrayValue[3] = PApplet.max(_myMin, snapValue(theValue));
    maxBHandle = (int)(_myArrayValue[3] * 24) + 21;
    dB = maxBHandle - minBHandle;
    return (isUpdate) ? update() : this;
  }

  public ThreshRange setMaxB(float theValue) {
    return setMaxB(theValue, true);
  }

  public ThreshRange setArrayValue(int i, float v) {
    if (i == 0) {
      setMinA(v, false);
    } else if (i == 1) {
      setMaxA(v, false);
    } else if (i == 2) {
      setMinB(v, false);
    } else if (i == 3) {
      setMaxB(v, false);
    }
    return update();
  }

  @Override public ThreshRange setArrayValue(float[] theArray) {
    setMinA(theArray[0], false);
    setMaxA(theArray[1], false);
    setMinB(theArray[2], false);
    setMaxB(theArray[3], false);
    return update();
  }

  @Override public ThreshRange setMin(float theValue) {
    _myMin = theValue;
    _myValueRange = _myMax - _myMin;
    return setMinA(_myArrayValue[0]);
  }

  @Override public ThreshRange setMax(float theValue) {
    _myMax = theValue;
    _myValueRange = _myMax - _myMin;
    return setMaxB(_myArrayValue[1]);
  }

  public float getMinA() {
    return _myArrayValue[0];
  }

  public float getMaxA() {
    return _myArrayValue[1];
  }

  public float getMinB() {
    return _myArrayValue[2];
  }

  public float getMaxB() {
    return _myArrayValue[3];
  }

  @Override public ThreshRange setWidth(int theValue) {
    super.setWidth(theValue);
    return this;
  }

  @Override public ThreshRange setHeight(int theValue) {
    super.setHeight(theValue);
    return this;
  }

  @Override public void mouseReleased() {
    isDragging = false;
    // Align
    switch (mode) {
      case MODE_MINA:
        minAHandle = (int)(_myArrayValue[0] * 24) + 3;
        break;
      case MODE_MAXA:
        maxAHandle = (int)(_myArrayValue[1] * 24) + 9;
        break;
      case MODE_MINB:
        minBHandle = (int)(_myArrayValue[2] * 24) + 15;
        break;
      case MODE_MAXB:
        maxBHandle = (int)(_myArrayValue[3] * 24) + 21;
        break;
      case MODE_MIDA:
        minAHandle = (int)(_myArrayValue[0] * 24) + 3;
        maxAHandle = (int)(_myArrayValue[1] * 24) + 9;
        break;
      case MODE_MIDB:
        minBHandle = (int)(_myArrayValue[2] * 24) + 15;
        maxBHandle = (int)(_myArrayValue[3] * 24) + 21;
        break;
    }
    dA = maxAHandle - minAHandle;
    dB = maxBHandle - minBHandle;
    mode = MODE_OFF;
  }

  @Override public void mouseReleasedOutside() {
    mouseReleased();
  }

  @Override public void onLeave() {
    isDragging = false;
  }

  public ThreshRange setRange(float theMinValue, float theMaxValue) {
    setMin(theMinValue);
    setMax(theMaxValue);
    return this;
  }

  public ThreshRange setRangeValues(float theMinA, float theMaxA, float theMinB, float theMaxB) {
    return setArrayValue(new float[] {theMinA, theMaxA, theMinB, theMaxB});
  }

  @Override public ThreshRange updateDisplayMode(int theMode) {
    _myDisplayMode = theMode;
    switch (theMode) {
      case (DEFAULT):
        _myControllerView = new ThreshRangeView();
        break;
      case (SPRITE):
        _myControllerView = new ThreshRangeSpriteView();
        break;
      case (IMAGE):
        _myControllerView = new ThreshRangeImageView();
        break;
      case (CUSTOM):
      default:
        break;
    }
    return this;
  }

  class ThreshRangeSpriteView implements ControllerView<ThreshRange> {
    public void display(PGraphics theGraphics, ThreshRange theController) {
      ControlP5.logger().log(Level.INFO, "ThreshRangeSpriteDisplay not available.");
    }
  }

  class ThreshRangeView implements ControllerView<ThreshRange> {
    public void display(PGraphics theGraphics, ThreshRange theController) {
      int high = getMode();
      theGraphics.pushMatrix();

      // Pattern Zones
      theGraphics.fill(0);
      theGraphics.rect(0, 0, getWidth(), getHeight());

      theGraphics.fill(color(255, 0, 0));
      theGraphics.rect(0, 0, minAHandle, getHeight());
      theGraphics.fill(color(255, 255, 0));
      theGraphics.rect(minAHandle, 0, maxAHandle - minAHandle, getHeight());
      theGraphics.fill(color(0, 255, 0));
      theGraphics.rect(maxAHandle, 0, minBHandle - maxAHandle, getHeight());
      theGraphics.fill(color(0, 255, 255));
      theGraphics.rect(minBHandle, 0, maxBHandle - minBHandle, getHeight());
      theGraphics.fill(color(0, 0, 255));
      theGraphics.rect(maxBHandle, 0, getWidth() - maxBHandle, getHeight());

      theGraphics.fill(255);
      theGraphics.stroke(0);
      theGraphics.rect(minAHandle - handleSize2, 0, handleSize, getHeight());
      theGraphics.rect(maxAHandle - handleSize2, 0, handleSize, getHeight());
      theGraphics.rect(minBHandle - handleSize2, 0, handleSize, getHeight());
      theGraphics.rect(maxBHandle - handleSize2, 0, handleSize, getHeight());

      if (isLabelVisible) {
        _myCaptionLabel.draw(theGraphics, 0, 0, theController);
        _myValueLabel.draw(theGraphics, 0, 0, theController);
        _myMidValueLabel.draw(theGraphics, 0, 0, theController);
        _myHighValueLabel.draw(theGraphics, 0, 0, theController);
      }

      theGraphics.popMatrix();
    }
  }

  class ThreshRangeImageView implements ControllerView<ThreshRange> {
    public void display(PGraphics theGraphics, ThreshRange theController) {
      ControlP5.logger().log(Level.INFO, "ThreshRangeImageDisplay not implemented.");
    }
  }

  @Override public String toString() {
    return "type:\tThreshRange\n" + super.toString();
  }

  @Deprecated public float lowValue() {
    return getMinA();
  }

  @Deprecated public float highValue() {
    return getMaxB();
  }

  @Deprecated public float[] arrayValue() {
    return _myArrayValue;
  }
}