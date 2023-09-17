//+------------------------------------------------------------------+
//|                                                          444.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\SignalKalman.mqh>
#include <Expert\Signal\SignalDUAL_RA.mqh>
#include <Expert\Signal\SignalTEMA.mqh>
#include <Expert\Signal\SignalMACD.mqh>
//--- available trailing
#include <Expert\TrailingATR.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title                     ="444";       // Document name
ulong                    Expert_MagicNumber               =8927;        //
bool                     Expert_EveryTick                 =false;       //
//--- inputs for main signal
input int                Signal_ThresholdOpen             =10;          // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose            =10;          // Signal threshold value to close [0...100]
input double             Signal_PriceLevel                =0.0;         // Price level to execute a deal
input double             Signal_StopLevel                 =50.0;        // Stop Loss level (in points)
input double             Signal_TakeLevel                 =50.0;        // Take Profit level (in points)
input int                Signal_Expiration                =4;           // Expiration of pending orders (in bars)
input ENUM_TIMEFRAMES    Signal_Kalman_Filter_TimeFrame   =PERIOD_H1;   // Signals of Kalman's filter degign by DNG Timeframe
input uint               Signal_Kalman_Filter_HistoryBars =3000;        // Signals of Kalman's filter degign by DNG Bars in history to analysis
input uint               Signal_Kalman_Filter_ShiftPeriod =0;           // Signals of Kalman's filter degign by DNG Period for shift-----------------------------------------------
input double             Signal_Kalman_Filter_Weight      =1.0;         // Signals of Kalman's filter degign by DNG Weight [0...1.0]
input int                Signal_DUAL_RA_Size              =10;          // Dual Regression Analysis(10,...) Number of indepenedent variables
input int                Signal_DUAL_RA_OpenCollinearity  =1;           // Dual Regression Analysis(10,...) Open Collinearity mode
input double             Signal_DUAL_RA_OpenDetermination =0.0;         // Dual Regression Analysis(10,...) Open Determination threshold
input int                Signal_DUAL_RA_CloseCollinearity =1;           // Dual Regression Analysis(10,...) Close Collinearity mode
input double             Signal_DUAL_RA_CloseDetermination=0.0;         // Dual Regression Analysis(10,...) Close Determination threshold
input int                Signal_DUAL_RA_OpenError         =0;           // Dual Regression Analysis(10,...) Open Error check Type
input int                Signal_DUAL_RA_OpenData          =1;           // Dual Regression Analysis(10,...) Open Data Type
input int                Signal_DUAL_RA_CloseError        =0;           // Dual Regression Analysis(10,...) Close Error check Type
input int                Signal_DUAL_RA_CloseData         =1;           // Dual Regression Analysis(10,...) Close Data Type
input double             Signal_DUAL_RA_Weight            =1.0;         // Dual Regression Analysis(10,...) Weight [0...1.0]
input int                Signal_TEMA_PeriodMA             =12;          // Triple Exponential Moving Average Period of averaging
input int                Signal_TEMA_Shift                =0;           // Triple Exponential Moving Average Time shift
input ENUM_APPLIED_PRICE Signal_TEMA_Applied              =PRICE_CLOSE; // Triple Exponential Moving Average Prices series
input double             Signal_TEMA_Weight               =1.0;         // Triple Exponential Moving Average Weight [0...1.0]
input int                Signal_MACD_PeriodFast           =12;          // MACD(12,24,9,PRICE_CLOSE) D1 Period of fast EMA
input int                Signal_MACD_PeriodSlow           =24;          // MACD(12,24,9,PRICE_CLOSE) D1 Period of slow EMA
input int                Signal_MACD_PeriodSignal         =9;           // MACD(12,24,9,PRICE_CLOSE) D1 Period of averaging of difference
input ENUM_APPLIED_PRICE Signal_MACD_Applied              =PRICE_CLOSE; // MACD(12,24,9,PRICE_CLOSE) D1 Prices series
input double             Signal_MACD_Weight               =1.0;         // MACD(12,24,9,PRICE_CLOSE) D1 Weight [0...1.0]
//--- inputs for trailing
input int                Trailing_ATR_Period              =12;          // Period of ATR
input double             Trailing_ATR_Weight              =2.0;         // Weight of ATR multiple
//--- inputs for money
input double             Money_FixLot_Lots                =0.1;         // Fixed volume
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Creating signal
   CExpertSignal *signal=new CExpertSignal;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
//--- Creating filter CSignalKalman
   CSignalKalman *filter0=new CSignalKalman;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.TimeFrame(Signal_Kalman_Filter_TimeFrame);
   filter0.HistoryBars(Signal_Kalman_Filter_HistoryBars);
   filter0.ShiftPeriod(Signal_Kalman_Filter_ShiftPeriod);
   filter0.Weight(Signal_Kalman_Filter_Weight);
//--- Creating filter CSignalDUAL_RA
   CSignalDUAL_RA *filter1=new CSignalDUAL_RA;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.Size(Signal_DUAL_RA_Size);
   filter1.OpenCollinearity(Signal_DUAL_RA_OpenCollinearity);
   filter1.OpenDetermination(Signal_DUAL_RA_OpenDetermination);
   filter1.CloseCollinearity(Signal_DUAL_RA_CloseCollinearity);
   filter1.CloseDetermination(Signal_DUAL_RA_CloseDetermination);
   filter1.OpenError(Signal_DUAL_RA_OpenError);
   filter1.OpenData(Signal_DUAL_RA_OpenData);
   filter1.CloseError(Signal_DUAL_RA_CloseError);
   filter1.CloseData(Signal_DUAL_RA_CloseData);
   filter1.Weight(Signal_DUAL_RA_Weight);
//--- Creating filter CSignalTEMA
   CSignalTEMA *filter2=new CSignalTEMA;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.PeriodMA(Signal_TEMA_PeriodMA);
   filter2.Shift(Signal_TEMA_Shift);
   filter2.Applied(Signal_TEMA_Applied);
   filter2.Weight(Signal_TEMA_Weight);
//--- Creating filter CSignalMACD
   CSignalMACD *filter3=new CSignalMACD;
   if(filter3==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter3");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter3);
//--- Set filter parameters
   filter3.Period(PERIOD_D1);
   filter3.PeriodFast(Signal_MACD_PeriodFast);
   filter3.PeriodSlow(Signal_MACD_PeriodSlow);
   filter3.PeriodSignal(Signal_MACD_PeriodSignal);
   filter3.Applied(Signal_MACD_Applied);
   filter3.Weight(Signal_MACD_Weight);
//--- Creation of trailing object
   CTrailingATR *trailing=new CTrailingATR;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set trailing parameters
   trailing.Period(Trailing_ATR_Period);
   trailing.Weight(Trailing_ATR_Weight);
//--- Creation of money object
   CMoneyFixedLot *money=new CMoneyFixedLot;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set money parameters
   money.Lots(Money_FixLot_Lots);
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
