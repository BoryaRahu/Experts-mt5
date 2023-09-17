//+------------------------------------------------------------------+
//|                                   SMACrossAutoCorr_EURUSDM15.mq5 |
//|                                         Copyright 2022, R.Poster |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>

CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object
COrderInfo     m_order;                      // pending orders object
CMoneyFixedMargin *m_money;

#define NAME		"SMACrossAutoCorr_EURUSDM15" 
//
// enumerations
 enum Prof_Type
  {
   Both     = 0,  // winning or losing trades
   Positive = 1,  // winning trades
   Negative = 2   // losing trades
  };
  //
// global values
  double MULT;
  ulong  m_slippage=10;                // slippage
  double ExtStopLoss=0.0;
  double ExtTakeProfit=0.0;
  double ExtTrailingStop=0.0;
  double ExtTrailingStep=0.0;
  ulong  m_magic;
  double m_tickvalue;
  int   _spread;
//+------------------------------------------------------------------+
//| Expert Advisor input parameters                                  |
//+------------------------------------------------------------------+

//--- Indicator parameters 
  input    ENUM_TIMEFRAMES      Timeframe=PERIOD_M15;   // Working Timeframe 
  //
  input string    Label1  ="----- Trigger Data -----";   
  input int       MagicNum      = 123456;        //Magic number                                     
  input int       SMA_Per1      =    2;          // Fast SMA Period
  input int       SMA_Per2      =   80;          // SLow SMA Period
  input double    DiffLim       =   0.;          // Total SMA Diff Limit 
  input int       CorrLen       =   45;          //  Correlation Length
  input int       LagLen        =    1;          //  Lag Period
  input double    CorrThrsh    =   0.015;        // Corr Threshold

// Bollinger Band external parameters
  input int       BBPeriod       =   20;         // Bollinger Band Period
  input double    BBSigma        =  2.0;         // BB Sigma
  input double    BBSprd_LwLim   =   15.;        // BB Lower Limit
  input double    BBSprd_UpLim   =   85.;        // BB Upper Limit
  input int       RSI_Per        =   14;         // RSI Period

//--- Money Management
  input string    Label2  ="----- Money Mgmt-----";      
  input double    Lots         =  0.1;                    //Lots
//
  input int       take_profit   =  80;        //Take Profit(points)  
  input int       stop_loss     =  75;        //Stop Loss(points)
  input int       trail_stop    =  30;        //Trailing Stop
  input int       trail_step    =  4;         //Trailing Step
  //
  input string    Label3  ="----- Entry/Close Data -----";   
  input bool      TimeFilters   =  true;
  input int       Day1          =   99;       // Disable Day 1 Trades
  input int       Day2          =   99;       // Disable Day 2 Trades
  input int       entryhour     =    4;       // Trade Entry Hour
  input int       openhours     =   18;       // Trade Entry Duration Hours
  input int       FridayEndHour =   23;       // Friday End Hour
  input int       MaxOpenPos    =    1;       // Maximum open positions            
  input int       MaxOpnMins    = 1650;       // Maximum Trade Open Time 
  input Prof_Type  ProfitType    =    2;       // Prof Type for Cls Trd (1=Prof,2=Loss)


  int Ind_Handle1,Ind_Handle2,Ind_Handle3,Ind_Handle4,Ind_Handle5;
  int Ind_Handle;
  string ind_type;  // custome indicator name
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Checking connection to the trade server
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
     {
      Print(": No Connection!");
      return(INIT_FAILED);
     }

//--- Checking automated trading permission
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Print(" Trade is not allowed!");
      return(INIT_FAILED);
     }
 //  
   MULT=1.0;
   if(_Digits==5 || _Digits==3) MULT=10.0; 
   //
   ExtStopLoss       = stop_loss * _Point*MULT;
   ExtTakeProfit     = take_profit * _Point*MULT;
   ExtTrailingStop   = trail_stop * _Point*MULT;
   ExtTrailingStep   = trail_step * _Point*MULT;
   //
   m_magic = MagicNum;
   //
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   m_tickvalue = m_symbol.TickValue();
      //
   RefreshRates();
//--- init trade data
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
   m_trade.SetDeviationInPoints(m_slippage);
// ------   
   //
//--- Getting the indicator handles 
   Ind_Handle1 = iRSI(_Symbol,0,RSI_Per,PRICE_CLOSE);
   Ind_Handle2 = iMA(_Symbol,0,SMA_Per1,0,MODE_SMA,PRICE_CLOSE);
   if(Ind_Handle2==INVALID_HANDLE)
     {
      printf("Error creating MA fast indicator");
      return(INIT_FAILED);
     }
   Ind_Handle3 = iMA(_Symbol,0,SMA_Per2,0,MODE_SMA,PRICE_CLOSE);
   if(Ind_Handle3==INVALID_HANDLE)
     {
      printf("Error creating MA slo indicator");
      return(INIT_FAILED);
     }
   Ind_Handle4 = iBands(_Symbol,0,BBPeriod,0,BBSigma,PRICE_CLOSE);
//   Ind_Handle=iCustom(Symbol(),Timeframe,ind_type,5);
   if(Ind_Handle2==INVALID_HANDLE || Ind_Handle3==INVALID_HANDLE)
     {
      Print(" Failed to get SMA indicator handle");
      Print("Handle = ",Ind_Handle1," ; ",Ind_Handle2,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Getting data for calculations
   bool TBuy,TSell;
   int open_trades,opn_mins;
   double takeprofit,stoploss,ordlots;
   open_trades = NumOpenedBySymbol(_Symbol,MagicNum);
   // manage trailing stop
   if(trail_stop>0 && open_trades>0) Trailing();
   //
 //  ----- check for new bar ------------------------------------------
   if(!IsNewBar()) return;  // return if already have open trades or not new bar
   // ----------- new bar ---------------------
   RefreshRates();
  // ------  close trade --------------------
    if(MaxOpnMins>0 && PositionsTotal()>0)
     {
      opn_mins = GetOpenTime(); // length of time trade is open
  //    Print(" ***** Open Minutes ",opn_mins);// ******
      if(opn_mins>MaxOpnMins) ClosePositionsByProf(ProfitType);
     }
   //---------------------------------------
     // open trades below max (=0)
   if(open_trades>=MaxOpenPos) return;
//
   _spread=m_symbol.Spread();
   // call triggger
   SMACrossTrigger(TBuy,TSell);
   // if doing time filtering
   if(TimeFilters && !Trig_Filters()) return;
   // setup input to trading functions
   takeprofit = ExtTakeProfit;
   stoploss   = ExtStopLoss;
   ordlots = Lots;
   RefreshRates();
 //--- Opening an order for buy signal
   if(TBuy) OpenBuy(ordlots,takeprofit,stoploss);    
  //--- Opening an order for sell signal
   if(TSell) OpenSell(ordlots,takeprofit,stoploss);
    //
   return;
  }
//-------------------------------------------------------------------------------------
void SMACrossTrigger( bool &TBuy, bool &TSell)
//+---------------------------------------------------------------+
//| fast SMA crosses up (Buy) or down (Sell) over slow SMA        |
//+---------------------------------------------------------------+
  {
//
   double SMADiff3,SMADiff2,SMADiff1,SMADiff4;
   double SMA1Buf[6],SMA2Buf[6],BollUprBuf[6],BollLwrBuf[6];
   double  BB_Spread;  
   double AIn[];
   double CorrVal;
   int jj;
   TBuy =  false;
   TSell = false;
 //   boll band buffers
   if(!GetIndValue(Ind_Handle4,1,0,5,BollUprBuf))  return; 
   if(!GetIndValue(Ind_Handle4,2,0,5,BollLwrBuf))  return; 
   //
   BB_Spread = (BollUprBuf[1]-BollLwrBuf[1])/(_Point*MULT); 
   if(BB_Spread<BBSprd_LwLim) return; 
   if(BB_Spread>BBSprd_UpLim) return; 
   // SMA buffers
   if(!GetIndValue(Ind_Handle2,0,0,5,SMA1Buf)) return; // fast sma
   if(!GetIndValue(Ind_Handle3,0,0,5,SMA2Buf)) return;  // slow sma
//   Print(" SMA 1 buffer ",SMA1Buf[0],"  ",SMA1Buf[1],"  ",SMA1Buf[2],"  ",SMA1Buf[3],"  ",SMA1Buf[4]);// *****
   
   SMADiff4 = (SMA1Buf[4]- SMA2Buf[4])/(_Point*MULT);
   SMADiff3 = (SMA1Buf[3]- SMA2Buf[3])/(_Point*MULT);
   SMADiff2 = (SMA1Buf[2]- SMA2Buf[2])/(_Point*MULT);
   SMADiff1 = (SMA1Buf[1]- SMA2Buf[1])/(_Point*MULT);  
//     
// ----- Auto Corr
   ArrayResize(AIn,CorrLen);
   for(jj=0;jj<CorrLen;jj++)
    {
     AIn[jj] = (iClose(_Symbol,0,jj+1)-iOpen(_Symbol,0,jj+1))/(_Point*MULT);
    }
   CorrVal = GetAtCorrVal(AIn,CorrLen,LagLen,0);
   if(SMADiff4<0. && SMADiff3<0. && SMADiff2<0. && SMADiff1>0. &&  (SMADiff1-SMADiff2)> DiffLim && 
       CorrVal>CorrThrsh) TBuy=true;  
   if(SMADiff4>0. && SMADiff3>0. && SMADiff2>0. && SMADiff1<0.  && (SMADiff2-SMADiff1)> DiffLim &&
      CorrVal>CorrThrsh) TSell=true;
   return;
  }
  //------------------------------------------------------------------------
  //+-----------------------------------------------------------------+
//|  AutoCorrelation Function
//+-----------------------------------------------------------------+
 double GetAtCorrVal(double &ClsOpn[],int CorrPer, int LagPer,int joff )
  {
   double corr;
   double AIn[],BIn[];
   double XMean,XNum,XDen;
   int jj;
   ArrayResize(AIn,CorrPer);
   ArrayResize(BIn,CorrPer);
   XMean = 0.;
   XNum = 0.;
   XDen = 0.;
   corr = 0.;
   if(CorrPer<2)
    {
     Print("No AutoCorr Processing Allowed ");
     return(corr);
    }
   // mean
   for(jj=0;jj<CorrPer;jj++)
    {
     XMean +=ClsOpn[jj+joff];
    }
   XMean = XMean/CorrPer;
  // variances 
   for(jj=0;jj<CorrPer;jj++)
    {
     if(jj<(CorrPer-LagPer)) 
       XNum  += (ClsOpn[jj+joff]-XMean)*(ClsOpn[jj+LagPer+joff]-XMean);
     XDen += (ClsOpn[jj+joff]-XMean)*(ClsOpn[jj+joff]-XMean);
    }  
    if(XDen==0.) Print( " ERROR AutoCorr per= ",CorrPer," ClsOPn ",ClsOpn[0],ClsOpn[CorrPer-1]);
   corr = XNum/XDen;
   return(corr); 
  }
//----------------------------------------------------------------
//----------------------------------------------------------------------------------
   bool Trig_Filters()
    {
     // Buy ot Sell signal is true upon entry
     // Set Buy and Sell signals to false if meet filter criteria
      datetime bartime_current;
      int hour_current,day_current;
      MqlDateTime s1;
      bool TradeOK;
      //
      bartime_current =iTime(_Symbol,0,0);
      TimeToStruct(bartime_current,s1);
      hour_current = s1.hour;
      day_current =  s1.day_of_week;
      TradeOK = true;
      //
      if(day_current==Day1 || day_current==Day2)
       {
        TradeOK = false;
       }
      if(hour_current>=FridayEndHour && day_current==5)
       {
        TradeOK = false;
       }
      // ---------------- Hour of Day Filer -----------------------------------------    
      if(!HourRange(hour_current,entryhour,openhours)) TradeOK=false;        
      return(TradeOK);
    }
 // --------------------------------------------------------------------------------  
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue(int Handle,int BufNum,int StartPos,int TotCopy,double &JBuffer[] )
  {
   int copied,jj;
   copied = 0;
   double IBuffer[];
   ArrayResize(IBuffer,TotCopy);
   ArrayInitialize(IBuffer,0.0);
   ArraySetAsSeries(IBuffer,true);

  // args: handle, buffer #, start pos, # copy, buffer)
  copied = CopyBuffer(Handle,BufNum,StartPos,TotCopy,IBuffer);
  for(jj=0;jj<TotCopy;jj++)
   {
    JBuffer[jj] = IBuffer[jj];
   }
  return(copied<=0)?false:true;
//   return(CopyBuffer(Handle,BufNum,StartPos,TotCopy,IBuffer)<=0)?false:true;
  }
//+------------------------------------------------------------------+
bool IsNewBar()
 {
  bool res;
  static datetime bartime_current;
  datetime bartime_previous;
  //
  res=false;
  bartime_previous = bartime_current;
  bartime_current =iTime(Symbol(),0,0);
  //
  if(bartime_current!=bartime_previous) res=true;
  return(res);
 }
 
//+------------------------------------------------------------------+
//| Trailing Stop                                                    |
//|  TrailingStop: min distance from price to Stop Loss              |
//+------------------------------------------------------------------+
void Trailing()
  {
   //
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStop+ExtTrailingStep)
                  if(m_position.StopLoss()<m_position.PriceCurrent()-(ExtTrailingStop+ExtTrailingStep))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTrailingStop),
                        m_position.TakeProfit()))
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                     RefreshRates();
                     m_position.SelectByIndex(i);
                     PrintResultModify(m_trade,m_symbol,m_position);
                     continue;
                    }
              }
            else
              {
               if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStop+ExtTrailingStep)
                  if((m_position.StopLoss()>(m_position.PriceCurrent()+(ExtTrailingStop+ExtTrailingStep))) || 
                     (m_position.StopLoss()==0))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtTrailingStop),
                        m_position.TakeProfit()))
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                     RefreshRates();
                     m_position.SelectByIndex(i);
                     PrintResultModify(m_trade,m_symbol,m_position);
                    }
              }

           }
           
  } //
  //-------------------------------------------------------------------------------------------
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void ClosePositionsType(const ENUM_POSITION_TYPE pos_type)
  {
  // know position type: = POSITION_TYPE_BUY, POSITION_TYPE_SELL
  // close poldest first
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions()
  {
  // close oldest first
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//-------------------------------------------------------------------
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void ClosePositionsByProf(int ProfType)
  {
   double profit;
  // close oldest first
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
    {
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
       {
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
          {
           profit = m_position.Profit();
           if((ProfType==0 || ProfType==1) && profit>0.)
             m_trade.PositionClose(m_position.Ticket()); //
           if((ProfType==0 || ProfType==2) && profit<=0.)
             m_trade.PositionClose(m_position.Ticket()); //            
         }
       }
     }  // ----- loop
   return;
  }
//-------------------------------------------------------------------
  //+----------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double orderlots, double takeprofit,double stoploss)
  {
   double price,sl,tp, long_lot;
   price=m_symbol.Ask();
   sl=price-stoploss;    // stoploss modified for digits already
   tp=price+takeprofit;  // takeprofit modified for digits already
//
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   long_lot=orderlots;
 //  Print("***DEBUG1 ",orderlots,"  ",takeprofit,"  ",stoploss,"  ",price);//********************************************
 //  Print("***DEBUG2 ",orderlots,"  ",tp,"  ",sl);//********************************************

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double free_margin_check=m_account.FreeMarginCheck(m_symbol.Name(),ORDER_TYPE_BUY,long_lot,m_symbol.Ask());
   if(free_margin_check>0.0)
     {
      if(m_trade.Buy(long_lot,m_symbol.Name(),m_symbol.Ask(),sl,tp))
        {
         if(m_trade.ResultDeal()==0)
           {
            Print("#1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
         else
           {
            Print("#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         Print("#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         PrintResultTrade(m_trade,m_symbol);
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CAccountInfo::FreeMarginCheck returned the value ",DoubleToString(free_margin_check,2));
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double orderlots, double takeprofit,double stoploss)
  {
   double price,sl,tp, short_lot;
   //
   price=m_symbol.Bid();
   sl=price+stoploss;
   tp=price-takeprofit;
//
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//

   short_lot=orderlots;
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double free_margin_check=m_account.FreeMarginCheck(m_symbol.Name(),ORDER_TYPE_SELL,short_lot,m_symbol.Bid());
   if(free_margin_check>0.0)
     {
      if(m_trade.Sell(short_lot,NULL,m_symbol.Bid(),sl,tp))
        {
         if(m_trade.ResultDeal()==0)
           {
            Print("#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
         else
           {
            Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         PrintResultTrade(m_trade,m_symbol);
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CAccountInfo::FreeMarginCheck returned the value ",DoubleToString(free_margin_check,2));
      return;
     }
//---
  }
  //---------------------------------------------------------------------------------------
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResultTrade(CTrade &trade,CSymbolInfo &symbol)
  {
   Print("File: ",__FILE__,", symbol: ",m_symbol.Name());
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result as a string: "+trade.ResultRetcodeDescription());
   Print("Deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("Order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("Volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("Price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("Current bid price: "+DoubleToString(symbol.Bid(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("Current ask price: "+DoubleToString(symbol.Ask(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("Broker comment: "+trade.ResultComment());
  }
  //-----------------------------------------------------------------------
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResultModify(CTrade &trade,CSymbolInfo &symbol,CPositionInfo &position)
  {
   Print("File: ",__FILE__,", symbol: ",m_symbol.Name());
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result as a string: "+trade.ResultRetcodeDescription());
   Print("Deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("Order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("Volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("Price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("Current bid price: "+DoubleToString(symbol.Bid(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("Current ask price: "+DoubleToString(symbol.Ask(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("Broker comment: "+trade.ResultComment());
   Print("Price of position opening: "+DoubleToString(position.PriceOpen(),symbol.Digits()));
   Print("Price of position's Stop Loss: "+DoubleToString(position.StopLoss(),symbol.Digits()));
   Print("Price of position's Take Profit: "+DoubleToString(position.TakeProfit(),symbol.Digits()));
   Print("Current price by position: "+DoubleToString(position.PriceCurrent(),symbol.Digits()));
  }
  //-------------------------------------------------------------------------------------- 
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+----------------------------------------------------------------------------------+
//|
//+----------------------------------------------------------------------------------+
  bool SelectByIndex(const int index)
  {
   ENUM_ACCOUNT_MARGIN_MODE margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
//---
   if(margin_mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      ulong ticket=PositionGetTicket(index);
      if(ticket==0)
         return(false);
     }
   else
     {
      string name=PositionGetSymbol(index);
      if(name=="")
         return(false);
     }
//---
   return(true);
  }
 //-----------------------------------------------------------------
 //+-----------------------------------------------------------------+
//| Checking open positions on the symbol with the magic number      |
//+------------------------------------------------------------------+
  int NumOpenedBySymbol(string symbol,int MagicNumber)
  {
   int pos=0;
   uint total=PositionsTotal();
//---
   for(uint i=0; i<total; i++)
     {
      if(SelectByIndex(i))
         if(PositionGetString(POSITION_SYMBOL)==symbol && PositionGetInteger(POSITION_MAGIC)==MagicNumber)
            pos++;
     }
   return(pos);
  }
  //------------------------------------------------------------------------------------
  //-------------------- Hour Range -------------------------------------
bool HourRange(int hour_current,int lentryhour,int lopenhours)
//+-----------------------------------------------------------------+ 
//| Open trades within a range of hours starting at entry_hour      |
//| Duration of trading window is open_hours   
//| open_hours = 0 means open for 1 hour                            |
//+-----------------------------------------------------------------+
  {
   bool Hour_Test;
   int closehour;
// 
   Hour_Test = false;
   closehour = int(MathMod((lentryhour+lopenhours),24));
// 
   if(closehour==lentryhour && hour_current==lentryhour)
      Hour_Test=true;

   if(closehour>lentryhour)
     {
      if(hour_current>=lentryhour && hour_current<=closehour)
         Hour_Test=true;
     }

   if(closehour<lentryhour)
     {
      if(hour_current>=lentryhour && hour_current<=23)
         Hour_Test=true;
      if(hour_current>=0 && hour_current<=closehour)
         Hour_Test=true;
     }
   return(Hour_Test);
  }
//----------------------------------------------------------------------
//+------------------------------------------------------------------+
//|                                          Library_GetOpenTime.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
 int GetOpenTime()
  // count bars for open duration in mins - skips market close times
  // default to (CurTime - OpenTime)/60.
  {
   int OpenTimeMins;
   int CBars,jj,ii,SrchLim;
   int PerFctr;
   datetime TOpen, CurTime;
   OpenTimeMins = 0;
   CBars = 0;
   SrchLim = 200;
   //
   CurTime = iTime(_Symbol,0,0);
   PerFctr = PeriodSeconds(PERIOD_CURRENT)/60;
   TOpen = 0;
   //
    for( ii=PositionsTotal()-1;ii>=0;ii--) // returns the number of current positions
     {
      if(m_position.SelectByIndex(ii)) 
       {    // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            TOpen = m_position.Time();
   //         Print(" *** DEBUG Found position open time =  ",TOpen);// *****
            for (jj=0;jj<SrchLim;jj++)
             {           
              if(iTime(_Symbol,0,jj)<=TOpen) break;
              CBars +=1;
            }
          } // test on symbol
        } // --- select
      }   // ------------- loop --------------- 
    //
   OpenTimeMins = PerFctr*CBars; // convert from bars to minutes
   // error case
   if(CBars==SrchLim) // if open time not found, use default
    {
     OpenTimeMins = int((CurTime-TOpen)/60.);
     return OpenTimeMins;
    }
   
   return OpenTimeMins;
  }    
  //---------------------------------------------------------------  
  void GetTimeFromClose(double &Profit,double &DTime)
//+----------------------------------------------------------------+
//| Get Deals from History File for Close Time and Profit          |
//| return time (mins) from last closed trade in History table     |
//+----------------------------------------------------------------+
  {
// 
   int cnt,total;
   ulong ticket;
   datetime clsTime;
   total = 0;
   DTime=99999.; // default 99,999 mins
   if(HistorySelect(0,TimeCurrent())) 
    total = HistoryDealsTotal(); // must do HistorySelect first
   else 
    return;
   if(total<1) return;
   //
   for(cnt=total-1;cnt>=0;cnt--)
    {    
      ticket = HistoryDealGetTicket(cnt);
      if(HistoryDealSelect(ticket))
       {
        if(HistoryDealGetString(ticket,DEAL_SYMBOL)==_Symbol && HistoryDealGetInteger(ticket,DEAL_MAGIC)==m_magic && 
           HistoryDealGetInteger(ticket,DEAL_ENTRY)==DEAL_ENTRY_OUT)
         {
          clsTime = (datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
          Profit = HistoryDealGetDouble(ticket,DEAL_PROFIT);
          DTime=(TimeCurrent()-clsTime)/60.;
          break;
         }
       } // -------- select ---------
     } // ----------- loop ---------------
   return;
  }
//----------------------------------------------------------------------------------
bool CloseOvertime5(int TimeLimit,int TimeLimitAll,double TkProf)
//+-------------------------------------------------------------------+
//|  Closes all trades if open past time lmit                         |
//| will be OK with FIFO rule because deletion is based on open time! |
//+-------------------------------------------------------------------+
  {
// ProfType = 0 close all, = 1 close Positive return, = 2 Negative return
   int total,cnt;
   double open_mins;
   double ord_profit;
   datetime ord_time,cur_time;
   bool result;
   double PipVal;
   result = true;
   total  = PositionsTotal();
   if(total == 0) return(result);
   //
   for(cnt=total-1; cnt>=0; cnt--)
    {
     if(m_position.SelectByIndex(cnt)) 
       {     
        if(m_position.PositionType()<=POSITION_TYPE_SELL && m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
         {
            ord_profit = m_position.Profit();
            PipVal = GetPipsFromProfit(Lots,ord_profit);
            ord_time = m_position.Time();
            cur_time = TimeCurrent();
            open_mins=(cur_time-ord_time)/60.;
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {          
               if((PipVal >= TkProf && open_mins>=TimeLimit && TimeLimit>0.) || 
                 (open_mins>TimeLimitAll && TimeLimitAll>0.))
                 m_trade.PositionClose(m_position.Ticket()); //        
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if((PipVal >= TkProf && open_mins>=TimeLimit && TimeLimit>0.) || 
                 (open_mins>TimeLimitAll && TimeLimitAll>0.))
                  m_trade.PositionClose(m_position.Ticket()); //
              }
           } // ---- end of if ordertype
        } // if OrderSelect
     }//  ----  end of loop ----------------
   if(result == false)
      Print(" *** ERROR on Close ",open_mins);
   return (result);
  } // -------------------- end CloseTime -----------------------------------------
  //
  //+-------------------------------------------------
  //|  PIPS FROM PROFIT
  //+------------------------------------------------
 double GetPipsFromProfit(double lots, double profit)
  {
   double PipVal;
   PipVal = profit/(10.*lots*m_tickvalue);
   return(PipVal);
  }
  //--------------------------------------------------------------------      