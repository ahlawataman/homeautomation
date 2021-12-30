#include <WiFi.h>
#include <FirebaseESP32.h>
#include "DHT.h"
#define DHTPIN 12
#define DHTTYPE DHT11
const int flamePin = 14;
int Flame = HIGH;
  
DHT dht(DHTPIN, DHTTYPE);

#define FIREBASE_HOST "ENTER_YOURS"
#define FIREBASE_AUTH "ENTER_YOURS"
#define WIFI_SSID "Ahlawat 2.4Ghz"
#define WIFI_PASSWORD "temp1234"

//Define FirebaseESP8266 data object
FirebaseData firebaseData;

FirebaseJson json;

void printResult(FirebaseData &data);

void setup()
{
  pinMode(13,OUTPUT);
  pinMode(27,OUTPUT);
  pinMode(flamePin, INPUT);
  Serial.begin(115200);
  dht.begin();

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);

  //Set database read timeout to 1 minute (max 15 minutes)
  Firebase.setReadTimeout(firebaseData, 1000 * 60);
  //tiny, small, medium, large and unlimited.
  //Size and its write timeout e.g. tiny (1s), small (10s), medium (30s) and large (60s).
  Firebase.setwriteSizeLimit(firebaseData, "tiny");
  Firebase.setBool(firebaseData,"/light",false);
  Firebase.setBool(firebaseData,"/fan",false);
}

void loop()
{
  led1();
  delay(100);
  th();
  flame();
  motor();
  
}

void led1(){
  Firebase.getBool(firebaseData,"/light");
  if(firebaseData.boolData()==true)
  {
    digitalWrite(13,HIGH);
  }
  else
  {
    digitalWrite(13,LOW);
  }
  }


 void th(){
  float h = dht.readHumidity();
  float t = dht.readTemperature();
  Firebase.setFloat(firebaseData,"/humidity",h);
  Firebase.setFloat(firebaseData,"/temperature",t);
  }

 void flame(){
  Flame = digitalRead(flamePin);
  if (Flame== LOW)
  {
   Firebase.setInt(firebaseData,"/fire",1);
  }
  else
  {
   Firebase.setInt(firebaseData,"/fire",0);
  }
  }

 void motor(){
  Firebase.getBool(firebaseData,"/fan");
  if(firebaseData.boolData()==true)
   {
    digitalWrite(27,HIGH);
  }
  else
  {
    digitalWrite(27,LOW);
  }
  }
