//+------------------------------------------------------------------+
//|                                                           gg.mq5 |
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
#include <Expert\Signal\SignalATCF.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingParabolicSAR.mqh>
//--- available money management
#include <Expert\Money\MoneySizeOptimized.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string          Expert_Title                      ="gg";      // Document name
ulong                 Expert_MagicNumber                =15382;     //
bool                  Expert_EveryTick                  =false;     //
//--- inputs for main signal
input int             Signal_ThresholdOpen              =10;        // Signal threshold value to open [0...100]
input int             Signal_ThresholdClose             =10;        // Signal threshold value to close [0...100]
input double          Signal_PriceLevel                 =0.0;       // Price level to execute a deal
input double          Signal_StopLevel                  =50.0;      // Stop Loss level (in points)
input double          Signal_TakeLevel                  =50.0;      // Take Profit level (in points)
input int             Signal_Expiration                 =4;         // Expiration of pending orders (in bars)
input ENUM_TIMEFRAMES Signal_ATCF_TimeFrame             =PERIOD_H4; // Signals Adaptive Trend & Cycles Following Method Timeframe
input uint            Signal_ATCF_HistoryBars           =1560;      // Signals Adaptive Trend & Cycles Following Method Bars in history to analysis
input uint            Signal_ATCF_AveragePeriod         =500;       // Signals Adaptive Trend & Cycles Following Method Period for RBCI and PCCI
input bool            Signal_ATCF_Pattern1              =true;      // Signals Adaptive Trend & Cycles Following Method Use pattern 1
input bool            Signal_ATCF_Pattern2              =true;      // Signals Adaptive Trend & Cycles Following Method Use pattern 2
input bool            Signal_ATCF_Pattern3              =true;      // Signals Adaptive Trend & Cycles Following Method Use pattern 3
input bool            Signal_ATCF_Pattern4              =true;      // Signals Adaptive Trend & Cycles Following Method Use pattern 4
input bool            Signal_ATCF_Pattern5              =true;      // Signals Adaptive Trend & Cycles Following Method Use pattern 5
input bool            Signal_ATCF_Pattern6              =true;      // Signals Adaptive Trend & Cycles Following Method Use pattern 6
input bool            Signal_ATCF_Pattern7              =true;      // Signals Adaptive Trend & Cycles Following Method Use pattern 7
input bool            Signal_ATCF_Pattern8              =true;      // Signals Adaptive Trend & Cycles Following Method Use pattern 8--------------------------------------------------
input double          Signal_ATCF_Weight                =1.0;       // Signals Adaptive Trend & Cycles Following Method Weight [0...1.0]
//--- inputs for trailing
input double          Trailing_ParabolicSAR_Step        =0.02;      // Speed increment
input double          Trailing_ParabolicSAR_Maximum     =0.2;       // Maximum rate
//--- inputs for money
input double          Money_SizeOptimized_DecreaseFactor=3.0;       // Decrease factor
input double          Money_SizeOptimized_Percent       =10.0;      // Percent
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
//--- Creating filter CSignalATCF
   CSignalATCF *filter0=new CSignalATCF;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.TimeFrame(Signal_ATCF_TimeFrame);
   filter0.HistoryBars(Signal_ATCF_HistoryBars);
   filter0.AveragePeriod(Signal_ATCF_AveragePeriod);
   filter0.Pattern1(Signal_ATCF_Pattern1);
   filter0.Pattern2(Signal_ATCF_Pattern2);
   filter0.Pattern3(Signal_ATCF_Pattern3);
   filter0.Pattern4(Signal_ATCF_Pattern4);
   filter0.Pattern5(Signal_ATCF_Pattern5);
   filter0.Pattern6(Signal_ATCF_Pattern6);
   filter0.Pattern7(Signal_ATCF_Pattern7);
   filter0.Pattern8(Signal_ATCF_Pattern8);
   filter0.Weight(Signal_ATCF_Weight);
//--- Creation of trailing object
   CTrailingPSAR *trailing=new CTrailingPSAR;
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
   trailing.Step(Trailing_ParabolicSAR_Step);
   trailing.Maximum(Trailing_ParabolicSAR_Maximum);
//--- Creation of money object
   CMoneySizeOptimized *money=new CMoneySizeOptimized;
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
   money.DecreaseFactor(Money_SizeOptimized_DecreaseFactor);
   money.Percent(Money_SizeOptimized_Percent);
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
