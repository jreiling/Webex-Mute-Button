#include <JC_Button.h>          // https://github.com/JChristensen/JC_Button

#define BUTTON_PIN 2
#define GREEN_LED_PIN 16
#define RED_LED_PIN 11

Button btn(BUTTON_PIN,25, true, false); 

void setup() {

  Serial.begin(9600);

  pinMode(GREEN_LED_PIN, OUTPUT);
  pinMode(RED_LED_PIN, OUTPUT);

  btn.begin();
}

void loop() {

  checkSerialForCommand();
  checkForButtonActivity();
}


void checkForButtonActivity() {

  btn.read();
  
  if (btn.wasPressed()) {
    Serial.print("Pressed");
  } else if (btn.wasReleased()){
    Serial.print("Released");
  }
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
