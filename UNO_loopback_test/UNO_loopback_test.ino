/*
 * RAMPS 1.4 Pump Controller for QML/Python backend
 * Commands (newline-terminated JSON at 115200 baud):
 *   {"prime": N}
 *   {"pump": N, "flow": F}     // µL/min (simple linear map)
 *   {"stop": N}
 *   {"stop_all": true}
 */

#include <AccelStepper.h>

// ---------- RAMPS 1.4 pins ----------
#define X_EN   38
#define X_DIR   1
#define X_STP   0

#define Y_EN    2
#define Y_DIR   7
#define Y_STP   6

#define Z_EN    8
#define Z_DIR  48
#define Z_STP  46

#define E0_EN  24
#define E0_DIR 28
#define E0_STP 26

#define E1_EN  30
#define E1_DIR 34
#define E1_STP 36

// ---------- Config ----------
#define BAUD 115200

// Map "UI pump number" -> which driver to use.
// Default: UI Pump 1 -> E1, 2 -> E0, 3 -> X, 4 -> Y, 5 -> Z
// Change this order if your wiring differs.
enum DriverId {DRV_E1=0, DRV_E0, DRV_X, DRV_Y, DRV_Z, DRV_COUNT};
const DriverId PUMP_MAP[] = {DRV_E1, DRV_E0, DRV_X, DRV_Y, DRV_Z};

// Steps-per-second mapping
const float PRIME_SPS       = 1500.0;     // prime speed (steps/s)
const uint32_t PRIME_MS     = 2000;       // prime duration (ms)
const float FLOW_UL_PER_MIN_MAX = 300.0;  // UI max flow used in mapping
const float MAX_SPS         = 1200.0;     // steps/s at max flow (tune!)

// If you know your calibration, set MAX_SPS = (steps_per_rev * rev_per_ul * F_max)
//
// Example if later you measure: 200 steps/rev * 32 usteps = 6400 steps/rev
// and pump does 50 µL/rev, then 300 µL/min = 6 rev/min = 0.1 rev/s -> 640 sps.
// For now we just use a safe default (1200 sps).

// ---------- Objects ----------
AccelStepper steppers[DRV_COUNT] = {
  AccelStepper(AccelStepper::DRIVER, E1_STP, E1_DIR),  // DRV_E1
  AccelStepper(AccelStepper::DRIVER, E0_STP, E0_DIR),  // DRV_E0
  AccelStepper(AccelStepper::DRIVER, X_STP,  X_DIR ),  // DRV_X
  AccelStepper(AccelStepper::DRIVER, Y_STP,  Y_DIR ),  // DRV_Y
  AccelStepper(AccelStepper::DRIVER, Z_STP,  Z_DIR )   // DRV_Z
};

const uint8_t EN_PINS[DRV_COUNT] = { E1_EN, E0_EN, X_EN, Y_EN, Z_EN };

// State
float targetSps[DRV_COUNT] = {0,0,0,0,0};
uint32_t primeUntilMs[DRV_COUNT] = {0,0,0,0,0};

String line;

void enableDriver(DriverId d, bool en) {
  // RAMPS enable is active LOW
  digitalWrite(EN_PINS[d], en ? LOW : HIGH);
}

void setSpeedSps(DriverId d, float sps) {
  if (sps < 0) sps = -sps;                // use positive; change DIR if needed later
  targetSps[d] = sps;
  if (sps > 0.0f) {
    enableDriver(d, true);
    steppers[d].setMaxSpeed(sps);
    steppers[d].setSpeed(sps);            // constant speed; runSpeed() in loop
  } else {
    steppers[d].setSpeed(0);
    enableDriver(d, false);
  }
}

void stopAll() {
  for (int i=0;i<DRV_COUNT;++i) {
    targetSps[i] = 0;
    primeUntilMs[i] = 0;
    steppers[i].setSpeed(0);
    enableDriver((DriverId)i, false);
  }
}

void setup() {
  Serial.begin(BAUD);
  // enables
  for (int i=0;i<DRV_COUNT;++i) {
    pinMode(EN_PINS[i], OUTPUT);
    enableDriver((DriverId)i, false);     // disabled at boot
    steppers[i].setAcceleration(2000);    // safe accel
    steppers[i].setMaxSpeed(1500);
    steppers[i].setSpeed(0);
  }
  Serial.println(F("{\"status\":\"ready\"}"));
}

static int readIntAfter(const String& s, const String& key, int deflt=-1) {
  int k = s.indexOf(key);
  if (k < 0) return deflt;
  k = s.indexOf(':', k);
  if (k < 0) return deflt;
  int j = k+1;
  while (j < (int)s.length() && (s[j]==' ')) j++;
  return s.substring(j).toInt();
}

static float readFloatAfter(const String& s, const String& key, float deflt=0) {
  int k = s.indexOf(key);
  if (k < 0) return deflt;
  k = s.indexOf(':', k);
  if (k < 0) return deflt;
  int j = k+1;
  while (j < (int)s.length() && (s[j]==' ')) j++;
  return s.substring(j).toFloat();
}

void handleLine(const String& s) {
  // Expect keys "prime", "pump"/"flow", "stop", "stop_all"
  if (s.indexOf("\"prime\"") >= 0) {
    int p = readIntAfter(s, "\"prime\"");
    if (p >= 1) {
      // map UI pump number to driver
      DriverId d = PUMP_MAP[(p-1) % (sizeof(PUMP_MAP)/sizeof(PUMP_MAP[0]))];
      setSpeedSps(d, PRIME_SPS);
      primeUntilMs[d] = millis() + PRIME_MS;
      Serial.println(F("{\"ack\":\"prime\"}"));
      return;
    }
  }

  if (s.indexOf("\"pump\"") >= 0 && s.indexOf("\"flow\"") >= 0) {
    int p = readIntAfter(s, "\"pump\"");
    float flow = readFloatAfter(s, "\"flow\"");
    if (p >= 1) {
      DriverId d = PUMP_MAP[(p-1) % (sizeof(PUMP_MAP)/sizeof(PUMP_MAP[0]))];
      // linear map: 0..FLOW_MAX (µL/min) -> 0..MAX_SPS (steps/s)
      float sps = (flow <= 0) ? 0.0f : (flow / FLOW_UL_PER_MIN_MAX) * MAX_SPS;
      setSpeedSps(d, sps);
      primeUntilMs[d] = 0;
      Serial.println(F("{\"ack\":\"set_flow\"}"));
      return;
    }
  }

  if (s.indexOf("\"stop_all\"") >= 0) {
    stopAll();
    Serial.println(F("{\"ack\":\"stop_all\"}"));
    return;
  }

  if (s.indexOf("\"stop\"") >= 0) {
    int p = readIntAfter(s, "\"stop\"");
    if (p >= 1) {
      DriverId d = PUMP_MAP[(p-1) % (sizeof(PUMP_MAP)/sizeof(PUMP_MAP[0]))];
      setSpeedSps(d, 0);
      primeUntilMs[d] = 0;
      Serial.println(F("{\"ack\":\"stop\"}"));
      return;
    }
  }
}

void loop() {
  // ----- read serial line -----
  while (Serial.available()) {
    char c = (char)Serial.read();
    if (c == '\n' || c == '\r') {
      if (line.length()) {
        handleLine(line);
        line = "";
      }
    } else {
      line += c;
      if (line.length() > 200) line = ""; // safety
    }
  }

  // ----- run motors -----
  uint32_t now = millis();
  for (int i=0;i<DRV_COUNT;++i) {
    // end of prime window?
    if (primeUntilMs[i] && now >= primeUntilMs[i]) {
      primeUntilMs[i] = 0;
      setSpeedSps((DriverId)i, 0);
    }
    // constant speed
    steppers[i].runSpeed();
  }
}
