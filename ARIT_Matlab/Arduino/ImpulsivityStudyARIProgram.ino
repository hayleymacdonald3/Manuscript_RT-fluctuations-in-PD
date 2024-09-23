//Can speed up pin reads with direct manipulation (from ~.35ms to .0125) can also read/write to pins at the same time
const float matlabTimingFudge = 1900; //Compenstates for time it takes matlab to read NI device (~1.9ms)

// Pin assignments
const int leftSwitchDown = 10; //OUTPUT: to NI device telling state of left switch
const int rightSwitchDown = 9; //OUTPUT: to NI device telling state of right switch
const int signalPin = 11; //OUTPUT: sends signal to signal telling it to start recording
const int tmsTriggerPin = 2; //OUTPUT: sends signal to TMS for stimulus
const int tmsCondPin = 4; //OUTPUT: sends signal to delay box and TMS for conditioning stimulus

const int leftSwitchPin = 6; //INPUT: From left switch
const int rightSwitchPin = 8; //INPUT: From right switch

// Constants and test variables
const int delayTime = 2000;
const int trialMaxTime = 1000;
const int debounceThreshold = 350;
int incomingByte = 0;

int tmsDelay = 65535;
byte tmsType = 0; //Trial types: 0 (no stim), 1 (no conditioning stim, 2 (conditioning stim)
int leftLiftTime = -1;
int rightLiftTime = -1;

unsigned long startMillis = 0;
unsigned long currentMillis = 0;
unsigned long debounceStartTime = 0;
unsigned long debounceTime = 0;

boolean trialGoing = true;
boolean barsRising = true;
boolean stillWaitingForTMS = true;
boolean waitingForSwitchesDown = true;

void setup() 
{
  //Setup outputs
  pinMode(13, OUTPUT);
  pinMode(tmsTriggerPin, OUTPUT);
  pinMode(tmsCondPin, OUTPUT);   
  pinMode(signalPin, OUTPUT); 
  pinMode(leftSwitchDown, OUTPUT);
  pinMode(rightSwitchDown, OUTPUT);
  digitalWrite(tmsTriggerPin, LOW);
  digitalWrite(tmsCondPin, LOW);
  digitalWrite(leftSwitchDown, LOW);
  digitalWrite(rightSwitchDown, LOW);
  digitalWrite(signalPin, LOW);
  
  //Setup inputs
  pinMode(leftSwitchPin, INPUT);
  pinMode(rightSwitchPin, INPUT);
  //Activate internal pullup resistors
  digitalWrite(leftSwitchPin, HIGH); 
  digitalWrite(rightSwitchPin, HIGH);
  randomSeed(analogRead(0));
}

void loop() 
{
  while(trialGoing) {
    // Recieves Delays from MatLab
    Serial.begin(9600);
    establishContact();
    Serial.println("Ready to recieve delays");
    while (Serial.available() == 0) {
      delay(2);
    }
    tmsDelay = Serial.parseInt();
    Serial.print("TMS Delay: ");
    Serial.println(tmsDelay);
    while (Serial.available() == 0) {
      delay(2);
    }
    tmsType = Serial.parseInt();
    Serial.print("TMS Type: ");
    switch (tmsType) {
      case 0:
        Serial.println("No Stim");
        break;
      case 1:
        Serial.println("No Cond Stim");
        break;
      case 2:
        Serial.println("Cond Stim");
        break;
    }
    Serial.end();
    
    if (tmsType == 0) {
      stillWaitingForTMS = false;
    } else {
      stillWaitingForTMS = true;
    }
    
    // Wait for both switches to be down before beginning trial
    waitingForSwitchesDown = true;
    debounceTime = 0;
    debounceStartTime = 0;
    while(waitingForSwitchesDown) {
      if (digitalRead(leftSwitchPin) == LOW && digitalRead(rightSwitchPin) == LOW) {
        if (debounceStartTime == 0) {
          debounceStartTime = millis();
        }
        debounceTime = millis() - debounceStartTime;
      } else {
        debounceTime = 0;
        debounceStartTime = 0;
      }
      if (debounceTime >= debounceThreshold) {
        waitingForSwitchesDown = false;
      }
      delay(1);
    }
      
    delay(random(400 - debounceThreshold,900 - debounceThreshold)); //Random delay before trial begins
    digitalWrite(13, HIGH); //Turn on status LED
    ////////////////////////////Start Trial//////////////////////////
    
    digitalWrite(leftSwitchDown, HIGH);
    digitalWrite(rightSwitchDown, HIGH); //Tell Matlab to start raising the on screen bars
    delayMicroseconds(matlabTimingFudge);
    startMillis = millis();
    digitalWrite(signalPin, HIGH); 
    // Figure out why trigger signal when reset
    while(barsRising || stillWaitingForTMS) {
      currentMillis  = millis();
      if(currentMillis - startMillis >= tmsDelay) {
        switch (tmsType) {
          case 0:
            break;
          case 1:
            digitalWrite(tmsTriggerPin, HIGH);
            stillWaitingForTMS = false;
            break;
          case 2:
            digitalWrite(tmsCondPin, HIGH);
            digitalWrite(tmsTriggerPin, HIGH);
            stillWaitingForTMS = false;
            break;
        }
      } 
      if(leftLiftTime < 0 && digitalRead(leftSwitchPin) == HIGH) {
        leftLiftTime = currentMillis - startMillis;
        digitalWrite(leftSwitchDown, LOW);
      }
      if(rightLiftTime < 0 && digitalRead(rightSwitchPin) == HIGH) {
        rightLiftTime = currentMillis - startMillis;
        digitalWrite(rightSwitchDown, LOW);
      }
      if((currentMillis - startMillis >= trialMaxTime) || (leftLiftTime > 0 && rightLiftTime > 0)) {
        digitalWrite(rightSwitchDown, LOW);
        digitalWrite(leftSwitchDown, LOW); //Tell Matlab to stop raising bars and prepare to receive lift times
        //digitalWrite(signalPin, LOW);
        barsRising = false;
      }
    }

    Serial.begin(9600);
    //Serial.print("Left Lift Time: ");
    Serial.println(leftLiftTime);
    //Serial.print("Right Lift Time: ");
    Serial.println(rightLiftTime);
    Serial.end();
    trialGoing = false;
    digitalWrite(13, LOW); //Turn off status LED
  }
  //Reset Trial
  resetState();
}

 void establishContact() {
   //Waiting for byte from Matlab before continuing
   while (Serial.available() <= 0) {
     delay(300);
   }
   while( Serial.read() != -1 ); //Reads data until empty to ensure buffer is flushed
 }
 
 void resetState() {
  digitalWrite(tmsTriggerPin, LOW);
  digitalWrite(tmsCondPin, LOW);
  digitalWrite(leftSwitchDown, LOW);
  digitalWrite(rightSwitchDown, LOW);
  digitalWrite(signalPin, LOW); 
  
  incomingByte = 0;
  tmsDelay = 65535;
  tmsType = 0; //Trial types: 0 (no stim), 1 (no conditioning stim, 2 (conditioning stim)
  leftLiftTime = -1;
  rightLiftTime = -1;
  startMillis = 0;
  currentMillis = 0;
  trialGoing = true;
  barsRising = true;
  stillWaitingForTMS = true;
  waitingForSwitchesDown = true;
}



