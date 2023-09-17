//+------------------------------------------------------------------+
//|                                          VolumesAndIntervals.mq5 |
//|                                Copyright 2020, Centropolis Corp. |
//|                                          https://Centropolis.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Centropolis Corp."
#property link      "https://Centropolis.com"
#property version   "1.00"

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
CPositionInfo  m_position=CPositionInfo();// trade position object
CTrade         m_trade=CTrade();          // trading object


enum MODE_CALCULATE
   {
   MODE_1=0,
   MODE_2=1,
   MODE_3=2,
   MODE_4=3
   };

input MODE_CALCULATE MODEE=MODE_1;//Mode
input int TradeHour=0;//Start Trading Hour
input int TradeMinute=1;//Start Trading Minute
input int TradeHourEnd=23;//End Trading Hour
input int TradeMinuteEnd=59;//End Trading Minute

input bool bWriteValuesE=false;//Log
input int CandlesE=50;//Bars To Analyse
input int Signal=200;//Signal Power
input int PercentE=52;//Percent Signals To One Side

input bool bInvert=false;//Trade Invert

///////параметры торговли
input int SLE=3000;//Stop Loss Points
input int TPE=3000;//Take Profit Points
input double Lot=0.01;//Lot

input int MagicF=15670867;//Magic
string CurrentSymbol=Symbol();


MqlTick LastTick;//последний тик

//////////минимальный код для имитации предопределенных массивов
double High[];
double Low[];
double Close[];
double Open[];
datetime Time[];
long Volume[];

void DimensionAllMQL5Values()//подготовка массивов
   {
   ArrayResize(Time,CandlesE,0);
   ArrayResize(High,CandlesE,0);
   ArrayResize(Close,CandlesE,0);
   ArrayResize(Open,CandlesE,0);   
   ArrayResize(Low,CandlesE,0);
   ArrayResize(Volume,CandlesE,0);
   }

void CalcAllMQL5Values()//пересчет массивов
   {
   ArraySetAsSeries(High,false);                        
   ArraySetAsSeries(Low,false);                              
   ArraySetAsSeries(Close,false);                        
   ArraySetAsSeries(Open,false);                                 
   ArraySetAsSeries(Time,false); 
   ArraySetAsSeries(Volume,false);                                   
   CopyHigh(_Symbol,_Period,0,CandlesE,High);
   CopyLow(_Symbol,_Period,0,CandlesE,Low);
   CopyClose(_Symbol,_Period,0,CandlesE,Close);
   CopyOpen(_Symbol,_Period,0,CandlesE,Open);
   CopyTime(_Symbol,_Period,0,CandlesE,Time);
   CopyTickVolume(_Symbol,_Period,0,CandlesE,Volume);
   ArraySetAsSeries(High,true);                        
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);                        
   ArraySetAsSeries(Open,true);                                 
   ArraySetAsSeries(Time,true);
   ArraySetAsSeries(Volume,true);
   }
/////////

class TickBox
   {
   public:
   static int BarsUp;
   static int BarsDown;
   static double PowerUp;
   static double PowerDown;
   static double PercentUp;
   static double PercentDown;
   static double PercentPowerUp;
   static double PercentPowerDown;

   static void CalculateAll(MODE_CALCULATE MODE0)//посчитаем все необходимые параметры
      {
      BarsUp=0;
      BarsDown=0;
      PercentUp=0.0;
      PercentDown=0.0;
      PowerUp=0.0;
      PowerDown=0.0;
      if ( MODE0 == MODE_1 )
         {
         for ( int i=0; i<CandlesE; i++ )
            {
            if ( Open[i] < Close[i] )
               {
               BarsUp++;
               PowerUp+=(MathAbs(Open[i] - Close[i])/(High[i] - Low[i]))*Volume[i];
               } 
            if ( Open[i] > Close[i] )
               {
               BarsDown++;
               PowerDown+=(MathAbs(Open[i] - Close[i])/(High[i] - Low[i]))*Volume[i];
               } 
            }
         }
         
      if ( MODE0 == MODE_2 )
         {
         for ( int i=0; i<CandlesE; i++ )
            {
            if ( Open[i] < Close[i] )
               {
               BarsUp++;
               PowerUp+=(MathAbs(Open[i] - Close[i])/_Point)*Volume[i];
               } 
            if ( Open[i] > Close[i] )
               {
               BarsDown++;
               PowerDown+=(MathAbs(Open[i] - Close[i])/-_Point)*Volume[i];
               } 
            }
         }
         
      if ( MODE0 == MODE_3 )
         {
         for ( int i=0; i<CandlesE; i++ )
            {
            if ( Open[i] < Close[i] )
               {
               BarsUp++;
               PowerUp+=(double(CandlesE-i)/double(CandlesE))*(MathAbs(Open[i] - Close[i])/_Point)*Volume[i];
               } 
            if ( Open[i] > Close[i] )
               {
               BarsDown++;
               PowerDown+=(double(CandlesE-i)/double(CandlesE))*(MathAbs(Open[i] - Close[i])/_Point)*Volume[i];
               } 
            }
         }
         
      if ( MODE0 == MODE_4 )
         {
         for ( int i=0; i<CandlesE; i++ )
            {
            if ( Open[i] < Close[i] )
               {
               BarsUp++;
               PowerUp+=(double(CandlesE-i)/double(CandlesE))*(MathAbs(Open[i] - Close[i])/(High[i] - Low[i]))*Volume[i];
               } 
            if ( Open[i] > Close[i] )
               {
               BarsDown++;
               PowerDown+=(double(CandlesE-i)/double(CandlesE))*(MathAbs(Open[i] - Close[i])/(High[i] - Low[i]))*Volume[i];
               } 
            }
         }
         
      if ( BarsUp > 0 && BarsDown > 0 )
         {
         PercentUp=(double(BarsUp)/double(BarsUp+BarsDown))*100.0;
         PercentDown=(double(BarsDown)/double(BarsUp+BarsDown))*100.0;
         PercentPowerUp=(double(PowerUp)/double(PowerUp+PowerDown))*100.0;
         PercentPowerDown=(double(PowerDown)/double(PowerUp+PowerDown))*100.0;
         }         
      }
   };
   int TickBox::BarsUp=0;
   int TickBox::BarsDown=0;
   double TickBox::PowerUp=0;
   double TickBox::PowerDown=0;   
   double TickBox::PercentUp=0;
   double TickBox::PercentDown=0;
   double TickBox::PercentPowerUp=0;
   double TickBox::PercentPowerDown=0;        

int HourCorrect(int hour0)
   {
   int rez=0;
   if ( hour0 < 24 && hour0 > 0 )
      {
      rez=hour0;
      }
   return rez;
   }
   
int MinuteCorrect(int minute0)
   {
   int rez=0;
   if ( minute0 < 60 && minute0 > 0 )
      {
      rez=minute0;
      }
   return rez;      
   }

void Trade()
   {
   SymbolInfoTick(Symbol(),LastTick);
   MqlDateTime tm;
   TimeToStruct(LastTick.time,tm);
   int MinuteEquivalent=tm.hour*60+tm.min;
   int BorderMinuteStartTrade=HourCorrect(TradeHour)*60+MinuteCorrect(TradeMinute);
   int BorderMinuteEndTrade=HourCorrect(TradeHourEnd)*60+MinuteCorrect(TradeMinuteEnd);
   if ( MathAbs(TickBox::BarsUp-TickBox::BarsDown) >= 1.0 && TickBox::PercentPowerUp >= 50.0 )
      {
      if ( !bInvert ) ClosePosition(POSITION_TYPE_BUY);
      else ClosePosition(POSITION_TYPE_SELL);
      }
      
   if ( MathAbs(TickBox::BarsUp-TickBox::BarsDown) >= 1.0 && TickBox::PercentPowerDown >= 50.0 )
      {
      if ( !bInvert ) ClosePosition(POSITION_TYPE_SELL);
      else ClosePosition(POSITION_TYPE_BUY);
      }
      
     if ( BorderMinuteStartTrade > BorderMinuteEndTrade )
        {
        if ( PositionsTotal() == 0 && !(MinuteEquivalent>=BorderMinuteEndTrade && MinuteEquivalent<= BorderMinuteStartTrade) )
           {
           if ( MathAbs(TickBox::BarsUp-TickBox::BarsDown) >= Signal && TickBox::PercentPowerUp >= PercentE )
              {
              if ( !bInvert ) m_trade.Sell(Lot,_Symbol,LastTick.ask,LastTick.ask+double(SLE)*_Point,LastTick.bid-double(TPE)*_Point);
              else m_trade.Buy(Lot,_Symbol,LastTick.ask,LastTick.bid-double(SLE)*_Point,LastTick.ask+double(TPE)*_Point);
              }
      
           if ( MathAbs(TickBox::BarsUp-TickBox::BarsDown) >= Signal && TickBox::PercentPowerDown >= PercentE )
              {
              if ( !bInvert ) m_trade.Buy(Lot,_Symbol,LastTick.ask,LastTick.bid-double(SLE)*_Point,LastTick.ask+double(TPE)*_Point);
              else m_trade.Sell(Lot,_Symbol,LastTick.ask,LastTick.ask+double(SLE)*_Point,LastTick.bid-double(TPE)*_Point);
              }
           }        
        }
     if ( PositionsTotal() == 0 && BorderMinuteStartTrade <= BorderMinuteEndTrade )
        {
        if ( MinuteEquivalent>=BorderMinuteStartTrade && MinuteEquivalent<= BorderMinuteEndTrade )
           {
           if ( MathAbs(TickBox::BarsUp-TickBox::BarsDown) >= Signal && TickBox::PercentPowerUp >= PercentE )
              {
              if ( !bInvert ) m_trade.Sell(Lot,_Symbol,LastTick.ask,LastTick.ask+double(SLE)*_Point,LastTick.bid-double(TPE)*_Point);
              else m_trade.Buy(Lot,_Symbol,LastTick.ask,LastTick.bid-double(SLE)*_Point,LastTick.ask+double(TPE)*_Point);
              }
      
           if ( MathAbs(TickBox::BarsUp-TickBox::BarsDown) >= Signal && TickBox::PercentPowerDown >= PercentE )
              {
              if ( !bInvert ) m_trade.Buy(Lot,_Symbol,LastTick.ask,LastTick.bid-double(SLE)*_Point,LastTick.ask+double(TPE)*_Point);
              else m_trade.Sell(Lot,_Symbol,LastTick.ask,LastTick.ask+double(SLE)*_Point,LastTick.bid-double(TPE)*_Point);
              }
           }        
        }
   }

void ClosePosition(ENUM_POSITION_TYPE Direction)//закрыть позицию по символу
   {
   bool ord;
   ord=PositionSelect(Symbol());
   if ( ord && int(PositionGetInteger(POSITION_MAGIC)) == MagicF  && Direction == ENUM_POSITION_TYPE(PositionGetInteger(POSITION_TYPE)) )
      {
      if(m_position.SelectByIndex(0)) m_trade.PositionClose(m_position.Ticket());          
      }
   }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  m_trade.SetExpertMagicNumber(MagicF);//установим магик для позиций
  DimensionAllMQL5Values();//подготовим предопределенные массивы
  return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+


datetime Time0;
datetime TimeX[1];
bool bNewBar()
   {
   CopyTime(_Symbol,_Period,0,1,TimeX);
   if ( Time0 < TimeX[0] )
      {
      if (Time0 != 0)
         {
         Time0=TimeX[0];
         return true;
         }
      else
         {
         Time0=TimeX[0];
         return false;
         }
      }
   else return false;
   }

void OnTick()
  {
  if ( bNewBar())//работаем по барам
     {
     CalcAllMQL5Values();
     TickBox::CalculateAll(MODEE);
     if (bWriteValuesE)
        {
        Print("% Sit in buy = ",TickBox::PercentUp);
        Print("% Sit in sell = ",TickBox::PercentDown);
        Print("Signal = ",MathAbs(TickBox::BarsDown-TickBox::BarsUp));
        Print("% Resistance = ",TickBox::PercentPowerUp);
        Print("% Support = ",TickBox::PercentPowerDown);        
        Print("***************************************************************************");
        }
     Trade();
     } 
  }
