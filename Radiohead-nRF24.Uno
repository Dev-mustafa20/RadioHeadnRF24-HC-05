// Mustafa Jawad Engineer | 2022
// Through this code, you can use the nRF24 with the Arduino to send data 
// at a distance of one thousand meters 1 km, 
// the data will be provided to the Arduino through Bluetooth HC-05, 
// which in turn is paired with the Android application for instant chat via Bluetooth

#include <SPI.h>
#include <SoftwareSerial.h>
#include <RH_NRF24.h>
#include <RF24.h>

SoftwareSerial Serialb(8,9);// RX TX
char radiopacket[100]; // Allocate some space for the string
char inChar; // Where to store the character read
byte index = 0; // Index into array; where to store the character
boolean test;

 #define LED      13
/************ Radio Setup ***************/
 #define RFM24_INT     3 // Pin 3 Arduino Uno (PWM)
 #define RFM24_CS      4 // Pin 4 Arduino Uno (PWM)
 #define RFM24_RST     2 

// Singleton instance of the radio driver
 RH_NRF24 nrf24(RFM24_CS, RFM24_INT);
 RF24 radio(4,3); 
void setup() 
{
  delay(500);
  Serial.begin(115200);
  Serialb.begin(9600);
  radio.setPALevel(RF24_PA_MAX);
  radio.setDataRate(RF24_2MBPS);
  pinMode(LED, OUTPUT);     
  pinMode(RFM24_RST, OUTPUT);
  digitalWrite(RFM24_RST, LOW);
  Serial.println("Feather RFM24 RX/TX Test!");

 // manual reset
  digitalWrite(RFM24_RST, HIGH);
  delay(10);
  digitalWrite(RFM24_RST, LOW);
  delay(10);

  
  while (!Serial); 
  // wait for serial port to connect.
  if (!nrf24.init())
    Serial.println("init failed");
  // Defaults after init are 2.402 GHz (channel 2), 2Mbps, 0dBm
  if (!nrf24.setChannel(1))
    Serial.println("setChannel failed");
  if (!nrf24.setRF(RH_NRF24::DataRate2Mbps, RH_NRF24::TransmitPower0dBm))
    Serial.println("setRF failed");   

  delay(500); 
}

void loop()
{
  if(nrf24.waitAvailableTimeout(200)) {
    // Should be a message for us now   
    uint8_t buf[RH_NRF24_MAX_MESSAGE_LEN];
    uint8_t len = sizeof(buf);
    
   if(!nrf24.recv(buf, &len)) {
      Serial.println("Receive failed");
      return;
     }
     digitalWrite(LED, HIGH);
     nrf24.printBuffer("Received: ", buf, len);
     buf[len] = 0;
     
     Serial.print("Message: "); Serial.println((char*)buf);
     Serialb.println((char*)buf);
     digitalWrite(LED, LOW);
  }
  
  while(Serialb.available() > 0) // Don't read unless there you know there is data
  {
      if(index < 99) // One less than the size of the array
      {
          inChar = Serialb.read(); // Read a character
          radiopacket[index] = inChar; // Store it
          index++; // Increment where to write next
          radiopacket[index] = '\0'; // Null terminate the string
      }
      test=true;
  }
    
  delay(500);
  
  if(index>0 && test==true){
    Serial.print("Sending "); Serial.println(radiopacket);
    nrf24.send((uint8_t *)radiopacket,strlen(radiopacket));
    nrf24.waitPacketSent();
       
   if(inChar == '1')            
      digitalWrite(13, HIGH);  
    else if(inChar == '0')      
      digitalWrite(13, LOW);   
      test=false;   
 index=0;    
}     
}
