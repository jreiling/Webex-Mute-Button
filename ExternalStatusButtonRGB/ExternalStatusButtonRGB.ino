#include <JC_Button.h>          // https://github.com/JChristensen/JC_Button

#define COMMON_ANODE
#define BUTTON_PIN 2
#define RED_PIN 18
#define GREEN_PIN 17
#define BLUE_PIN 19

Button btn(BUTTON_PIN,25, true); 

void setup() {

  Serial.begin(9600);

  pinMode(RED_PIN, OUTPUT);
  pinMode(GREEN_PIN, OUTPUT);
  pinMode(BLUE_PIN, OUTPUT);  
  setColor(0,0,0);

  
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
    setColor(255,0,0);    
  } else if (command == "s1") {
    setColor(0,255,0);    
  } else if (command == "s0") {
    setColor(0,0,0);    
  }
}

void setColor(int red, int green, int blue)
{
  #ifdef COMMON_ANODE
    red = 255 - red;
    green = 255 - green;
    blue = 255 - blue;
  #endif

  setColorPin(GREEN_PIN, green);
  setColorPin(RED_PIN, red);
  setColorPin(BLUE_PIN, blue);
}

void setColorPin(int pin, int val)
{
  if (val == 255) {
    digitalWrite(pin, HIGH); // This prevents the green from glowing when off.
  } else {
    analogWrite(pin, val);
  }  
}
