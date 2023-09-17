#define VERSION "1.0"
#property version VERSION

#define PROJECT_NAME MQLInfoString(MQL_PROGRAM_NAME)

#include <Trade/Trade.mqh>
#include <Trade\PositionInfo.mqh> CPositionInfo     m_position;
#include <Trade\SymbolInfo.mqh>


input int           PointStep                 = 20 ; 
input double        iStartLots          = 0.01;     // Start lot
input ulong          iMagicNumber        = -1;      // Magic Number (in number)
input int          iSlippage           = 30;       // Slippage (in pips)
input int          MaxOrderAver        = 0;
input int          MaxOrderPyramid     = 6;
input bool         COMENT              = false; 
//---
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
  
input double Lots = 0.1;
input double RiskPercent = 2.0; //RiskPercent (0 = Fix)

input int OrderDistPoints = 200;
input int TpPoints = 200;
input int SlPoints = 200;
input int TslPoints = 5;
input int TslTriggerPoints = 5;

input ENUM_TIMEFRAMES Timeframe = PERIOD_H1;
input int BarsHigh1 = 5;
input int BarsHigh2 = 200;
input int BarsLow1 = 5;
input int BarsLow2 = 200;
input int ExpirationHours = 50;

input int Magic = 11123;
input bool    VirtualTrailingStop=false; 
//виртуальный трейлингстоп
input t        parameters_trailing  =3;                        //метод трала
input  int     delta                =5;                            // отступ от расчетного уровня стоплосса
input          ENUM_TIMEFRAMES TF_Tralling=0;      // таймфрейм индикаторов (0-текущий)
input  int     StepTrall            =5;                        // шаг перемещения стоплосс
input  int          StartTrall           =  0 ;                       // минимальная прибыль трала в пунктах
color          text_color           =clrGreen;     //цвет вывода информации
sinput string Advanced_Options="";
input int     period_ATR=14;//Период ATR (метод 3)
input  double        koef = 100;
input double    Step=50000; //Parabolic Step (метод 4)
input double    Maximum=0.2; //Parabolic Maximum (метод 4)
  // int     iMagicNumber= -1;//с каким магиком тралить (-1 все)
extern bool    GeneralNoLoss=false;   // трал от точки безубытка
extern bool    DrawArrow=false;   // показывать метки безубытка и стопов
//+------------------MACD------------------------------------------------+
input ENUM_TIMEFRAMES  Fast_period=0; ;
input int ema_period=12;
input int low_ema_period=26;
input int signal_period=9;

input ENUM_APPLIED_PRICE applied_priceS=PRICE_CLOSE;



input int ma_period=34;//период МА (метод 5)
input ENUM_MA_METHOD ma_method=MODE_SMA; // метод усреднения  (метод 5)
input ENUM_APPLIED_PRICE applied_price=PRICE_CLOSE;    // тип цены  (метод 5)

input double PercetnProfit=50;//процент от профита (метод 6)
CTrade trade;
CPositionInfo     m_Position;   // entity for obtaining information on positions
ulong buyPos, sellPos;
int totalBars;

CSymbolInfo       m_symbol;


double eStep = 0;
int    HighBig ,LowBig, HighLitl,LowLitl, MA,handleClose, rsi, handle , MidlBig , MACD,STOC , JMAhandle, JMAhandlebig, MAbig ,JMAhandleM ,JMAhandlel ,Envelop ,EJMAhandle;
int STOPLEVEL;
double Bid,Ask,SLB=0,SLS=0;
int slippage=100;
int maHandle;    // хэндл индикатора Moving Average
double maVal[] , hiMACD;  // динамический массив для хранения значений индикатора Moving Average для каждого бара
int atrHandle;    // хэндл индикатора Moving Average
double atrVal[];  // динамический массив для хранения значений индикатора Moving Average для каждого бара
int sarHandle;    // хэндл индикатора Moving Average
double sarVal[];  // динамический массив для хранения значений индикатора Moving Average для каждого бара

MqlTradeRequest   request;  // параметры торгового запроса
MqlTradeResult   result;    // результат торгового запроса
MqlTradeCheckResult check;
//**************************




int OnInit(){
   trade.SetExpertMagicNumber(Magic);
   if(!trade.SetTypeFillingBySymbol(_Symbol)){
      trade.SetTypeFilling(ORDER_FILLING_RETURN);
   }

   static bool isInit = false;
   if(!isInit){
      isInit = true;
      Print(__FUNCTION__," > EA (re)start...");
      Print(__FUNCTION__," > EA version ",VERSION,"...");
       
      for(int i = PositionsTotal()-1; i >= 0; i--){
         CPositionInfo pos;
         if(pos.SelectByIndex(i)){
            if(pos.Magic() != Magic) continue;
            if(pos.Symbol() != _Symbol) continue;

            Print(__FUNCTION__," > Found open position with ticket #",pos.Ticket(),"...");
            if(pos.PositionType() == POSITION_TYPE_BUY) buyPos = pos.Ticket();
            if(pos.PositionType() == POSITION_TYPE_SELL) sellPos = pos.Ticket();
         }
      }

      for(int i = OrdersTotal()-1; i >= 0; i--){
         COrderInfo order;
         if(order.SelectByIndex(i)){
            if(order.Magic() != Magic) continue;
            if(order.Symbol() != _Symbol) continue;

            Print(__FUNCTION__," > Found pending order with ticket #",order.Ticket(),"...");
            if(order.OrderType() == ORDER_TYPE_BUY_STOP) buyPos = order.Ticket();
            if(order.OrderType() == ORDER_TYPE_SELL_STOP) sellPos = order.Ticket();
         }
      }
   }
   
  
   
   eStep  = Step * _Point*_Digits ;
   
  double  MABuffer[];
  double  _MAbig[];
    HighBig=iMA(_Symbol,NULL,ema_period,1,MODE_EMA,PRICE_HIGH); 
  LowBig =iMA(_Symbol,NULL,ema_period,1,MODE_EMA,PRICE_LOW); 
  trade.SetTypeFillingBySymbol(m_symbol.Name());
  hiMACD = iMACD(_Symbol,Fast_period,ema_period,low_ema_period,signal_period,applied_priceS); 
   
     if(VirtualTrailingStop) GeneralNoLoss=true;
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
   
  
  if ( COMENT) Comment("");
   trade.LogLevel(LOG_LEVEL_ERRORS);
   trade.SetExpertMagicNumber(iMagicNumber);
   trade.SetDeviationInPoints(iSlippage);
   trade.SetMarginMode();
   trade.SetTypeFillingBySymbol(Symbol());

   return(INIT_SUCCEEDED);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){

}
//////////////////////////////////////////////////void OnTick()
void OnTick(){

   
   
   
   
   
   
    ulong    tk=0;
   
   
   int bs=0,ss=0;  
   int total=PositionsTotal(); 
    
    
      ENUM_ORDER_TYPE order_type =WRONG_VALUE ;  
   for(int k=total-1; k>=0; k--)
      if(m_position.SelectByIndex(k))
       
         if(m_position.Symbol()==Symbol())
            if(m_position.Magic()==Magic)

            
               if(m_position.PositionType()==POSITION_TYPE_BUY || m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  tk=m_position.Ticket();
                  
                  if(m_position.PositionType()==POSITION_TYPE_BUY)
                    {
                     bs++;
                      processPos(tk);
                    }
     
                  if(m_position.PositionType()==POSITION_TYPE_SELL)
                    {
                     ss++;
                     processPos(tk);
                    } 
                }     
                     
     
  
             
                     
                     
                     
                     
                     
                     

   int bars = iBars(_Symbol,Timeframe);
   if(totalBars != bars){
      totalBars = bars;
         double high1 = findHigh1();
         double high2 = findHigh2();
         double low1 = findLow1();
         double low2 = findLow2();
///////////////////////////////////////////////BUY      
      if(buyPos <= 0){
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   //if ( low1>low2 && high1>high2&& ask>low1  ){
    if ( low1>low2 && high1>high2&& ask>low1//&& low2>0   
   ){
   double tp =  ask+ TpPoints * _Point;
   tp = NormalizeDouble(tp,_Digits);
   double sl = ask - SlPoints * _Point;
   sl = NormalizeDouble(sl,_Digits);
   double lots = Lots;
  // if(RiskPercent > 0) lots = calcLots(low2-sl);
                              //Print("Bid",DoubleToString(Bid));   
                              {
                              if(!trade.Buy (NormalizeDouble(lots ,2 ),_Symbol,ask, sl,tp    ))
                               Print("OrderSend error 2   # Buy",GetLastError());   
                             }
                
           }
         }
      
//Print(DoubleToString(ss,3));

      if(ss <= 0){
          double Bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   if ( low1>low2 && high1>high2&& Bid>low1//&& low2>0   
   ){
   /*
   double tp =(low1- low2)-Bid;//  Bid- TpPoints * _Point;
   tp = NormalizeDouble(tp,_Digits);
   double sl =Bid + TslPoints * _Point;
   sl = NormalizeDouble(sl,_Digits);
   */
   
   
   double tp = Bid - TpPoints * _Point;
   tp = NormalizeDouble(tp,_Digits);
   
   double sl = Bid + SlPoints * _Point;
   sl = NormalizeDouble(sl,_Digits);
   double lots = Lots;
  // if(RiskPercent > 0) lots = calcLots(low2-sl);

                              {
                          //    Print("Bid",DoubleToString(Bid));   
                           //    Print("low1",DoubleToString(low1));
                          //      Print("low2",DoubleToString(low2));
                              
                            //  if(!trade.Sell(NormalizeDouble(lots ,2 ),_Symbol,Bid, sl,tp    ))
                            //   Print("OrderSend error 2   # Buy",GetLastError());   
                             }
                
           }
         }
      }
      
      
      
      

 
//************************************************************
/*
   
if ( COMENT)
{
      StringConcatenate(txt,"Profit TOTAL ",DoubleToString(TPP  ,2));
   DrawLABEL(2,"Profit SELLccc",txt,5,85,Lime,ANCHOR_RIGHT);
   
   StringConcatenate(txt,"TLB ",DoubleToString(TPB  ,3));
   DrawLABEL(2,"TLB",txt,5,100,Lime,ANCHOR_RIGHT);
  StringConcatenate(txt," TLS ",DoubleToString( TPS ,3));
 DrawLABEL(2," TLS",txt,5,115,Lime,ANCHOR_RIGHT);
    StringConcatenate(txt,"Profit TOTAL ",DoubleToString(TPP  ,2));
   DrawLABEL(2,"Profit SELLccc",txt,5,85,Lime,ANCHOR_RIGHT);
 }
       
/*************************************************************/
//           Закрытие  ордеров по тралу по атр
//*************************************************************//     

int b=0,s=0;   
long OT;
   int n=0;
   double OOP=0;
    double
   selln=0,buyn=0,op=0,lt=0,tp=0, sl=0;
   
  // StringConcatenate(txt,"Balance ",DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2));
  // StringConcatenate(txt,"Equity ",DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2));
 //  DrawLABEL(2,"cm Equity",txt,5,35,Lime,ANCHOR_RIGHT);
//----
   if(!VirtualTrailingStop) STOPLEVEL=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
  // double sl,SL;
   Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   int i;
   double PB=0,PS=0,OL=0,NLb=0,NLs=0,LS=0,LB=0;double SL;
//----
   for(i=0; i<PositionsTotal(); i++)
     {
     
      if(_Symbol==PositionGetSymbol(i))
        {
       //  Print("111111111111111111111111111111111"); 
       //  if(iMagicNumber==OrderGetInteger(ORDER_MAGIC) ||iMagicNumber==-1)
        //   {
            
           
            OL  = PositionGetDouble(POSITION_VOLUME);
            OOP = PositionGetDouble(POSITION_PRICE_OPEN);
            OT  = PositionGetInteger(POSITION_TYPE);
            if(OT==POSITION_TYPE_BUY ) {PB += OOP*OL; LB+=OL; b++;}
            if(OT==POSITION_TYPE_SELL) {PS += OOP*OL; LS+=OL; s++;}
        //   }
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
        if( Magic==OrderGetInteger(ORDER_MAGIC) || Magic ==-1)
      //     {
            OL  = PositionGetDouble(POSITION_VOLUME);
            OOP = PositionGetDouble(POSITION_PRICE_OPEN);
            OT  = PositionGetInteger(POSITION_TYPE);
            sl=PositionGetDouble(POSITION_SL);
            if(OT==POSITION_TYPE_BUY  )
            
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
                // Print("222222222222222222"); 
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
       // }
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
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
}
void  OnTradeTransaction(
   const MqlTradeTransaction&    trans,
   const MqlTradeRequest&        request,
   const MqlTradeResult&         result
   ){
   
   if(trans.type == TRADE_TRANSACTION_ORDER_ADD){
      COrderInfo order;
      if(order.Select(trans.order)){
         if(order.Magic() == Magic){
            if(order.OrderType() == ORDER_TYPE_BUY_STOP){
               buyPos = order.Ticket();
            }else if(order.OrderType() == ORDER_TYPE_SELL_STOP){
               sellPos = order.Ticket();
            }
         }
      }
   }
}

void processPos(ulong &posTicket){
   if(posTicket <= 0) return;
   if(OrderSelect(posTicket)) return;
   
   CPositionInfo pos;
   if(!pos.SelectByTicket(posTicket)){
      posTicket = 0;
      return;
   }else{
      if(pos.PositionType() == POSITION_TYPE_BUY){
         double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
         
         if(bid > pos.PriceOpen() + TslTriggerPoints * _Point){
            double sl = bid - TslPoints * _Point;
            sl = NormalizeDouble(sl,_Digits);
            
            if(sl > pos.StopLoss()){
               trade.PositionModify(pos.Ticket(),sl,pos.TakeProfit());
            }
         }
      }else if(pos.PositionType() == POSITION_TYPE_SELL){
         double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         
         if(ask < pos.PriceOpen() - TslTriggerPoints * _Point){
            double sl = ask + TslPoints * _Point;
            sl = NormalizeDouble(sl,_Digits);
            
            if(sl < pos.StopLoss() || pos.StopLoss() == 0){
               trade.PositionModify(pos.Ticket(),sl,pos.TakeProfit());
            }
         }
      }
   }
}


double calcLots(double slPoints){
   double risk = AccountInfoDouble(ACCOUNT_BALANCE) * RiskPercent / 100;
   
   double ticksize = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tickvalue = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double lotstep = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   
   double moneyPerLotstep = slPoints / ticksize * tickvalue * lotstep;   
   double lots = MathFloor(risk / moneyPerLotstep) * lotstep;
   
   lots = MathMin(lots,SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX));
   lots = MathMax(lots,SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN));
   
   return lots;
}

double findHigh1(){
   double highestHigh = 0;
   for(int i = 0; i < 200; i++){
      double high = iHigh(_Symbol,Timeframe,i);
      if(i > BarsHigh1 && iHighest(_Symbol,Timeframe,MODE_HIGH,BarsHigh1*2+1,i-BarsHigh1) == i){
         if(high > highestHigh){
            return high;
         }
      }
      highestHigh = MathMax(high,highestHigh);
   }
   return -1;
}

double findHigh2(){
   double highestHigh = 0;
   for(int i = 0; i < 200; i++){
      double high2 = iHigh(_Symbol,Timeframe,i);
      if(i > BarsHigh2 && iHighest(_Symbol,Timeframe,MODE_HIGH,BarsHigh2*2+1,i-BarsHigh2) == i){
         if(high2 > highestHigh){
            return high2;
         }
      }
      highestHigh = MathMax(high2,highestHigh);
   }
   return -1;
}





double findLow1(){
   double lowestLow = DBL_MAX;
   for(int i = 0; i < 200; i++){
      double low = iLow(_Symbol,Timeframe,i);
      if(i > BarsLow1 && iLowest(_Symbol,Timeframe,MODE_LOW, BarsLow1*2+1,i- BarsLow1) == i){
         if(low < lowestLow){
            return low;
         }
      }   
      lowestLow = MathMin(low,lowestLow);
   }
   return -1;
   
   

}
double findLow2(){
   double lowestLow = DBL_MAX;
   for(int i = 0; i < 200; i++){
      double low2 = iLow(_Symbol,Timeframe,i);
      if(i >BarsLow2 && iLowest(_Symbol,Timeframe,MODE_LOW,BarsLow2*2+1,i-BarsLow2) == i){
         if(low2 < lowestLow){
            return low2;
         }
      }   
      lowestLow = MathMin(low2,lowestLow);
   }
   return -1;
}
//+------------------------------------------------------------------+
//| Возвращает true, если появился новый бар для пары символ/период  |
//+------------------------------------------------------------------+
bool isNewBar()
  {


 static datetime PrevBars=0;
   datetime time_0=iTime(Symbol(),PERIOD_M1,0);
   if(time_0==PrevBars)
   {
      return(false);
    PrevBars=time_0;
   
   }
  else 
   return(true);
   
    }
    
    
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
                  prc=_iHigh(Symbol(),TF_Tralling,i);
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
double _iLow(string symbol,ENUM_TIMEFRAMES tf,int index)
  {
   if(index < 0) return(-1);
   double Arr[];
   if(CopyLow(symbol,tf, index, 1, Arr)>0) return(Arr[0]);
   else return(-1);
  }
//--------------------------------------------------------------------
double _iHigh(string symbol,ENUM_TIMEFRAMES tf,int index)
  {
   if(index < 0) return(-1);
   double Arr[];
   if(CopyHigh(symbol,tf, index, 1, Arr)>0) return(Arr[0]);
   else return(-1);
  }


void CloseAllPosition()
{
for(int i =PositionsTotal()-1; i>=0; i--)
           {
           ulong ticket =  PositionGetTicket(i);
           trade.PositionClose(ticket,30);
           }
 }     
 

 

 
 
 