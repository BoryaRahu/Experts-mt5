//+------------------------------------------------------------------+
//|                                                 PivotsTrader.mq5 |
//|                                           Copyright 2017, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, denkir"
#property link      "https://login.mql5.com/ru/users/denkir"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include "PivotsExpert.mqh"
#include "SignalPivots.mqh"
#include <Expert\Trailing\TrailingNone.mqh>
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
sinput string Info_trade="+===-- Торговые --====+"; // +===-- Торговые --====+
sinput ulong InpMagicNumber=777;          // Магик
//---
sinput string Info_signals="+===-- Сигналы --====+"; // +===-- Сигналы --====+
input int InpThresholdOpen=70;            // Порог сигнала на открытие, [0...100]
input double InpSignalWeight=1.0;         // Вес, [0...1.0]
input int InpPattern0=70;                 // Модель 0, [0...100]
input int InpPattern1=40;                 // Модель 1, [0...100]
input int InpSpeedupAllowance=10;         // Поправка на ускорение 
input uint InpWidthLimit=500;             // Лимит по ширине, пп
//---
sinput string Info_money="+===-- Управление капиталом --====+"; // +===-- Управление капиталом --====+
input double InpLots=0.1;                 // Фиксированный объём
//---
sinput string Info_channels="+===-- Пивоты --====+";  // +===-- Пивоты --====+
input uint InpNearPips=15;                // Допуск, пп
//---
sinput string Info_trend="+===-- Тренд --====+";  // +===-- Тренд --====+
input int InpFastMaPeriod=55;             // Быстрая МА
input int InpSlowMaPeriod=100;            // Медленная МА
input ENUM_MA_METHOD InpMaType=MODE_EMA;  // Тип МА
input int InpCutoff=100;                  // Отсечка, пп
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CPivotsExpert myPivotsExpert;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация 
   if(!myPivotsExpert.Init(false,InpMagicNumber))
     {
      //--- ошибка
      PrintFormat(__FUNCTION__+": error initializing expert");
      return INIT_FAILED;
     }
//--- создание сигнала
   CExpertUserSignal *signal=new CExpertUserSignal;
   if(signal==NULL)
     {
      //--- ошибка
      PrintFormat(__FUNCTION__+": error creating signal");
      return INIT_FAILED;
     }
//--- базовые параметры
   myPivotsExpert.InitSignal(signal);
   signal.ThresholdOpen(InpThresholdOpen);
   signal.ThresholdClose(0);
//--- фильтр CSignalPivots
   CSignalPivots *filter0=new CSignalPivots;
   if(filter0==NULL)
     {
      //--- ошибка
      PrintFormat(__FUNCTION__+": error creating filter0");
      return INIT_FAILED;
     }
   signal.AddFilter(filter0);
   signal.General(0);
//--- параметры 
   filter0.ToPlotMinor(true);
   filter0.Weight(InpSignalWeight);
   filter0.Pattern_0(InpPattern0);
   filter0.Pattern_1(InpPattern1);
   filter0.PointsNear(InpNearPips);
   filter0.SpeedupAllowance(InpSpeedupAllowance);
   filter0.WidthLimit(InpWidthLimit);
//--- trend catcher
   filter0.FastMa(InpFastMaPeriod);
   filter0.SlowMa(InpSlowMaPeriod);
   filter0.MaType(InpMaType);
   filter0.Cutoff(InpCutoff);
//--- нулевой объект трала
   CTrailingNone *trailing=new CTrailingNone;
   if(trailing==NULL)
     {
      //--- ошибка
      PrintFormat(__FUNCTION__+": error creating trailing");
      return INIT_FAILED;
     }
//--- добавление объекта трала (will be deleted automatically))
   if(!myPivotsExpert.InitTrailing(trailing))
     {
      //--- ошибка
      PrintFormat(__FUNCTION__+": error initializing trailing");
      return INIT_FAILED;
     }
//--- объект управления капиталом
   CMoneyFixedLot *money=new CMoneyFixedLot;
   if(money==NULL)
     {
      //--- ошибка
      PrintFormat(__FUNCTION__+": error creating money");
      return INIT_FAILED;
     }
//--- добавление объекта управления капиталом (will be deleted automatically))
   if(!myPivotsExpert.InitMoney(money))
     {
      //--- ошибка
      PrintFormat(__FUNCTION__+": error initializing money");
      return INIT_FAILED;
     }
//--- параметры объекта управления капиталом
   money.Lots(InpLots);
//--- проверка всех параметров
   if(!myPivotsExpert.ValidationSettings())
     {
      //--- ошибка      
      return INIT_FAILED;
     }
//--- настройка необходимых индикаторов
   if(!myPivotsExpert.InitIndicators())
     {
      //--- ошибка
      PrintFormat(__FUNCTION__+": error initializing indicators");
      return INIT_FAILED;
     }
//---
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- обработчик деинициализации
   myPivotsExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- обработчик нового тика
   myPivotsExpert.OnTick();
  }
//+------------------------------------------------------------------+

//--- [EOF]
