const int pingPin = D6;
int greenLED1 = D0;
int greenLED2 = D1;
int yellowLED1 = D2;
int yellowLED2 = D3;
int redLED1 = D4;
int redLED2 = D5;

void setup() {
  Spark.function("led", ledController);
  Serial.begin(9600);
  pinMode(greenLED1, OUTPUT);
  pinMode(greenLED2, OUTPUT);
  pinMode(yellowLED1, OUTPUT);
  pinMode(yellowLED2, OUTPUT);
  pinMode(redLED1, OUTPUT);
  pinMode(redLED2, OUTPUT);

}

void loop() {}

long microsecondsToInches(long microseconds) {
  // According to Parallax's datasheet for the PING))), there are
  // 73.746 microseconds per inch (i.e. sound travels at 1130 feet per
  // second).  This gives the distance travelled by the ping, outbound
  // and return, so we divide by 2 to get the distance of the obstacle.
  // See: http://www.parallax.com/dl/docs/prod/acc/28015-PING-v1.3.pdf
  return microseconds / 74 / 2;
}

long microsecondsToCentimeters(long microseconds) {
  // The speed of sound is 340 m/s or 29 microseconds per centimeter.
  // The ping travels out and back, so to find the distance of the
  // object we take half of the distance travelled.
  return microseconds / 29 / 2;
}

unsigned long pulseIn(uint8_t pin, uint8_t state) {
  unsigned long pulseWidth = 0;
  unsigned long loopCount = 0;
  unsigned long loopMax = 5000000;

  // While the pin is *not* in the target state we make sure the timeout hasn't been reached.
  while ((digitalRead(pin)) != state) {
    if (loopCount++ == loopMax) {
      return 0;
    }
  }

  // When the pin *is* in the target state we bump the counter while still keeping track of the timeout.
  while ((digitalRead(pin)) == state) {
    if (loopCount++ == loopMax) {
      return 0;
    }
    pulseWidth++;
  }

  // Return the pulse time in microsecond!
  return pulseWidth * 2.36; // Calculated the pulseWidth++ loop to be about 2.36uS in length.
}


int ledController(String command) {
    while(1) {
      long duration, inches, cm;

      // The PING))) is triggered by a HIGH pulse of 2 or more microseconds.
      // Give a short LOW pulse beforehand to ensure a clean HIGH pulse:
      pinMode(pingPin, OUTPUT);
      digitalWrite(pingPin, LOW);
      delayMicroseconds(2);
      digitalWrite(pingPin, HIGH);
      delayMicroseconds(5);
      digitalWrite(pingPin, LOW);

      // The same pin is used to read the signal from the PING))): a HIGH
      // pulse whose duration is the time (in microseconds) from the sending
      // of the ping to the reception of its echo off of an object.
      pinMode(pingPin, INPUT);
      duration = pulseIn(pingPin, HIGH);

      // convert the time into a distance
      inches = microsecondsToInches(duration);
      cm = microsecondsToCentimeters(duration);

      Serial.print(inches);
      Serial.print("in, ");
      Serial.print(cm);
      Serial.print("cm");
      Serial.println();

      if (inches <= 12) {
        digitalWrite(greenLED1, HIGH);
        digitalWrite(greenLED2, HIGH);
        digitalWrite(redLED1, LOW);
        digitalWrite(redLED2, LOW);

        // delay(500);
        // digitalWrite(yellowLED1, HIGH);
        // digitalWrite(yellowLED2, HIGH);
        // delay(1000);
        // digitalWrite(yellowLED1, LOW);
        // digitalWrite(yellowLED2, LOW);

        // delay(1000);


      } else {
        digitalWrite(greenLED1, LOW);
        digitalWrite(greenLED2, LOW);
        digitalWrite(redLED1, HIGH);
        digitalWrite(redLED2, HIGH);

        // delay(500);
        // digitalWrite(yellowLED1, HIGH);
        // digitalWrite(yellowLED2, HIGH);
        // delay(1000);
        // digitalWrite(yellowLED1, LOW);
        // digitalWrite(yellowLED2, LOW);

        // delay(1000);
      }

      delay(100);
    }
  return 1;
}
