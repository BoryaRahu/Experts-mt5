//+------------------------------------------------------------------+
//|                                          MACD_Cross_Stoploss.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include<Trade\Trade.mqh>
CTrade trade;
int MATrend;
int MADirection;
int MACD;
int ATR;
int RSI;
input int afi;// ----------RiskAmount------------
input double risk = 0.02; //% Amount to risk
input int atrValue = 20; // ATR VAlue
input int rsi = 20; // RSI VAlue
input int ai;// ----------Moving Average inputs------------
input int movAvgTrend = 200;// Moving Average Trend
input int movAvgDirection = 50;//moving Average for trend Direction;
input int i;// -----------MACD inputs-----------------------
input int fast = 12;// Macd Fast
input int slow = 26; //Macd Slow
input int signal = 9; //Signal Line

double point;
double pipValue  = 0.0;// 
double Equity;
double Balance;
double theLotsize;
double lowestrsiValue = 100;
double highestrsiValue = 0.0;

bool buyTrade = false; //Buy if all Conditions are true
bool sellTrade = false;//Sell if all Conditions are true
string trend = "";
int OnInit()
  {
//---
      //Moving Averages Indicators''
      MATrend = iMA(_Symbol,_Period,movAvgTrend,0,MODE_SMA,PRICE_CLOSE);
      MADirection = iMA(_Symbol,_Period,movAvgDirection,0,MODE_EMA,PRICE_CLOSE);
      //MACD
      MACD = iMACD(_Symbol,_Period,fast,slow,signal,PRICE_CLOSE);
      //ATR
      ATR = iATR(_Symbol,_Period,atrValue);
      //RSI
      RSI = iRSI(_Symbol,_Period,rsi,PRICE_CLOSE);
      //---
      point=_Point;
      double Digits=_Digits;
      
      if((_Digits==3) || (_Digits==5))
      {
         point*=10;
      }
      return(INIT_SUCCEEDED);
  }

void OnTick()
  {
//---
   pipValue  = ((((SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE))*point)/(SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE))));
   Equity = AccountInfoDouble(ACCOUNT_EQUITY);
   Balance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   if (PositionsTotal()==0) {
      Strategy();
   } else if (PositionsTotal()>0) {
      smartClose();// This method is called only when there is an active trade
   }
  }
//+------------------------------------------------------------------+
void Strategy() {
   MqlRates priceAction[];
   ArraySetAsSeries(priceAction,true);
   int priceData = CopyRates(_Symbol,_Period,0,200,priceAction); 
   
   double maTrend[]; ArraySetAsSeries(maTrend,true);
   CopyBuffer(MATrend,0,0,200,maTrend); //200 MA
     
   double madirection[]; ArraySetAsSeries(madirection,true);
   CopyBuffer(MADirection,0,0,200,madirection);  //50 MA
   
   double macd[]; ArraySetAsSeries(macd,true);
   CopyBuffer(MACD,0,0,200,macd);  //MACD
   
   double macds[]; ArraySetAsSeries(macds,true);
   CopyBuffer(MACD,1,0,200,macds);  //MACD_Signal Line   
      
   double Bid  = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);  
   ObjectDelete(0,"sl");
   buyTrade = false;
   sellTrade = false;
   lowestrsiValue = 100;
   highestrsiValue = 0.0;
   
   if (madirection[1]>maTrend[1]) {
      //Buy ; Uptrend
     
     trend = "UpTrade";
      
      bool macd_bZero = macds[1]<0; //MacD Signal Line is less than Zero
      bool macd_cross = macd[1]>macds[1];// Macd Crosses the signal line
      
      if (macd_bZero && macd_cross) {
         buyTrade = true;
      }
      
      
   } else if (madirection[1]<maTrend[1]) {
      //Sell; DownTrend
      
      trend = "DownTrend";
      bool macd_bZero = macds[1]>0; //MacD Signal Line is less than Zero
      bool macd_cross = macd[1]<macds[1];// Macd Crosses the signal line
      
      if (macd_bZero && macd_cross) {
         sellTrade = true;
      }      
      
    }  
    
   if (buyTrade && sellTrade) {
      buyTrade = false;
      sellTrade = false;
   return;
   }
      
      
   if (buyTrade) {
      //buyTrade = false;
      sellTrade = false;
      
      Buy(Ask);
   } else if (sellTrade) {
      buyTrade = false;
      //sellTrade = false;
      
      Sell(Bid);   
   }
   Comment("Trend:-"+trend);
}


void smartClose() {
   double thersi[]; ArraySetAsSeries(thersi,true);
   CopyBuffer(RSI,0,0,200,thersi);
   if (Equity<Balance) {// First check if we are at loss
      if (buyTrade) {// Determine if its a buy trade or sell Trade
           // Print(ObjectGetDouble(0,"sl",OBJPROP_PRICE,0));
            
            if (thersi[1]<ObjectGetDouble(0,"sl",OBJPROP_PRICE,0)) {
                   for(int i=PositionsTotal();i>=0;i--) {
                        trade.PositionClose(PositionGetTicket(i)); 
                     }                  
                  buyTrade = false;
            }
            
         
      } else if (sellTrade) {// Determine if its a buy trade or sell Trade
            //Print(ObjectGetDouble(0,"sl",OBJPROP_PRICE,0)); 
            if (thersi[1]>ObjectGetDouble(0,"sl",OBJPROP_PRICE,0)) {
                for(int i=PositionsTotal();i>=0;i--) {
                     trade.PositionClose(PositionGetTicket(i)); 
                  }            
                  sellTrade = false;
            }                  
      }
   }
}
void Buy(double Ask) {
   double atr[]; ArraySetAsSeries(atr,true); //This array is use to store all ATR value to the last closed bar
   CopyBuffer(ATR,0,0,200,atr); // This method copy the buffer value of the ATR indicator into the array (200 buffered data)

   theLotsize =0.01; // NormalizeDouble((Balance*risk)/((MathAbs(Ask-((stoplossforBuy(20)-atr[1])))*100)*pipValue),2); // This Calculate the lotsize using the % to risk
   
   ObjectCreate(0,"sl",OBJ_HLINE,3,0,lowestRSI(10)); // Since our stoploss is zero we assign a smart stoploss on the rsi by drawing a line on the rsi window
   trade.Buy(theLotsize,_Symbol,Ask,0,Ask+(2*MathAbs(Ask-((stoplossforBuy(20)-atr[1])))),NULL);//Buy Entry with zero stoploss && take profit is twice the distance between the entry and the lowest candle
    Print("SL",lowestRSI(10));
}
void Sell(double Bid) {
   double atr[]; ArraySetAsSeries(atr,true); //This array is use to store all ATR value to the last closed bar
   CopyBuffer(ATR,0,0,200,atr); // This method copy the buffer value of the ATR indicator into the array (200 buffered data)
   
   theLotsize =  0.01; // NormalizeDouble((Balance*risk)/((MathAbs(Bid-((stoplossforSell(20)+atr[1])))*100)*pipValue),2);  // This Calculate the lotsize using the % to risk
   
   ObjectCreate(0,"sl",OBJ_HLINE,3,0,highestRSI(10)); // Since our stoploss is zero we assign a smart stoploss on the rsi by drawing a line on the rsi window
   trade.Sell(theLotsize,_Symbol,Bid,0,Bid-(2*MathAbs(((stoplossforSell(20)+atr[1]))-Bid)),NULL);//Sell Entry with zero stoploss && take profit is twice the distance between the entry and the highest candle
   Print("SL",highestRSI(10));
}


double stoplossforBuy(int numcandle) {
         int LowestCandle;
         
         //Create array for candle lows
         double low[];
         
         //Sort Candle from current downward
         ArraySetAsSeries(low,true);
         
         //Copy all lows for 100 candle
         CopyLow(_Symbol,_Period,0,numcandle,low);
         
         //Calculate the lowest candle
         LowestCandle = ArrayMinimum(low,0,numcandle);
         
         //Create array of price
         MqlRates PriceInfo[];
         
         ArraySetAsSeries(PriceInfo,true);
         
         //Copy price data to array
         
         int Data = CopyRates(Symbol(),Period(),0,Bars(Symbol(),Period()),PriceInfo);
      
         return PriceInfo[LowestCandle].low;
                  
      
         

}
double stoplossforSell(int numcandle) {
         int HighestCandle;
         double High[];
       
       //Sort array downward from current candle
         ArraySetAsSeries(High,true);
       
       //Fill array with data for 100 candle
         CopyHigh(_Symbol,_Period,0,numcandle,High);
         
         //calculate highest candle
         HighestCandle = ArrayMaximum(High,0,numcandle);
         
         //Create array for price
         MqlRates PriceInformation[];
         ArraySetAsSeries(PriceInformation,true);
         
         
         //Copy price data to array
         int Data = CopyRates(Symbol(),Period(),0,Bars(Symbol(),Period()),PriceInformation);
         
         return PriceInformation[HighestCandle].high;
           
 
 }
 //This method get the lowest RSI afer ENtry to set the smart Stoploss
 double lowestRSI(int count) {     
      double thersi[]; ArraySetAsSeries(thersi,true);
      CopyBuffer(RSI,0,0,200,thersi);
      
      for (int i = 0; i<count;i++) {
      
         if (thersi[i]<lowestrsiValue) {
            lowestrsiValue = thersi[i];
         }
      }
   return lowestrsiValue;
}
//This method get the Highest RSI afer ENtry to set the smart Stoploss
double highestRSI(int count) {

      
      double thersi[]; ArraySetAsSeries(thersi,true);
      CopyBuffer(RSI,0,0,200,thersi);
      
      for (int i = 0; i<count;i++) {
      
         if (thersi[i]>highestrsiValue) {
            highestrsiValue = thersi[i];
         }
      }
   return highestrsiValue;
}