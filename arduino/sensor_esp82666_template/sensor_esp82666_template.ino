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
String name = "Green LED controller";
String local_ip = "";

// vector of endpoints
std::vector<String> endpoints;

// data to post to server
DynamicJsonDocument doc(1024);  //allocates 1024 bytes of memory on the heap

// array for the endpoints in the POSTed json
JsonArray doc_endpoints = doc.createNestedArray("endpoints");

int bytesWritten = 0;

// function prototypes
void handleNotFound();
void turnOnLED();
void turnOffLED();

int ledPin = 16;
int dotDelay = 50;
//For letters
char* letters[] = {
  ".-", "-...", "-.-.", "-..", ".", "..-.", "--.", "....", "..",    // A-I
  ".---", "-.-", ".-..", "--", "-.", "---", ".--.", "--.-", ".-.",  // J-R
  "...", "-", "..-", "...-", ".--", "-..-", "-.--", "--.."          // S-Z
};

//For Numbers
char* numbers[] = {
  "-----", ".----", "..---", "...--", "....-", ".....",
  "-....", "--...", "---..", "----."
};

void setup(void) {
  // set D0 as output pin for a green status LED
  pinMode(ledPin, OUTPUT);

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
  endpoints.push_back("turnOnLED");
  server.on("/turnOnLED", HTTP_GET, turnOnLED);
  endpoints.push_back("turnOffLED");
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
    At startup, while (!succesfull) post your {name, local_ip, [list of GET enpoint routes]}
    
    *on server* if local_ip exists in db, replace it with new data, else create new entry

    After startup, wait for commands from outside

    ex. of POST packet to 
  */
  // listen for http requests
  server.handleClient();
}

void turnOnLED() {
  //digitalWrite(ledPin, HIGH);
  String bobi = "bobi e un prieten bun";
  server.send(200, "text/plain", "LED is on");
  for (auto ch : bobi) {
    if (ch >= 'a' && ch <= 'z') {
      flashSequence(letters[ch - 'a']);
    } else if (ch >= 'A' && ch <= 'Z') {
      flashSequence(letters[ch - 'A']);
    } else if (ch >= '0' && ch <= '9') {
      flashSequence(numbers[ch - '0']);
    } else if (ch == ' ') {
      delay(dotDelay * 4);
    }
  }
}

void turnOffLED() {
  digitalWrite(ledPin, LOW);
  server.send(200, "text/plain", "LED is off");
}

// Handlers
void handleNotFound() {
  server.send(404, "text/plain", "404: Not found");
}

void flashSequence(char* sequence) {
  int i = 0;
  while (sequence[i] != NULL) {
    flashDotOrDash(sequence[i]);
    i++;
  }
  delay(dotDelay * 3);
}


void flashDotOrDash(char dotOrDash) {
  digitalWrite(ledPin, HIGH);
  if (dotOrDash == '.') {
    delay(dotDelay);
  } else  // must be a -
  {
    delay(dotDelay * 3);
  }
  digitalWrite(ledPin, LOW);
  delay(dotDelay);
}
