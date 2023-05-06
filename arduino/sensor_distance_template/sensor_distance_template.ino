#include <SPI.h>
#include <RF24.h>
#include <RF24Network.h>

// radio module initialization
RF24 radio(7, 8);

// network initialization
RF24Network network(radio);

// constants that will be configured as per config_sensor.py
const uint16_t this_node = 01; // octal format
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

void setup(void)
{
  Serial.begin(115200);

  pinMode(trigPin, OUTPUT); // Sets the trigPin as an Output
  pinMode(echoPin, INPUT);  // Sets the echoPin as an Input

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
  network.begin(this_node);
}

void loop()
{
  // polling the network for updates
  network.update();

  // time the messages properly
  unsigned long now = millis();

  // check if we have to send message
  if (now - last_sent >= interval)
  {
    // Calculating the distance
    calculate_distance();
    Serial.print("Distance = ");
    Serial.println(distance);

    last_sent = now;

    Serial.print(F("Sending... "));
    payload_t payload = {"Distance", distance};
    RF24NetworkHeader header(base_station);
    bool ok = network.write(header, &payload, sizeof(payload));
    Serial.println(ok ? F("ok.") : F("failed."));
  }
}