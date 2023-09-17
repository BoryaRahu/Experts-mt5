//+------------------------------------------------------------------+
//|                                                        EA MM.mq5 |
//|                                                        AIS Forex |
//|                        https://www.mql5.com/ru/users/aleksej1966 |
//+------------------------------------------------------------------+
#property copyright "AIS Forex"
#property link      "https://www.mql5.com/ru/users/aleksej1966"

#include <Trade\PositionInfo.mqh> CPositionInfo     m_position;
#include<Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
enum MM {MinLot,Lin1,Lin2,Exp,Hyp};
input MM MoneyManagement=Lin1;
input uchar Risk=3;
input ushort SL=985,
             TP=620,
             PeriodMA1=30,
             PeriodMA2=20;
CTrade trade;
CSymbolInfo   a_symbol;
CPositionInfo     m_Position;
int risk;
double balance,lastMA1,lastMA2,RSIGBP,RSIUK100;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   risk=MathMax(1,Risk);
   balance=AccountInfoDouble(ACCOUNT_BALANCE);

   lastMA1=CalcMA(PeriodMA1);
   
   lastMA2=CalcMA(PeriodMA2);
   
   RSIGBP = iRSI(_Symbol,PERIOD_H1,20,PRICE_MEDIAN) ;
   //RSIUK100 = iRSI( Symbol UK100 ,PERIOD_H1,20,PRICE_MEDIAN) ;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---


 int pos=PositionsTotal();
   
   
    int posO =0;
    
     for(int i = PositionsTotal() - 1; i >= 0; i--) 
                {
                   if(m_position.SelectByIndex(i)   )  // select a position
                     if(m_position.Symbol()==Symbol())
                        // if(m_position.Magic()==magic_number)
                       posO ++;    
                         
                 } 
     if(0<1)
        {      

   if(NewBar()==true)
     {
      double curMA1=CalcMA(PeriodMA1),
             curMA2=CalcMA(PeriodMA2);

      if(curMA1>curMA2 && lastMA1<lastMA2)
         PutPosition(ORDER_TYPE_BUY);

      if(curMA1<curMA2 && lastMA1>lastMA2)
         PutPosition(ORDER_TYPE_SELL);

      lastMA1=curMA1;
      lastMA2=curMA2;
      }
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PutPosition(ENUM_ORDER_TYPE type)
  {
//---
   double price=type==ORDER_TYPE_BUY? SymbolInfoDouble(_Symbol,SYMBOL_ASK):SymbolInfoDouble(_Symbol,SYMBOL_BID),
          lot=CalcLot(type);

   int slippage=(int)MathMax(SymbolInfoInteger(_Symbol,SYMBOL_SPREAD)/2,3),
     stoplvl=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   double sl=0,tp=0;

   if(type==ORDER_TYPE_BUY)
     {
      sl=SymbolInfoDouble(_Symbol,SYMBOL_BID)-SL*_Point;
      tp=SymbolInfoDouble(_Symbol,SYMBOL_ASK)+TP*_Point;    
     }
   else
     {
      sl=SymbolInfoDouble(_Symbol,SYMBOL_ASK)+SL*_Point;
      tp=SymbolInfoDouble(_Symbol,SYMBOL_BID)-TP*_Point;
     }
/*
   MqlTradeRequest request;
   MqlTradeResult result;
   request.action=TRADE_ACTION_DEAL;
   request.symbol=_Symbol;
   request.volume=lot;
   request.type=type;
   request.price=price;
   request.sl=NormalizeDouble(sl,_Digits);
   request.tp=NormalizeDouble(tp,_Digits);
   request.deviation=slippage;

   if(OrderSend(request,result)==false)
      Print("OrderSend error ",GetLastError());
  */    
     if(ORDER_TYPE_SELL == type)     
               if(!trade.Sell(lot,_Symbol,a_symbol.Bid(),sl,tp,"ORDER_TYPE_SELL"))
                Print("Open .Sell error 1# ",GetLastError()); 
      
        if(ORDER_TYPE_BUY == type)     
               if(!trade.Buy(lot,_Symbol,a_symbol.Ask(),sl,tp,"ORDER_TYPE_BUY"))
                Print("Open .Sell error 1# ",GetLastError()); 
      
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcLot(ENUM_ORDER_TYPE type)
  {
//---
   int m=0,n=0,stoplvl=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL),sl=SL,tp=TP,step;
   double pv=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE)*SymbolInfoDouble(_Symbol,SYMBOL_POINT)/SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE),
          price=type==ORDER_TYPE_BUY? SymbolInfoDouble(_Symbol,SYMBOL_ASK):SymbolInfoDouble(_Symbol,SYMBOL_BID),
          res[][3],lot=0,margin=0,deposit=AccountInfoDouble(ACCOUNT_MARGIN_FREE),
                   lot_min=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN),
                   lot_step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP),
                   lot_max=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);

   if(MoneyManagement==MinLot)
      return(lot_min);

   if(OrderCalcMargin(type,_Symbol,1,price,margin)==false)
      return(lot_min);

   double max_lot=deposit/(deposit-margin);
   step=MathMax(0,(int)MathFloor((max_lot-lot_min)/lot_step));
   lot_max=MathMin(lot_max,lot_min+step*lot_step);

   HistorySelect(0,TimeCurrent());
   int size=HistoryDealsTotal();
   ArrayResize(res,size);

   for(int i=0; i<size; i++)
     {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket>0 && HistoryDealGetInteger(ticket,DEAL_ENTRY)==DEAL_ENTRY_OUT)
        {
         double profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
         n++;
         if(profit>0)
            m++;

         res[i][0]=(double)ticket;
         res[i][1]=profit;
         res[i][2]=HistoryDealGetDouble(ticket,DEAL_VOLUME);
        }
     }

   if((m+0.5)*tp-(n-m+0.5)*sl<=0)
      return(lot_min);
//---
   if(MoneyManagement==Lin1 || MoneyManagement==Lin2)
     {
      double L=0;
      if(size>0)
        {
         for(int i=0; i<size; i++)
            L=L+res[i][1]*res[i][1];
         L=MathSqrt(L/size);
        }
      if(MoneyManagement==Lin1)
         lot=L*(sl+risk*tp)/(2*pv*sl*tp);
      else
         lot=lot_min+L/(risk*tp*pv);
     }

   if(MoneyManagement==Exp || MoneyManagement==Hyp)
     {
      ArraySort(res);
      double d[][2];
      ArrayResize(d,size+1);
      d[0][0]=balance;
      d[0][1]=0;
      for(int i=0; i<size; i++)
        {
         d[i+1][0]=d[i][0]+res[i][1];
         d[i+1][1]=res[i][1]/res[i][2];
        }

      if(MoneyManagement==Exp)
        {
         double sum=0;
         for(int i=1; i<=size; i++)
            sum=sum+d[i][1]/(risk*d[i][1]+d[i-1][0]);
         lot=tp*pv/(risk*tp*pv+d[size][0])-sl*pv/(d[size][0]-risk*sl*pv)+2*sum;
        }

/*
      if(MoneyManagement==WF)
        {
         double w=0;
         double l=0;
         for(int i=1; i<=size; i++)
            sum=sum+d[i][1]/(risk*d[i][1]+d[i-1][0]);
         lot=tp*pv/(risk*tp*pv+d[size][0])-sl*pv/(d[size][0]-risk*sl*pv)+2*sum;
        }

*/
      if(MoneyManagement==Hyp)
        {
         double D=DBL_MAX,clot=lot_min;
         while(clot<=lot_max)
           {
            double sum=0;
            for(int i=1; i<=size; i++)
               sum=sum+d[i][1]/(risk*lot*d[i][1]+d[i-1][0]);
            sum=MathAbs(tp*pv/(risk*lot*tp*pv+d[size][0])-sl*pv/(d[size][0]-risk*lot*sl*pv)-2*sum);
            if(D>sum)
              {
               D=sum;
               lot=clot;
              }
            else
               break;
            clot=clot+lot_step;
           }
        }
     }

   step=MathMax(0,(int)MathRound((lot-lot_min)/lot_step));
   return(MathMin(lot_min+step*lot_step,lot_max));
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcMA(int period)
  {
//---
   double sum=0;
   for(int i=0; i<period; i++)
      sum=sum+iOpen(_Symbol,PERIOD_CURRENT,i);
   return(sum/period);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar()
  {
//---
   static long last_bar;
   long cur_bar=SeriesInfoInteger(_Symbol,PERIOD_CURRENT,SERIES_LASTBAR_DATE);
   if(last_bar<cur_bar)
     {
      last_bar=cur_bar;
      return(true);
     }
   return(false);
//---
  }
//+------------------------------------------------------------------+
