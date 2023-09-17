//+------------------------------------------------------------------+
//|                                                     mm_ha_ma.mqh |
//|                                                   Enrico Lambino |
//|                             https://www.mql5.com/en/users/iceron |
//+------------------------------------------------------------------+
#property copyright "Enrico Lambino."
#property link      "https://www.mql5.com/en/users/iceron"
#property version   "1.00"
#property strict
#include "MQLx\Base\OrderManager\OrderManagerBase.mqh"
#include "MQLx\Base\Signal\SignalsBase.mqh"
#include <Indicators\Custom.mqh>
input int maperiod=14;
input ENUM_MA_METHOD mamethod=MODE_SMA;
input ENUM_APPLIED_PRICE maapplied=PRICE_CLOSE;
input int signal_bar=1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CiHA: public CiCustom
  {
public:
                     CiHA(void);
                    ~CiHA(void);
   bool              Create(const string symbol,const ENUM_TIMEFRAMES period,
                            const ENUM_INDICATOR type,const int num_params,const MqlParam &params[],const int buffers);
   double            GetData(const int buffer_num,const int index) const;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CiHA::CiHA(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CiHA::~CiHA(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CiHA::Create(const string symbol,const ENUM_TIMEFRAMES period,const ENUM_INDICATOR type,const int num_params,const MqlParam &params[],const int buffers)
  {
   NumBuffers(buffers);
   if(CIndicator::Create(symbol,period,type,num_params,params))
      return Initialize(symbol,period,num_params,params);
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CiHA::GetData(const int buffer_num,const int index) const
  {
#ifdef __MQL5__
   return CiCustom::GetData(buffer_num,index);
#else
   return iCustom(m_symbol,m_period,m_params[0].string_value,buffer_num,index);
#endif
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class SignalHA: public CSignal
  {
protected:
   CiHA             *m_ha;
   CSymbolInfo      *m_symbol;
   string            m_symbol_name;
   int               m_signal_bar;
   double            m_open;
   double            m_close;
public:
   void              SignalHA(const string symbol,const ENUM_TIMEFRAMES timeframe,const int numparams,const MqlParam &params[],const int bar);
   void             ~SignalHA();
   virtual bool      Init(CSymbolManager *symbol_man,CEventAggregator *event_man=NULL);
   virtual bool      Calculate(void);
   virtual void      Update(void);
   virtual bool      LongCondition(void);
   virtual bool      ShortCondition(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SignalHA::SignalHA(const string symbol,const ENUM_TIMEFRAMES timeframe,const int numparams,const MqlParam &params[],const int bar)
  {
   m_symbol_name= symbol;
   m_signal_bar = bar;
   m_ha=new CiHA();
   m_ha.Create(symbol,timeframe,IND_CUSTOM,numparams,params,4);
   m_indicators.Add(m_ha);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SignalHA::~SignalHA(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalHA::Init(CSymbolManager *symbol_man,CEventAggregator *event_man=NULL)
  {
   if(CSignal::Init(symbol_man,event_man))
     {
      if(CheckPointer(m_symbol_man))
        {
         m_symbol=m_symbol_man.Get();
         if(CheckPointer(m_symbol))
            return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalHA::Calculate(void)
  {
#ifdef __MQL5__
   m_open=m_ha.GetData(0,signal_bar);
#else
   m_open=m_ha.GetData(2,signal_bar);
#endif
   m_close=m_ha.GetData(3,signal_bar);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SignalHA::Update(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalHA::LongCondition(void)
  {
   return m_open<m_close;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalHA::ShortCondition(void)
  {
   return m_open>m_close;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class SignalMA: public CSignal
  {
protected:
   CiMA             *m_ma;
   CSymbolInfo      *m_symbol;
   string            m_symbol_name;
   ENUM_TIMEFRAMES   m_timeframe;
   int               m_signal_bar;
   double            m_close;
public:
   void              SignalMA(const string symbol,const ENUM_TIMEFRAMES timeframe,const int period,const int shift,const ENUM_MA_METHOD method,const ENUM_APPLIED_PRICE applied,const int bar);
   virtual bool      Init(CSymbolManager *symbol_man,CEventAggregator *event_man=NULL);
   virtual bool      Calculate(void);
   virtual void      Update(void);
   virtual bool      LongCondition(void);
   virtual bool      ShortCondition(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SignalMA::SignalMA(const string symbol,const ENUM_TIMEFRAMES timeframe,const int period,const int shift,const ENUM_MA_METHOD method,const ENUM_APPLIED_PRICE applied,const int bar)
  {
   m_symbol_name=symbol;
   m_timeframe=timeframe;
   m_signal_bar=bar;
   m_ma=new CiMA();
   m_ma.Create(symbol,timeframe,period,0,method,applied);
   m_indicators.Add(m_ma);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalMA::Init(CSymbolManager *symbol_man,CEventAggregator *event_man=NULL)
  {
   if(CSignal::Init(symbol_man,event_man))
     {
      if(CheckPointer(m_symbol_man))
        {
         m_symbol=m_symbol_man.Get();
         if(CheckPointer(m_symbol))
            return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalMA::Calculate(void)
  {
   double close[];
   if(CopyClose(m_symbol_name,m_timeframe,signal_bar,1,close)>0)
     {
      m_close=close[0];
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SignalMA::Update(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalMA::LongCondition(void)
  {
   return m_close>m_ma.Main(m_signal_bar);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SignalMA::ShortCondition(void)
  {
   return m_close<m_ma.Main(m_signal_bar);
  }
COrderManager *order_manager;
CSymbolManager *symbol_manager;
CSymbolInfo *symbol_info;
CSignals *signals;
CMoneys *money_manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   order_manager=new COrderManager();
   money_manager = new CMoneys();
   CMoney *money_fixed= new CMoneyFixedLot(0.05);
   //CMoney *money_ff= new CMoneyFixedFractional(5);
   CMoney *money_ratio= new CMoneyFixedRatio(0,0.1,1000);
   //CMoney *money_riskperpoint= new CMoneyFixedRiskPerPoint(0.1);
   //CMoney *money_risk= new CMoneyFixedRisk(100);
   
   money_manager.Add(money_fixed);
   //money_manager.Add(money_ff);
   money_manager.Add(money_ratio);
   //money_manager.Add(money_riskperpoint);
   //money_manager.Add(money_risk);
   order_manager.AddMoneys(money_manager);
   //order_manager.Account(money_manager);
   symbol_manager=new CSymbolManager();
   symbol_info=new CSymbolInfo();
   if(!symbol_info.Name(Symbol()))
      Print("symbol not set");
   symbol_manager.Add(GetPointer(symbol_info));
   order_manager.Init(symbol_manager,new CAccountInfo());

   MqlParam params[1];
   params[0].type=TYPE_STRING;
#ifdef __MQL5__
   params[0].string_value="Examples\\Heiken_Ashi";
#else
   params[0].string_value="Heiken Ashi";
#endif
   SignalHA *signal_ha=new SignalHA(Symbol(),0,1,params,signal_bar);
   SignalMA *signal_ma=new SignalMA(Symbol(),(ENUM_TIMEFRAMES) Period(),maperiod,0,mamethod,maapplied,signal_bar);
   signals=new CSignals();
   signals.Add(GetPointer(signal_ha));
   signals.Add(GetPointer(signal_ma));
   signals.Init(GetPointer(symbol_manager),NULL);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   delete symbol_info;
   delete symbol_manager;
   delete order_manager;
   delete signals;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(symbol_info.RefreshRates())
     {
      signals.Check();
      if(signals.CheckOpenLong())
        {
         close_last();
         //Print("Entering buy trade..");
         money_manager.Selected(0);
         order_manager.TradeOpen(Symbol(),ORDER_TYPE_BUY,symbol_info.Ask());
        }
      else if(signals.CheckOpenShort())
        {
         close_last();
         //Print("Entering sell trade..");
         money_manager.Selected(1);
         order_manager.TradeOpen(Symbol(),ORDER_TYPE_SELL,symbol_info.Bid());
        }
     }
  }
//+------------------------------------------------------------------+
void close_last(void)
  {
   COrder *last=order_manager.LatestOrder();
   if(CheckPointer(last) && !last.IsClosed())
      order_manager.CloseOrder(last);
  }
//+------------------------------------------------------------------+
