#include <SPI.h>
#include <RF24.h>
#include <RF24Network.h>
 

// RADIO MODULE
RF24 radio(7, 8);  // nRF24L01(+) radio attached using Getting Started board
 
RF24Network network(radio);  // Network uses that radio
 
const uint16_t this_node = 01;   // Address of our node in Octal format
const uint16_t base_station = 00;  // Address of the other node in Octal format
 
const unsigned long interval = 2000;  // How often (in ms) to send 'hello world' to the other unit
 
unsigned long last_sent;     // When did we last send?
unsigned long packets_sent;  // How many have we sent already
 
 
struct payload_t {  // Structure of our payload
  unsigned char type;
  unsigned long value;
};
 

// DISTANCE SENSOR
const int trigPin = 4;
const int echoPin = 3;
long duration;
unsigned long distance;

void calculate_distance()
{
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  // Sets the trigPin on HIGH state for 10 micro seconds
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  // Reads the echoPin, returns the sound wave travel time in microseconds
  duration = pulseIn(echoPin, HIGH);
  // Calculating the distance
  distance = duration * 0.034 / 2;
}


void setup(void) {
  Serial.begin(115200);

  pinMode(trigPin, OUTPUT); // Sets the trigPin as an Output
  pinMode(echoPin, INPUT); // Sets the echoPin as an Input
    
  while (!Serial) {
    // some boards need this because of native USB capability
  }
  Serial.println(F("RF24Network/examples/helloworld_tx/"));
 
  if (!radio.begin()) {
    Serial.println(F("Radio hardware not responding!"));
    while (1) {
      /*
        Flash in-built LED once per 500ms        
      */
    digitalWrite(LED_BUILTIN, HIGH);
    delay(500);
    digitalWrite(LED_BUILTIN, LOW);
    delay(500);           
    }
  }
  radio.setChannel(90);
  network.begin(/*node address*/ this_node);
}
 
void loop() {

  network.update();  // Check the network regularly
 
  unsigned long now = millis();
 
  // If it's time to send a message, send it!
  if (now - last_sent >= interval) {
    //Calculating the distance
    calculate_distance();
    Serial.print("Distance = ");
    Serial.println(distance);
  
    last_sent = now;
 
    Serial.print(F("Sending... "));
    payload_t payload = { 'D', distance };
    RF24NetworkHeader header(/*to node*/ base_station);
    bool ok = network.write(header, &payload, sizeof(payload));
    Serial.println(ok ? F("ok.") : F("failed."));    
  }
}