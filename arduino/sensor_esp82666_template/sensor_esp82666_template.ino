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
unsigned long lastTime = 0;
unsigned long timerDelay = 5000;  //5 seconds
unsigned long postDelay = 5000;   // replace with 300000 for 5 minutes

// instance of webserver listening on port 80
ESP8266WebServer server(80);

// data for identification
String name = "Wifi Lights";
String local_ip = "";

// vector of endpoints
std::vector<String> endpoints;

// data to post to server
DynamicJsonDocument doc(1024);  //allocates 1024 bytes of memory on the heap

// array for the endpoints in the POSTed json
JsonArray doc_endpoints = doc.createNestedArray("endpoints");

int bytesWritten = 0;
/* 
doc["sensor"] = "gps"; doc["time"] = 1351824120;
  JsonArray data = doc.createNestedArray("data");
  data.add(48.756080);
  data.add(2.302038);
  int bytesWritten = serializeJson(doc, json, 1024);
*/

// function prototypes
void handleNotFound();
void turnOnLED();
void turnOffLED();

void setup(void) {
  // set D0 as output pin for a green status LED
  pinMode(16, OUTPUT);

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
  doc["local_ip"] = WiFi.localIP().toString();

  // adding custom endpoints with handlers
  endpoints.push_back("/turnOnLED");
  server.on("/turnOnLED", HTTP_GET, turnOnLED);
  endpoints.push_back("/turnOffLED");
  server.on("/turnOffLED", HTTP_GET, turnOffLED);

  server.onNotFound(handleNotFound);  // unknown uri

  // creating the json for the POST to the server
  for (auto endpoint : endpoints) {
    doc_endpoints.add(endpoint);
  }

  // creating the json string
  char* json = (char*)malloc(1024);

  // write to json the data structure
  bytesWritten = serializeJson(doc, json, 1024);

  // start the server
  server.begin();
}

void loop(void) {
  /*
    At startup, while (!succesfull) post your {name, local_ip, [list of GET enpoint routes]}
    
    *on server* if local_ip exists in db, replace it with new data, else create new entry

    After startup, wait for commands from outside

    ex. of POST packet to 
  */
  // listen for http requests
  server.handleClient();

  // // do this once per 5 seconds
  // if ((millis() - lastTime) > timerDelay) {

  //   // checking to see if we are still connected to the network
  //   if (WiFi.status() == WL_CONNECTED) {

  //     // create a WifiClientSecure instance
  //     std::unique_ptr<BearSSL::WiFiClientSecure> client(new BearSSL::WiFiClientSecure);

  //     // create a httpClient
  //     HTTPClient https;

  //     // ignore SSL certificate validation
  //     client->setInsecure();

  //     // create the path for the URL
  //     String sensors_path = base_url + "/sensors";

  //     // make a GET request to the specified URL
  //     if (https.begin(*client, sensors_path.c_str())) {
  //       //Serial.print("[HTTPS] GET...\n");

  //       // send the request
  //       int httpCode = https.GET();

  //       if (httpCode > 0) {

  //         // HTTP header has been send and Server response header has been handled
  //         //Serial.printf("[HTTPS] GET... code: %d\n", httpCode);

  //         // file found at server
  //         if (httpCode == HTTP_CODE_OK || httpCode == HTTP_CODE_MOVED_PERMANENTLY) {
  //           String payload = https.getString();
  //           Serial.println(payload);

  //           // post the data to url
  //           WiFiClient clientpost;
  //           HTTPClient httpClientpost;
  //           httpClientpost.begin(clientpost, "http://192.168.0.106:5000/post");
  //           int httpCodePost = httpClientpost.POST(payload);
  //           httpClientpost.end();

  //           Serial.flush();
  //           blink_led(100);
  //         } else {
  //           Serial.printf("[HTTPS] GET... failed, error: %s\n", https.errorToString(httpCode).c_str());
  //           blink_led(500);
  //         }
  //       }


  //       https.end();
  //     } else {
  //       Serial.println("WiFi not connected");
  //     }
  //     delay(3000);
  //   }
  // }
}

void turnOnLED() {
  digitalWrite(16, HIGH);
  server.send(200);
}

void turnOffLED() {
  digitalWrite(16, LOW);
  server.send(200);
}

// Handlers
void handleNotFound() {
  server.send(404, "text/plain", "404: Not found");
}
