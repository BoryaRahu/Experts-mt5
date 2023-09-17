//+------------------------------------------------------------------+
//|                                                    expert_se.mq5 |
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
#include <Expert\Signal\SignalSE.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingNone.mqh>
//--- available money management
#include <Expert\Money\MoneyNone.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string Expert_Title            ="expert_se"; // Document name
ulong        Expert_MagicNumber      =17189;       //
bool         Expert_EveryTick        =false;       //
//--- inputs for main signal
input int    Signal_ThresholdOpen    =10;          // Signal threshold value to open [0...100]
input int    Signal_ThresholdClose   =10;          // Signal threshold value to close [0...100]
input double Signal_PriceLevel       =0.0;         // Price level to execute a deal
input double Signal_StopLevel        =50.0;        // Stop Loss level (in points)
input double Signal_TakeLevel        =50.0;        // Take Profit level (in points)
input int    Signal_Expiration       =4;           // Expiration of pending orders (in bars)
input bool   Signal_SE_Reset         =false;       // Shannon Entropy(false,50,...) Reset Training
input int    Signal_SE_Trees         =50;          // Shannon Entropy(false,50,...) Trees number
input double Signal_SE_Regularization=0.15;        // Shannon Entropy(false,50,...) Regularization Threshold
input int    Signal_SE_Trainings     =21;          // Shannon Entropy(false,50,...) Trainings number
input double Signal_SE_Weight        =1.0;         // Shannon Entropy(false,50,...) Weight [0...1.0]
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
CSignalSE *filter0;
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
//--- Creating filter CSignalSE
   filter0=new CSignalSE;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.Reset(Signal_SE_Reset);
   filter0.Trees(Signal_SE_Trees);
   filter0.Regularization(Signal_SE_Regularization);
   filter0.Trainings(Signal_SE_Trainings);
   filter0.Weight(Signal_SE_Weight);
//--- Creation of trailing object
   CTrailingNone *trailing=new CTrailingNone;
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
//--- Creation of money object
   CMoneyNone *money=new CMoneyNone;
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
     
		EventSetTimer(PeriodSeconds(Period()));
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
		//--- destroy timer
		EventKillTimer();
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!filter0.m_read_forest) filter0.WriteForest();
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
   if(PositionSelect(Symbol()) && Signal_ThresholdClose<=fabs(filter0.m_last_condition))
     {
      filter0.ResultUpdate(filter0.Result());
     }
   //
   if(!PositionSelect(Symbol()) && Signal_ThresholdOpen<=fabs(filter0.m_last_condition))
     {
      filter0.SignalUpdate(filter0.m_last_signal);
     }
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
