#include <OneButton.h>

#define BUTTON_PIN 2
#define GREEN_LED_PIN 16
#define RED_LED_PIN 11

OneButton btn = OneButton(BUTTON_PIN, HIGH, false);

void setup() {

  Serial.begin(9600);

  pinMode(GREEN_LED_PIN, OUTPUT);
  pinMode(RED_LED_PIN, OUTPUT);

  btn.attachClick(handlePress); 
}

void loop() {

  checkSerialForCommand();
  btn.tick();
  delay(1);       
}

static void handlePress() {
  Serial.print("Press");
}

void checkSerialForCommand() {

  String command = "";
  char character;

  while(Serial.available()) {
      character = Serial.read();
      command.concat(character);
  }
  
  if (command == "s2") {
      digitalWrite(RED_LED_PIN,HIGH);
      digitalWrite(GREEN_LED_PIN,LOW);
  } else if (command == "s1") {
      digitalWrite(RED_LED_PIN,LOW);
      digitalWrite(GREEN_LED_PIN,HIGH);
  } else if (command == "s0") {
      digitalWrite(RED_LED_PIN,LOW);
      digitalWrite(GREEN_LED_PIN,LOW);
    
  }
}
