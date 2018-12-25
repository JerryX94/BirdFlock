static final int INITW = 800;
static final int FR = 60;
static final int NFLOCK = 100;
static final int NBORN = 2;
static final int NSIZE = 5;
static final int PWFLCT = 5;
static final float G = 9.81;//Gravity
static final float KVR = 100.;//Times of Display to Reality
static final float KPOW = 3.;//Times of Power to Own Weight
static final float KDRG = .001;//Drag Coefficient
static final float KRMZ = 8.;
static final float UBACC = 4500.;
static final float UBVEL = 640.;
static final float LBRCT = .1;

class Bird {
  private float[] target = {0, 0};
  private float[] coord = {0, 0};
  private float[] veloc = {0, 0};
  private float[] accel = {0, 0};
  private float vellmt;
  private float acclmt;
  private float angle;
  private float dist;
  private float size;
  private float diam;
  private float mass;
  private float power;
  private float react;
  private int rcnt;
  private boolean abnml;
  private color c0;
  private color c1;

  Bird(float xLoc, float yLoc, int sz) {
    coord[0] = xLoc;
    coord[1] = yLoc;
    angle = 0;
    dist = 0;
    size = sz;
    diam = .02 * (5 + size) * width / INITW;
    mass = PI * diam * diam * diam / 6;
    power = KPOW * mass * G;
    power *= random(10 - PWFLCT, 10 + PWFLCT) / 10;
    acclmt = KVR * power / mass;
    vellmt = sqrt(KVR * power / KDRG / diam / diam);
    react = random(1, 5) / 10;
    rcnt = 0;
    abnml = ((acclmt > UBACC) || (vellmt > UBVEL)) ? true : false;
    c0 = SetColor0();
    c1 = SetColor1();
  }

  private color SetColor0() {
    int[] RGB = {255, 255, 255};
    if (!abnml) {
      for (int i = 0; i < 3; i++) {
        RGB[i] = (int)random(128);
      }
      int i = (int)(random(4));
      if (i < 3) RGB[i] += 128;
    }
    return color(RGB[0], RGB[1], RGB[2]);
  }

  private color SetColor1() {
    int[] RGB = {0, 0, 0};
    RGB[0] = (int)(255 * acclmt / UBACC);
    RGB[2] = (int)(255 * vellmt / UBVEL);
    RGB[1] = (int)(255 * LBRCT / (react - LBRCT));
    println(acclmt, vellmt, react);
    return color(RGB[0], RGB[1], RGB[2]);
  }

  void Fly() {
    if (rcnt == 0) {
      float aLoc = random(2 * PI);
      float dLoc = random(width / KRMZ);
      float xLoc = mouseX + dLoc * cos(aLoc);
      float yLoc = mouseY + dLoc * sin(aLoc);
      target[0] = xLoc;
      target[1] = yLoc;
      rcnt = (int)(react * FR);
    } else {
      rcnt--;
    }
    float xDist = target[0] - coord[0];
    float yDist = target[1] - coord[1];
    dist = sqrt(xDist * xDist + yDist * yDist);
    angle = acos(xDist / dist);
    if (yDist < 0) angle = 2 * PI - angle;
    if (veloc[0] == 0) veloc[0] = 1E-6;
    if (veloc[1] == 0) veloc[1] = 1E-6;
    float xDrag = -veloc[0] / abs(veloc[0]);
    float yDrag = -veloc[1] / abs(veloc[1]);
    xDrag *= KDRG * diam * diam * abs(pow(veloc[0], 2));
    yDrag *= KDRG * diam * diam * abs(pow(veloc[1], 2));
    float force0 = dist / width;
    if (force0 >= 1) force0 = 1;
    force0 *= KVR * power;
    float xForce = force0 * cos(angle) + xDrag;
    float yForce = force0 * sin(angle) + yDrag;
    accel[0] = xForce / mass;
    accel[1] = yForce / mass;
    veloc[0] += accel[0] / FR;
    veloc[1] += accel[1] / FR;
    coord[0] += veloc[0] / FR;
    coord[1] += veloc[1] / FR;
  }

  void Show() {
    stroke(c1);
    fill(c1);
    float diamShow = diam * KVR;
    float x[], y[], d;
    x = new float[3];
    y = new float[3];
    d = diamShow * 2. / 3;
    x[0] = coord[0] + d * cos(angle);
    y[0] = coord[1] + d * sin(angle);
    d = diamShow * .5;
    x[1] = coord[0] + d * cos(angle + 2. * PI / 3);
    y[1] = coord[1] + d * sin(angle + 2. * PI / 3);
    x[2] = coord[0] + d * cos(angle - 2. * PI / 3);
    y[2] = coord[1] + d * sin(angle - 2. * PI / 3);
    triangle(x[0], y[0], x[1], y[1], coord[0], coord[1]);
    triangle(x[0], y[0], x[2], y[2], coord[0], coord[1]);
    stroke(c0);
    fill(c0);
    x[1] = x[0] + .5 * (x[1] - x[0]);
    y[1] = y[0] + .5 * (y[1] - y[0]);
    x[2] = x[0] + .5 * (x[2] - x[0]);
    y[2] = y[0] + .5 * (y[2] - y[0]);
    triangle(x[0], y[0], x[1], y[1], x[2], y[2]);
  }
}

Bird flock[];
int count = 0;
boolean start = false;

void setup() {
  size(800, 600);
  //fullScreen();
  frameRate(FR);
  flock = new Bird[NFLOCK];
}

void draw() {
  background(255);
  if (start) {
    ShowTarget();
    for (int i = 0; i < count; i++) {
      flock[i].Fly();
      flock[i].Show();
    }
  }
  ShowText();
}

void mousePressed() {
  if (start) {
    for (int i = 0; i < NBORN; i++) {
      if (count < NFLOCK) {
        float aLoc = random(2 * PI);
        float dLoc = random(width / KRMZ);
        float xLoc = mouseX + dLoc * cos(aLoc);
        float yLoc = mouseY + dLoc * sin(aLoc);
        flock[count++] = new Bird(xLoc, yLoc, (int)random(NSIZE));
      }
    }
  } else {
    start = true;
  }
}

void ShowTarget() {
  color c = color(128);
  float d = width / KRMZ / KRMZ;
  stroke(c);
  fill(c);
  ellipseMode(CENTER);
  ellipse(mouseX, mouseY, d, d);
}

void ShowText() {
  int tSize = width / 10;
  color c = color(0);
  stroke(c);
  fill(c);
  if (start) {
    textSize(tSize / 4);
    textAlign(CENTER);
    text("Population(Max       ) :", width / 6, height / 20);
    text(NFLOCK, width / 4, height / 20);
    if (count >= NFLOCK - 1) {
      c = color(255, 0, 0);
      fill(c);
    }
    text(count, width / 3, height / 20);
  } else {
    textSize(tSize);
    textAlign(CENTER);
    text("Bird Flock", width / 2, height / 2);
    textSize(tSize / 4);
    textAlign(CENTER);
    text("Click to Start & Add Birds", width / 2, height / 2 + tSize);
    textSize(tSize / 2);
    textAlign(CENTER);
    text("Programmed by Jiayu", width / 2, 9 * height / 10);
  }
}
