#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecureBearSSL.h>  //for HTTPS
#include <Arduino_JSON.h>

#ifndef STASSID
#define STASSID "GoodFellas"
#define STAPSK "goodfellas_123"
#endif

const char* ssid = STASSID;
const char* password = STAPSK;
String server = "https://andr3w.ddns.net";

unsigned long lastTime = 0;
unsigned long timerDelay = 5000;  //5 seconds

void setup(void) {
  pinMode(16, OUTPUT);
  // begin serial communication on 115200 baud (14.4 KB/s)
  Serial.begin(115200);

  // station mode(module connects to an AP)
  WiFi.mode(WIFI_STA);

  // SSID&PSK
  WiFi.begin(ssid, password);
  Serial.println("");

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
}

void loop(void) {

  // do this once per 5 seconds
  if ((millis() - lastTime) > timerDelay) {

    // checking to see if we are still connected to the network
    if (WiFi.status() == WL_CONNECTED) {

      WiFiClient clientpost;
      HTTPClient http;

      // create a WifiClientSecure instance
      std::unique_ptr<BearSSL::WiFiClientSecure> client(new BearSSL::WiFiClientSecure);

      // create a httpClient
      HTTPClient https;

      // ignore SSL certificate validation
      client->setInsecure();

      // create the path for the URL
      String sensors_path = server + "/sensors";

      // make a GET request to the specified URL
      if (https.begin(*client, sensors_path.c_str())) {
        //Serial.print("[HTTPS] GET...\n");

        // send the request
        int httpCode = https.GET();

        if (httpCode > 0) {

          // HTTP header has been send and Server response header has been handled
          //Serial.printf("[HTTPS] GET... code: %d\n", httpCode);

          // file found at server
          if (httpCode == HTTP_CODE_OK || httpCode == HTTP_CODE_MOVED_PERMANENTLY) {
            String payload = https.getString();
            http.addHeader("Content-Type", "application/json");
            http.begin(clientpost, "http://192.168.0.106:5000/post");
            httpCode = http.POST(payload);
            Serial.println(payload);
            Serial.flush();
            blink_led(100);
          } else {
            Serial.printf("[HTTPS] GET... failed, error: %s\n", https.errorToString(httpCode).c_str());
            blink_led(500);
          }
        }


        https.end();
      } else {
        Serial.println("WiFi not connected");
      }
      delay(3000);
    }
  }
}

void blink_led(int duration) {
  digitalWrite(16, HIGH);
  delay(duration);
  digitalWrite(16, LOW);
  delay(duration);
}
