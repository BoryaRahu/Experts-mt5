//+------------------------------------------------------------------+
//|                                       NSATS (North Sulawesi ATS) |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
#include "Volume\VolumeHeader.mq5";
class Volume {
 private:
   int               volume;                    // 1 = high volume, 2 = low volume, 0 = default
   void              checkVolume();             //return output from selected strategies
   void              setVolume(int volume);
 public:
                     Volume(void);
   int               getVolume();
                    ~Volume(void);
};
//+------------------------------------------------------------------+
//| Constructor automatically check volume                           |
//+------------------------------------------------------------------+
Volume::Volume(void) {
   setVolume(0);
   checkVolume();
}
//+------------------------------------------------------------------+
//| Destructor set volume to 0 (default)                             |
//+------------------------------------------------------------------+
Volume::~Volume(void) {
   setVolume(0);
}
//+------------------------------------------------------------------+
//| setVolume() set 3 value and prevent others                       |
//+------------------------------------------------------------------+
void Volume::setVolume(int volume) {
   if(volume == 1 || volume == 2 || volume == 0) {
      this.volume = volume;
   } else {
      Print("Invalid Volume Input");
   }
}
//+------------------------------------------------------------------+
//| checkVolume() check confirmation from volume type indicators     |
//+------------------------------------------------------------------+
void Volume::checkVolume(void) {
   setVolume(1);
}
//+------------------------------------------------------------------+
//| getVolume() return 1 or 2 as volume signal                       |
//+------------------------------------------------------------------+
int Volume::getVolume(void) {
   if(volume == 1 || volume == 2) {
      return volume;
   } else if(volume == 0) {
      Print("No Volume found");
      return -1;
   } else {
      Print("Invalid Volume");
      return -1;
   }
}
//+------------------------------------------------------------------+