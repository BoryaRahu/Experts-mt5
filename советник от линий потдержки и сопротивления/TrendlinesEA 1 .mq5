//+------------------------------------------------------------------+
//|                                                 TrendlinesEA.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|   https://www.mql5.com/ru/articles/3215                                          https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\PositionInfo.mqh> CPositionInfo     m_position;
#include <Trade\OrderInfo.mqh> COrderInfo     m_order;
#include <Trade\Trade.mqh> CTrade trade;
#include <Trade\AccountInfo.mqh>  CAccountInfo   AI;  
#include <Trade\SymbolInfo.mqh>

//--- input parameters
enum tip
  {
   tip1=0,//otskok 
   tip2=1,//probui
   tip3=2//all 
  };

input string s="-------------------------------------------"; //Main settings
input int Magic=12345;
input double LotSize=0.1;
input int Slippage=30; //Slippage, points 
input int StopLoss=0; //StopLoss, points 
input int TakeProfit=0; //TakeProfit, points
input int TrailingStart=0; //Trailing Start, points     
input int TrailingStop= 0; //Trailing Stop, points     
input int TrailingStep= 0; //Trailing Step, points
input int SL_prof=0; //Start BE, points
input int SL_lev=0; //BE level, points
input int Buy_max=1; //Max Buy orders
input int Sell_max=1; //Max Sell orders
input bool Sig_close=true; //Закрыть противоположный
input tip mode=0;
input string s0="-------------------------------------------"; //Indicators settings
input int _ExtDepth=12;
input int _ExtDeviation=5;
input int _ExtBackstep=3;

input int _Min_dist=0; // Minimum distance
input int _fibo=30; // Fibo ratio
input int _tolerance=200; // Tolerance
input int _Intersection_ab=1; //The allowed number of intersections from point a to point b
input int _Intersection_bc=1; //The allowed number of intersections from point b to point c

input string s1="-------------------------------------------"; //MACD settings
input ENUM_TIMEFRAMES macd_tf=PERIOD_CURRENT; // period
input int fast_ema_period=12; //period of fast ma 
input int slow_ema_period=26; //period of slow ma 
input int signal_period=9; //period of averaging of difference 
input ENUM_APPLIED_PRICE applied_price=PRICE_CLOSE; //type of price 

input string s2="-------------------------------------------"; //RSI settings
input ENUM_TIMEFRAMES rsi_tf=PERIOD_CURRENT; // period
input int rsi_period=14; // period 
input ENUM_APPLIED_PRICE rsi_applied_price=PRICE_CLOSE; //type of price
input double rsi_max_s=100; // max price for Sell
input double rsi_min_s=70; // min price for Sell
input double rsi_max_b=30; // max price for Buy
input double rsi_min_b=0; // min price for Buy

input string s3="-------------------------------------------"; //WPR settings
input ENUM_TIMEFRAMES wpr_tf=PERIOD_CURRENT; // period
input int calc_period=14; // period  
input double wpr_max_s=0; // max price for Sell
input double wpr_min_s=-20; // min price for Sell
input double wpr_max_b=-80; // max price for Buy
input double wpr_min_b=-100; // min price for Buy

input string s4="-------------------------------------------";//MA settings
input ENUM_TIMEFRAMES ma_tf=PERIOD_CURRENT; // period
input int ma_period=10; // period of ma 
input int ma_shift=0; // shift 
input ENUM_MA_METHOD ma_method=MODE_SMA; // type of smoothing 
input ENUM_APPLIED_PRICE ma_applied_price=PRICE_CLOSE; // type of price 

input bool Use_macd=true; //Use MACD as a filter
input bool Use_rsi=false; //Use RSI as a filter
input bool Use_wpr=false; //Use WPR as a filter
input bool Use_ma=false; //Use MA as a filter

input int sbar=1; //Signal bar 0-current, 1-close

int handle_TL,handle_rind;
int hmacd,hma,hwpr,hrsi;
double macda[2],rsia[2],maa[4],wpra[2];
int BuyCount;
int SellCount;
int Sig=0;
double Signals=0;
int bars=0,barsp=0;
int n=0;
int a=0,b=0;
int p1=0,p2=0;
double ax=0,bx=0;
double kkk=0;
double lvl=0;
double plvl=0;
double C[3],H[3],L[3],O[3];
  double
   AveridgeBuyPrice=0,AveridgeSellPrice=0  ;

   double
   op=0,lt=0,tp=0, sl=0;

   ulong    tk=0;
  
   int bs=0,ss=0; 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   handle_TL=iCustom(NULL,0,"Trendlines",_ExtDepth,_ExtDeviation,_ExtBackstep,_Min_dist,_fibo,_tolerance,_Intersection_ab,_Intersection_bc);
    if (handle_TL == INVALID_HANDLE)
   {
      Print("Не удалось создать описатель индикатора Trendlines");
      return(INIT_FAILED);
   }
  //  handle_rind=iCustom(NULL,0,"rind");
    if (handle_rind == INVALID_HANDLE)
   {
      Print("Не удалось создать описатель индикатора Trendlines");
      return(INIT_FAILED);
   }
   if(Use_macd==true) hmacd=iMACD(NULL,macd_tf,fast_ema_period,slow_ema_period,signal_period,applied_price);
   if(Use_rsi==true)hrsi=iRSI(NULL,rsi_tf,rsi_period,rsi_applied_price);
   if(Use_wpr==true)hwpr=iWPR(NULL,wpr_tf,calc_period);
   if(Use_ma==true)hma=iMA(NULL,ma_tf,ma_period,ma_shift,ma_method,applied_price);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   MyMarkets();

   if(TrailingStart>0 && TrailingStop>0) Trail();
   if(SL_prof>0) BE();

   bars=Bars(NULL,0);

   if(bars!=barsp)
     {
      barsp=bars;
      Sig=signal();

      if(BuyCount<Buy_max && Sig==1)
        {
         Buy(LotSize,StopLoss,TakeProfit,Magic);
         if(Sig_close==true)CloseAllSell();
        }
      if(SellCount<Sell_max && Sig==2)
        {
         Sell(LotSize,StopLoss,TakeProfit,Magic);
         if(Sig_close==true)CloseAllBuy();
        }
     }

  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int signal()
  {
 // iCustom(NULL,0,"Trendlines",_ExtDepth,_ExtDeviation,_ExtBackstep,_Min_dist,_fibo,_tolerance,_Intersection_ab,_Intersection_bc);
  double  Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  double  Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   int res=0;

   int macd=0;
   int rsi=0;
   int wpr=0;
   int ma=0;

   if(Use_macd==true)macd=macdS();
   if(Use_rsi==true)rsi=rsiS();
   if(Use_wpr==true)wpr=wprS();
   if(Use_ma==true)ma=maS();

   CopyOpen(NULL,0,1,3,O);
   CopyHigh(NULL,0,1,3,H);
   CopyLow(NULL,0,1,3,L);
   CopyClose(NULL,0,1,3,C);
   
   
    int total=PositionsTotal();
    
      ENUM_ORDER_TYPE order_type =WRONG_VALUE ;  
   for(int k=total-1; k>=0; k--)
      if(m_position.SelectByIndex(k))
       
         if(m_position.Symbol()==Symbol())
            if(m_position.Magic()==Magic)

            
               if(m_position.PositionType()==POSITION_TYPE_BUY || m_position.PositionType()==POSITION_TYPE_SELL)
                 {

                  op=NormalizeDouble(m_position.PriceOpen(),Digits());
                  lt=NormalizeDouble(m_position.Volume(),3);
                  tk=m_position.Ticket();
                  
                     
                  if(m_position.PositionType()==POSITION_TYPE_BUY)
                    {
                     bs++;                    
                     AveridgeBuyPrice    = op++;                   
                    }
                  // ===
                  if(m_position.PositionType()==POSITION_TYPE_SELL)
                    {
                     ss++;
                     AveridgeSellPrice    = op++;
                     }
                    }                  
   double rind1[];
   double rind2[];
   double Line[];
   double Line1[];
   
   ArraySetAsSeries(rind1,true);
   CopyBuffer(handle_rind,2,0,3,rind1);  
   ArraySetAsSeries(rind2,true);
   CopyBuffer(handle_rind,1,0,3,rind2); 
   
    ArraySetAsSeries(Line,true);
   CopyBuffer(handle_TL,2,0,3,Line);  
   ArraySetAsSeries(Line1,true);
   CopyBuffer(handle_TL,1,0,3,Line1); 
      // rind2  "UpTrend"    
   // rind1 "DownTrend"  
   
    // Print("Line 0 " + DoubleToString(Line[1]));
    // Print(DoubleToString(Line1[1])); 
   
 //  Print(DoubleToString(rind2[1]));
 //    Print(DoubleToString(rind1[1]));               
          
          
         Print(DoubleToString(ObjectsTotal(0,0,OBJ_TREND)));
   Signals=0;
   /*
    if(mode==0 || mode==2)
           {
           if(rind2[0]>Bid && L[1]<=rind2[0] && C[1]>rind2[0] && C[0]>rind2[0])Signals=1;
            if(rind1[0]<Bid && H[1]>=rind1[0] && C[1]<plvl && C[0]<lvl)Signals=2;
           }

         if(mode==1 || mode==2)
           {
           if(rind2[0]>Bid && L[1]<=rind2[0] && C[1]>rind2[0] && C[0]<rind2[0])Signals=2;
            if(rind1[0]<Bid && H[1]>=rind1[0] && C[1]<rind1[0] && C[0]>rind1[0])Signals=1;
           }
           
        //   if(rind2[0]>Bid  && AveridgeSellPrice > Bid )    CloseAllSell();
        //  if(rind1[0]<Bid   && AveridgeBuyPrice <  Bid )    CloseAllBuy();
    */       
   
   for(int i=0;i<ObjectsTotal(0,0,OBJ_TREND);i++)
     {
     
     
      string sName=ObjectName(0,i,0,OBJ_TREND);
     if(StringFind(sName,"UpTrend")==0 || StringFind(sName,"DownTrend")==0)
       {
         ax=ObjectGetDouble(0,sName,OBJPROP_PRICE,0);
         bx=ObjectGetDouble(0,sName,OBJPROP_PRICE,1);
         p1=(int)ObjectGetInteger(0,sName,OBJPROP_TIME,0);
         p2=(int)ObjectGetInteger(0,sName,OBJPROP_TIME,1);
         a=iBarShift(p1);
         b=iBarShift(p2);
         kkk=(bx-ax)/(a-b);
         lvl=bx+kkk*b;
         plvl=bx+kkk*(b-1);

         if(StringFind(sName,"DownTrend")==0)Print("DownTrend==0"+ DoubleToString(ax));
         if(StringFind(sName,"UpTrend")==0)Print("UpTrend==0"+ DoubleToString(bx));
     
     
     // 0 отскок
    // 1 пробой
    // 2 all     
    
      if(mode==0 || mode==2 )
           {
            if(StringFind(sName,"DownTrend")==0 && O[1]<ax &&Ask > ax && H[1]>=ax && C[1]>ax  )Signals=1;
            //if(StringFind(sName,"UpTrend")==0&& Bid > bx   && L[0]<=plvl && C[0]>lvl)Signals=1;
            if(StringFind(sName,"UpTrend")==0  && O[1]>bx && Ask  < bx && H[0]>= bx  && C[0]< bx)Signals=2;
            
            // ЗАКРЫТИЕ
           // if( AveridgeSellPrice > bx&& L[0]<=plvl)    CloseAllSell();
           // if( AveridgeBuyPrice <  ax&& H[0]>=plvl )    CloseAllBuy();
         //   if( AveridgeSellPrice < bx&& L[0]>=plvl &&L[1]>=plvl )    CloseAllSell();
         //   if( AveridgeBuyPrice >  ax&& H[0]<=plvl && H[1]<=plvl  )    CloseAllBuy();
            
           }

         if(mode==1 || mode==2)
           {// ОТКРЫТИЕ
            if(StringFind(sName,"UpTrend")==0 && O[1]>bx  &&Bid > bx  && L[1]<=bx && C[1]>bx )Signals=1;
            if(StringFind(sName,"DownTrend")==0 && O[1]<ax &&Ask < ax && H[1]>=ax && C[1]<ax  )Signals=2;
            
            // ЗАКРЫТИЕ
         //if(StringFind(sName,"UpTrend")==0 && AveridgeSellPrice > Bid )    CloseAllSell();
        // if(StringFind(sName,"DownTrend")==0 && AveridgeBuyPrice <  Bid )    CloseAllBuy();
         
         
         
            
           }
     }
    
    
    
     
 
     }
  
   if(Signals==1 // sig 1 Buy
      &&(macd==1 || Use_macd==false)
      && (rsi==1 || Use_rsi==false)
      && (wpr==1 || Use_wpr==false)
      && (ma==1 || Use_ma==false))res=1;

   if(Signals==2  // sig 2 Sell
      &&(macd==2 || Use_macd==false)
      && (rsi==2 || Use_rsi==false)
      && (wpr==2 || Use_wpr==false)
      && (ma==2 || Use_ma==false))res=2;

   return(res);
  }
//+------------------------------------------------------------------+
double macd(int shift)
  {
   double res=0;
   CopyBuffer(hmacd,0,shift,1,macda);
   res=macda[0];
   return(res);
  }
//+------------------------------------------------------------------+
int macdS()
  {
   int res=0;
   double ind=macd(sbar);

   if(ind<0)res=1;
   if(ind>0)res=2;

   return (res);
  }
//+------------------------------------------------------------------+
double rsi(int shift)
  {
   double res=0;
   CopyBuffer(hrsi,0,shift,1,rsia);
   res=rsia[0];
   return(res);
  }
//+------------------------------------------------------------------+
int rsiS()
  {
   int res=0;
   double ind=rsi(sbar);

   if(ind>=rsi_min_b && ind <=rsi_max_b)res=1;
   if(ind>=rsi_min_s && ind <=rsi_max_s)res=2;

   return (res);
  }
//+------------------------------------------------------------------+
double ma(int shift)
  {
   double res;
  // CopyBuffer(hma,2,0,0,maa);
   
   ArraySetAsSeries(maa,true);
   CopyBuffer(hma,0,0,4,maa);  
   
   if(maa[1]>maa[2])res=1;
   if(maa[1]<maa[2])res=2;
   return(res);
  }
//+------------------------------------------------------------------+
int maS()
  {
   int res=0;
   double ind=ma(sbar);
   double indp=ma(sbar+1);

   if(ind>indp)res=1;
   if(ind<indp)res=2;

   return (res);
  }
//+------------------------------------------------------------------+
double wpr(int shift)
  {
   double res=0;
   CopyBuffer(hwpr,0,shift,1,wpra);
   
   res=wpra[0];
   return(res);
  }
//+------------------------------------------------------------------+
int wprS()
  {
   int res=0;
   double ind=wpr(sbar);

   if(ind>=wpr_min_b && ind <=wpr_max_b)res=1;
   if(ind>=wpr_min_s && ind <=wpr_max_s)res=2;

   return (res);
  }
//+------------------------------------------------------------------+
int Trail()
  {
   for(int i=0;i<PositionsTotal();i++)
     {
      if(PositionGetSymbol(i)==_Symbol && PositionGetInteger(POSITION_MAGIC)==Magic)
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
           {
            ulong  ticket=PositionGetTicket(i);
            double pp=SymbolInfoDouble(_Symbol,SYMBOL_BID);
            double sl=PositionGetDouble(POSITION_SL);
            double op=PositionGetDouble(POSITION_PRICE_OPEN);
            double tp=PositionGetDouble(POSITION_TP);

            if(pp-op>=TrailingStart*_Point)
              {
               if(sl<pp-(TrailingStop+TrailingStep)*_Point || sl==0)
                 {
                  Modify(ticket,pp-TrailingStop*_Point,tp);
                 }
              }
           }
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
           {
            ulong  ticket=PositionGetTicket(i);
            double pp=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
            double sl=PositionGetDouble(POSITION_SL);
            double op=PositionGetDouble(POSITION_PRICE_OPEN);
            double tp=PositionGetDouble(POSITION_TP);

            if(op-pp>=TrailingStart*_Point)
              {
               if(sl>pp+(TrailingStop+TrailingStep)*_Point || sl==0)
                 {
                  Modify(ticket,pp+TrailingStop*_Point,tp);
                 }
              }
           }
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+

int BE()
  {
   for(int i=0;i<PositionsTotal();i++)
     {
      if(PositionGetSymbol(i)==_Symbol && PositionGetInteger(POSITION_MAGIC)==Magic)
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
           {
            ulong  ticket=PositionGetTicket(i);
            double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
            double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
            double sl=PositionGetDouble(POSITION_SL);
            double op=PositionGetDouble(POSITION_PRICE_OPEN);
            double tp=PositionGetDouble(POSITION_TP);
            if((bid-op)>SL_prof*_Point)
              {

               double sl1=NormalizeDouble(op+(SL_lev*_Point),_Digits);
               if(sl1!=sl)
                 {
                  Modify(ticket,sl1,tp);
                 }

              }
           }
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
           {
            ulong  ticket=PositionGetTicket(i);
            double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
            double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
            double sl=PositionGetDouble(POSITION_SL);
            double op=PositionGetDouble(POSITION_PRICE_OPEN);
            double tp=PositionGetDouble(POSITION_TP);
            if((op-ask)>SL_prof*_Point)
              {

               double sl1=NormalizeDouble(op-(SL_lev*_Point),_Digits);
               if(sl1!=sl)
                 {
                  Modify(ticket,sl1,tp);
                 }

              }
           }
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+

int Modify(ulong t,double sl,double tp)
  {

   MqlTradeRequest request;
   MqlTradeResult result;
   MqlTradeCheckResult check;
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);
   request.action  =TRADE_ACTION_SLTP;
   request.position=t;
   request.symbol=_Symbol;
   request.sl      =sl;
   request.tp      =tp;
   request.magic=Magic;

   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Error inputs for trade order");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(-1);
     }
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): Unable to modify");
      Print(__FUNCTION__,"(): Modify(): ",ResultRetcodeDescription(result.retcode));
      return(-1);
     }
   else
   if(result.retcode!=TRADE_RETCODE_DONE)

     {
      Print(__FUNCTION__,"(): Unable to modify");
      Print(__FUNCTION__,"(): Modify(): ",ResultRetcodeDescription(result.retcode));
      return (-1);
     }

   return(0);
  }
//+------------------------------------------------------------------+

string ResultRetcodeDescription(int retcode)
  {
   string str;
//----
   switch(retcode)
     {
      case TRADE_RETCODE_REQUOTE: str="Requote"; break;
      case TRADE_RETCODE_REJECT: str="Rejected"; break;
      case TRADE_RETCODE_CANCEL: str="Cancelled"; break;
      case TRADE_RETCODE_PLACED: str="Order placed"; break;
      case TRADE_RETCODE_DONE: str="Request done"; break;
      case TRADE_RETCODE_DONE_PARTIAL: str="Request done partial"; break;
      case TRADE_RETCODE_INVALID: str="Invalid request"; break;
      case TRADE_RETCODE_INVALID_VOLUME: str="Invalid volume"; break;
      case TRADE_RETCODE_INVALID_PRICE: str="Invalid price"; break;
      case TRADE_RETCODE_INVALID_STOPS: str="INVALID STOPS"; break;
      case TRADE_RETCODE_TRADE_DISABLED: str="Trade disabled"; break;
      case TRADE_RETCODE_MARKET_CLOSED: str="Market closed"; break;
      case TRADE_RETCODE_NO_MONEY: str="Of insufficient funds"; break;
      case TRADE_RETCODE_PRICE_CHANGED: str="Price changed"; break;
      case TRADE_RETCODE_ORDER_CHANGED: str="Order changed "; break;
      case TRADE_RETCODE_TOO_MANY_REQUESTS: str="Too many requests"; break;
      case TRADE_RETCODE_NO_CHANGES: str="No changes"; break;
      case TRADE_RETCODE_SERVER_DISABLES_AT: str="Server disables autotrading"; break;
      case TRADE_RETCODE_CLIENT_DISABLES_AT: str="Client disables autotrading"; break;
      case TRADE_RETCODE_LOCKED: str="Request is locked"; break;
      case TRADE_RETCODE_LIMIT_ORDERS: str="Limit orders"; break;
      case TRADE_RETCODE_LIMIT_VOLUME: str="Limit volume"; break;
      default: str="Unknown error "+IntegerToString(retcode);
     }
//----
   return(str);
  }
//+------------------------------------------------------------------+
int Buy(double l,int SL,int TP,int magic)
  {

   MqlTradeRequest request;
   MqlTradeResult result;
   MqlTradeCheckResult check;
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);

   int digit=int(SymbolInfoInteger(_Symbol,SYMBOL_DIGITS));
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   double Ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double Bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   long ds=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   double minl=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double po=NormalizeDouble(Ask,digit);

   double lot=l;
   lot=NormalizeDouble(lot,2);
   if(lot<minl) lot=minl;

   double tp=0;
   double sl=0;

   if(TP>0)tp=NormalizeDouble(Bid+TP*point,digit);
   if(SL>0)sl=NormalizeDouble(Bid-SL*point,digit);


   request.type   = ORDER_TYPE_BUY;
   request.price  = po;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = lot;
   request.magic=magic;
//   request.comment=Comm;
   request.tp=tp;
   request.sl=sl;
   request.type_filling=ORDER_FILLING_IOC;
   request.deviation=Slippage;
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Error inputs for trade order");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(-1);
     }
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): Unable to make the transaction");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(-1);
     }
   else
   if(result.retcode!=TRADE_RETCODE_DONE)

     {
      Print(__FUNCTION__,"(): Unable to make the transaction");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return (-1);
     }

   return(0);
  }
//+------------------------------------------------------------------+

int Sell(double l,int SL,int TP,int magic)
  {

   MqlTradeRequest request;
   MqlTradeResult result;
   MqlTradeCheckResult check;
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);

   int digit=int(SymbolInfoInteger(_Symbol,SYMBOL_DIGITS));
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   double Ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double Bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   long ds=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   double minl=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double po=NormalizeDouble(Bid,digit);

   double lot=l;
   lot=NormalizeDouble(lot,2);
   if(lot<minl) lot=minl;

   double tp=0;
   double sl=0;

   if(TP>0)tp=NormalizeDouble(Ask-TP*point,digit);
   if(SL>0)sl=NormalizeDouble(Ask+SL*point,digit);

   request.type   = ORDER_TYPE_SELL;
   request.price  = po;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = lot;
   request.magic=magic;
//  request.comment=Comm;
   request.tp=tp;
   request.sl=sl;
   request.type_filling=ORDER_FILLING_IOC;
   request.deviation=Slippage;
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Error inputs for trade order");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(-1);
     }
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): Unable to make the transaction");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(-1);
     }
   else
   if(result.retcode!=TRADE_RETCODE_DONE)

     {
      Print(__FUNCTION__,"(): Unable to make the transaction");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return (-1);
     }

   return(0);
  }
//+------------------------------------------------------------------+

int MyMarkets()
  {
   BuyCount=0;
   SellCount=0;

   for(int i=0;i<PositionsTotal();i++)
     {
      if(PositionGetSymbol(i)==_Symbol && PositionGetInteger(POSITION_MAGIC)==Magic)
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
           {
            BuyCount++;
           }
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
           {
            SellCount++;
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
int CloseAllBuy()
  {
   MqlTradeRequest request;
   MqlTradeResult  result;
   int total=PositionsTotal();
   for(int i=total-1; i>=0; i--)
     {

      ulong  position_ticket=PositionGetTicket(i);                                      // тикет позиции
      string position_symbol=PositionGetString(POSITION_SYMBOL);                        // символ 
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);              // количество знаков после запятой
      ulong  magic=PositionGetInteger(POSITION_MAGIC);                                  // Magicumber позиции
      double volume=PositionGetDouble(POSITION_VOLUME);                                 // объем позиции
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);    // тип позиции

      if((position_symbol==_Symbol) && (type==POSITION_TYPE_BUY) && PositionGetInteger(POSITION_MAGIC)==Magic)
        {

         ZeroMemory(request);
         ZeroMemory(result);

         request.action   =TRADE_ACTION_DEAL;
         request.position =position_ticket;
         request.symbol   =position_symbol;
         request.volume   =volume;
         request.deviation=Slippage;
         request.magic    =magic;
         request.type_filling=ORDER_FILLING_IOC;
         request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
         request.type =ORDER_TYPE_SELL;


         if(!OrderSend(request,result))
            PrintFormat("OrderSend error %d",GetLastError());  // если отправить запрос не удалось, вывести код ошибки

        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
int CloseAllSell()
  {
   MqlTradeRequest request;
   MqlTradeResult  result;
   int total=PositionsTotal();
   for(int i=total-1; i>=0; i--)
     {

      ulong  position_ticket=PositionGetTicket(i);                                      // тикет позиции
      string position_symbol=PositionGetString(POSITION_SYMBOL);                        // символ 
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);              // количество знаков после запятой
      ulong  magic=PositionGetInteger(POSITION_MAGIC);                                  // Magicumber позиции
      double volume=PositionGetDouble(POSITION_VOLUME);                                 // объем позиции
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);    // тип позиции

      if((position_symbol==_Symbol) && (type==POSITION_TYPE_SELL) && PositionGetInteger(POSITION_MAGIC)==Magic)
        {
         //--- обнуление значений запроса и результата
         ZeroMemory(request);
         ZeroMemory(result);
         //--- установка параметров операции
         request.action   =TRADE_ACTION_DEAL;
         request.position =position_ticket;
         request.symbol   =position_symbol;
         request.volume   =volume;
         request.deviation=Slippage;
         request.magic    =magic;
         request.type_filling=ORDER_FILLING_IOC;
         request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
         request.type =ORDER_TYPE_BUY;
        
        
         if(!OrderSend(request,result))
            PrintFormat("OrderSend error %d",GetLastError());  // если отправить запрос не удалось, вывести код ошибки

        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
int iBarShift(datetime time)
  {
   if(time<0) return(-1);
   datetime Arr[],time1;
   CopyTime(NULL,0,0,1,Arr);
   time1=Arr[0];
   if(CopyTime(NULL,0,time,time1,Arr)>0)
     {
      if(ArraySize(Arr)>2) return(ArraySize(Arr)-1);
      if(time<time1) return(1);
      else return(0);
     }
   else return(-1);
  }
//+------------------------------------------------------------------+
//+--------надоптсаное улучшение----------------------------------------------------------+
int CloseOne(int Ticket,ENUM_POSITION_TYPE)
  {
   MqlTradeRequest request;
   MqlTradeResult  result;
   if (Ticket==0 )
   {
   int total=PositionsTotal();
   for(int i=total-1; i>=0; i--)
     {

      ulong  position_ticket=PositionGetTicket(i);                                      // тикет позиции
      string position_symbol=PositionGetString(POSITION_SYMBOL);                        // символ 
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);              // количество знаков после запятой
      ulong  magic=PositionGetInteger(POSITION_MAGIC);                                  // Magicumber позиции
      double volume=PositionGetDouble(POSITION_VOLUME);                                 // объем позиции
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);    // тип позиции

      if((position_symbol==_Symbol) && (type==POSITION_TYPE_BUY) && PositionGetInteger(POSITION_MAGIC)==Magic)
        {

         ZeroMemory(request);
         ZeroMemory(result);

         request.action   =TRADE_ACTION_DEAL;
         request.position =position_ticket;
         request.symbol   =position_symbol;
         request.volume   =volume;
         request.deviation=Slippage;
         request.magic    =magic;
         request.type_filling=ORDER_FILLING_IOC;
         request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
         request.type =ORDER_TYPE_SELL;


         if(!OrderSend(request,result))
            PrintFormat("OrderSend error %d",GetLastError());  // если отправить запрос не удалось, вывести код ошибки

        }
     }
   } 
   return(GetLastError());
  }