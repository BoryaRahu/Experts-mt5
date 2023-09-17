//+------------------------------------------------------------------+
//|                                        SIMPLE AND PROFITABLE.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property version   "1.00"
#include <Trade/Trade.mqh>

int HandleTrendMAFast;
int HandleTrendMASlow;

int handleMAfast;
int handleMaMiddle;
int handelemaSlow;

CTrade trade;
int EAMagik = 12;
double Lots  = 0.05;
enum t
  {
   b=1,     // по экстремумам свечей
   c=2,     // по фракталам
   d=3,     // по индикатору ATR
   e=4,     // по индикатору Parabolic
   f=5,     // по индикатору МА
   g=6,     // % от профита
   i=7,     // по пунктам
  };
extern bool    VirtualTrailingStop=false;//виртуальный трейлингстоп
input t        parameters_trailing=1;      //метод трала

extern int       delta=0;     // отступ от расчетного уровня стоплосса
input  ENUM_TIMEFRAMES TF_Tralling=0;      // таймфрейм индикаторов (0-текущий)

input int     StepTrall=1;      // шаг перемещения стоплосс
input int     StartTrall=1;      // минимальная прибыль трала в пунктах

color   text_color=clrGreen;     //цвет вывода информации

sinput string Advanced_Options="";

input int     period_ATR=14;//Период ATR (метод 3)

input double Step=0.02; //Parabolic Step (метод 4)
input double Maximum=0.2; //Parabolic Maximum (метод 4)
sinput  int     Magic= -1;//с каким магиком тралить (-1 все)
input bool    GeneralNoLoss=true;   // трал от точки безубытка
input bool    DrawArrow=false;   // показывать метки безубытка и стопов

input int ma_period=34;//период МА (метод 5)
input ENUM_MA_METHOD ma_method=MODE_SMA; // метод усреднения  (метод 5)
input ENUM_APPLIED_PRICE applied_price=PRICE_CLOSE;    // тип цены  (метод 5)

input double PercetnProfit=50;//процент от профита (метод 6)

MqlTradeRequest request;  // параметры торгового запроса
MqlTradeResult result;    // результат торгового запроса
MqlTradeCheckResult check;
int STOPLEVEL;
double Bid,Ask,SLB=0,SLS=0;
int slippage=100;
int maHandle;    // хэндл индикатора Moving Average
double maVal[];  // динамический массив для хранения значений индикатора Moving Average для каждого бара
int atrHandle;    // хэндл индикатора Moving Average
double atrVal[];  // динамический массив для хранения значений индикатора Moving Average для каждого бара
int sarHandle;    // хэндл индикатора Moving Average
double sarVal[];  // динамический массив для хранения значений индикатора Moving Average для каждого бара
//--------------------------------------------------------------------
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   trade.SetExpertMagicNumber(EAMagik);
   
   
   HandleTrendMAFast = iMA(USDYPY,PERIOD_H1,8,0,MODE_EMA,PRICE_CLOSE);
   HandleTrendMASlow = iMA(_USDYPY,PERIOD_H1,21,0,MODE_EMA,PRICE_CLOSE);
   
   HandleTrendMAFast = iMA(_Symbol,PERIOD_H1,8,0,MODE_EMA,PRICE_CLOSE);
   HandleTrendMASlow = iMA(_Symbol,PERIOD_H1,21,0,MODE_EMA,PRICE_CLOSE);
  
 // handleMAfast = iMA(_Symbol,PERIOD_M5,8,0,MODE_EMA,PRICE_CLOSE);
 // handleMaMiddle =iMA(_Symbol,PERIOD_M5,13,0,MODE_EMA,PRICE_CLOSE);
 // handelemaSlow =iMA(_Symbol,PERIOD_M5,21,0,MODE_EMA,PRICE_CLOSE);
  
  
   
   //---
    // if(VirtualTrailingStop) GeneralNoLoss=true;
   string txt;
   switch(parameters_trailing)
     {
      case 1: // по экстремумам свечей
         StringConcatenate(txt,"по свечам ",StrPer(TF_Tralling)," +- ",delta);
         break;
      case 2: // по фракталам
         StringConcatenate(txt,"по фракталам ",StrPer(TF_Tralling)," +- ",delta);
         break;
      case 3: // по индикатору ATR
         StringConcatenate(txt,"по ATR (",IntegerToString(period_ATR),") ",StrPer(TF_Tralling),"+- ",delta);
         atrHandle=iATR(_Symbol,TF_Tralling,period_ATR);
         break;
      case 4: // по индикатору Parabolic
         StringConcatenate(txt,"по параболику (",DoubleToString(Step,2)," ",DoubleToString(Maximum,2),") ",StrPer(TF_Tralling)," +- ",delta);
         sarHandle=iSAR(_Symbol,TF_Tralling,Step,Maximum);
         break;
      case 5: // по индикатору МА
         StringConcatenate(txt,"по MA (",ma_period," ",ma_method," ",applied_price,") ",StrPer(TF_Tralling)," +- ",delta);
         maHandle=iMA(_Symbol,TF_Tralling,ma_period,0,ma_method,applied_price);
         break;
      case 6: // % от профита
         StringConcatenate(txt," ",DoubleToString(PercetnProfit,2),"% от профита)");
         break;
      default: // по пунктам
         StringConcatenate(txt,"по пунктам ",delta," п");
         break;
     }
   if(VirtualTrailingStop)
     {
      StringConcatenate(txt,"Виртуальный трал ",txt);
     }
   else
     {
      StringConcatenate(txt,"Tрал ",txt);
     }
   DrawLABEL(3,"cm 3",txt,5,30,text_color,ANCHOR_RIGHT);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,"cm");
   Comment("");
   if(parameters_trailing==3) IndicatorRelease(atrHandle);
   if(parameters_trailing==4) IndicatorRelease(sarHandle);
   if(parameters_trailing==5) IndicatorRelease(maHandle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
 double maTrendfast [], maTrendSlow[];
   CopyBuffer(HandleTrendMAFast,0,1,3,maTrendfast);
    CopyBuffer(HandleTrendMASlow,0,1,3,maTrendSlow);
   //Comment("\nFast Trend MA "ma[0],"\n",ma[1],"\n",ma[2],"\n" );
   
  double maFast[],maMiddle[],maSlow[];
  CopyBuffer(handleMAfast,0,0,1,maFast );
  CopyBuffer(handleMaMiddle,0,0,1,maMiddle );
  CopyBuffer(handelemaSlow,0,0,1,maSlow);
   
 double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);  
 static double lastbid = bid;
 
  double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);  
 static double lastbid = bid;

int StartTrall = 0;
 int TrendDirection = 0;
 if   (maTrendfast[0] > maTrendSlow[0] && bid> maTrendfast[0]){
       TrendDirection=1;
       }
 else if   (maTrendfast[0] < maTrendSlow[0] && bid< maTrendfast[0]){
       TrendDirection=-1;
       }     
 
 int positions =0;      
 for(int i= PositionsTotal()-1 ;i>=0; i--){
 ulong PosTicket = PositionGetTicket(i);
  if(PositionSelectByTicket(PosTicket)){
    if (PositionGetString (POSITION_SYMBOL) ==_Symbol && PositionGetInteger(POSITION_MAGIC)==EAMagik){
    positions= positions + 1;
    
   // if (PositionGetInteger(POSITION_TYPE)== POSITION_TYPE_BUY){
    //  if (PositionGetDouble(POSITION_VOLUME)>=Lots){
      
     
     /* 
     StartTrall  =(PositionGetDouble(POSITION_PRICE_OPEN)-PositionGetDouble(POSITION_SL));
        /*  if (bid>= tp){
       //        if (trade.PositionClosePartial(PosTicket,NormalizeDouble(PositionGetDouble(POSITION_VOLUME)/2,2))){
               
               double sl = PositionGetDouble(POSITION_PRICE_OPEN) + (PositionGetDouble(POSITION_PRICE_OPEN)-PositionGetDouble(POSITION_SL));
               sl = NormalizeDouble(sl,_Digits);
                if (trade.PositionModify(PosTicket,sl,0)){
                }
             }
         //     }
             }else {
                 int Lowest = iLowest(_Symbol,PERIOD_M5,MODE_LOW,3,1);
                 double sl = iLow (_Symbol,PERIOD_M5,Lowest);
                 sl = NormalizeDouble(sl,_Digits);
                 if (sl> PositionGetDouble(POSITION_SL)){
                  if (trade.PositionModify(PosTicket,sl,0)){
                  }
                }
             }*/
             
     //       }
            
  //  else if (PositionGetInteger(POSITION_TYPE)== POSITION_TYPE_SELL){
   // if (PositionGetDouble(POSITION_VOLUME)>=Lots){
  //     StartTrall =   (PositionGetDouble(POSITION_SL) - PositionGetDouble(POSITION_PRICE_OPEN));
       /*  if (bid<= tp){
          //     if (trade.PositionClosePartial(PosTicket,NormalizeDouble(PositionGetDouble(POSITION_VOLUME)/2,2))){
               
               double sl = PositionGetDouble(POSITION_PRICE_OPEN)-  (PositionGetDouble(POSITION_SL) - PositionGetDouble(POSITION_PRICE_OPEN));
               sl = NormalizeDouble(sl,_Digits);
                if (trade.PositionModify(PosTicket,sl,0)){
                }
               }
        //      }
             }
             else {
                 int Higest = iHighest(_Symbol,PERIOD_M5,MODE_HIGH,3,1);
                 double sl = iLow (_Symbol,PERIOD_M5,Higest);
                 sl = NormalizeDouble(sl,_Digits);
                 if (sl< PositionGetDouble(POSITION_SL)){
                  if (trade.PositionModify(PosTicket,sl,0)){
                  }
                 }   
               }*/
   // }*/
  }
  }       
         
 }     
 
 
 
 
 



 int orders =0;      
 for(int i= OrdersTotal()-1 ;i>=0; i--){
 ulong OrderTicket = OrderGetTicket(i);
  if(OrderSelect(OrderTicket)){
    if (OrderGetString (ORDER_SYMBOL) ==_Symbol && OrderGetInteger(ORDER_MAGIC)==EAMagik){
     if (OrderGetInteger(ORDER_TIME_SETUP)<TimeCurrent() - 30 * PeriodSeconds(PERIOD_M1)){
       trade.OrderDelete(OrderTicket);}
    orders= orders + 1;
    }
   }
  } 
  
         
       
 if (TrendDirection == 1)  { 
     if (maFast[0]> maMiddle[0]&& maMiddle[0] > maSlow[0]) {
         if (bid <= maFast[0] && lastbid >maFast[0]){
          //Print ("Buy Signal");
            if (positions + orders<=0){
             
             
               int IndexHigest= iHighest(_Symbol,PERIOD_M5,MODE_HIGH,5,1);
               double highPrice = iHigh(_Symbol,PERIOD_M5,IndexHigest);
               highPrice = NormalizeDouble(highPrice,_Digits);
               
               double sl = iLow(_Symbol,PERIOD_M5,0)-30 *_Point*_Digits;
               sl = NormalizeDouble(sl,_Digits);
               
               
              // double tp =  highPrice + (highPrice - sl);
              // tp = NormalizeDouble(tp,_Digits);
               
               trade.BuyStop(Lots,highPrice,_Symbol,sl);
               }
         }
      }
    }
    else  if (TrendDirection == -1){ 
       if (maFast[0]< maMiddle[0]&& maMiddle[0] < maSlow[0]) {
         if (bid >= maFast[0] && lastbid <maFast[0]){  
           
           //Print ("Sell Signal");
            if (positions + orders<=0){
            
                int IndexLowest= iLowest(_Symbol,PERIOD_M5,MODE_HIGH,5,1);
                double lowestPrice = iLow(_Symbol,PERIOD_M5,IndexLowest);
               lowestPrice = NormalizeDouble(lowestPrice,_Digits);
               
               double sl = iHigh(_Symbol,PERIOD_M5,0)+30 *_Point*_Digits;
               sl = NormalizeDouble(sl,_Digits);
               
            //   double tp =  lowestPrice - (sl - lowestPrice);
            //    tp = NormalizeDouble(tp,_Digits);
                
               trade.SellStop(Lots,lowestPrice,_Symbol,sl);
               }
           
           
           
         }
       }
     }      
  lastbid = bid;
  
  
  long OT;
   int n=0;
   double OOP=0;
   string txt;
   StringConcatenate(txt,"Balance ",DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2));
   DrawLABEL(2,"cm Balance",txt,5,20,Lime,ANCHOR_RIGHT);
   StringConcatenate(txt,"Equity ",DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2));
   DrawLABEL(2,"cm Equity",txt,5,35,Lime,ANCHOR_RIGHT);
//----
   if(!VirtualTrailingStop) STOPLEVEL=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   double sl,SL;
   Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   int i,b=0,s=0;
   double PB=0,PS=0,OL=0,NLb=0,NLs=0,LS=0,LB=0;
//----
   for(i=0; i<PositionsTotal(); i++)
     {
      if(_Symbol==PositionGetSymbol(i))
        {
         if(Magic==OrderGetInteger(ORDER_MAGIC) || Magic==-1)
           {
            OL  = PositionGetDouble(POSITION_VOLUME);
            OOP = PositionGetDouble(POSITION_PRICE_OPEN);
            OT  = PositionGetInteger(POSITION_TYPE);
            if(OT==POSITION_TYPE_BUY ) {PB += OOP*OL; LB+=OL; b++;}
            if(OT==POSITION_TYPE_SELL) {PS += OOP*OL; LS+=OL; s++;}
           }
        }
     }
//----
   if(LB!=0)
     {
      NLb=PB/LB;
      ARROW("cm_NL_Buy",NLb,clrAqua);
     }
   if(LS!=0)
     {
      NLs=PS/LS;
      ARROW("cm_NL_Sell",NLs,clrRed);
     }
//----
   request.symbol=_Symbol;
   for(i=0; i<PositionsTotal(); i++)
     {
      if(_Symbol==PositionGetSymbol(i))
        {
         if(Magic==OrderGetInteger(ORDER_MAGIC) || Magic==-1)
           {
            OL  = PositionGetDouble(POSITION_VOLUME);
            OOP = PositionGetDouble(POSITION_PRICE_OPEN);
            OT  = PositionGetInteger(POSITION_TYPE);
            sl=PositionGetDouble(POSITION_SL);
            if(OT==POSITION_TYPE_BUY)
              {
               if(VirtualTrailingStop)
                 {
                  SL=SlLastBar(POSITION_TYPE_BUY,Bid,NLb);
                  if(SL!=-1 && NLb+StartTrall*_Point<SL && SLB<SL) SLB=SL;
                  if(SLB!=0)
                    {
                     HLINE("cm_slb",SLB,clrAqua);
                     if(Bid<=SLB)
                       {
                        request.deviation=slippage;
                        request.volume=PositionGetDouble(POSITION_VOLUME);
                        request.position=PositionGetInteger(POSITION_TICKET);
                        request.action=TRADE_ACTION_DEAL;
                        request.type_filling=ORDER_FILLING_FOK;
                        request.type=ORDER_TYPE_SELL;
                        request.price=Bid;
                        request.comment="";
                        if(!OrderSend(request,result)) Print("error ",GetLastError());
                       }
                    }
                 }
               else
                 {
                  SL=SlLastBar(POSITION_TYPE_BUY,Bid,OOP);
                  if(SL!=-1 && sl+StepTrall*_Point<SL && SL>=OOP+StartTrall*_Point)
                    {
                     request.action    = TRADE_ACTION_SLTP;
                     request.position  = PositionGetInteger(POSITION_TICKET);
                     request.sl        = SL;
                     request.tp        = PositionGetDouble(POSITION_TP);
                     if(!OrderSend(request,result)) Print("error ",GetLastError());
                    }
                 }
              }
            if(OT==POSITION_TYPE_SELL)
              {
               if(VirtualTrailingStop)
                 {
                  SL=SlLastBar(POSITION_TYPE_SELL,Ask,NLs);
                  if(SL!=-1 && (SLS==0 || SLS>SL) && SL<=NLs-StartTrall*_Point) SLS=SL;
                  if(SLS!=0)
                    {
                     HLINE("cm_sls",SLS,clrRed);
                     if(Ask>=SLS)
                       {
                        request.volume=PositionGetDouble(POSITION_VOLUME);
                        request.position=PositionGetInteger(POSITION_TICKET);
                        request.action=TRADE_ACTION_DEAL;
                        request.type_filling=ORDER_FILLING_FOK;
                        request.type=ORDER_TYPE_BUY;
                        request.price=Ask;
                        request.comment="";
                        if(!OrderSend(request,result)) Print("error ",GetLastError());
                       }
                    }
                 }
               else
                 {
                  SL=SlLastBar(POSITION_TYPE_SELL,Ask,OOP);
                  if(SL!=-1 && (sl==0 || sl-StepTrall*_Point>SL) && SL<=OOP-StartTrall*_Point)
                    {
                     request.action    = TRADE_ACTION_SLTP;
                     request.position  = PositionGetInteger(POSITION_TICKET);
                     request.sl        = SL;
                     request.tp        = PositionGetDouble(POSITION_TP);
                     if(OrderCheck(request,check)) if(!OrderSend(request,result)) Print("error ",GetLastError());
                     else Print("error ",GetLastError());
                    }
                 }
              }
           }
        }
     }

   if(b==0)
     {
      SLB=0;
      ObjectDelete(0,"cm SLb");
      ObjectDelete(0,"cm_SLb");
      ObjectDelete(0,"cm_slb");
     }
   if(s==0)
     {
      SLS=0;
      ObjectDelete(0,"cm SLs");
      ObjectDelete(0,"cm_SLs");
      ObjectDelete(0,"cm_sls");
     }
   return;
      
  }
//+------------------------------------------------------------------+
//--------------------------------------------------------------------
double SlLastBar(int tip,double price,double OOP)
  {
   double prc=0;
   int i;
   string txt;
   switch(parameters_trailing)
     {
      case 1: // по экстремумам свечей
         if(tip==POSITION_TYPE_BUY)
           {
            for(i=1; i<500; i++)
              {
               prc=NormalizeDouble(iLow(Symbol(),TF_Tralling,i)-delta*_Point,_Digits);
               if(prc!=0) if(price-STOPLEVEL*_Point>prc) break;
               else prc=0;
              }
            StringConcatenate(txt,"SL Buy candle ",DoubleToString(prc,_Digits));
           }
         if(tip==POSITION_TYPE_SELL)
           {
            for(i=1; i<500; i++)
              {
               prc=NormalizeDouble(iHigh(Symbol(),TF_Tralling,i)+delta*_Point,_Digits);
               if(prc!=0) if(price+STOPLEVEL*_Point<prc) break;
               else prc=0;
              }
            StringConcatenate(txt,"SL Sell candle ",DoubleToString(prc,_Digits));
           }
         break;

      case 2: // по фракталам
         if(tip==POSITION_TYPE_BUY)
           {
            for(i=2; i<100; i++)
              {
               if(iLow(Symbol(),TF_Tralling,i)<iLow(Symbol(),TF_Tralling,i+1) && 
                  iLow(Symbol(),TF_Tralling,i)<iLow(Symbol(),TF_Tralling,i-1) && 
                  iLow(Symbol(),TF_Tralling,i)<iLow(Symbol(),TF_Tralling,i+2))
                 {
                  prc=iLow(Symbol(),TF_Tralling,i);
                  if(prc!=0)
                    {
                     prc=NormalizeDouble(prc-delta*_Point,_Digits);
                     if(price-STOPLEVEL*_Point>prc) break;
                    }
                  else prc=0;
                 }
              }
            StringConcatenate(txt,"SL Buy Fractals ",DoubleToString(prc,_Digits));
           }
         if(tip==POSITION_TYPE_SELL)
           {
            for(i=2; i<100; i++)
              {
               if(iHigh(Symbol(),TF_Tralling,i)>iHigh(Symbol(),TF_Tralling,i+1) && 
                  iHigh(Symbol(),TF_Tralling,i)>iHigh(Symbol(),TF_Tralling,i-1) && 
                  iHigh(Symbol(),TF_Tralling,i)>iHigh(Symbol(),TF_Tralling,i+2))
                 {
                  prc=iHigh(Symbol(),TF_Tralling,i);
                  if(prc!=0)
                    {
                     prc=NormalizeDouble(prc+delta*_Point,_Digits);
                     if(price+STOPLEVEL*_Point<prc) break;
                    }
                  else prc=0;
                 }
              }
            StringConcatenate(txt,"SL Sell Fractals ",DoubleToString(prc,_Digits));
           }
         break;
      case 3: // по индикатору ATR
         ArraySetAsSeries(atrVal,true);
         if(CopyBuffer(atrHandle,0,0,3,atrVal)<0)
           {
            StringConcatenate(txt,"Ошибка ATR :",GetLastError());
            prc=-1;
            break;
           }
         prc=atrVal[1];
         if(tip==POSITION_TYPE_BUY)
           {
            prc=NormalizeDouble(Bid-prc-delta*_Point,_Digits);
            StringConcatenate(txt,"SL Buy ATR ",DoubleToString(prc,_Digits));
           }
         if(tip==POSITION_TYPE_SELL)
           {
            prc=NormalizeDouble(Ask+prc+delta*_Point,_Digits);
            StringConcatenate(txt,"SL Buy ATR ",DoubleToString(prc,_Digits));
           }
         break;

      case 4: // по индикатору Parabolic
         ArraySetAsSeries(sarVal,true);
         if(CopyBuffer(sarHandle,0,0,3,sarVal)<0)
           {
            StringConcatenate(txt,"Ошибка Parabolic SAR :",GetLastError());
            prc=-1;
            break;
           }
         prc=sarVal[1];
         if(tip==POSITION_TYPE_BUY)
           {
            prc=NormalizeDouble(prc-delta*_Point,_Digits);
            if(price-STOPLEVEL*_Point<prc) prc=0;
            StringConcatenate(txt,"SL Buy Parabolic ",DoubleToString(prc,_Digits));
           }
         if(tip==POSITION_TYPE_SELL)
           {
            prc=NormalizeDouble(prc+delta*_Point,_Digits);
            if(price+STOPLEVEL*_Point>prc) prc=0;
            StringConcatenate(txt,"SL Buy Parabolic ",DoubleToString(prc,_Digits));
           }
         break;

      case 5: // по индикатору МА
         ArraySetAsSeries(maVal,true);
         if(CopyBuffer(maHandle,0,0,3,maVal)<0)
           {
            StringConcatenate(txt,"Ошибка Moving Average :",GetLastError());
            prc=-1;
            break;
           }
         prc=maVal[1];
         if(tip==POSITION_TYPE_BUY)
           {
            prc=NormalizeDouble(prc-delta*_Point,_Digits);
            if(price-STOPLEVEL*_Point<prc) prc=0;
            StringConcatenate(txt,"SL Buy MA ",DoubleToString(prc,_Digits));
           }
         if(tip==POSITION_TYPE_SELL)
           {
            prc=NormalizeDouble(prc+delta*_Point,_Digits);
            if(price+STOPLEVEL*_Point>prc) prc=0;
            StringConcatenate(txt,"SL Sell MA ",DoubleToString(prc,_Digits));
           }
         break;
      case 6: // % от профита
         if(tip==POSITION_TYPE_BUY)
           {
            prc=NormalizeDouble(OOP+(price-OOP)/100*PercetnProfit,_Digits);
            StringConcatenate(txt,"SL Buy % ",DoubleToString(prc,_Digits));
           }
         if(tip==POSITION_TYPE_SELL)
           {
            prc=NormalizeDouble(OOP-(OOP-price)/100*PercetnProfit,_Digits);
            StringConcatenate(txt,"SL Sell % ",DoubleToString(prc,_Digits));
           }
         break;
      default: // по пунктам
         if(tip==POSITION_TYPE_BUY)
           {
            prc=NormalizeDouble(price-delta*_Point,_Digits);
            StringConcatenate(txt,"SL Buy pips ",DoubleToString(prc,_Digits));
           }
         if(tip==POSITION_TYPE_SELL)
           {
            prc=NormalizeDouble(price+delta*_Point,_Digits);
            StringConcatenate(txt,"SL Sell pips ",DoubleToString(prc,_Digits));
           }
         break;
     }
   if(tip==POSITION_TYPE_BUY)
     {
      ARROW("cm_SLb",prc,clrGray);
      DrawLABEL(3,"cm SLb",txt,5,50,Color(prc>OOP,clrGreen,clrGray),ANCHOR_RIGHT);
     }
   if(tip==POSITION_TYPE_SELL)
     {
      ARROW("cm_SLs",prc,clrGray);
      DrawLABEL(3,"cm SLs",txt,5,70,Color(prc<OOP,clrRed,clrGray),ANCHOR_RIGHT);
     }
   return(prc);
  }
//--------------------------------------------------------------------
string StrPer(int per)
  {
   if(per==PERIOD_CURRENT) per=Period();
   if(per > 0 && per < 31) return("M"+IntegerToString(per));
   if(per == PERIOD_H1) return("H1");
   if(per == PERIOD_H2) return("H2");
   if(per == PERIOD_H3) return("M3");
   if(per == PERIOD_H4) return("M4");
   if(per == PERIOD_H6) return("M6");
   if(per == PERIOD_H8) return("M8");
   if(per == PERIOD_H12) return("M12");
   if(per == PERIOD_D1) return("D1");
   if(per == PERIOD_W1) return("W1");
   if(per == PERIOD_MN1) return("MN1");
   return("ошибка периода");
  }
//+------------------------------------------------------------------+
void HLINE(string Name,double Price,color c)
  {
   ObjectDelete(0,Name);
   ObjectCreate(0,Name,OBJ_HLINE,0,0,Price,0,0,0,0);
   ObjectSetInteger(0,Name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,Name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,Name,OBJPROP_COLOR,c);
   ObjectSetInteger(0,Name,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,Name,OBJPROP_WIDTH,1);
  }
//+------------------------------------------------------------------+
void ARROW(string Name,double Price,color c)
  {
   if(!DrawArrow) return;
   ObjectDelete(0,Name);
   ObjectCreate(0,Name,OBJ_ARROW_RIGHT_PRICE,0,TimeCurrent(),Price,0,0,0,0);
   ObjectSetInteger(0,Name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,Name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,Name,OBJPROP_COLOR,c);
   ObjectSetInteger(0,Name,OBJPROP_WIDTH,1);
  }
//--------------------------------------------------------------------
void DrawLABEL(int c,string name,string text,int X,int Y,color clr,int ANCHOR=ANCHOR_LEFT,int FONTSIZE=8)
  {
   if(ObjectFind(0,name)==-1)
     {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,c);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,X);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,Y);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FONTSIZE);
      ObjectSetString(0,name,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR);
     }
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
  }
//--------------------------------------------------------------------
color Color(bool P,color c1,color c2)
  {
   if(P) return(c1);
   return(c2);
  }
//--------------------------------------------------------------------
