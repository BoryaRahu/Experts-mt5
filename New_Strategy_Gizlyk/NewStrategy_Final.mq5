//+------------------------------------------------------------------+
//|                                            NewStrategy_Final.mq5 |
//|                                              Copyright 2017, DNG |
//|                                 http://www.mql5.com/ru/users/dng |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, DNG"
#property link      "http://www.mql5.com/ru/users/dng"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- input parameters
input double            Lot               =  0.1                  ;
input double            Reward_Risk       =  15.0                 ;
input ENUM_TIMEFRAMES   ATR_TimeFrame     =  PERIOD_M5            ;
input int               ATR_Period        =  288                  ;
input string            s5                =  "CCI"                ;  //---
input ENUM_TIMEFRAMES   CCI_TimeFrame     =  PERIOD_D1            ;
input uint              CCI_Period        =  14                   ;
input ENUM_APPLIED_PRICE CCI_Price        =  PRICE_TYPICAL        ;
input string            s6                =  "Chaikin"            ;  //---
input ENUM_TIMEFRAMES   Ch_TimeFrame      =  PERIOD_D1            ;
input uint              Ch_Fast_Period    =  6                    ;
input uint              Ch_Slow_Period    =  28                   ;
input ENUM_MA_METHOD    Ch_Method         =  MODE_EMA             ;
input ENUM_APPLIED_VOLUME Ch_Volume       =  VOLUME_TICK          ;
input string            s7                =  "Force Index"        ;  //---
input ENUM_TIMEFRAMES   Force_TimeFrame   =  PERIOD_M5            ;
input uint              Force_Period      =  56                   ;
input ENUM_MA_METHOD    Force_Method      =  MODE_SMA             ;
input ENUM_APPLIED_VOLUME Force_Volume    =  VOLUME_TICK          ;
input string            s8                =  "MACD"               ;  //---
input ENUM_TIMEFRAMES   MACD_TimeFrame    =  PERIOD_M5            ;
input uint              MACD_Fast         =  12                   ;
input uint              MACD_Slow         =  26                   ;
input uint              MACD_Signal       =  9                    ;
input ENUM_APPLIED_PRICE MACD_Price       =  PRICE_CLOSE          ;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime             last_bar;
datetime             last_deal;
int                  atr;
int                  force;
int                  macd;
int                  cho;
int                  cci;
CTrade               Trade;                           // Class of trade operations
ENUM_TIMEFRAMES      MinPeriod, MaxPeriod;   
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   last_bar=0;
   last_deal=0;
//---
   atr=iATR(_Symbol,ATR_TimeFrame,ATR_Period);
   if(atr==INVALID_HANDLE)
      return INIT_FAILED;
//---
   force=iForce(_Symbol,Force_TimeFrame,Force_Period,Force_Method,Force_Volume);
   if(force==INVALID_HANDLE)
      return INIT_FAILED;
//---
   macd=iMACD(_Symbol,MACD_TimeFrame,MACD_Fast,MACD_Slow,MACD_Signal,MACD_Price);
   if(macd==INVALID_HANDLE)
      return INIT_FAILED;
//---
   cho=iChaikin(_Symbol,Ch_TimeFrame,Ch_Fast_Period,Ch_Slow_Period,Ch_Method,Ch_Volume);
   if(cho==INVALID_HANDLE)
      return INIT_FAILED;
//---
   cci=iCCI(_Symbol,CCI_TimeFrame,CCI_Period,CCI_Price);
   if(cci==INVALID_HANDLE)
      return INIT_FAILED;
//---
   MaxPeriod=fmax(Force_TimeFrame,MACD_TimeFrame);
   MaxPeriod=fmax(MaxPeriod,Ch_TimeFrame);
   MaxPeriod=fmax(MaxPeriod,CCI_TimeFrame);
   MinPeriod=fmin(Force_TimeFrame,MACD_TimeFrame);
   MinPeriod=fmin(MinPeriod,Ch_TimeFrame);
   MinPeriod=fmin(MinPeriod,CCI_TimeFrame);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(atr!=INVALID_HANDLE)
      IndicatorRelease(atr);
//---
   if(force==INVALID_HANDLE)
      IndicatorRelease(force);
//---
   if(macd==INVALID_HANDLE)
      IndicatorRelease(macd);
//---
   if(cho==INVALID_HANDLE)
      IndicatorRelease(cho);
//---
   if(cci==INVALID_HANDLE)
      IndicatorRelease(cci);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   //if(PositionSelect(_Symbol))
   //  {
   //   if(PositionGetDouble(POSITION_VOLUME)==Lot && PositionGetDouble(POSITION_PROFIT)>0)
   //      if(MathAbs(PositionGetDouble(POSITION_PRICE_CURRENT)-PositionGetDouble(POSITION_PRICE_OPEN))>=MathAbs(PositionGetDouble(POSITION_PRICE_OPEN)-PositionGetDouble(POSITION_SL)))
   //        {
   //         switch((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE))
   //           {
   //            case POSITION_TYPE_BUY:
   //              Trade.Sell(Lot/2);
   //              break;
   //            case POSITION_TYPE_SELL:
   //              Trade.Buy(Lot/2);
   //              break;
   //           }
   //        }
   //  }
//---
   datetime cur_bar=(datetime)SeriesInfoInteger(_Symbol,MinPeriod,SERIES_LASTBAR_DATE);
   datetime cur_max=(datetime)SeriesInfoInteger(_Symbol,MaxPeriod,SERIES_LASTBAR_DATE);
   datetime cur_time=TimeCurrent();
   if(cur_bar==last_bar || (cur_time-cur_bar)>10 || cur_max<=last_deal)
      return;
   last_bar=cur_bar;
   double atrs[];
   double force_data[];
   double macd_data[];
   double cho_data[];
   double cci_data[];
   if(CopyBuffer(atr,0,1,1,atrs)<=0 || CopyBuffer(force,0,1,1,force_data)<=0 || CopyBuffer(macd,0,1,1,macd_data)<=0
      || CopyBuffer(cho,0,1,2,cho_data)<2 || CopyBuffer(cci,0,1,2,cci_data)<2)
     {
      return;
     }
   double force_Step=_Point*1000;
   if(MathAbs(NormalizeDouble(force_data[0]/force_Step,0)*force_Step)<=0.01)
      return;

   double macd_Step=_Point*50;
   macd_data[0]=NormalizeDouble(macd_data[0]/macd_Step,0)*macd_Step;
   if(macd_data[0]>=0.0015 && macd_data[0]<=0.0035 && (cho_data[1]-cho_data[0])<0 && (cci_data[1]-cci_data[0])>0)
     {
      last_deal=cur_max;
      double stops=MathMax(2*atrs[0],SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*_Point);
      double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double sl=NormalizeDouble(stops,_Digits);
      double tp=NormalizeDouble(Reward_Risk*(stops+ask-bid),_Digits);
      double SL=NormalizeDouble(bid-sl,_Digits);
      double TP=NormalizeDouble(ask+tp,_Digits);
      if(PositionSelect(_Symbol))
        {
         switch((int)PositionGetInteger(POSITION_TYPE))
           {
            case POSITION_TYPE_BUY:
              if(PositionGetDouble(POSITION_PROFIT)<=0)
                 return;
              break;
            case POSITION_TYPE_SELL:
              Trade.PositionClose(_Symbol);
              break;
           }
        }
      if(!Trade.Buy(Lot,_Symbol,ask,SL,TP,"New Strategy"))
         Print("Error of open BUY ORDER "+Trade.ResultComment());
     }
   if(macd_data[0]<=(-0.0015) && macd_data[0]>=(-0.0035) && (cho_data[1]-cho_data[0])>0 && (cci_data[1]-cci_data[0])<0)
     {
      last_deal=cur_max;
      double stops=MathMax(2*atrs[0],SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*_Point);
      double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double sl=NormalizeDouble(stops,_Digits);
      double tp=NormalizeDouble(Reward_Risk*(stops+ask-bid),_Digits);
      double SL=NormalizeDouble(ask+sl,_Digits);
      double TP=NormalizeDouble(bid-tp,_Digits);
      if(PositionSelect(_Symbol))
        {
         switch((int)PositionGetInteger(POSITION_TYPE))
           {
            case POSITION_TYPE_SELL:
              if(PositionGetDouble(POSITION_PROFIT)<=0)
                 return;
              break;
            case POSITION_TYPE_BUY:
              Trade.PositionClose(_Symbol);
              break;
           }
        }
      if(!Trade.Sell(Lot,_Symbol,bid,SL,TP,"New Strategy"))
         Print("Error of open SELL ORDER "+Trade.ResultComment());
     }
   return;
  }
//+------------------------------------------------------------------+
