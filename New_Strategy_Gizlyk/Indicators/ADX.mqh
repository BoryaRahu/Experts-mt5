//+------------------------------------------------------------------+
//|                                                          ADX.mqh |
//|                                              Copyright 2017, DNG |
//|                                 http://www.mql5.com/ru/users/dng |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, DNG"
#property link      "http://www.mql5.com/ru/users/dng"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "ADXValue.mqh"
#include <Arrays\\ArrayObj.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CADX        :  public CObject
  {
private:
   CArrayObj        *IndicatorValues;     //Array of indicator's values
   
   int               i_handle;            //Handle of indicator
   string            s_Name;
   string            GetIndicatorName(int handle);
   
public:
                     CADX(string symbol, ENUM_TIMEFRAMES timeframe, uint period, string name);
                    ~CADX();
   //---
   bool              SaveNewValues(long ticket);
   //---
   double            GetADXValue(long ticket);
   double            GetADXDinamic(long ticket);
   double            GetPDIValue(long ticket);
   double            GetPDIDinamic(long ticket);
   double            GetNDIValue(long ticket);
   double            GetNDIDinamic(long ticket);
   bool              GetValues(long ticket,double &adx_value,double &adx_dinamic,double &pdi_value,double &pdi_dinamic,double &ndi_value,double &ndi_dinamic);
   int               GetIndyHandle(void)  {  return i_handle;  }
   string            GetName(void)        {  return (s_Name!= NULL ? s_Name : "ADX");       }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CADX::CADX(string symbol, ENUM_TIMEFRAMES timeframe, uint period, string name)
  {
   i_handle=iADX(symbol, timeframe, period);
   IndicatorValues=new CArrayObj();
   s_Name=name;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CADX::~CADX()
  {
   if(i_handle!=INVALID_HANDLE)
      IndicatorRelease(i_handle);
   if(CheckPointer(IndicatorValues)!=POINTER_INVALID)
      delete IndicatorValues;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CADX::SaveNewValues(long ticket)
  {
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return false;
   if(i_handle==INVALID_HANDLE)
      return false;
   double adx[], pdi[], ndi[];
   if(CopyBuffer(i_handle,0,1,2,adx)<2 || CopyBuffer(i_handle,1,1,2,pdi)<2 || CopyBuffer(i_handle,2,1,2,ndi)<2)
      return false;
   CADXValue *object=new CADXValue(adx[1], (adx[0]!=0 ? adx[1]/adx[0] : 1), pdi[1], (pdi[0]!=0 ? pdi[1]/pdi[0] : 1), ndi[1], (ndi[0]!=0 ? ndi[1]/ndi[0] : 1), ticket);
   if(CheckPointer(object)==POINTER_INVALID)
      return false;
   if(s_Name==NULL)
      s_Name=GetIndicatorName(i_handle);
   return IndicatorValues.Add(object);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CADX::GetADXDinamic(long ticket)
  {
   double result=0;
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return result;
   int total=IndicatorValues.Total();
   for(int i=0;(i<total && result==0);i++)
     {
      CADXValue *object=IndicatorValues.At(i);
      if(object.GetTicket()==ticket)
        {
         result=object.GetADXDinamic();
         break;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CADX::GetADXValue(long ticket)
  {
   double result=0;
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return result;
   int total=IndicatorValues.Total();
   for(int i=0;(i<total && result==0);i++)
     {
      CADXValue *object=IndicatorValues.At(i);
      if(object.GetTicket()==ticket)
        {
         result=object.GetADXValue();
         break;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CADX::GetPDIDinamic(long ticket)
  {
   double result=0;
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return result;
   int total=IndicatorValues.Total();
   for(int i=0;(i<total && result==0);i++)
     {
      CADXValue *object=IndicatorValues.At(i);
      if(object.GetTicket()==ticket)
        {
         result=object.GetPDIDinamic();
         break;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CADX::GetPDIValue(long ticket)
  {
   double result=0;
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return result;
   int total=IndicatorValues.Total();
   for(int i=0;(i<total && result==0);i++)
     {
      CADXValue *object=IndicatorValues.At(i);
      if(object.GetTicket()==ticket)
        {
         result=object.GetPDIValue();
         break;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CADX::GetValues(long ticket,double &adx_value,double &adx_dinamic,double &pdi_value,double &pdi_dinamic,double &ndi_value,double &ndi_dinamic)
  {
   double result=false;
   if(ticket<0)
      return result;
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return result;
   int total=IndicatorValues.Total();
   int i=(int)fmin(total-1,ticket);
   CADXValue *object=IndicatorValues.At(i);
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
      object.GetValues(adx_value, adx_dinamic, pdi_value, pdi_dinamic, ndi_value, ndi_dinamic);
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CADX::GetIndicatorName(int handle)
  {
   if(handle<0)
      return NULL;
   long chart=0;//ChartFirst();
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
