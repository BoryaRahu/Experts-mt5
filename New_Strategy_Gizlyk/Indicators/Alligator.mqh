//+------------------------------------------------------------------+
//|                                                    Alligator.mqh |
//|                                              Copyright 2017, DNG |
//|                                 http://www.mql5.com/ru/users/dng |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, DNG"
#property link      "http://www.mql5.com/ru/users/dng"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "AlligatorValue.mqh"
#include <Arrays\\ArrayObj.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CAlligator
  {
private:
   CArrayObj        *IndicatorValues;     //Array of indicator's values
   
   int               i_handle;            //Handle of indicator
   string            s_Name;
   string            GetIndicatorName(int handle);
   
public:
                     CAlligator(string symbol, ENUM_TIMEFRAMES timeframe, uint jaw_period, uint jaw_shift, uint teeth_period, uint teeth_shift, uint lips_period, uint lips_shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE price, string name);
                    ~CAlligator();
   //---
   bool              SaveNewValues(long ticket);
   //---
   double            GetJAWValue(long ticket);
   double            GetJAWDinamic(long ticket);
   double            GetTEETHValue(long ticket);
   double            GetTEETHDinamic(long ticket);
   double            GetLIPSValue(long ticket);
   double            GetLIPSDinamic(long ticket);
   bool              GetValues(long ticket,double &jaw_value,double &jaw_dinamic,double &teeth_value,double &teeth_dinamic,double &lips_value,double &lips_dinamic);
   int               GetIndyHandle(void)  {  return i_handle;  }
   string            GetName(void)        {  return (s_Name!= NULL ? s_Name : "Alligator");       }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAlligator::CAlligator(string symbol, ENUM_TIMEFRAMES timeframe, uint jaw_period, uint jaw_shift, uint teeth_period, uint teeth_shift, uint lips_period, uint lips_shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE price, string name)
  {
   i_handle=iAlligator(symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, method, price);
   IndicatorValues=new CArrayObj();
   s_Name=name;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CAlligator::~CAlligator()
  {
   if(i_handle!=INVALID_HANDLE)
      IndicatorRelease(i_handle);
   if(CheckPointer(IndicatorValues)!=POINTER_INVALID)
      delete IndicatorValues;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAlligator::SaveNewValues(long ticket)
  {
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return false;
   if(i_handle==INVALID_HANDLE)
      return false;
   double jaw[], teeth[], lips[];
   if(CopyBuffer(i_handle,0,1,2,jaw)<2 || CopyBuffer(i_handle,1,1,2,teeth)<2 || CopyBuffer(i_handle,2,1,2,lips)<2)
      return false;
   CAlligatorValue *object=new CAlligatorValue(jaw[1], (jaw[0]!=0 ? jaw[1]/jaw[0] : 1), teeth[1], (teeth[0]!=0 ? teeth[1]/teeth[0] : 1), lips[1], (lips[0]!=0 ? lips[1]/lips[0] : 1), ticket);
   if(CheckPointer(object)==POINTER_INVALID)
      return false;
   if(s_Name==NULL)
      s_Name=GetIndicatorName(i_handle);
   return IndicatorValues.Add(object);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CAlligator::GetJAWDinamic(long ticket)
  {
   double result=0;
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return result;
   int total=IndicatorValues.Total();
   for(int i=0;(i<total && result==0);i++)
     {
      CAlligatorValue *object=IndicatorValues.At(i);
      if(object.GetTicket()==ticket)
        {
         result=object.GetJAWDinamic();
         break;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CAlligator::GetJAWValue(long ticket)
  {
   double result=0;
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return result;
   int total=IndicatorValues.Total();
   for(int i=0;(i<total && result==0);i++)
     {
      CAlligatorValue *object=IndicatorValues.At(i);
      if(object.GetTicket()==ticket)
        {
         result=object.GetJAWValue();
         break;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CAlligator::GetTEETHDinamic(long ticket)
  {
   double result=0;
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return result;
   int total=IndicatorValues.Total();
   for(int i=0;(i<total && result==0);i++)
     {
      CAlligatorValue *object=IndicatorValues.At(i);
      if(object.GetTicket()==ticket)
        {
         result=object.GetTEETHDinamic();
         break;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CAlligator::GetTEETHValue(long ticket)
  {
   double result=0;
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return result;
   int total=IndicatorValues.Total();
   for(int i=0;(i<total && result==0);i++)
     {
      CAlligatorValue *object=IndicatorValues.At(i);
      if(object.GetTicket()==ticket)
        {
         result=object.GetTEETHValue();
         break;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAlligator::GetValues(long ticket,double &jaw_value,double &jaw_dinamic,double &teeth_value,double &teeth_dinamic,double &lips_value,double &lips_dinamic)
  {
   double result=false;
   if(ticket<0)
      return result;
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return result;
   int total=IndicatorValues.Total();
   int i=(int)fmin(total-1,ticket);
   CAlligatorValue *object=IndicatorValues.At(i);
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
      object.GetValues(jaw_value, jaw_dinamic, teeth_value, teeth_dinamic, lips_value, lips_dinamic);
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CAlligator::GetIndicatorName(int handle)
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
