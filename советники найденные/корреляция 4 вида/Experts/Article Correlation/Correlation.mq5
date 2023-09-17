//+------------------------------------------------------------------+
//|                                                  Correlation.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "Trade.mqh" 
CTradeBase Trade;
//+------------------------------------------------------------------+
//| Перечисление режимов работы                                      |
//+------------------------------------------------------------------+
enum Strategy_type
  {
   DECREASE = 1,           //On Decrease       
   INCREASE                //On Increase
  };
//+------------------------------------------------------------------+
//| Перечисление методов измерения корреляции                        |
//+------------------------------------------------------------------+
enum Corr_method
  {
   PEARSON = 1,            //Pearson       
   SPEARMAN,               //Spearman
   KENDALL,                //Kendall
   FECHNER                 //Fechner
  };
//+------------------------------------------------------------------+
//| Входные параметры эксперта                                       |
//+------------------------------------------------------------------+
input    string               Inp_EaComment="Correlation Strategy";        //EA Comment
input    double               Inp_Lot=0.01;                                //Lot
input    MarginMode           Inp_MMode=LOT;                               //MM

//--- Выбор метода расчета корреляции и тип стратегии
input    Corr_method          Inp_Corr_method=1;                           //Correlation Method
input    Strategy_type        Inp_Strategy_type=1;                         //Strategy type

//--- Параметры эксперта
input    string               Inp_Str_label="===EA parameters===";         //Label
input    int                  Inp_MagicNum=1111;                           //Magic number
input    int                  Inp_StopLoss=40;                             //Stop Loss(points)
input    int                  Inp_TakeProfit=30;                           //Take Profit(points)
//--- Параметры индикатора 
input    int                  Inp_RangeN=8;                                //Rang Calculation
input    double               Inp_KeyLevel=0.4;                            //Key Level    
input    ENUM_TIMEFRAMES      Inp_Timeframe=PERIOD_M10;                    //Working Timeframe                                       

int InpInd_Handle;
double corr[];
string ind_type;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Проверка на наличие подключения к торговому серверу
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
     {
      Print(Inp_EaComment,": No Connection!");
      return(INIT_FAILED);
     }

//--- Проверка на разрешение автоторговли
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Print(Inp_EaComment,": Trade is not allowed!");
      return(INIT_FAILED);
     }
//--- Проверка на правильность ключевого уровня
   if(Inp_KeyLevel>1 || Inp_KeyLevel<0)
     {
      Print(Inp_EaComment,": Incorrect key level!");
      return(INIT_FAILED);
     }
//--- 
   switch(Inp_Corr_method)
     {
      case 1:
         ind_type="Correlation\\PearsonCorrelation";
         break;
      case 2:
         ind_type="Correlation\\SpearmanCorrelation";
         break;
      case 3:
         ind_type="Correlation\\KendallCorrelation";
         break;
      case 4:
         ind_type="Correlation\\FechnerCorrelation";
         break;
      default:
         break;
     }
//--- Получение хэндла индикатора 
   InpInd_Handle=iCustom(Symbol(),Inp_Timeframe,ind_type,Inp_RangeN);
   if(InpInd_Handle==INVALID_HANDLE)
     {
      Print(Inp_EaComment,": Failed to get indicator handle");
      Print("Handle = ",InpInd_Handle,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//---
   ArrayInitialize(corr,0.0);
   ArraySetAsSeries(corr,true);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- Получение данных для расчета

   if(!GetIndValue())
      return;

   if(!Trade.IsOpenedByMagic(Inp_MagicNum))
     {
      //--- Открытие ордера при наличии сигнала на покупку
      if(BuySignal())
         Trade.BuyPositionOpen(Symbol(),Inp_Lot,Inp_StopLoss,Inp_TakeProfit,Inp_MagicNum,Inp_EaComment);
      //--- Открытие ордера при наличии сигнала на продажу
      if(SellSignal())
         Trade.SellPositionOpen(Symbol(),Inp_Lot,Inp_StopLoss,Inp_TakeProfit,Inp_MagicNum,Inp_EaComment);
     }
  }
//+------------------------------------------------------------------+
//| Условия на покупку                                               |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   bool res=false;
   if(Inp_Strategy_type==1)
      res=(corr[1]>Inp_KeyLevel && corr[0]<Inp_KeyLevel)?true:false;
   else if(Inp_Strategy_type==2)
      res=(corr[0]>Inp_KeyLevel && corr[1]<Inp_KeyLevel)?true:false;
   return res;
  }
//+------------------------------------------------------------------+
//| Условия на продажу                                               |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   bool res=false;
   if(Inp_Strategy_type==1)
      res=(corr[1]<-Inp_KeyLevel && corr[0]>-Inp_KeyLevel)?true:false;
   else if(Inp_Strategy_type==2)
      res=(corr[0]<-Inp_KeyLevel && corr[1]>-Inp_KeyLevel)?true:false;
   return res;
  }
//+------------------------------------------------------------------+
//| Получение текущих значений индикаторов                           |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   return(CopyBuffer(InpInd_Handle,0,0,2,corr)<=0)?false:true;
  }
//+------------------------------------------------------------------+
