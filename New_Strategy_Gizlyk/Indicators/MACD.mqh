//+------------------------------------------------------------------+
//|                                                         MACD.mqh |
//|                                              Copyright 2017, DNG |
//|                                 http://www.mql5.com/ru/users/dng |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, DNG"
#property link      "http://www.mql5.com/ru/users/dng"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "MACDValue.mqh"
#include <Arrays\\ArrayObj.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMACD
  {
private:
   CArrayObj        *IndicatorValues;     //Array of indicator's values
   
   int               i_handle;            //Handle of indicator
   string            s_Name;
   string            GetIndicatorName(int handle);
   
public:
                     CMACD(string symbol, ENUM_TIMEFRAMES timeframe, uint fast_ema, uint slow_ema, uint signal, ENUM_APPLIED_PRICE applied_price, string name);
                    ~CMACD();
   //---
   bool              SaveNewValues(long ticket);
   //---
   double            GetMainValue(long ticket);
   double            GetMainDinamic(long ticket);
   double            GetSignalValue(long ticket);
   double            GetSignalDinamic(long ticket);
   bool              GetValues(long ticket, double &main_value, double &main_dinamic, double &signal_value, double &signal_dinamic);
   int               GetIndyHandle(void)  {  return i_handle;  }
   string            GetName(void)        {  return (s_Name!= NULL ? s_Name : "ADX");       }
                 
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMACD::CMACD(string symbol, ENUM_TIMEFRAMES timeframe, uint fast_ema, uint slow_ema, uint signal, ENUM_APPLIED_PRICE applied_price, string name)
  {
   i_handle=iMACD(symbol, timeframe, fast_ema, slow_ema, signal, applied_price);
   IndicatorValues=new CArrayObj();
   s_Name=name;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMACD::~CMACD()
  {
   if(i_handle!=INVALID_HANDLE)
      IndicatorRelease(i_handle);
   if(CheckPointer(IndicatorValues)!=POINTER_INVALID)
      delete IndicatorValues;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMACD::SaveNewValues(long ticket)
  {
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return false;
   if(i_handle==INVALID_HANDLE)
      return false;
   double main[], signal[];
   if(CopyBuffer(i_handle,0,1,2,main)<2 || CopyBuffer(i_handle,1,1,2,signal)<2)
      return false;
   CMACDValue *object=new CMACDValue(main[1], (main[0]!=0 ? (main[1]-main[0]>0 ? 1.1 : (main[1]-main[0]<0 ?  0.9 : 1)) : 1), signal[1], (signal[0]!=0 ? (signal[1]-signal[0]>0 ? 1.1 : (signal[1]-signal[0]<0 ?  0.9 : 1)) : 1), ticket);
   if(CheckPointer(object)==POINTER_INVALID)
      return false;
   if(s_Name==NULL)
      s_Name=GetIndicatorName(i_handle);

   return IndicatorValues.Add(object);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMACD::GetMainDinamic(long ticket)
  {
   double result=0;
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return result;
   int total=IndicatorValues.Total();
   for(int i=0;(i<total && result==0);i++)
     {
      CMACDValue *object=IndicatorValues.At(i);
      if(object.GetTicket()==ticket)
        {
         result=object.GetMainDinamic();
         break;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMACD::GetMainValue(long ticket)
  {
   double result=0;
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return result;
   int total=IndicatorValues.Total();
   for(int i=0;(i<total && result==0);i++)
     {
      CMACDValue *object=IndicatorValues.At(i);
      if(object.GetTicket()==ticket)
        {
         result=object.GetMainValue();
         break;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMACD::GetSignalDinamic(long ticket)
  {
   double result=0;
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return result;
   int total=IndicatorValues.Total();
   for(int i=0;(i<total && result==0);i++)
     {
      CMACDValue *object=IndicatorValues.At(i);
      if(object.GetTicket()==ticket)
        {
         result=object.GetSignalDinamic();
         break;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CMACD::GetSignalValue(long ticket)
  {
   double result=0;
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return result;
   int total=IndicatorValues.Total();
   for(int i=0;(i<total && result==0);i++)
     {
      CMACDValue *object=IndicatorValues.At(i);
      if(object.GetTicket()==ticket)
        {
         result=object.GetSignalValue();
         break;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMACD::GetValues(long ticket,double &main_value,double &main_dinamic,double &signal_value,double &signal_dinamic)
  {
   double result=false;
   if(ticket<0)
      return result;
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return result;
   int total=IndicatorValues.Total();
   int i=(int)fmin(total-1,ticket);
   CMACDValue *object=IndicatorValues.At(i);
   int prev=0;
   while(object.GetTicket()!=ticket)
     {
      if(object.GetTicket()>ticket)
        {
         if(prev>0 || i==0)
            return false;
         i--;
         prev=-1;
        }
      else
         if(object.GetTicket()<ticket)
           {
            if(prev<0 || i>=(total-1))
               return false;
            i++;
            prev=1;
           }
      object=IndicatorValues.At(i);
     }
   if(object.GetTicket()==ticket)
     {
      result=true;
      object.GetValues(main_value, main_dinamic, signal_value, signal_dinamic);
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CMACD::GetIndicatorName(int handle)
  {
   if(handle<0)
      return NULL;
   long chart=ChartFirst();
   do
     {
      int windows=(int)ChartGetInteger(chart,CHART_WINDOWS_TOTAL); 
      //--- про ходим по окнам 
      for(int w=0;w<windows;w++) 
        { 
         int total=ChartIndicatorsTotal(chart,w); 
         for(int i=0;i<total;i++) 
           { 
            string name=ChartIndicatorName(chart,w,i); 
            if(ChartIndicatorGet(chart,w,name)==handle)
               return (name+" "+StringSubstr(EnumToString(ChartPeriod(chart)),7));
           } 
        }
      chart=ChartNext(chart);
     }
   while(chart>=0);
//---
   return NULL;
  }
//+------------------------------------------------------------------+
