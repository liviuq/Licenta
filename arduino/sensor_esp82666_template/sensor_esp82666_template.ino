#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <ESP8266WebServer.h>
#include <WiFiClient.h>               //for HTTP
#include <WiFiClientSecureBearSSL.h>  //for HTTPS
#include <ArduinoJson.h>

#ifndef STASSID
#define STASSID "GoodFellas"
#define STAPSK "goodfellas_123"
#endif

// WIFI info
const char* ssid = STASSID;
const char* password = STAPSK;

// server hostname
String base_url = "https://andr3w.ddns.net";

// timed 5 second delay
unsigned long previousMillis = 0;
unsigned long timerDelay = 5000;  //5 seconds
unsigned long postDelay = 20000;  // replace with 300000 for 5 minutes

// instance of webserver listening on port 80
ESP8266WebServer server(80);

// value for the secure mode
bool secure;

// data for identification
String name = "Lamp controller";
String local_ip = "";

// vector of endpoints
std::vector<String> endpoints;

// data to post to server
DynamicJsonDocument doc(1024);  //allocates 1024 bytes of memory on the heap

// array for the endpoints in the POSTed json
JsonArray doc_endpoints = doc.createNestedArray("endpoints");
char* json = (char*)malloc(1024);

int bytesWritten = 0;

// function prototypes
void handleNotFound();
void turnOnLED();
void turnOffLED();

int lampPin = 16;


void setup(void) {
  // set D0 as output pin for a green status LED
  pinMode(lampPin, OUTPUT);

  // begin serial communication on 115200 baud (14.4 KB/s)
  Serial.begin(115200);

  // station mode(module connects to an AP)
  WiFi.mode(WIFI_STA);

  // SSID&PSK
  WiFi.begin(ssid, password);

  // Wait for connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  // debug information
  Serial.println("");
  Serial.print("Connected to ");
  Serial.println(ssid);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  // populate json
  doc["name"] = name.c_str();
  doc["ip"] = WiFi.localIP().toString();

  // adding custom endpoints with handlers
  endpoints.push_back("turnOnLamp");
  server.on("/turnOnLamp", HTTP_GET, turnOnLamp);
  endpoints.push_back("turnOffLamp");
  server.on("/turnOffLamp", HTTP_GET, turnOffLamp);
  endpoints.push_back("intruderLampAlert");
  server.on("/intruderLampAlert", HTTP_GET, intruderLampAlert);

  server.onNotFound(handleNotFound);  // unknown uri



  // creating the json for the POST to the server
  for (auto endpoint : endpoints) {
    doc_endpoints.add(endpoint);
  }

  // setting the json string to 0
  memset(json, 0, 1024);

  // write to json the data structure
  bytesWritten = serializeJson(doc, json, 1024);
  Serial.println("Final json: " + String(json));

  // create a WifiClientSecure instance
  std::unique_ptr<BearSSL::WiFiClientSecure> client(new BearSSL::WiFiClientSecure);
  HTTPClient https;
  client->setInsecure();
  String sensors_path = base_url + "/advanced/";
  if (https.begin(*client, sensors_path.c_str())) {
    int httpCode = https.PUT(json);
  }
  // start the server
  server.begin();
}

void loop(void) {
  /*
    DONE At startup, while (!succesfull) post your {name, local_ip, [list of GET enpoint routes]}
    
    DONE *on server* if local_ip exists in db, replace it with new data, else create new entry

    DONE After startup, wait for commands from outside

    ex. of POST packet to 
  */

  // handle client even if not in 10 second period
  server.handleClient();

  // get the current time
  unsigned long currentMillis = millis();

  // check if 10s have passed
  if (currentMillis - previousMillis >= postDelay) {
    // post data
    postData();
    secure = getSecureMode();

    // Update the previousMillis variable to the current time
    previousMillis = currentMillis;
  }
}

void turnOnLamp() {
  digitalWrite(lampPin, HIGH);
  server.send(200, "text/plain", "Lamp is on");
}

void turnOffLamp() {
  digitalWrite(lampPin, LOW);
  server.send(200, "text/plain", "Lamp is off");
}

void intruderLampAlert() {
  server.send(200, "text/plain", "Intruder time!");
  for (int i = 0; i < 100; i++) {
    digitalWrite(lampPin, HIGH);
    delay(50);
    digitalWrite(lampPin, LOW);
    delay(50);
  }
}

// Handlers
void handleNotFound() {
  server.send(404, "text/plain", "404: Not found");
}

void postData() {
  // write to json the data structure
  bytesWritten = serializeJson(doc, json, 1024);
  //Serial.println("Final json: " + String(json));

  // create a WifiClientSecure instance
  std::unique_ptr<BearSSL::WiFiClientSecure> client(new BearSSL::WiFiClientSecure);
  HTTPClient https;
  client->setInsecure();
  String sensors_path = base_url + "/advanced/";
  if (https.begin(*client, sensors_path.c_str())) {
    int httpCode = https.PUT(json);
  }
}

bool getSecureMode() {
  std::unique_ptr<BearSSL::WiFiClientSecure> client(new BearSSL::WiFiClientSecure);
  HTTPClient https;
  client->setInsecure();
  String sensors_path = base_url + "/secure";
  if (https.begin(*client, sensors_path.c_str())) {
    int httpCode = https.GET();
    if (httpCode > 0) {
      String responseBody = https.getString();

      // Parse the JSON response
      StaticJsonDocument<200> doc;
      DeserializationError error = deserializeJson(doc, responseBody);
      if (error) {
        Serial.print("Error parsing JSON: ");
        Serial.println(error.c_str());
      } else {
        // Extract the value from the "value" field
        const char* value = doc["value"];

        // Print the extracted value
        Serial.print("Value: ");
        Serial.println(value);

        if( strcmp_P(value, "true") == 0) return true;
        else return false;
      }
    }
    https.end();
  }

  return false;
}