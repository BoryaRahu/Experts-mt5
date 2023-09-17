//+------------------------------------------------------------------+
//|                                            DealsToIndicators.mqh |
//|                                              Copyright 2017, DNG |
//|                                 http://www.mql5.com/ru/users/dng |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, DNG"
#property link      "http://www.mql5.com/ru/users/dng"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "Indicators\\StaticOneBuffer.mqh"
#include "Indicators\\StaticMACD.mqh"
#include "Indicators\\StaticADX.mqh"
#include "Indicators\\StaticAlligator.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDealsToIndicators
  {
private:
   CADX              *ADX[];
   CAlligator        *Alligator[];
   COneBufferArray   *OneBuffer[];
   CMACD             *MACD[];
   CStaticOneBuffer  *OneBufferStatic[];
   CStaticMACD       *MACD_Static[];
   CStaticADX        *ADX_Static[];
   CStaticAlligator  *Alligator_Static[];
   
   template<typename T>
   void              CleareArray(T *&array[]);

public:
                     CDealsToIndicators();
                    ~CDealsToIndicators();
   //---
   bool              AddADX(string symbol, ENUM_TIMEFRAMES timeframe, int period, string name);
   bool              AddADX(string symbol, ENUM_TIMEFRAMES timeframe, int period, string name, int &handle);
   bool              AddAlligator(string symbol,ENUM_TIMEFRAMES timeframe,uint jaw_period, uint jaw_shift, uint teeth_period, uint teeth_shift, uint lips_period, uint lips_shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE price, string name);
   bool              AddAlligator(string symbol,ENUM_TIMEFRAMES timeframe,uint jaw_period, uint jaw_shift, uint teeth_period, uint teeth_shift, uint lips_period, uint lips_shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE price, string name, int &handle);
   bool              AddMACD(string symbol, ENUM_TIMEFRAMES timeframe, uint fast_ema, uint slow_ema, uint signal, ENUM_APPLIED_PRICE applied_price, string name);
   bool              AddMACD(string symbol, ENUM_TIMEFRAMES timeframe, uint fast_ema, uint slow_ema, uint signal, ENUM_APPLIED_PRICE applied_price, string name, int &handle);
   bool              AddOneBuffer(int handle, string name);
   //---
   bool              SaveNewValues(long ticket);
   //---
   bool              Static(CArrayObj *deals);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDealsToIndicators::CDealsToIndicators()
  {
   CleareArray(ADX);
   CleareArray(Alligator);
   CleareArray(OneBuffer);
   CleareArray(MACD);
   CleareArray(OneBufferStatic);
   CleareArray(MACD_Static);
   CleareArray(ADX_Static);
   CleareArray(Alligator_Static);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDealsToIndicators::~CDealsToIndicators()
  {
   CleareArray(ADX);
   CleareArray(Alligator);
   CleareArray(OneBuffer);
   CleareArray(MACD);
   CleareArray(OneBufferStatic);
   CleareArray(MACD_Static);
   CleareArray(ADX_Static);
   CleareArray(Alligator_Static);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
CDealsToIndicators::CleareArray(T *&array[])
  {
   int total=ArraySize(array);
   for(int i=0;i<total;i++)
     {
      if(CheckPointer(array[i])!=POINTER_INVALID)
         delete array[i];
     }
   ArrayFree(array);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDealsToIndicators::AddADX(string symbol, ENUM_TIMEFRAMES timeframe, int period, string name)
  {
   int handle=INVALID_HANDLE;
   return AddADX(symbol,timeframe,period,name,handle);
  }
bool CDealsToIndicators::AddADX(string symbol, ENUM_TIMEFRAMES timeframe, int period, string name, int &handle)
  {
   CADX  *object = new CADX(symbol, timeframe, period, name);
   if(CheckPointer(object)==POINTER_INVALID)
      return false;
   int size=ArraySize(ADX);
   if(ArrayResize(ADX,size+1)<=0)
     {
      delete object;
      return false;
     }
   ADX[size]=object;
   handle=object.GetIndyHandle();
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDealsToIndicators::AddAlligator(string symbol,ENUM_TIMEFRAMES timeframe,uint jaw_period, uint jaw_shift, uint teeth_period, uint teeth_shift, uint lips_period, uint lips_shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE price, string name)
  {
   int handle=INVALID_HANDLE;
   return AddAlligator(symbol,timeframe,jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, method, price, name, handle);
  }
bool CDealsToIndicators::AddAlligator(string symbol,ENUM_TIMEFRAMES timeframe,uint jaw_period, uint jaw_shift, uint teeth_period, uint teeth_shift, uint lips_period, uint lips_shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE price, string name, int &handle)
  {
   CAlligator  *object = new CAlligator(symbol, timeframe, jaw_period, jaw_shift, teeth_period, teeth_shift, lips_period, lips_shift, method, price, name);
   if(CheckPointer(object)==POINTER_INVALID)
      return false;
   int size=ArraySize(Alligator);
   if(ArrayResize(Alligator,size+1)<=0)
     {
      delete object;
      return false;
     }
   Alligator[size]=object;
   handle=object.GetIndyHandle();
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDealsToIndicators::AddMACD(string symbol,ENUM_TIMEFRAMES timeframe,uint fast_ema,uint slow_ema,uint signal,ENUM_APPLIED_PRICE applied_price, string name)
  {
   int handle=INVALID_HANDLE;
   return AddMACD( symbol, timeframe, fast_ema, slow_ema, signal, applied_price, name, handle);
  }
bool CDealsToIndicators::AddMACD(string symbol,ENUM_TIMEFRAMES timeframe,uint fast_ema,uint slow_ema,uint signal,ENUM_APPLIED_PRICE applied_price, string name, int &handle)
  {
   CMACD  *object = new CMACD(symbol, timeframe, fast_ema, slow_ema, signal, applied_price, name);
   if(CheckPointer(object)==POINTER_INVALID)
      return false;
   int size=ArraySize(MACD);
   if(ArrayResize(MACD,size+1)<=0)
     {
      delete object;
      return false;
     }
   MACD[size]=object;
   handle=object.GetIndyHandle();
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDealsToIndicators::AddOneBuffer(int handle, string name)
  {
   COneBufferArray   *object = new COneBufferArray(handle, name);
   if(CheckPointer(object)==POINTER_INVALID)
      return false;
   int size=ArraySize(OneBuffer);
   if(ArrayResize(OneBuffer,size+1)<=0)
     {
      delete object;
      return false;
     }
   OneBuffer[size]=object;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDealsToIndicators::SaveNewValues(long ticket)
  {
   if(ticket<0)
      return false;
//---
   int total=ArraySize(ADX);
   for(int i=0;i<total;i++)
      if(CheckPointer(ADX[i])!=POINTER_INVALID)
         ADX[i].SaveNewValues(ticket);
//---
   total=ArraySize(Alligator);
   for(int i=0;i<total;i++)
      if(CheckPointer(Alligator[i])!=POINTER_INVALID)
         Alligator[i].SaveNewValues(ticket);
//---
   total=ArraySize(MACD);
   for(int i=0;i<total;i++)
      if(CheckPointer(MACD[i])!=POINTER_INVALID)
         MACD[i].SaveNewValues(ticket);
//---
   total=ArraySize(OneBuffer);
   for(int i=0;i<total;i++)
      if(CheckPointer(OneBuffer[i])!=POINTER_INVALID)
         OneBuffer[i].SaveNewValues(ticket);
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDealsToIndicators::Static(CArrayObj *deals)
  {
   int total_deals=deals.Total();
   if(total_deals<=0)
      return false;
//---
   int size_ob=ArraySize(OneBuffer);
   if(size_ob>0 && ArrayResize(OneBufferStatic,size_ob)<=0)
      return false;
   for(int i=0;i<size_ob;i++)
     {
      double step=10;
      string name=OneBuffer[i].GetName();
      if(StringFind(name,"Force",0)>=0)
         step=_Point*1000;
      else
         if(StringFind(name,"CHO",0)>=0)
            step=100;
      OneBufferStatic[i]=new CStaticOneBuffer(OneBuffer[i],step);
     }
//---
   int size_adx=ArraySize(ADX);
   if(size_adx>0 && ArrayResize(ADX_Static,size_adx)<=0)
      return false;
   for(int i=0;i<size_adx;i++)
      ADX_Static[i]=new CStaticADX(ADX[i],1);
//---
   int size_al=ArraySize(Alligator);
   if(size_al>0 && ArrayResize(Alligator_Static,size_al)<=0)
      return false;
   for(int i=0;i<size_al;i++)
      Alligator_Static[i]=new CStaticAlligator(Alligator[i]);
//---
   int size_macd=ArraySize(MACD);
   if(size_macd>0 && ArrayResize(MACD_Static,size_macd)<=0)
      return false;
   for(int i=0;i<size_macd;i++)
      MACD_Static[i]=new CStaticMACD(MACD[i],_Point*50);
//---
   Print(" Start count statistic");
   double completed=-1;
   CDeal               *deal;
   int total_indy=0;
   for(int i=0;i<total_deals;i++)
     {
                           deal     =  deals.At(i);
      ENUM_POSITION_TYPE   type     =  deal.Type();
      double               d_profit =  deal.GetProfit();
      double com=NormalizeDouble((double)i/total_deals*100,1);
      if(completed<com)
        {
         completed=com;
         Print(" completed ",DoubleToString(completed,1),"%");
        }
      
      for(int ind=0;ind<size_ob;ind++)
        if(CheckPointer(OneBufferStatic[ind])!=POINTER_INVALID)
           {
            OneBufferStatic[ind].Ad(i,d_profit,type);
            total_indy++;
           }
      for(int ind=0;ind<size_adx;ind++)
         if(CheckPointer(ADX_Static[ind])!=POINTER_INVALID)
           {
            ADX_Static[ind].Ad(i,d_profit,type);
            total_indy++;
           }
      for(int ind=0;ind<size_al;ind++)
         if(CheckPointer(Alligator_Static[ind])!=POINTER_INVALID)
           {
            Alligator_Static[ind].Ad(i,d_profit,type);
            total_indy++;
           }
      for(int ind=0;ind<size_macd;ind++)
         if(CheckPointer(MACD_Static[ind])!=POINTER_INVALID)
           {
            MACD_Static[ind].Ad(i,d_profit,type);
            total_indy++;
           }
     }
//---
   Print(" Create report...");
   if(total_indy>0)
     {
      string file_name=MQLInfoString(MQL_PROGRAM_NAME)+"_Report.html";
      int handle=FileOpen(file_name,FILE_WRITE|FILE_TXT|FILE_COMMON);
      if(handle<0)
         return false;
      FileWrite(handle,"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">");
      FileWrite(handle,"<html> <head> <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">");
      FileWrite(handle,"<title>Deals to Indicators</title> <!-- - -->");
      FileWrite(handle,"<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.4.4/jquery.js\" type=\"text/javascript\"></script>");
      FileWrite(handle,"<script src=\"https://code.highcharts.com/highcharts.js\" type=\"text/javascript\"></script>");
      FileWrite(handle,"<!-- - --> <script type=\"text/javascript\">$(document).ready(function(){");
      for(int ind=0;ind<size_ob;ind++)
         if(CheckPointer(OneBufferStatic[ind])!=POINTER_INVALID)
            FileWrite(handle,OneBufferStatic[ind].HTML_header());
      for(int ind=0;ind<size_macd;ind++)
         if(CheckPointer(MACD_Static[ind])!=POINTER_INVALID)
            FileWrite(handle,MACD_Static[ind].HTML_header());
      for(int ind=0;ind<size_adx;ind++)
         if(CheckPointer(ADX_Static[ind])!=POINTER_INVALID)
            FileWrite(handle,ADX_Static[ind].HTML_header());
      for(int ind=0;ind<size_al;ind++)
         if(CheckPointer(Alligator_Static[ind])!=POINTER_INVALID)
            FileWrite(handle,Alligator_Static[ind].HTML_header());
      FileWrite(handle,"});</script> <!-- - --> </head> <body>");
      for(int ind=0;ind<size_ob;ind++)
         if(CheckPointer(OneBufferStatic[ind])!=POINTER_INVALID)
            FileWrite(handle,OneBufferStatic[ind].HTML_body());
      for(int ind=0;ind<size_macd;ind++)
         if(CheckPointer(MACD_Static[ind])!=POINTER_INVALID)
            FileWrite(handle,MACD_Static[ind].HTML_body());
      for(int ind=0;ind<size_adx;ind++)
         if(CheckPointer(ADX_Static[ind])!=POINTER_INVALID)
            FileWrite(handle,ADX_Static[ind].HTML_body());
      for(int ind=0;ind<size_al;ind++)
         if(CheckPointer(Alligator_Static[ind])!=POINTER_INVALID)
            FileWrite(handle,Alligator_Static[ind].HTML_body());
      FileWrite(handle,"</body> </html>");
      FileFlush(handle);
      FileClose(handle);
     }
   Print(" Completed");
//---
   return true;
  }
//+------------------------------------------------------------------+
