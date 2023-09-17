//+------------------------------------------------------------------+
//|                                                        Value.mqh |
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
class CValue      : public CObject
  {
private:
   double            Value;            //Indicator's value
   double            Dinamic;          //Dinamics value of indicator
   long              Deal_Ticket;      //Ticket of deal 
   
public:
                     CValue(double value, double dinamic, long ticket);
                    ~CValue(void);
   //---
   long              GetTicket(void)   {  return Deal_Ticket;  }
   double            GetValue(void)    {  return Value;        }
   double            GetDinamic(void)  {  return Dinamic;      }
   void              GetValues(double &value, double &dinamic);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CValue::CValue(double value, double dinamic, long ticket)
  {
   Value       =  value;
   Dinamic     =  dinamic;
   Deal_Ticket =  ticket;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CValue::~CValue()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CValue::GetValues(double &value,double &dinamic)
  {
   value    =  Value;
   dinamic  =  Dinamic;
  }
//+------------------------------------------------------------------+
