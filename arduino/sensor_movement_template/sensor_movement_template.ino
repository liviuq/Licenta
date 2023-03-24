#include <SPI.h>
#include <RF24.h>
#include <RF24Network.h>
 

// RADIO MODULE
RF24 radio(7, 8);  // nRF24L01(+) radio attached using Getting Started board
 
RF24Network network(radio);  // Network uses that radio
 
const uint16_t this_node = 02;   // Address of our node in Octal format
const uint16_t base_station = 00;  // Address of the other node in Octal format
 
const unsigned long interval = 2000;  // How often (in ms) to send 'hello world' to the other unit
 
unsigned long last_sent;     // When did we last send?
unsigned long packets_sent;  // How many have we sent already
 
 
struct payload_t
{  
  // Structure of our payload
  unsigned char type;
  unsigned long value;
};
 

// MOVEMENT SENSOR

const int outPin = 2;   // the pin that OUTPUT pin of sensor is connected to
int pinStateCurrent   = LOW; // current state of pin
int pinStatePrevious  = LOW; // previous state of pin


void setup(void)
{
  Serial.begin(115200);

  // Movement sensor pin
  pinMode(outPin, INPUT);
    
  while (!Serial)
  {
    // some boards need this because of native USB capability
  }
 
  if (!radio.begin())
  {
    Serial.println(F("Radio hardware not responding!"));
    while (1)
    {
      // Flash in-built LED once per 500ms        
      digitalWrite(LED_BUILTIN, HIGH);
      delay(500);
      digitalWrite(LED_BUILTIN, LOW);
      delay(500);           
    }
  }

  radio.setChannel(90);
  network.begin(/*node address*/ this_node);
}
 
void loop()
{
  // Value to be sent over the air
  unsigned long isMoving = 0;

  network.update();  // Check the network regularly
 
  unsigned long now = millis(); // Timing the sending intervals
 
  // If it's time to send a message, send it!
  if (now - last_sent >= interval) 
  {
    pinStatePrevious = pinStateCurrent; // store old state
    pinStateCurrent = digitalRead(outPin);   // read new state

    if (pinStatePrevious == LOW && pinStateCurrent == HIGH)
    {  
      // pin state change: LOW -> HIGH
      Serial.println("Motion detected!");
      isMoving = 1;
    }
    else
    {
      if (pinStatePrevious == HIGH && pinStateCurrent == LOW)
      {   
        // pin state change: HIGH -> LOW
        Serial.println("Motion stopped!");
        isMoving = 0;
      }
    }
  

    last_sent = now;
 
    Serial.print(F("Sending... "));
    payload_t payload = { 'M', isMoving };
    RF24NetworkHeader header(/*to node*/ base_station);
    bool ok = network.write(header, &payload, sizeof(payload));
    Serial.println(ok ? F("ok.") : F("failed."));    
  }
}