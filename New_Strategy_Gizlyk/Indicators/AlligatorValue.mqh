//+------------------------------------------------------------------+
//|                                               AlligatorValue.mqh |
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
class CAlligatorValue      : public CObject
  {
private:
   double            JAW_Value;        //Alligator value
   double            JAW_Dinamic;      //Dinamics value of Alligator
   double            TEETH_Value;      //Teeth value
   double            TEETH_Dinamic;    //Dinamics value of Teeth
   double            LIPS_Value;       //Lips value
   double            LIPS_Dinamic;     //Dinamics value of Lips
   long              Deal_Ticket;      //Ticket of deal 
   
public:
                     CAlligatorValue(double jaw_value, double jaw_dinamic, double teeth_value, double teeth_dinamic, double lips_value, double lips_dinamic, long ticket);
                    ~CAlligatorValue(void);
   //---
   long              GetTicket(void)         {  return Deal_Ticket;     }
   double            GetJAWValue(void)       {  return JAW_Value;       }
   double            GetJAWDinamic(void)     {  return JAW_Dinamic;     }
   double            GetTEETHValue(void)     {  return TEETH_Value;     }
   double            GetTEETHDinamic(void)   {  return TEETH_Dinamic;   }
   double            GetLIPSValue(void)      {  return LIPS_Value;      }
   double            GetLIPSDinamic(void)    {  return LIPS_Dinamic;    }
   void              GetValues(double &jaw_value, double &jaw_dinamic, double &teeth_value, double &teeth_dinamic, double &lips_value, double &lips_dinamic);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAlligatorValue::CAlligatorValue(double jaw_value,double jaw_dinamic,double teeth_value,double teeth_dinamic,double lips_value,double lips_dinamic,long ticket)
  {
   JAW_Value      =  jaw_value;
   JAW_Dinamic    =  jaw_dinamic;
   TEETH_Value    =  teeth_value;
   TEETH_Dinamic  =  teeth_dinamic;
   LIPS_Value     =  lips_value;
   LIPS_Dinamic   =  lips_dinamic;
   Deal_Ticket    =  ticket;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAlligatorValue::~CAlligatorValue()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAlligatorValue::GetValues(double &jaw_value,double &jaw_dinamic,double &teeth_value,double &teeth_dinamic,double &lips_value,double &lips_dinamic)
  {
   jaw_value      =  JAW_Value;
   jaw_dinamic    =  JAW_Dinamic;
   teeth_value    =  TEETH_Value;
   teeth_dinamic  =  TEETH_Dinamic;
   lips_value     =  LIPS_Value;
   lips_dinamic   =  LIPS_Dinamic;
  }
//+------------------------------------------------------------------+
