//+------------------------------------------------------------------+
//|                                                    MACDValue.mqh |
//|                                              Copyright 2017, DNG |
//|                                 http://www.mql5.com/ru/users/dng |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, DNG"
#property link      "http://www.mql5.com/ru/users/dng"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <Object.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMACDValue      : public CObject
  {
private:
   double            Main_Value;        //Main line value
   double            Main_Dinamic;      //Dinamics value of main lime
   double            Signal_Value;      //Signal line value
   double            Signal_Dinamic;    //Dinamics value of signal lime
   long              Deal_Ticket;       //Ticket of deal 
   
public:
                     CMACDValue(double main_value, double main_dinamic, double signal_value, double signal_dinamic, long ticket);
                    ~CMACDValue(void);
   //---
   long              GetTicket(void)         {  return Deal_Ticket;     }
   double            GetMainValue(void)      {  return Main_Value;      }
   double            GetMainDinamic(void)    {  return Main_Dinamic;    }
   double            GetSignalValue(void)    {  return Signal_Value;    }
   double            GetSignalDinamic(void)  {  return Signal_Dinamic;  }
   void              GetValues(double &main_value, double &main_dinamic, double &signal_value, double &signal_dinamic);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMACDValue::CMACDValue(double main_value,double main_dinamic,double signal_value,double signal_dinamic,long ticket)
  {
   Main_Value     =  main_value;
   Main_Dinamic   =  main_dinamic;
   Signal_Value   =  signal_value;
   Signal_Dinamic =  signal_dinamic;
   Deal_Ticket    =  ticket;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMACDValue::~CMACDValue()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMACDValue::GetValues(double &main_value,double &main_dinamic,double &signal_value,double &signal_dinamic)
  {
   main_value     =  Main_Value;
   main_dinamic   =  Main_Dinamic;
   signal_value   =  Signal_Value;
   signal_dinamic =  Signal_Dinamic;
  }
//+------------------------------------------------------------------+
