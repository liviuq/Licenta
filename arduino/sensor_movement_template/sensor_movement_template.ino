#include <SPI.h>
#include <RF24.h>
#include <RF24Network.h>

// radio module initialization
RF24 radio(7, 8);

// network initialization
RF24Network network(radio);

// constants that will be configured as per config_sensor.py
const uint16_t this_node = 02; // octal format
const uint16_t base_station = 00;

// interval to send data
const unsigned long interval = 2000;

// time spent after last send
unsigned long last_sent;
unsigned long packets_sent;

// defining the payload
struct payload_t
{
  unsigned char type[16];
  unsigned long value;
};

// movement sensor configuration
const int outPin = 2;       // the pin that OUTPUT pin of sensor is connected to
int pinStateCurrent = LOW;  // current state of pin
int pinStatePrevious = LOW; // previous state of pin

void setup(void)
{
  // begin serial communication
  Serial.begin(115200);

  // movement sensor pin
  pinMode(outPin, INPUT);

  while (!Serial)
  {
  } // required by some boards

  if (!radio.begin())
  {
    Serial.println(F("Radio hardware not responding!"));
    while (1)
    {
      // flash in-built LED once per 500ms
      digitalWrite(LED_BUILTIN, HIGH);
      delay(500);
      digitalWrite(LED_BUILTIN, LOW);
      delay(500);
    }
  }

  // setting the channel and current node
  radio.setChannel(90);
  network.begin(this_node);
}

void loop()
{
  // value to be sent over the air
  unsigned long isMoving = 1;

  // polling the network for updates
  network.update();

  // time the messages properly
  unsigned long now = millis();

  // check if we have to send message
  if (now - last_sent >= interval)
  {
    // movement sensor checking to see
    pinStatePrevious = pinStateCurrent;
    pinStateCurrent = digitalRead(outPin);

    if (pinStatePrevious == LOW && pinStateCurrent == HIGH)
    {
      // pin state change: LOW -> HIGH
      Serial.println("Motion detected!");
      isMoving = 0;
    }
    else
    {
      if (pinStatePrevious == HIGH && pinStateCurrent == LOW)
      {
        // pin state change: HIGH -> LOW
        Serial.println("Motion stopped!");
        isMoving = 1;
      }
    }

    last_sent = now;

    Serial.print(F("Sending... "));
    payload_t payload = {"Motion", isMoving};
    RF24NetworkHeader header(base_station);
    bool ok = network.write(header, &payload, sizeof(payload));
    Serial.println(ok ? F("ok.") : F("failed."));
  }
}