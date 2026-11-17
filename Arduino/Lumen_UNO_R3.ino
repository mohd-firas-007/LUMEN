
void setup() {
  Serial.begin(9600);
}

void loop() {
  int readings[6];

  for (int i = 0; i < 6; i++) {
    readings[i] = analogRead(A0 + i);
  }

  for (int i = 0; i < 6; i++) {
    Serial.print(readings[i]);

    if (i < 5) {
      Serial.print(",");
    }
  }

  Serial.println();
  delay(20);
}
