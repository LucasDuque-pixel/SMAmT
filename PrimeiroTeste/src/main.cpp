#include <WiFi.h>
#include <HTTPClient.h>
#include <DHT.h>
#include <ArduinoJson.h>
#include <driver/i2s.h>
#include <string>

const char* ssid = "AndroidLucas";
const char* password = "kags1111";
const char* serverName = "https://smamt.onrender.com/dados"; 

#define DHTPIN 4 
#define DHTTYPE DHT11 
DHT dht(DHTPIN, DHTTYPE);

const int sensor = 32;
bool estado = 0;

void setup() {
  Serial.begin(115200);
  dht.begin();
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();

  pinMode(sensor, INPUT);
 
  delay(100);

  WiFi.begin(ssid, password);
  Serial.print("Conectando ao WiFi");
  while(WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConectado à rede WiFi com sucesso!");
}

void loop() {
  unsigned ruido=0;
  for (unsigned indice=0; indice<50; indice++){
    delay(100);
    if (digitalRead(sensor) == HIGH){//Se o sensor detectar o ruído seu nivel lógico será 1, ou seja, HIGH. Então ele fará a ação.
      ruido+=1;
    }
  }

  float temperatura = dht.readTemperature();
  float umidade = dht.readHumidity();

  if (isnan(temperatura) || isnan(umidade)) {
    Serial.println("Falha ao ler do sensor DHT!");
    return;
  }

  if(WiFi.status() == WL_CONNECTED){
    HTTPClient http;
    http.begin(serverName);
    http.addHeader("Content-Type", "application/json");

    JsonDocument doc;
    doc["temperatura"] = temperatura;
    doc["umidade"] = umidade;
    doc["ruido"] = ruido;
    
    String requestBody;
    serializeJson(doc, requestBody);

    int httpResponseCode = http.POST(requestBody);

    if (httpResponseCode > 0) {
      Serial.print("Código de resposta HTTP: ");
      Serial.println(httpResponseCode);
    } else {
      Serial.print("Código de erro na requisição: ");
      Serial.println(httpResponseCode);
    }
    
    http.end();
  } else {
    Serial.println("WiFi Desconectado.");
  }
}