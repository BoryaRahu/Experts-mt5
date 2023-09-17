//+------------------------------------------------------------------+
//|                                               OneBufferArray.mqh |
//|                                              Copyright 2017, DNG |
//|                                 http://www.mql5.com/ru/users/dng |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, DNG"
#property link      "http://www.mql5.com/ru/users/dng"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "Value.mqh"
#include <Arrays\\ArrayObj.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class COneBufferArray   :  CObject
  {
private:
   CArrayObj        *IndicatorValues;     //Array of indicator's values
   
   int               i_handle;            //Handle of indicator
   string            s_Name;
   string            GetIndicatorName(int handle);
   
public:
                     COneBufferArray(int handle, string name);
                    ~COneBufferArray();
   //---
   bool              SaveNewValues(long ticket);
   //---
   double            GetValue(long ticket);
   double            GetDinamic(long ticket);
   bool              GetValues(long ticket, double &value, double &dinamic);
   int               GetIndyHandle(void)  {  return i_handle;     }
   string            GetName(void)        {  return (s_Name!= NULL ? s_Name : "...");       }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
COneBufferArray::COneBufferArray(int handle, string name)
  {
   i_handle=handle;
   IndicatorValues=new CArrayObj();
   s_Name=name;   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
COneBufferArray::~COneBufferArray()
  {
   if(i_handle!=INVALID_HANDLE)
      IndicatorRelease(i_handle);
   if(CheckPointer(IndicatorValues)!=POINTER_INVALID)
      delete IndicatorValues;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COneBufferArray::SaveNewValues(long ticket)
  {
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return false;
   if(i_handle==INVALID_HANDLE)
      return false;
   double ind_buffer[];
   if(CopyBuffer(i_handle,0,1,2,ind_buffer)<2)
      return false;
   CValue *object=new CValue(ind_buffer[1], (ind_buffer[0]!=0 ? (ind_buffer[1]-ind_buffer[0]>0 ? 1.1 : (ind_buffer[1]-ind_buffer[0]<0 ? 0.9  : 1)) : 1), ticket);
   if(CheckPointer(object)==POINTER_INVALID)
      return false;
   if(s_Name==NULL)
      s_Name=GetIndicatorName(i_handle);

   return IndicatorValues.Add(object);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double COneBufferArray::GetDinamic(long ticket)
  {
   double result=0;
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return result;
   int total=IndicatorValues.Total();
   for(int i=0;(i<total && result==0);i++)
     {
      CValue *object=IndicatorValues.At(i);
      if(object.GetTicket()==ticket)
        {
         result=object.GetDinamic();
         break;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double COneBufferArray::GetValue(long ticket)
  {
   double result=0;
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return result;
   int total=IndicatorValues.Total();
   for(int i=0;(i<total && result==0);i++)
     {
      CValue *object=IndicatorValues.At(i);
      if(object.GetTicket()==ticket)
        {
         result=object.GetValue();
         break;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COneBufferArray::GetValues(long ticket,double &value,double &dinamic)
  {
   double result=false;
   if(ticket<0)
      return result;
   if(CheckPointer(IndicatorValues)==POINTER_INVALID)
      return result;
   int total=IndicatorValues.Total();
   int i=(int)fmin(total-1,ticket);
   CValue *object=IndicatorValues.At(i);
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
      object.GetValues(value, dinamic);
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string COneBufferArray::GetIndicatorName(int handle)
  {
   if(handle<0)
      return NULL;
   long chart=ChartFirst();
   do
     {
      if(ChartSymbol(chart)!=_Symbol)
        {
         chart=ChartNext(chart);
         continue;
        }
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
