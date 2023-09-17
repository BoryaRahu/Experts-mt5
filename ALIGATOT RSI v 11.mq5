//+------------------------------------------------------------------+
//|                                              Bill Williams 2.mq5 |
//|                              Copyright © 2020, Vladimir Karputov |
//|                     https://www.mql5.com/ru/market/product/43516 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2020, Vladimir Karputov"
#property link      "https://www.mql5.com/ru/market/product/43516"
#property version   "2.000"
#property description "Version 2: One and the same fractal cannot be used in several signals"
/*
   barabashkakvn Trading engine 3.146
*/
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
//---
CPositionInfo  m_position;                   // object of CPositionInfo class
CTrade         m_trade;                      // object of CTrade class
CSymbolInfo    m_symbol;                     // object of CSymbolInfo class
CAccountInfo   m_account;                    // object of CAccountInfo class
CDealInfo      m_deal;                       // object of CDealInfo class
CMoneyFixedMargin *m_money;                  // object of CMoneyFixedMargin class
//+------------------------------------------------------------------+
//| Enum Lor or Risk                                                 |
//+------------------------------------------------------------------+
enum ENUM_LOT_OR_RISK
  {
   lots_min=0, // Lots Min
   lot=1,      // Constant lot
   risk=2,     // Risk in percent for a deal (range: from 1.00 to 100.00)
  };
//+------------------------------------------------------------------+
//| Enum Trade Mode                                                  |
//+------------------------------------------------------------------+
enum ENUM_TRADE_MODE
  {
   buy=0,      // Allowed only BUY positions
   sell=1,     // Allowed only SELL positions
   buy_sell=2, // Allowed BUY and SELL positions
  };
//+------------------------------------------------------------------+
//| Enum Pips Or Points                                              |
//+------------------------------------------------------------------+
enum ENUM_PIPS_OR_POINTS
  {
   pips=0,     // Pips (1.00045-1.00055=1 pips)
   points=1,   // Points (1.00045-1.00055=10 points)
  };
//--- input parameters
input group             "Trading settings"
input ENUM_TIMEFRAMES      InpWorkingPeriod=PERIOD_CURRENT; // Working timeframe
input ENUM_PIPS_OR_POINTS  InpPipsOrPoints=pips;            // Pips Or Points:
input uint     InpStopLoss          = 15;          // Stop Loss
input uint     InpTakeProfit        = 46;          // Take Profit
input ushort   InpTrailingFrequency = 10;          // Trailing, in seconds (< "10" -> only on a new bar)
input ushort   InpSignalsFrequency  = 9;           // Search signals, in seconds (< "10" -> only on a new bar)
input uint     InpTrailingStop      = 25;          // Trailing Stop (min distance from price to Stop Loss)
input uint     InpTrailingStep      = 5;           // Trailing Step
input group             "Position size management (lot calculation)"
input ENUM_LOT_OR_RISK InpLotOrRisk = lots_min;    // Money management: Lot OR Risk
input double   InpVolumeLotOrRisk   = 3.0;         // The value for "Money management"
input group             "Trade mode"
input ENUM_TRADE_MODE InpTradeMode  = buy_sell;    // Trade mode:
input group             "Time control"
input bool     InpTimeControl       = false;       // Use time control
input uchar    InpStartHour         = 10;          // Start Hour
input uchar    InpStartMinute       = 01;          // Start Minute
input uchar    InpEndHour           = 15;          // End Hour
input uchar    InpEndMinute         = 02;          // End Minute

input int                  maperiod      = 130;  // MA: period for the calculation of filter 
input group             "Alligator"
input int                  Inp_Alligator_jaw_period      = 13;             // Alligator: period for the calculation of jaws
input int                  Inp_Alligator_jaw_shift       = 8;              // Alligator: horizontal shift of jaws
input int                  Inp_Alligator_teeth_period    = 8;              // Alligator: period for the calculation of teeth
input int                  Inp_Alligator_teeth_shift     = 5;              // Alligator: horizontal shift of teeth
input int                  Inp_Alligator_lips_period     = 5;              // Alligator: period for the calculation of lips
input int                  Inp_Alligator_lips_shift      = 3;              // Alligator: horizontal shift of lips
input ENUM_MA_METHOD       Inp_Alligator_ma_method       = MODE_SMMA;      // Alligator: type of smoothing
input ENUM_APPLIED_PRICE   Inp_Alligator_applied_price   = PRICE_MEDIAN;   // Alligator: type of price
input group             "Additional features"
input bool     InpOnlyOne           = false;       // Positions: Only one
input bool     InpReverse           = true;        // Positions: Reverse
input bool     InpCloseOpposite     = false;       // Positions: Close opposite
input bool     InpPrintLog          = false;       // Print log
input uchar    InpFreezeCoefficient = 1;           // Coefficient (if Freeze==0 Or StopsLevels==0)
input ulong    InpDeviation         = 10;          // Deviation
input ulong    InpMagic             = 200;         // Magic number
//---
double   m_stop_loss                = 0.0;      // Stop Loss                  -> double
double   m_take_profit              = 0.0;      // Take Profit                -> double
double   m_trailing_stop            = 0.0;      // Trailing Stop              -> double
double   m_trailing_step            = 0.0;      // Trailing Step              -> double

int      handle_iFractals;                      // variable for storing the handle of the iFractals indicator
int      handle_iAlligator;                     // variable for storing the handle of the iAlligator indicator
int      handle_iMA; 
double   m_adjusted_point;                      // point value adjusted for 3 or 5 points
datetime m_last_trailing            = 0;        // "0" -> D'1970.01.01 00:00';
datetime m_last_signal              = 0;        // "0" -> D'1970.01.01 00:00';
datetime m_prev_bars                = 0;        // "0" -> D'1970.01.01 00:00';
datetime m_last_deal_in             = 0;        // "0" -> D'1970.01.01 00:00';
datetime m_signal_bars_up           = 0;        // "0" -> D'1970.01.01 00:00';
datetime m_signal_bars_down         = 0;        // "0" -> D'1970.01.01 00:00';
int      m_bar_current              = 0;
//--- the tactic is this: for positions we strictly monitor the result,
//---    and pending orders (if the spread was verified)
//---    just shoot and zero out the arrays of structures
//+------------------------------------------------------------------+
//| Structure Positions                                              |
//+------------------------------------------------------------------+
struct STRUCT_POSITION
  {
   ENUM_POSITION_TYPE pos_type;              // position type
   bool              waiting_transaction;    // waiting transaction, "true" -> it's forbidden to trade, we expect a transaction
   ulong             waiting_order_ticket;   // waiting order ticket, ticket of the expected order
   bool              transaction_confirmed;  // transaction confirmed, "true" -> transaction confirmed
   //--- Constructor
                     STRUCT_POSITION()
     {
      pos_type                   = WRONG_VALUE;
      waiting_transaction        = false;
      waiting_order_ticket       = 0;
      transaction_confirmed      = false;
     }
  };
STRUCT_POSITION SPosition[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(InpTrailingStop!=0 && InpTrailingStep==0)
     {
      string err_text=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")?
                      "Трейлинг невозможен: параметр \"Trailing Step\" равен нулю!":
                      "Trailing is not possible: parameter \"Trailing Step\" is zero!";
      //--- when testing, we will only output to the log about incorrect input parameters
      if(MQLInfoInteger(MQL_TESTER))
        {
         Print(__FILE__," ",__FUNCTION__,", ERROR: ",err_text);
         return(INIT_FAILED);
        }
      else // if the Expert Advisor is run on the chart, tell the user about the error
        {
         Alert(__FILE__," ",__FUNCTION__,", ERROR: ",err_text);
         return(INIT_PARAMETERS_INCORRECT);
        }
     }
//---
   ResetLastError();
   if(!m_symbol.Name(Symbol())) // sets symbol name
     {
      Print(__FILE__," ",__FUNCTION__,", ERROR: CSymbolInfo.Name");
      return(INIT_FAILED);
     }
   RefreshRates();
//---
   m_trade.SetExpertMagicNumber(InpMagic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
   m_trade.SetDeviationInPoints(InpDeviation);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
   if(InpPipsOrPoints==pips) // Pips (1.00045-1.00055=1 pips)
     {
      m_stop_loss                = InpStopLoss                 * m_adjusted_point;
      m_take_profit              = InpTakeProfit               * m_adjusted_point;
      m_trailing_stop            = InpTrailingStop             * m_adjusted_point;
      m_trailing_step            = InpTrailingStep             * m_adjusted_point;
     }
   else // Points (1.00045-1.00055=10 points)
     {
      m_stop_loss                = InpStopLoss                 * m_symbol.Point();
      m_take_profit              = InpTakeProfit               * m_symbol.Point();
      m_trailing_stop            = InpTrailingStop             * m_symbol.Point();
      m_trailing_step            = InpTrailingStep             * m_symbol.Point();
     }
//--- check the input parameter "Lots"
   string err_text="";
   if(InpLotOrRisk==lot)
     {
      if(!CheckVolumeValue(InpVolumeLotOrRisk,err_text))
        {
         //--- when testing, we will only output to the log about incorrect input parameters
         if(MQLInfoInteger(MQL_TESTER))
           {
            Print(__FILE__," ",__FUNCTION__,", ERROR: ",err_text);
            return(INIT_FAILED);
           }
         else // if the Expert Advisor is run on the chart, tell the user about the error
           {
            Alert(__FILE__," ",__FUNCTION__,", ERROR: ",err_text);
            return(INIT_PARAMETERS_INCORRECT);
           }
        }
     }
   else
      if(InpLotOrRisk==risk)
        {
         if(m_money!=NULL)
            delete m_money;
         m_money=new CMoneyFixedMargin;
         if(m_money!=NULL)
           {
            if(InpVolumeLotOrRisk<1 || InpVolumeLotOrRisk>100)
              {
               Print(__FILE__," ",__FUNCTION__,", ERROR: ");
               Print("The value for \"Money management\" (",DoubleToString(InpVolumeLotOrRisk,2),") -> invalid parameters");
               Print("   parameter must be in the range: from 1.00 to 100.00");
               return(INIT_FAILED);
              }
            if(!m_money.Init(GetPointer(m_symbol),InpWorkingPeriod,m_symbol.Point()*digits_adjust))
              {
               Print(__FILE__," ",__FUNCTION__,", ERROR: CMoneyFixedMargin.Init");
               return(INIT_FAILED);
              }
            m_money.Percent(InpVolumeLotOrRisk);
           }
         else
           {
            Print(__FILE__," ",__FUNCTION__,", ERROR: Object CMoneyFixedMargin is NULL");
            return(INIT_FAILED);
           }
        }
//--- create handle of the indicator iFractals
   handle_iFractals=iFractals(m_symbol.Name(),Period());
//--- if the handle is not created
   if(handle_iFractals==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iFractals indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      return(INIT_FAILED);
     }
//--- create handle of the indicator iAlligator
   handle_iAlligator=iAlligator(m_symbol.Name(),Period(),Inp_Alligator_jaw_period,Inp_Alligator_jaw_shift,
                                Inp_Alligator_teeth_period,Inp_Alligator_teeth_shift,
                                Inp_Alligator_lips_period,Inp_Alligator_lips_shift,MODE_SMMA,PRICE_MEDIAN);
//--- if the handle is not created
   if(handle_iAlligator==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iAlligator indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      return(INIT_FAILED);
     }
     
     
   handle_iMA=iMA(m_symbol.Name(),Period(),maperiod, 1,MODE_EMA,PRICE_CLOSE );
//--- if the handle is not created
   if(handle_iFractals==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iFractals indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      return(INIT_FAILED);
     }  
     
     
     
     
     
     
     
     
//---
   m_bar_current=(InpSignalsFrequency<10)?1:0;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(m_money!=NULL)
      delete m_money;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
MqlRates rates[];
double _FRACTAL[];
 ArraySetAsSeries(_FRACTAL,true);
  CopyBuffer(handle_iFractals,0,0,5,_FRACTAL);
   int start_pos=0,count=100;
 double _MA[];
 ArraySetAsSeries(_MA,true);
  CopyBuffer(handle_iMA,0,0,5,_MA);  
   
   if (_MA[1] >_FRACTAL[1] )




   ClosePositions(POSITION_TYPE_SELL);




   int size_need_position=ArraySize(SPosition);
   if(size_need_position>0)
     {
      for(int i=size_need_position-1; i>=0; i--)
        {
         if(SPosition[i].waiting_transaction)
           {
            if(!SPosition[i].transaction_confirmed)
              {
               if(InpPrintLog)
                  Print(__FILE__," ",__FUNCTION__,", OK: ","transaction_confirmed: ",SPosition[i].transaction_confirmed);
               return;
              }
            else
               if(SPosition[i].transaction_confirmed)
                 {
                  ArrayRemove(SPosition,i,1);
                  return;
                 }
           }
         if(SPosition[i].pos_type==POSITION_TYPE_BUY)
           {
            if(InpCloseOpposite || InpOnlyOne)
              {
               int      count_buys           = 0;
               double   volume_buys          = 0.0;
               double   volume_biggest_buys  = 0.0;
               int      count_sells          = 0;
               double   volume_sells         = 0.0;
               double   volume_biggest_sells = 0.0;
               CalculateAllPositions(count_buys,volume_buys,volume_biggest_buys,
                                     count_sells,volume_sells,volume_biggest_sells);
               if(InpCloseOpposite)
                 {
                  if(count_sells>0)
                    {
                     ClosePositions(POSITION_TYPE_SELL);
                     return;
                    }
                 }
               if(InpOnlyOne)
                 {
                  if(count_buys+count_sells==0)
                    {
                     SPosition[i].waiting_transaction=true;
                     OpenPosition(i);
                     return;
                    }
                  else
                     ArrayRemove(SPosition,i,1);
                  return;
                 }
              }
            SPosition[i].waiting_transaction=true;
            OpenPosition(i);
            return;
           }
         if(SPosition[i].pos_type==POSITION_TYPE_SELL)
           {
            if(InpCloseOpposite || InpOnlyOne)
              {
               int      count_buys           = 0;
               double   volume_buys          = 0.0;
               double   volume_biggest_buys  = 0.0;
               int      count_sells          = 0;
               double   volume_sells         = 0.0;
               double   volume_biggest_sells = 0.0;
               CalculateAllPositions(count_buys,volume_buys,volume_biggest_buys,
                                     count_sells,volume_sells,volume_biggest_sells);
               if(InpCloseOpposite)
                 {
                  if(count_buys>0)
                    {
                     ClosePositions(POSITION_TYPE_BUY);
                     return;
                    }
                 }
               if(InpOnlyOne)
                 {
                  if(count_buys+count_sells==0)
                    {
                     SPosition[i].waiting_transaction=true;
                     OpenPosition(i);
                     return;
                    }
                  else
                     ArrayRemove(SPosition,i,1);
                  return;
                 }
              }
            SPosition[i].waiting_transaction=true;
            OpenPosition(i);
            return;
           }
        }
     }
//---
   if(InpTrailingFrequency>=10) // trailing no more than once every 10 seconds
     {
      datetime time_current=TimeCurrent();
      if(time_current-m_last_trailing>InpTrailingFrequency)
        {
         Trailing();
         m_last_trailing=time_current;
        }
     }
   if(InpSignalsFrequency>=10) // search for trading signals no more than once every 10 seconds
     {
      datetime time_current=TimeCurrent();
      if(time_current-m_last_signal>InpSignalsFrequency)
        {
         //--- search for trading signals
         if(!RefreshRates())
            return;
         if(!SearchTradingSignals())
            return;
         m_last_signal=time_current;
        }
     }
//--- we work only at the time of the birth of new bar
   if(InpTrailingFrequency<10 || InpSignalsFrequency<10)
     {
      datetime time_0=iTime(m_symbol.Name(),InpWorkingPeriod,0);
      if(time_0==m_prev_bars)
         return;
      m_prev_bars=time_0;
      if(InpTrailingFrequency<10) // trailing only at the time of the birth of new bar
        {
         Trailing();
        }
      if(InpSignalsFrequency<10) // search for trading signals only at the time of the birth of new bar
        {
         if(!RefreshRates())
           {
            m_prev_bars=0;
            return;
           }
         //--- search for trading signals
         if(!SearchTradingSignals())
           {
            m_prev_bars=0;
            return;
           }
        }
     }
//---
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//--- get transaction type as enumeration value
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      ResetLastError();
      if(HistoryDealSelect(trans.deal))
         m_deal.Ticket(trans.deal);
      else
        {
         Print(__FILE__," ",__FUNCTION__,", ERROR: ","HistoryDealSelect(",trans.deal,") error: ",GetLastError());
         return;
        }
      if(m_deal.Symbol()==m_symbol.Name() && m_deal.Magic()==InpMagic)
        {
         if(m_deal.DealType()==DEAL_TYPE_BUY || m_deal.DealType()==DEAL_TYPE_SELL)
           {
            if(m_deal.Entry()==DEAL_ENTRY_IN || m_deal.Entry()==DEAL_ENTRY_INOUT)
               m_last_deal_in=iTime(m_symbol.Name(),InpWorkingPeriod,0);
            int size_need_position=ArraySize(SPosition);
            if(size_need_position>0)
              {
               for(int i=0; i<size_need_position; i++)
                 {
                  if(SPosition[i].waiting_transaction)
                     if(SPosition[i].waiting_order_ticket==m_deal.Order())
                       {
                        Print(__FUNCTION__," Transaction confirmed");
                        SPosition[i].transaction_confirmed=true;
                        break;
                       }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print(__FILE__," ",__FUNCTION__,", ERROR: ","RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
     {
      Print(__FILE__," ",__FUNCTION__,", ERROR: ","Ask == 0.0 OR Bid == 0.0");
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the correctness of the position volume                     |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=m_symbol.LotsMin();
   if(volume<min_volume)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем меньше минимально допустимого SYMBOL_VOLUME_MIN=%.2f",min_volume);
      else
         error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем больше максимально допустимого SYMBOL_VOLUME_MAX=%.2f",max_volume);
      else
         error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем не кратен минимальному шагу SYMBOL_VOLUME_STEP=%.2f, ближайший правильный объем %.2f",
                                        volume_step,ratio*volume_step);
      else
         error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                        volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check Freeze and Stops levels                                    |
//+------------------------------------------------------------------+
void FreezeStopsLevels(double &freeze,double &stops)
  {
//--- check Freeze and Stops levels
   /*
   SYMBOL_TRADE_FREEZE_LEVEL shows the distance of freezing the trade operations
      for pending orders and open positions in points
   ------------------------|--------------------|--------------------------------------------
   Type of order/position  |  Activation price  |  Check
   ------------------------|--------------------|--------------------------------------------
   Buy Limit order         |  Ask               |  Ask-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy Stop order          |  Ask               |  OpenPrice-Ask  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Limit order        |  Bid               |  OpenPrice-Bid  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Stop order         |  Bid               |  Bid-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy position            |  Bid               |  TakeProfit-Bid >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  Bid-StopLoss   >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell position           |  Ask               |  Ask-TakeProfit >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  StopLoss-Ask   >= SYMBOL_TRADE_FREEZE_LEVEL
   ------------------------------------------------------------------------------------------

   SYMBOL_TRADE_STOPS_LEVEL determines the number of points for minimum indentation of the
      StopLoss and TakeProfit levels from the current closing price of the open position
   ------------------------------------------------|------------------------------------------
   Buying is done at the Ask price                 |  Selling is done at the Bid price
   ------------------------------------------------|------------------------------------------
   TakeProfit        >= Bid                        |  TakeProfit        <= Ask
   StopLoss          <= Bid                        |  StopLoss          >= Ask
   TakeProfit - Bid  >= SYMBOL_TRADE_STOPS_LEVEL   |  Ask - TakeProfit  >= SYMBOL_TRADE_STOPS_LEVEL
   Bid - StopLoss    >= SYMBOL_TRADE_STOPS_LEVEL   |  StopLoss - Ask    >= SYMBOL_TRADE_STOPS_LEVEL
   ------------------------------------------------------------------------------------------
   */
   double coeff=(double)InpFreezeCoefficient;
   if(!RefreshRates() || !m_symbol.Refresh())
      return;
//--- FreezeLevel -> for pending order and modification
   double freeze_level=m_symbol.FreezeLevel()*m_symbol.Point();
   if(freeze_level==0.0)
      if(InpFreezeCoefficient>0)
         freeze_level=(m_symbol.Ask()-m_symbol.Bid())*coeff;
//--- StopsLevel -> for TakeProfit and StopLoss
   double stop_level=m_symbol.StopsLevel()*m_symbol.Point();
   if(stop_level==0.0)
      if(InpFreezeCoefficient>0)
         stop_level=(m_symbol.Ask()-m_symbol.Bid())*coeff;
//---
   freeze=freeze_level;
   stops=stop_level;
//---
   return;
  }
//+------------------------------------------------------------------+
//| Open position                                                    |
//|   double stop_loss                                               |
//|      -> pips * m_adjusted_point (if "0.0" -> the m_stop_loss)    |
//|   double take_profit                                             |
//|      -> pips * m_adjusted_point (if "0.0" -> the m_take_profit)  |
//+------------------------------------------------------------------+
void OpenPosition(const int index)
  {
   double freeze=0.0,stops=0.0;
   FreezeStopsLevels(freeze,stops);
   /*
   SYMBOL_TRADE_STOPS_LEVEL determines the number of points for minimum indentation of the
      StopLoss and TakeProfit levels from the current closing price of the open position
   ------------------------------------------------|------------------------------------------
   Buying is done at the Ask price                 |  Selling is done at the Bid price
   ------------------------------------------------|------------------------------------------
   TakeProfit        >= Bid                        |  TakeProfit        <= Ask
   StopLoss          <= Bid                        |  StopLoss          >= Ask
   TakeProfit - Bid  >= SYMBOL_TRADE_STOPS_LEVEL   |  Ask - TakeProfit  >= SYMBOL_TRADE_STOPS_LEVEL
   Bid - StopLoss    >= SYMBOL_TRADE_STOPS_LEVEL   |  StopLoss - Ask    >= SYMBOL_TRADE_STOPS_LEVEL
   ------------------------------------------------------------------------------------------
   */
//--- buy
   if(SPosition[index].pos_type==POSITION_TYPE_BUY)
     {
      double sl=(m_stop_loss==0.0)?0.0:m_symbol.Ask()-m_stop_loss;
      if(sl>0.0)
         if(m_symbol.Bid()-sl<stops)
            sl=m_symbol.Bid()-stops;
      double tp=(m_take_profit==0.0)?0.0:m_symbol.Bid()+m_take_profit;
      if(tp>0.0)
         if(tp-m_symbol.Ask()<stops)
            tp=m_symbol.Ask()+stops*5;
     // ОШИБКА OpenBuy(index,sl,tp);
      return;
     }
//--- sell
   if(SPosition[index].pos_type==POSITION_TYPE_SELL)
     {
      double sl=(m_stop_loss==0.0)?0.0:m_symbol.Bid()+m_stop_loss;
      if(sl>0.0)
         if(sl-m_symbol.Ask()<stops)
            sl=m_symbol.Ask()+stops;
      double tp=(m_take_profit==0.0)?0.0:m_symbol.Ask()-m_take_profit;
      if(tp>0.0)
         if(m_symbol.Bid()-tp<stops)
            tp=m_symbol.Bid()-stops*5;
      OpenSell(index,sl,tp);
      return;
     }
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(const int index,double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
   double long_lot=0.0;
   if(InpLotOrRisk==risk)
     {
      long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
      if(InpPrintLog)
         Print(__FILE__," ",__FUNCTION__,", OK: ","sl=",DoubleToString(sl,m_symbol.Digits()),
               ", CheckOpenLong: ",DoubleToString(long_lot,2),
               ", Balance: ",    DoubleToString(m_account.Balance(),2),
               ", Equity: ",     DoubleToString(m_account.Equity(),2),
               ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
      if(long_lot==0.0)
        {
         ArrayRemove(SPosition,index,1);
         if(InpPrintLog)
            Print(__FILE__," ",__FUNCTION__,", ERROR: ","CMoneyFixedMargin.CheckOpenLong returned the value of 0.0");
         return;
        }
     }
   else
      if(InpLotOrRisk==lot)
         long_lot=InpVolumeLotOrRisk;
      else
         if(InpLotOrRisk==lots_min)
            long_lot=m_symbol.LotsMin();
         else
           {
            ArrayRemove(SPosition,index,1);
            return;
           }
//---
   if(m_symbol.LotsLimit()>0.0)
     {
      int      count_buys           = 0;
      double   volume_buys          = 0.0;
      double   volume_biggest_buys  = 0.0;
      int      count_sells          = 0;
      double   volume_sells         = 0.0;
      double   volume_biggest_sells = 0.0;
      CalculateAllPositions(count_buys,volume_buys,volume_biggest_buys,
                            count_sells,volume_sells,volume_biggest_sells);
      if(volume_buys+volume_sells+long_lot>m_symbol.LotsLimit())
        {
         ArrayRemove(SPosition,index,1);
         if(InpPrintLog)
            Print(__FILE__," ",__FUNCTION__,", ERROR: ","#0 Buy, Volume Buy (",DoubleToString(volume_buys,2),
                  ") + Volume Sell (",DoubleToString(volume_sells,2),
                  ") + Volume long (",DoubleToString(long_lot,2),
                  ") > Lots Limit (",DoubleToString(m_symbol.LotsLimit(),2),")");
         return;
        }
     }
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double free_margin_check=m_account.FreeMarginCheck(m_symbol.Name(),
                            ORDER_TYPE_BUY,
                            long_lot,
                            m_symbol.Ask());
   double margin_check=m_account.MarginCheck(m_symbol.Name(),
                       ORDER_TYPE_BUY,
                       long_lot,
                       m_symbol.Ask());
   if(free_margin_check>margin_check)
     {
      if(m_trade.Buy(long_lot,m_symbol.Name(),
      
                     m_symbol.Ask(),sl,tp)) // CTrade::Buy -> "true"
        {
         if(m_trade.ResultDeal()==0)
           {
            if(m_trade.ResultRetcode()==10009) // trade order went to the exchange
              {
               SPosition[index].waiting_transaction=true;
               SPosition[index].waiting_order_ticket=m_trade.ResultOrder();
              }
            else
              {
               SPosition[index].waiting_transaction=false;
               if(InpPrintLog)
                  Print(__FILE__," ",__FUNCTION__,", ERROR: ","#1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            if(InpPrintLog)
               PrintResultTrade(m_trade,m_symbol);
           }
         else
           {
            if(m_trade.ResultRetcode()==10009)
              {
               SPosition[index].waiting_transaction=true;
               SPosition[index].waiting_order_ticket=m_trade.ResultOrder();
              }
            else
              {
               SPosition[index].waiting_transaction=false;
               if(InpPrintLog)
                  Print(__FILE__," ",__FUNCTION__,", OK: ","#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            if(InpPrintLog)
               PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         SPosition[index].waiting_transaction=false;
         if(InpPrintLog)
            Print(__FILE__," ",__FUNCTION__,", ERROR: ","#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
         if(InpPrintLog)
            PrintResultTrade(m_trade,m_symbol);
        }
     }
   else
     {
      ArrayRemove(SPosition,index,1);
      if(InpPrintLog)
         Print(__FILE__," ",__FUNCTION__,", ERROR: ","CAccountInfo.FreeMarginCheck returned the value ",DoubleToString(free_margin_check,2));
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(const int index,double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
   double short_lot=0.0;
   if(InpLotOrRisk==risk)
     {
      short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
      if(InpPrintLog)
         Print(__FILE__," ",__FUNCTION__,", OK: ","sl=",DoubleToString(sl,m_symbol.Digits()),
               ", CheckOpenLong: ",DoubleToString(short_lot,2),
               ", Balance: ",    DoubleToString(m_account.Balance(),2),
               ", Equity: ",     DoubleToString(m_account.Equity(),2),
               ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
      if(short_lot==0.0)
        {
         ArrayRemove(SPosition,index,1);
         if(InpPrintLog)
            Print(__FILE__," ",__FUNCTION__,", ERROR: ","CMoneyFixedMargin.CheckOpenShort returned the value of \"0.0\"");
         return;
        }
     }
   else
      if(InpLotOrRisk==lot)
         short_lot=InpVolumeLotOrRisk;
      else
         if(InpLotOrRisk==lots_min)
            short_lot=m_symbol.LotsMin();
         else
           {
            ArrayRemove(SPosition,index,1);
            return;
           }
//---
   if(m_symbol.LotsLimit()>0.0)
     {
      int      count_buys           = 0;
      double   volume_buys          = 0.0;
      double   volume_biggest_buys  = 0.0;
      int      count_sells          = 0;
      double   volume_sells         = 0.0;
      double   volume_biggest_sells = 0.0;
      CalculateAllPositions(count_buys,volume_buys,volume_biggest_buys,
                            count_sells,volume_sells,volume_biggest_sells);
      if(volume_buys+volume_sells+short_lot>m_symbol.LotsLimit())
        {
         ArrayRemove(SPosition,index,1);
         if(InpPrintLog)
            Print(__FILE__," ",__FUNCTION__,", ERROR: ","#0 Buy, Volume Buy (",DoubleToString(volume_buys,2),
                  ") + Volume Sell (",DoubleToString(volume_sells,2),
                  ") + Volume short (",DoubleToString(short_lot,2),
                  ") > Lots Limit (",DoubleToString(m_symbol.LotsLimit(),2),")");
         return;
        }
     }
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double free_margin_check=m_account.FreeMarginCheck(m_symbol.Name(),
                            ORDER_TYPE_SELL,
                            short_lot,
                            m_symbol.Bid());
   double margin_check=m_account.MarginCheck(m_symbol.Name(),
                       ORDER_TYPE_SELL,
                       short_lot,
                       m_symbol.Bid());
   if(free_margin_check>margin_check)
     {
      if(m_trade.Sell(short_lot,m_symbol.Name(),
                      m_symbol.Bid(),sl,tp)) // CTrade::Sell -> "true"
        {
         if(m_trade.ResultDeal()==0)
           {
            if(m_trade.ResultRetcode()==10009) // trade order went to the exchange
              {
               SPosition[index].waiting_transaction=true;
               SPosition[index].waiting_order_ticket=m_trade.ResultOrder();
              }
            else
              {
               SPosition[index].waiting_transaction=false;
               if(InpPrintLog)
                  Print(__FILE__," ",__FUNCTION__,", ERROR: ","#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            if(InpPrintLog)
               PrintResultTrade(m_trade,m_symbol);
           }
         else
           {
            if(m_trade.ResultRetcode()==10009)
              {
               SPosition[index].waiting_transaction=true;
               SPosition[index].waiting_order_ticket=m_trade.ResultOrder();
              }
            else
              {
               SPosition[index].waiting_transaction=false;
               if(InpPrintLog)
                  Print(__FILE__," ",__FUNCTION__,", OK: ","#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            if(InpPrintLog)
               PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         SPosition[index].waiting_transaction=false;
         if(InpPrintLog)
            Print(__FILE__," ",__FUNCTION__,", ERROR: ","#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
         if(InpPrintLog)
            PrintResultTrade(m_trade,m_symbol);
        }
     }
   else
     {
      ArrayRemove(SPosition,index,1);
      if(InpPrintLog)
         Print(__FILE__," ",__FUNCTION__,", ERROR: ","CAccountInfo.FreeMarginCheck returned the value ",DoubleToString(free_margin_check,2));
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResultTrade(CTrade &trade,CSymbolInfo &symbol)
  {
   Print(__FILE__," ",__FUNCTION__,", Symbol: ",symbol.Name()+", "+
         "Code of request result: "+IntegerToString(trade.ResultRetcode())+", "+
         "Code of request result as a string: "+trade.ResultRetcodeDescription(),
         "Trade execution mode: "+symbol.TradeExecutionDescription());
   Print("Deal ticket: "+IntegerToString(trade.ResultDeal())+", "+
         "Order ticket: "+IntegerToString(trade.ResultOrder())+", "+
         "Order retcode external: "+IntegerToString(trade.ResultRetcodeExternal())+", "+
         "Volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("Price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits())+", "+
         "Current bid price: "+DoubleToString(symbol.Bid(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultBid(),symbol.Digits())+", "+
         "Current ask price: "+DoubleToString(symbol.Ask(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("Broker comment: "+trade.ResultComment());
  }
//+------------------------------------------------------------------+
//| Get value of buffers                                             |
//+------------------------------------------------------------------+
bool iGetArray(const int handle,const int buffer,const int start_pos,
               const int count,double &arr_buffer[])
  {
   bool result=true;
   if(!ArrayIsDynamic(arr_buffer))
     {
      if(InpPrintLog)
         PrintFormat("ERROR! EA: %s, FUNCTION: %s, this a no dynamic array!",__FILE__,__FUNCTION__);
      return(false);
     }
   ArrayFree(arr_buffer);
//--- reset error code
   ResetLastError();
//--- fill a part of the iBands array with values from the indicator buffer
   int copied=CopyBuffer(handle,buffer,start_pos,count,arr_buffer);
   if(copied!=count)
     {
      //--- if the copying fails, tell the error code
      if(InpPrintLog)
         PrintFormat("ERROR! EA: %s, FUNCTION: %s, amount to copy: %d, copied: %d, error code %d",
                     __FILE__,__FUNCTION__,count,copied,GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
     }
   return(result);
  }
//+------------------------------------------------------------------+
//| Trailing                                                         |
//|   InpTrailingStop: min distance from price to Stop Loss          |
//+------------------------------------------------------------------+
void Trailing()
  {
   if(InpTrailingStop==0)
      return;
   double freeze=0.0,stops=0.0;
   FreezeStopsLevels(freeze,stops);
   /*
   SYMBOL_TRADE_FREEZE_LEVEL shows the distance of freezing the trade operations
      for pending orders and open positions in points
   ------------------------|--------------------|--------------------------------------------
   Type of order/position  |  Activation price  |  Check
   ------------------------|--------------------|--------------------------------------------
   Buy Limit order         |  Ask               |  Ask-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy Stop order          |  Ask               |  OpenPrice-Ask  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Limit order        |  Bid               |  OpenPrice-Bid  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Stop order         |  Bid               |  Bid-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy position            |  Bid               |  TakeProfit-Bid >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  Bid-StopLoss   >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell position           |  Ask               |  Ask-TakeProfit >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  StopLoss-Ask   >= SYMBOL_TRADE_FREEZE_LEVEL
   ------------------------------------------------------------------------------------------
   */
   for(int i=PositionsTotal()-1; i>=0; i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==InpMagic)
           {
            double price_current = m_position.PriceCurrent();
            double price_open    = m_position.PriceOpen();
            double stop_loss     = m_position.StopLoss();
            double take_profit   = m_position.TakeProfit();
            double ask           = m_symbol.Ask();
            double bid           = m_symbol.Bid();
            //---
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(price_current-price_open>m_trailing_stop+m_trailing_step)
                  if(stop_loss<price_current-(m_trailing_stop+m_trailing_step))
                     if(m_trailing_stop>=freeze && (take_profit-bid>=freeze || take_profit==0.0))
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                                                   m_symbol.NormalizePrice(price_current-m_trailing_stop),
                                                   take_profit))
                           if(InpPrintLog)
                              Print(__FILE__," ",__FUNCTION__,", ERROR: ","Modify BUY ",m_position.Ticket(),
                                    " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                    ", description of result: ",m_trade.ResultRetcodeDescription());
                        if(InpPrintLog)
                          {
                           RefreshRates();
                           m_position.SelectByIndex(i);
                           PrintResultModify(m_trade,m_symbol,m_position);
                          }
                        continue;
                       }
              }
            else
              {
               if(price_open-price_current>m_trailing_stop+m_trailing_step)
                  if((stop_loss>(price_current+(m_trailing_stop+m_trailing_step))) || (stop_loss==0))
                     if(m_trailing_stop>=freeze && ask-take_profit>=freeze)
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                                                   m_symbol.NormalizePrice(price_current+m_trailing_stop),
                                                   take_profit))
                           if(InpPrintLog)
                              Print(__FILE__," ",__FUNCTION__,", ERROR: ","Modify SELL ",m_position.Ticket(),
                                    " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                    ", description of result: ",m_trade.ResultRetcodeDescription());
                        if(InpPrintLog)
                          {
                           RefreshRates();
                           m_position.SelectByIndex(i);
                           PrintResultModify(m_trade,m_symbol,m_position);
                          }
                       }
              }
           }
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResultModify(CTrade &trade,CSymbolInfo &symbol,CPositionInfo &position)
  {
   Print("File: ",__FILE__,", symbol: ",symbol.Name());
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result as a string: "+trade.ResultRetcodeDescription());
   Print("Deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("Order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("Volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("Price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("Current bid price: "+DoubleToString(symbol.Bid(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("Current ask price: "+DoubleToString(symbol.Ask(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("Broker comment: "+trade.ResultComment());
   Print("Freeze Level: "+DoubleToString(symbol.FreezeLevel(),0),", Stops Level: "+DoubleToString(symbol.StopsLevel(),0));
   Print("Price of position opening: "+DoubleToString(position.PriceOpen(),symbol.Digits()));
   Print("Price of position's Stop Loss: "+DoubleToString(position.StopLoss(),symbol.Digits()));
   Print("Price of position's Take Profit: "+DoubleToString(position.TakeProfit(),symbol.Digits()));
   Print("Current price by position: "+DoubleToString(position.PriceCurrent(),symbol.Digits()));
  }
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions(const ENUM_POSITION_TYPE pos_type)
  {
   double freeze=0.0,stops=0.0;
   FreezeStopsLevels(freeze,stops);
   /*
   SYMBOL_TRADE_FREEZE_LEVEL shows the distance of freezing the trade operations
      for pending orders and open positions in points
   ------------------------|--------------------|--------------------------------------------
   Type of order/position  |  Activation price  |  Check
   ------------------------|--------------------|--------------------------------------------
   Buy Limit order         |  Ask               |  Ask-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy Stop order          |  Ask               |  OpenPrice-Ask  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Limit order        |  Bid               |  OpenPrice-Bid  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Stop order         |  Bid               |  Bid-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy position            |  Bid               |  TakeProfit-Bid >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  Bid-StopLoss   >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell position           |  Ask               |  Ask-TakeProfit >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  StopLoss-Ask   >= SYMBOL_TRADE_FREEZE_LEVEL
   ------------------------------------------------------------------------------------------
   */
   for(int i=PositionsTotal()-1; i>=0; i--) // returns the number of current positions
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==InpMagic)
            if(m_position.PositionType()==pos_type)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                 {
                  bool take_profit_level=((m_position.TakeProfit()!=0.0 && m_position.TakeProfit()-m_position.PriceCurrent()>=freeze) || m_position.TakeProfit()==0.0);
                  bool stop_loss_level=((m_position.StopLoss()!=0.0 && m_position.PriceCurrent()-m_position.StopLoss()>=freeze) || m_position.StopLoss()==0.0);
                  if(take_profit_level && stop_loss_level)
                     if(!m_trade.PositionClose(m_position.Ticket())) // close a position by the specified m_symbol
                        if(InpPrintLog)
                           Print(__FILE__," ",__FUNCTION__,", ERROR: ","BUY PositionClose ",m_position.Ticket(),", ",m_trade.ResultRetcodeDescription());
                 }
               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  bool take_profit_level=((m_position.TakeProfit()!=0.0 && m_position.PriceCurrent()-m_position.TakeProfit()>=freeze) || m_position.TakeProfit()==0.0);
                  bool stop_loss_level=((m_position.StopLoss()!=0.0 && m_position.StopLoss()-m_position.PriceCurrent()>=freeze) || m_position.StopLoss()==0.0);
                  if(take_profit_level && stop_loss_level)
                     if(!m_trade.PositionClose(m_position.Ticket())) // close a position by the specified m_symbol
                        if(InpPrintLog)
                           Print(__FILE__," ",__FUNCTION__,", ERROR: ","SELL PositionClose ",m_position.Ticket(),", ",m_trade.ResultRetcodeDescription());
                 }
              }
  }
//+------------------------------------------------------------------+
//| Calculate all positions                                          |
//+------------------------------------------------------------------+
void CalculateAllPositions(int &count_buys,double &volume_buys,double &volume_biggest_buys,
                           int &count_sells,double &volume_sells,double &volume_biggest_sells)
  {
   count_buys  = 0;
   volume_buys   = 0.0;
   volume_biggest_buys  = 0.0;
   count_sells = 0;
   volume_sells  = 0.0;
   volume_biggest_sells = 0.0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               count_buys++;
               volume_buys+=m_position.Volume();
               if(m_position.Volume()>volume_biggest_buys)
                  volume_biggest_buys=m_position.Volume();
               continue;
              }
            else
               if(m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  count_sells++;
                  volume_sells+=m_position.Volume();
                  if(m_position.Volume()>volume_biggest_sells)
                     volume_biggest_sells=m_position.Volume();
                 }
           }
  }
//+------------------------------------------------------------------+
//| Search trading signals                                           |
//+------------------------------------------------------------------+
bool SearchTradingSignals(void)
  {
   if(iTime(m_symbol.Name(),InpWorkingPeriod,0)==m_last_deal_in) // on one bar - only one deal
      return(true);
   if(!TimeControlHourMinute())
      return(true);
   double fractals_upper[],fractals_lower[],jaw[],teeth[],lips[],_MA[];
   MqlRates rates[];
   ArraySetAsSeries(fractals_upper,true);
   ArraySetAsSeries(fractals_lower,true);
   ArraySetAsSeries(jaw,true);
   ArraySetAsSeries(teeth,true);
   ArraySetAsSeries(lips,true);
   ArraySetAsSeries(rates,true);
   ArraySetAsSeries(_MA,true);
  CopyBuffer(handle_iMA,0,0,200,_MA);
   int start_pos=0,count=100;
   if(!iGetArray(handle_iFractals,UPPER_LINE,start_pos,count,fractals_upper) ||
      !iGetArray(handle_iFractals,LOWER_LINE,start_pos,count,fractals_lower) ||
      !iGetArray(handle_iAlligator,GATORJAW_LINE,start_pos,count,jaw) ||
      !iGetArray(handle_iAlligator,GATORTEETH_LINE,start_pos,count,teeth) ||
      !iGetArray(handle_iAlligator,GATORLIPS_LINE,start_pos,count,lips) ||
      CopyRates(m_symbol.Name(),InpWorkingPeriod,start_pos,count,rates)!=count)
     {
      return(false);
     }
//---
   int size_need_position=ArraySize(SPosition);
   if(size_need_position>0)
      return(true);
//---
   double fractals_up         = EMPTY_VALUE;
   double fractals_down       = EMPTY_VALUE;
   int    fractals_up_number  = -1;
   int    fractals_down_number= -1;
   for(int i=35; i<count; i++)
     {
      if(fractals_upper[i]!=0.0 && fractals_upper[i]!=EMPTY_VALUE)
         if(fractals_up==EMPTY_VALUE)
           {
            fractals_up=fractals_upper[i];
            fractals_up_number=i;
           }
      if(fractals_lower[i]!=0.0 && fractals_lower[i]!=EMPTY_VALUE)
         if(fractals_down==EMPTY_VALUE)
           {
            fractals_down=fractals_lower[i];
            fractals_down_number=i;
           }
      if(fractals_up!=EMPTY_VALUE && fractals_down!=EMPTY_VALUE)
         break;
     }
   if(fractals_up==EMPTY_VALUE || fractals_down==EMPTY_VALUE)
      return(false);
//--- BUY signal
   if(//fractals_up>jaw[fractals_up_number] &&fractals_up>teeth[fractals_up_number] &&
      //fractals_up>lips[fractals_up_number] && m_symbol.Ask()>fractals_up
     // && jaw[fractals_up_number]>jaw[fractals_up_number-1]
      
    // fractals_down < jaw[fractals_up_number] &&fractals_down<teeth[fractals_up_number] &&// 250    100
    // fractals_down < lips[fractals_up_number] && m_symbol.Ask()>fractals_down
    //  && jaw[fractals_up_number]>jaw[fractals_up_number-1] 
      
  1>1
    
      
      
      )
      
      
      
     {
      if(rates[fractals_up_number].time==m_signal_bars_up)
         return(true);
      m_signal_bars_up=rates[fractals_up_number].time;
      if(!InpReverse)
        {
         if(InpTradeMode!=sell)
           {
            ArrayResize(SPosition,size_need_position+1);
            SPosition[size_need_position].pos_type=POSITION_TYPE_BUY;
            if(InpPrintLog)
               Print(__FILE__," ",__FUNCTION__,", OK: ","Signal BUY");
            return(true);
           }
        }
      else
        {
         if(InpTradeMode!=buy)
           {
            ArrayResize(SPosition,size_need_position+1);
            SPosition[size_need_position].pos_type=POSITION_TYPE_SELL;
            if(InpPrintLog)
               Print(__FILE__," ",__FUNCTION__,", OK: ","Signal SELL");
            return(true);
           }
        }
     }
//--- SELL signal
   if(
   //fractals_down<jaw[fractals_down_number] && fractals_down<teeth[fractals_down_number] &&
      //fractals_down<lips[fractals_down_number] && m_symbol.Bid()<fractals_down
      //&& jaw[fractals_up_number]<jaw[fractals_up_number-1]
    
      fractals_up <jaw[fractals_up_number]&&fractals_up<teeth[fractals_up_number] &&fractals_up<lips[fractals_up_number]
      && m_symbol.Ask()<fractals_up
      //&& m_symbol.Bid()<fractals_down
      && jaw[fractals_up_number]
      && jaw[fractals_up_number]>jaw[fractals_up_number-5] 
      && jaw[fractals_up_number-5]>jaw[fractals_up_number-15] 
      && jaw[fractals_up_number-15]>jaw[fractals_up_number-34] 
      
     && _MA[2] > _MA[1]
      &&_MA[45] > _MA[2]
      &&_MA[134] > _MA[45]
      )
  
    
    /* 
    _MA[1]>lips[fractals_down_number]&&
    _MA[1]>jaw[fractals_down_number]&&
    _MA[1]>teeth[fractals_down_number]&&
      m_symbol.Bid()< _MA[1]
       &&fractals_down< jaw[fractals_up_number]
      &&  m_symbol.Ask()>jaw[fractals_up_number]
    //  && _MA[2] > _MA[1]
    //  &&_MA[45] > _MA[2]
     // &&_MA[134] > _MA[45]
      && jaw[fractals_up_number]<jaw[fractals_up_number-1]
     // && jaw[fractals_up_number]>jaw[fractals_up_number-5] 
     // && jaw[fractals_up_number-5]>jaw[fractals_up_number-15] 
     // && jaw[fractals_up_number-15]>jaw[fractals_up_number-34] 
      
   && _MA[2] > _MA[1]
     &&_MA[45] > _MA[2]
     &&_MA[134] > _MA[45]
     */
   //   )
      
      
      
      
      
      
      
     {
      if(rates[fractals_down_number].time==m_signal_bars_down)
         return(true);
      m_signal_bars_down=rates[fractals_down_number].time;
      if(!InpReverse)
        {
         if(InpTradeMode!=buy)
           {
            ArrayResize(SPosition,size_need_position+1);
            SPosition[size_need_position].pos_type=POSITION_TYPE_SELL;
            if(InpPrintLog)
               Print(__FILE__," ",__FUNCTION__,", OK: ","Signal SELL");
            return(true);
           }
        }
      else
        {
         if(InpTradeMode!=sell)
           {
            ArrayResize(SPosition,size_need_position+1);
            SPosition[size_need_position].pos_type=POSITION_TYPE_BUY;
            if(InpPrintLog)
               Print(__FILE__," ",__FUNCTION__,", OK: ","Signal BUY");
            return(true);
           }
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| TimeControl                                                      |
//+------------------------------------------------------------------+
bool TimeControlHourMinute(void)
  {
   if(!InpTimeControl)
      return(true);
   MqlDateTime STimeCurrent;
   datetime time_current=TimeCurrent();
   if(time_current==D'1970.01.01 00:00')
      return(false);
   TimeToStruct(time_current,STimeCurrent);
   if((InpStartHour*60*60+InpStartMinute*60)<(InpEndHour*60*60+InpEndMinute*60)) // intraday time interval
     {
      /*
      Example:
      input uchar    InpStartHour      = 5;        // Start hour
      input uchar    InpEndHour        = 10;       // End hour
      0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19 20 21 22 23 0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15
      _  _  _  _  _  +  +  +  +  +  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  _  +  +  +  +  +  _  _  _  _  _  _
      */
      if((STimeCurrent.hour*60*60+STimeCurrent.min*60>=InpStartHour*60*60+InpStartMinute*60) &&
         (STimeCurrent.hour*60*60+STimeCurrent.min*60<InpEndHour*60*60+InpEndMinute*60))
         return(true);
     }
   else
      if((InpStartHour*60*60+InpStartMinute*60)>(InpEndHour*60*60+InpEndMinute*60)) // time interval with the transition in a day
        {
         /*
         Example:
         input uchar    InpStartHour      = 10;       // Start hour
         input uchar    InpEndHour        = 5;        // End hour
         0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19 20 21 22 23 0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15
         _  _  _  _  _  _  _  _  _  _  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  +  _  _  _  _  _  +  +  +  +  +  +
         */
         if(STimeCurrent.hour*60*60+STimeCurrent.min*60>=InpStartHour*60*60+InpStartMinute*60 ||
            STimeCurrent.hour*60*60+STimeCurrent.min*60<InpEndHour*60*60+InpEndMinute*60)
            return(true);
        }
      else
         return(false);
//---
   return(false);
  }
//+------------------------------------------------------------------+
