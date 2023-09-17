//+------------------------------------------------------------------+
//|                                                 NewStrategy1.mq5 |
//|                                              Copyright 2017, DNG |
//|                                 http://www.mql5.com/ru/users/dng |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, DNG"
#property link      "http://www.mql5.com/ru/users/dng"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "Deal.mqh"
#include "DealsToIndicators.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- input parameters
input double            Reward_Risk    =  5.0;
input int               ATR_Period     =  21;
input ENUM_TIMEFRAMES   TimeFrame1     =  PERIOD_M5;
input ENUM_TIMEFRAMES   TimeFrame2     =  PERIOD_M30;
input ENUM_TIMEFRAMES   TimeFrame3     =  PERIOD_H4;
input string            s1                =  "ADX"                ;  //---
input uint              ADX_Period1       =  14                   ;
input uint              ADX_Period2       =  28                   ;
input uint              ADX_Period3       =  56                   ;
input string            s2                =  "Alligator"          ;  //---
input uint              JAW_Period1       =  13                   ;
input uint              JAW_Shift1        =  8                    ;
input uint              TEETH_Period1     =  8                    ;
input uint              TEETH_Shift1      =  5                    ;
input uint              LIPS_Period1      =  5                    ;
input uint              LIPS_Shift1       =  3                    ;
input uint              JAW_Period2       =  26                   ;
input uint              JAW_Shift2        =  16                   ;
input uint              TEETH_Period2     =  16                   ;
input uint              TEETH_Shift2      =  10                   ;
input uint              LIPS_Period2      =  10                   ;
input uint              LIPS_Shift2       =  6                    ;
input uint              JAW_Period3       =  42                   ;
input uint              JAW_Shift3        =  32                   ;
input uint              TEETH_Period3     =  32                   ;
input uint              TEETH_Shift3      =  20                   ;
input uint              LIPS_Period3      =  20                   ;
input uint              LIPS_Shift3       =  12                   ;
input ENUM_MA_METHOD    Alligator_Method  =  MODE_SMMA            ;
input ENUM_APPLIED_PRICE Alligator_Price  =  PRICE_MEDIAN         ;
input string            s5                =  "CCI"                ;  //---
input uint              CCI_Period1       =  14                   ;
input uint              CCI_Period2       =  28                   ;
input uint              CCI_Period3       =  56                   ;
input ENUM_APPLIED_PRICE CCI_Price        =  PRICE_TYPICAL        ;
input string            s6                =  "Chaikin"            ;  //---
input uint              Ch_Fast_Period1   =  3                    ;
input uint              Ch_Slow_Period1   =  14                   ;
input uint              Ch_Fast_Period2   =  6                    ;
input uint              Ch_Slow_Period2   =  28                   ;
input uint              Ch_Fast_Period3   =  12                   ;
input uint              Ch_Slow_Period3   =  56                   ;
input ENUM_MA_METHOD    Ch_Method         =  MODE_EMA             ;
input ENUM_APPLIED_VOLUME Ch_Volume       =  VOLUME_TICK          ;
input string            s7                =  "Force Index"        ;  //---
input uint              Force_Period1     =  14                   ;
input uint              Force_Period2     =  28                   ;
input uint              Force_Period3     =  56                   ;
input ENUM_MA_METHOD    Force_Method      =  MODE_SMA             ;
input ENUM_APPLIED_VOLUME Force_Volume    =  VOLUME_TICK          ;
input string            s8                =  "MACD"               ;  //---
input uint              MACD_Fast1        =  12                   ;
input uint              MACD_Slow1        =  26                   ;
input uint              MACD_Signal1      =  9                    ;
input uint              MACD_Fast2        =  24                   ;
input uint              MACD_Slow2        =  52                   ;
input uint              MACD_Signal2      =  18                   ;
input uint              MACD_Fast3        =  48                   ;
input uint              MACD_Slow3        =  104                  ;
input uint              MACD_Signal3      =  36                   ;
input ENUM_APPLIED_PRICE MACD_Price       =  PRICE_CLOSE          ;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime             last_bar;
CArrayObj            *Deals;
CDealsToIndicators   *IndicatorsStatic;
int                  atr;
int                  force;
int                  macd;
int                  last_closed_deal;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   last_bar=0;
//---
   Deals =  new CArrayObj();
   if(CheckPointer(Deals)==POINTER_INVALID)
      return INIT_FAILED;
//---
   IndicatorsStatic  =  new CDealsToIndicators();
   if(CheckPointer(IndicatorsStatic)==POINTER_INVALID)
      return INIT_FAILED;
//---
   atr=iATR(_Symbol,TimeFrame1,ATR_Period);
   if(atr==INVALID_HANDLE)
      return INIT_FAILED;
//---
   AddIndicators(TimeFrame1);
   AddIndicators(TimeFrame2);
   AddIndicators(TimeFrame3);
   last_closed_deal=0;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(CheckPointer(Deals)!=POINTER_INVALID)
      delete Deals;
   if(CheckPointer(IndicatorsStatic)!=POINTER_INVALID)
      delete IndicatorsStatic;
   if(atr!=INVALID_HANDLE)
      IndicatorRelease(atr);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(CheckPointer(Deals)==POINTER_INVALID)
     {
      Deals =  new CArrayObj();
      if(CheckPointer(Deals)==POINTER_INVALID)
         return;
     }
   int total=Deals.Total();
   CDeal *deal;
   bool found=false;
   for(int i=last_closed_deal;i<total;i++)
     {
      deal  =  Deals.At(i);
      if(CheckPointer(deal)==POINTER_INVALID)
         continue;
      if(!found)
        {
         if(deal.IsClosed())
           {
            last_closed_deal=i;
            continue;
           }
         else
            found=true;
        }
      deal.Tick();
     }
   datetime cur_bar=(datetime)SeriesInfoInteger(_Symbol,PERIOD_CURRENT,SERIES_LASTBAR_DATE);
   datetime cur_time=TimeCurrent();
   
   if(cur_bar==last_bar || (cur_time-cur_bar)>10)
      return;
   double atrs[];
   double force_data[];
   double macd_data[];
   if(CopyBuffer(atr,0,1,1,atrs)<=0 || CopyBuffer(force,0,1,1,force_data)<=0 || CopyBuffer(macd,0,1,1,macd_data)<=0)
     {
      return;
     }
   last_bar=cur_bar;
   double force_Step=_Point*1000;
   if(MathAbs(NormalizeDouble(force_data[0]/force_Step,0)*force_Step)<=0.01)
      return;

   double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double stops=MathMax(2*atrs[0],SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*_Point);
   double sl=NormalizeDouble(stops,_Digits);
   double tp=NormalizeDouble(Reward_Risk*(stops+ask-bid),_Digits);
   double macd_Step=_Point*50;
   macd_data[0]=NormalizeDouble(macd_data[0]/macd_Step,0)*macd_Step;
   if(macd_data[0]>=0.0015 && macd_data[0]<=0.0035)
     {
      deal  =  new CDeal(_Symbol,POSITION_TYPE_BUY,TimeCurrent(),ask,bid-sl,ask+tp);
      if(CheckPointer(deal)!=POINTER_INVALID)
         if(Deals.Add(deal))
            IndicatorsStatic.SaveNewValues(Deals.Total()-1);
     }
   if(macd_data[0]<=(-0.0015) && macd_data[0]>=(-0.0035))
     {
      deal  =  new CDeal(_Symbol,POSITION_TYPE_SELL,TimeCurrent(),bid,ask+sl,bid-tp);
      if(CheckPointer(deal)!=POINTER_INVALID)
         if(Deals.Add(deal))
            IndicatorsStatic.SaveNewValues(Deals.Total()-1);
     }
   return;
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---
   if(CheckPointer(IndicatorsStatic)!=POINTER_INVALID)
      IndicatorsStatic.Static(Deals);
//---
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AddIndicators(ENUM_TIMEFRAMES timeframe)
  {
   if(CheckPointer(IndicatorsStatic)==POINTER_INVALID)
     {
      IndicatorsStatic  =  new CDealsToIndicators();
      if(CheckPointer(IndicatorsStatic)==POINTER_INVALID)
         return false;
     }
   string tf_name=StringSubstr(EnumToString(timeframe),7);
   string name="ADX("+IntegerToString(ADX_Period1)+") "+tf_name;
   if(!IndicatorsStatic.AddADX(_Symbol, timeframe, ADX_Period1, name))
      return false;
   name="ADX("+IntegerToString(ADX_Period2)+") "+tf_name;
   if(!IndicatorsStatic.AddADX(_Symbol, timeframe, ADX_Period2, name))
      return false;
   name="ADX("+IntegerToString(ADX_Period3)+") "+tf_name;
   if(!IndicatorsStatic.AddADX(_Symbol, timeframe, ADX_Period3, name))
      return false;
   name="Alligator("+IntegerToString(JAW_Period1)+","+IntegerToString(TEETH_Period1)+","+IntegerToString(LIPS_Period1)+") "+tf_name;
   if(!IndicatorsStatic.AddAlligator(_Symbol, timeframe, JAW_Period1, JAW_Shift1, TEETH_Period1, TEETH_Shift1, LIPS_Period1, LIPS_Shift1, Alligator_Method, Alligator_Price, name))
      return false;
   name="Alligator("+IntegerToString(JAW_Period2)+","+IntegerToString(TEETH_Period2)+","+IntegerToString(LIPS_Period2)+") "+tf_name;
   if(!IndicatorsStatic.AddAlligator(_Symbol, timeframe, JAW_Period2, JAW_Shift2, TEETH_Period2, TEETH_Shift2, LIPS_Period2, LIPS_Shift2, Alligator_Method, Alligator_Price, name))
      return false;
   name="Alligator("+IntegerToString(JAW_Period3)+","+IntegerToString(TEETH_Period3)+","+IntegerToString(LIPS_Period3)+") "+tf_name;
   if(!IndicatorsStatic.AddAlligator(_Symbol, timeframe, JAW_Period3, JAW_Shift3, TEETH_Period3, TEETH_Shift3, LIPS_Period3, LIPS_Shift3, Alligator_Method, Alligator_Price, name))
      return false;
   name="MACD("+IntegerToString(MACD_Fast1)+","+IntegerToString(MACD_Slow1)+","+IntegerToString(MACD_Signal1)+") "+tf_name;
   if(!IndicatorsStatic.AddMACD(_Symbol, timeframe, MACD_Fast1, MACD_Slow1, MACD_Signal1, MACD_Price, name))
      return false;
   name="MACD("+IntegerToString(MACD_Fast2)+","+IntegerToString(MACD_Slow2)+","+IntegerToString(MACD_Signal2)+") "+tf_name;
   if(timeframe==TimeFrame1)
     {
      if(!IndicatorsStatic.AddMACD(_Symbol, timeframe, MACD_Fast2, MACD_Slow2, MACD_Signal2, MACD_Price, name, macd))
         return false;
     }
   else
     {
      if(!IndicatorsStatic.AddMACD(_Symbol, timeframe, MACD_Fast2, MACD_Slow2, MACD_Signal2, MACD_Price, name))
         return false;
     }
   name="MACD("+IntegerToString(MACD_Fast3)+","+IntegerToString(MACD_Slow3)+","+IntegerToString(MACD_Signal3)+") "+tf_name;
   if(!IndicatorsStatic.AddMACD(_Symbol, timeframe, MACD_Fast3, MACD_Slow3, MACD_Signal3, MACD_Price, name))
      return false;
   name="CCI("+IntegerToString(CCI_Period1)+") "+tf_name;
   int handle = iCCI(_Symbol, timeframe, CCI_Period1, CCI_Price);
   if(handle<0 || !IndicatorsStatic.AddOneBuffer(handle, name) )
      return false;
   name="CCI("+IntegerToString(CCI_Period2)+") "+tf_name;
   handle = iCCI(_Symbol, timeframe, CCI_Period2, CCI_Price);
   if(handle<0 || !IndicatorsStatic.AddOneBuffer(handle, name) )
      return false;
   handle = iCCI(_Symbol, timeframe, CCI_Period3, CCI_Price);
   name="CCI("+IntegerToString(CCI_Period3)+") "+tf_name;
   if(handle<0 || !IndicatorsStatic.AddOneBuffer(handle, name) )
      return false;
   handle = iForce(_Symbol, timeframe, Force_Period1, Force_Method, Force_Volume);
   name="Force("+IntegerToString(Force_Period1)+") "+tf_name;
   if(handle<0 || !IndicatorsStatic.AddOneBuffer(handle, name) )
      return false;
   handle = iForce(_Symbol, timeframe, Force_Period2, Force_Method, Force_Volume);
   name="Force("+IntegerToString(Force_Period2)+") "+tf_name;
   if(handle<0 || !IndicatorsStatic.AddOneBuffer(handle, name) )
      return false;
   handle = iForce(_Symbol, timeframe, Force_Period3, Force_Method, Force_Volume);
   if(timeframe==TimeFrame1)
     {
      force=handle;
     }
   name="Force("+IntegerToString(Force_Period3)+") "+tf_name;
   if(handle<0 || !IndicatorsStatic.AddOneBuffer(handle, name) )
      return false;
   name="CHO("+IntegerToString(Ch_Slow_Period1)+","+IntegerToString(Ch_Fast_Period1)+") "+tf_name;
   handle = iChaikin(_Symbol, timeframe, Ch_Fast_Period1, Ch_Slow_Period1, Ch_Method, Ch_Volume);
   if(handle<0 || !IndicatorsStatic.AddOneBuffer(handle, name) )
      return false;
   handle = iChaikin(_Symbol, timeframe, Ch_Fast_Period2, Ch_Slow_Period2, Ch_Method, Ch_Volume);
   name="CHO("+IntegerToString(Ch_Slow_Period2)+","+IntegerToString(Ch_Fast_Period2)+") "+tf_name;
   if(handle<0 || !IndicatorsStatic.AddOneBuffer(handle, name) )
      return false;
   handle = iChaikin(_Symbol, timeframe, Ch_Fast_Period3, Ch_Slow_Period3, Ch_Method, Ch_Volume);
   name="CHO("+IntegerToString(Ch_Slow_Period3)+","+IntegerToString(Ch_Fast_Period3)+") "+tf_name;
   if(handle<0 || !IndicatorsStatic.AddOneBuffer(handle, name) )
      return false;
   return true;
  }
//+------------------------------------------------------------------+
