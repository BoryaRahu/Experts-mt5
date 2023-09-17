//+------------------------------------------------------------------+
//|                                                           se.mq5 |
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
//--- available money_se management
#include <Expert\Money\MoneySE.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string Expert_Title            ="se";  // Document name
ulong        Expert_MagicNumber      =29562; //
bool         Expert_EveryTick        =false; //
//--- inputs for main signal
input int    Signal_ThresholdOpen    =5;    // Signal threshold value to open [0...100]
input int    Signal_ThresholdClose   =30;    // Signal threshold value to close [0...100]
input double Signal_PriceLevel       =25.0;   // Price level to execute a deal
input double Signal_StopLevel        =5.0;  // Stop Loss level (in points)
input double Signal_TakeLevel        =480.0;  // Take Profit level (in points)
input int    Signal_Expiration       =4;     // Expiration of pending orders (in bars)
input bool   Signal_SE_Reset         =false; // Shannon Entropy(false,50,...) Reset Training
input int    Signal_SE_Trees         =50;    // Shannon Entropy(false,50,...) Trees number
input double Signal_SE_Regularization=0.15;  // Shannon Entropy(false,50,...) Regularization Threshold
input int    Signal_SE_Trainings     =17;    // Shannon Entropy(false,50,...) Trainings number
input double Signal_SE_Weight        =1.0;   // Shannon Entropy(false,50,...) Weight [0...1.0]
//--- inputs for money_se
input int    Money_SE_ScaleFactor    =3;     // Scale factor
input double Money_SE_Percent        =10.0;  // Percent
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
CSignalSE *signal_se;
CMoneySE *money_se;
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
   signal_se=new CSignalSE;
   if(signal_se==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal_se");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(signal_se);
//--- Set filter parameters
   signal_se.Reset(Signal_SE_Reset);
   signal_se.Trees(Signal_SE_Trees);
   signal_se.Regularization(Signal_SE_Regularization);
   signal_se.Trainings(Signal_SE_Trainings);
   signal_se.Weight(Signal_SE_Weight);
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
//--- Creation of money_se object
   money_se=new CMoneySE;
   if(money_se==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money_se");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money_se to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money_se))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money_se");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set money_se parameters
   money_se.ScaleFactor(Money_SE_ScaleFactor);
   money_se.Percent(Money_SE_Percent);
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
   if(!signal_se.m_read_forest) signal_se.WriteForest();
   
   money_se.AbsoluteCondition(fabs(signal_se.m_last_condition));
   
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
   if(PositionSelect(Symbol()) && Signal_ThresholdClose<=fabs(signal_se.m_last_condition))
     {
      signal_se.ResultUpdate(signal_se.Result());
     }
   //
   if(!PositionSelect(Symbol()) && Signal_ThresholdOpen<=fabs(signal_se.m_last_condition))
     {
      signal_se.SignalUpdate(signal_se.m_last_signal);
     }
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
//| "Tester" event handler function                                  |
//+------------------------------------------------------------------+  
double OnTester()
   {
    signal_se.ReadForest();
    return(0.0);
   }
//+------------------------------------------------------------------+
