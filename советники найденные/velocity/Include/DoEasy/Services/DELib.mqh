//+------------------------------------------------------------------+
//|                                                        DELib.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/ru/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/ru/users/artmedia70"
#property strict  // Нужно для mql4
//+------------------------------------------------------------------+
//| Включаемые файлы                                                 |
//+------------------------------------------------------------------+
#include "..\Defines.mqh"
#include "TimerCounter.mqh"
//+------------------------------------------------------------------+
//| Сервисные функции                                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Распечатывает в журнал все константы перечисления сортировок     |
//+------------------------------------------------------------------+
void EnumNumbersTest()
  {
   string enm="ENUM_SORT_ORDERS_MODE";
   string t=StringSubstr(enm,5,5)+"BY";
   Print("Search of the values of the enumaration ",enm,":");
   ENUM_SORT_ORDERS_MODE type=0;
   while(StringFind(EnumToString(type),t)==0)
     {
      Print(enm,"[",type,"]=",EnumToString(type));
      if(type>500) break;
      type++;
     }
   Print("\nNumber of members of the ",enm,"=",type);
  }
//+------------------------------------------------------------------+
//| Возвращает текст на одном из двух языков                         |
//+------------------------------------------------------------------+
string TextByLanguage(const string text_country_lang,const string text_en)
  {
   return(TerminalInfoString(TERMINAL_LANGUAGE)==COUNTRY_LANG ? text_country_lang : text_en);
  }
//+------------------------------------------------------------------+
//| Возвращает время с милисекундами                                 |
//+------------------------------------------------------------------+
string TimeMSCtoString(const long time_msc)
  {
   return TimeToString(time_msc/1000,TIME_DATE|TIME_MINUTES|TIME_SECONDS)+"."+IntegerToString(time_msc%1000,3,'0');
  }
//+------------------------------------------------------------------+
//| Возвращает количество десятичных знаков в лоте символа           |
//+------------------------------------------------------------------+
uint DigitsLots(const string symbol_name) 
  { 
   return (int)ceil(fabs(log(SymbolInfoDouble(symbol_name,SYMBOL_VOLUME_STEP))/log(10)));
  }
//+------------------------------------------------------------------+
//| Возвращает минимальный лот символа                               |
//+------------------------------------------------------------------+
double MinimumLots(const string symbol_name) 
  { 
   return SymbolInfoDouble(symbol_name,SYMBOL_VOLUME_MIN);
  }
//+------------------------------------------------------------------+
//| Возвращает максимальный лот символа                              |
//+------------------------------------------------------------------+
double MaximumLots(const string symbol_name) 
  { 
   return SymbolInfoDouble(symbol_name,SYMBOL_VOLUME_MAX);
  }
//+------------------------------------------------------------------+
//| Возвращает шаг изменения лота символа                            |
//+------------------------------------------------------------------+
double StepLots(const string symbol_name) 
  { 
   return SymbolInfoDouble(symbol_name,SYMBOL_VOLUME_STEP);
  }
//+------------------------------------------------------------------+
//| Возвращает нормализованный лот                                   |
//+------------------------------------------------------------------+
double NormalizeLot(const string symbol_name, double order_lots) 
  {
   double ml=SymbolInfoDouble(symbol_name,SYMBOL_VOLUME_MIN);
   double mx=SymbolInfoDouble(symbol_name,SYMBOL_VOLUME_MAX);
   double ln=NormalizeDouble(order_lots,int(ceil(fabs(log(ml)/log(10)))));
   return(ln<ml ? ml : ln>mx ? mx : ln);
  }
//+------------------------------------------------------------------+
//| Возвращает корректный StopLoss относительно StopLevel            |
//+------------------------------------------------------------------+
double CorrectStopLoss(const string symbol_name,const ENUM_ORDER_TYPE order_type,const double price_set,const double stop_loss,const int spread_multiplier=2)
  {
   if(stop_loss==0) return 0;
   int lv=StopLevel(symbol_name,spread_multiplier), dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   double price=(order_type==ORDER_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : order_type==ORDER_TYPE_SELL ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : price_set);
   return
     (order_type==ORDER_TYPE_BUY       || 
      order_type==ORDER_TYPE_BUY_LIMIT || 
      order_type==ORDER_TYPE_BUY_STOP
      #ifdef __MQL5__                  ||
      order_type==ORDER_TYPE_BUY_STOP_LIMIT
      #endif ? 
      NormalizeDouble(fmin(price-lv*pt,stop_loss),dg) :
      NormalizeDouble(fmax(price+lv*pt,stop_loss),dg)
     );
  }
//+------------------------------------------------------------------+
//| Возвращает корректный StopLoss относительно StopLevel            |
//+------------------------------------------------------------------+
double CorrectStopLoss(const string symbol_name,const ENUM_ORDER_TYPE order_type,const double price_set,const int stop_loss,const int spread_multiplier=2)
  {
   if(stop_loss==0) return 0;
   int lv=StopLevel(symbol_name,spread_multiplier), dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   double price=(order_type==ORDER_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : order_type==ORDER_TYPE_SELL ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : price_set);
   return
     (order_type==ORDER_TYPE_BUY       || 
      order_type==ORDER_TYPE_BUY_LIMIT || 
      order_type==ORDER_TYPE_BUY_STOP
      #ifdef __MQL5__                  ||
      order_type==ORDER_TYPE_BUY_STOP_LIMIT
      #endif ?
      NormalizeDouble(fmin(price-lv*pt,price-stop_loss*pt),dg) :
      NormalizeDouble(fmax(price+lv*pt,price+stop_loss*pt),dg)
     );
  }
//+------------------------------------------------------------------+
//| Возвращает корректный TakeProfit относительно StopLevel          |
//+------------------------------------------------------------------+
double CorrectTakeProfit(const string symbol_name,const ENUM_ORDER_TYPE order_type,const double price_set,const double take_profit,const int spread_multiplier=2)
  {
   if(take_profit==0) return 0;
   int lv=StopLevel(symbol_name,spread_multiplier), dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   double price=(order_type==ORDER_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : order_type==ORDER_TYPE_SELL ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : price_set);
   return
     (order_type==ORDER_TYPE_BUY       || 
      order_type==ORDER_TYPE_BUY_LIMIT || 
      order_type==ORDER_TYPE_BUY_STOP
      #ifdef __MQL5__                  ||
      order_type==ORDER_TYPE_BUY_STOP_LIMIT
      #endif ?
      NormalizeDouble(fmax(price+lv*pt,take_profit),dg) :
      NormalizeDouble(fmin(price-lv*pt,take_profit),dg)
     );
  }
//+------------------------------------------------------------------+
//| Возвращает корректный TakeProfit относительно StopLevel          |
//+------------------------------------------------------------------+
double CorrectTakeProfit(const string symbol_name,const ENUM_ORDER_TYPE order_type,const double price_set,const int take_profit,const int spread_multiplier=2)
  {
   if(take_profit==0) return 0;
   int lv=StopLevel(symbol_name,spread_multiplier), dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT);
   double price=(order_type==ORDER_TYPE_BUY ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : order_type==ORDER_TYPE_SELL ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : price_set);
   return
     (order_type==ORDER_TYPE_BUY       || 
      order_type==ORDER_TYPE_BUY_LIMIT || 
      order_type==ORDER_TYPE_BUY_STOP
      #ifdef __MQL5__                  ||
      order_type==ORDER_TYPE_BUY_STOP_LIMIT
      #endif ?
      ::NormalizeDouble(::fmax(price+lv*pt,price+take_profit*pt),dg) :
      ::NormalizeDouble(::fmin(price-lv*pt,price-take_profit*pt),dg)
     );
  }
//+------------------------------------------------------------------+
//| Возвращает корректную цену постановки ордера                     |
//| относительно StopLevel                                           |
//+------------------------------------------------------------------+
double CorrectPricePending(const string symbol_name,const ENUM_ORDER_TYPE order_type,const double price_set,const double price=0,const int spread_multiplier=2)
  {
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT),pp=0;
   int lv=StopLevel(symbol_name,spread_multiplier), dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   switch(order_type)
     {
      case ORDER_TYPE_BUY_LIMIT        :  pp=(price==0 ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : price); return NormalizeDouble(fmin(pp-lv*pt,price_set),dg);
      case ORDER_TYPE_BUY_STOP         :  
      case ORDER_TYPE_BUY_STOP_LIMIT   :  pp=(price==0 ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : price); return NormalizeDouble(fmax(pp+lv*pt,price_set),dg);
      case ORDER_TYPE_SELL_LIMIT       :  pp=(price==0 ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : price); return NormalizeDouble(fmax(pp+lv*pt,price_set),dg);
      case ORDER_TYPE_SELL_STOP        :  
      case ORDER_TYPE_SELL_STOP_LIMIT  :  pp=(price==0 ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : price); return NormalizeDouble(fmin(pp-lv*pt,price_set),dg);
      default                          :  Print(DFUN,TextByLanguage("Не правильный тип ордера: ","Invalid order type: "),EnumToString(order_type)); return 0;
     }
  }
//+------------------------------------------------------------------+
//| Возвращает корректную цену постановки ордера                     |
//| относительно StopLevel                                           |
//+------------------------------------------------------------------+
double CorrectPricePending(const string symbol_name,const ENUM_ORDER_TYPE order_type,const int distance_set,const double price=0,const int spread_multiplier=2)
  {
   double pt=SymbolInfoDouble(symbol_name,SYMBOL_POINT),pp=0;
   int lv=StopLevel(symbol_name,spread_multiplier), dg=(int)SymbolInfoInteger(symbol_name,SYMBOL_DIGITS);
   switch(order_type)
     {
      case ORDER_TYPE_BUY_LIMIT        :  pp=(price==0 ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : price); return NormalizeDouble(fmin(pp-lv*pt,pp-distance_set*pt),dg);
      case ORDER_TYPE_BUY_STOP         :  
      case ORDER_TYPE_BUY_STOP_LIMIT   :  pp=(price==0 ? SymbolInfoDouble(symbol_name,SYMBOL_ASK) : price); return NormalizeDouble(fmax(pp+lv*pt,pp+distance_set*pt),dg);
      case ORDER_TYPE_SELL_LIMIT       :  pp=(price==0 ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : price); return NormalizeDouble(fmax(pp+lv*pt,pp+distance_set*pt),dg);
      case ORDER_TYPE_SELL_STOP        :  
      case ORDER_TYPE_SELL_STOP_LIMIT  :  pp=(price==0 ? SymbolInfoDouble(symbol_name,SYMBOL_BID) : price); return NormalizeDouble(fmin(pp-lv*pt,pp-distance_set*pt),dg);
      default                          :  Print(DFUN,TextByLanguage("Не правильный тип ордера: ","Invalid order type: "),EnumToString(order_type)); return 0;
     }
  }
//+------------------------------------------------------------------+
//| Проверяет размер стоп-уровня в пунктах относительно StopLevel    |
//+------------------------------------------------------------------+
bool CheckStopLevel(const string symbol_name,const int stop_in_points,const int spread_multiplier)
  {
   return(stop_in_points>=StopLevel(symbol_name,spread_multiplier));
  }
//+------------------------------------------------------------------+
//| Возвращает размер StopLevel в пунктах                            |
//+------------------------------------------------------------------+
int StopLevel(const string symbol_name,const int spread_multiplier)
  {
   int spread=(int)SymbolInfoInteger(symbol_name,SYMBOL_SPREAD);
   int stop_level=(int)SymbolInfoInteger(symbol_name,SYMBOL_TRADE_STOPS_LEVEL);
   return(stop_level==0 ? spread*spread_multiplier : stop_level);
  }
//+------------------------------------------------------------------+
//| Возвращает наименование ордера                                   |
//+------------------------------------------------------------------+
string OrderTypeDescription(const ENUM_ORDER_TYPE type)
  {
   string pref=(#ifdef __MQL5__ "Market order" #else "Position" #endif );
   return
     (
      type==ORDER_TYPE_BUY_LIMIT       ?  "Buy Limit"                                                 :
      type==ORDER_TYPE_BUY_STOP        ?  "Buy Stop"                                                  :
      type==ORDER_TYPE_SELL_LIMIT      ?  "Sell Limit"                                                :
      type==ORDER_TYPE_SELL_STOP       ?  "Sell Stop"                                                 :
   #ifdef __MQL5__
      type==ORDER_TYPE_BUY_STOP_LIMIT  ?  "Buy Stop Limit"                                            :
      type==ORDER_TYPE_SELL_STOP_LIMIT ?  "Sell Stop Limit"                                           :
      type==ORDER_TYPE_CLOSE_BY        ?  TextByLanguage("Закрывающий ордер","Order for closing by")  :  
   #else 
      type==ORDER_TYPE_BALANCE         ?  TextByLanguage("Балансовая операция","Balance operation")   :
      type==ORDER_TYPE_CREDIT          ?  TextByLanguage("Кредитная операция","Credit operation")     :
   #endif 
      type==ORDER_TYPE_BUY             ?  pref+" Buy"                                                 :
      type==ORDER_TYPE_SELL            ?  pref+" Sell"                                                :  
      TextByLanguage("Неизвестный тип ордера","Unknown order type")
     );
  }
//+------------------------------------------------------------------+
//| Возвращает наименование позиции                                  |
//+------------------------------------------------------------------+
string PositionTypeDescription(const ENUM_POSITION_TYPE type)
  {
   return
     (
      type==POSITION_TYPE_BUY    ? "Buy"  :
      type==POSITION_TYPE_SELL   ? "Sell" :  
      TextByLanguage("Неизвестный тип позиции","Unknown position type")
     );
  }
//+------------------------------------------------------------------+
//| Возвращает наименование сделки                                   |
//+------------------------------------------------------------------+
string DealTypeDescription(const ENUM_DEAL_TYPE type)
  {
   return
     (
      type==DEAL_TYPE_BUY                       ?  TextByLanguage("Сделка на покупку","The deal to Buy") :
      type==DEAL_TYPE_SELL                      ?  TextByLanguage("Сделка на продажу","The deal to Sell") :
      type==DEAL_TYPE_BALANCE                   ?  TextByLanguage("Балансовая операция","Balance operation") :
      type==DEAL_TYPE_CREDIT                    ?  TextByLanguage("Начисление кредита","Credit") :
      type==DEAL_TYPE_CHARGE                    ?  TextByLanguage("Дополнительные сборы","Additional charge") :
      type==DEAL_TYPE_CORRECTION                ?  TextByLanguage("Корректирующая запись","Correction") :
      type==DEAL_TYPE_BONUS                     ?  TextByLanguage("Перечисление бонусов","Bonus") :
      type==DEAL_TYPE_COMMISSION                ?  TextByLanguage("Дополнительные комиссии","Additional comissions") :
      type==DEAL_TYPE_COMMISSION_DAILY          ?  TextByLanguage("Комиссия, начисляемая в конце торгового дня","Daily commission") :
      type==DEAL_TYPE_COMMISSION_MONTHLY        ?  TextByLanguage("Комиссия, начисляемая в конце месяца","Monthly commission") :
      type==DEAL_TYPE_COMMISSION_AGENT_DAILY    ?  TextByLanguage("Агентская комиссия, начисляемая в конце торгового дня","Daily agent commission") :
      type==DEAL_TYPE_COMMISSION_AGENT_MONTHLY  ?  TextByLanguage("Агентская комиссия, начисляемая в конце месяца","Monthly agent commission") :
      type==DEAL_TYPE_INTEREST                  ?  TextByLanguage("Начисления процентов на свободные средства","Agency commission charged at the end of the month") :
      type==DEAL_TYPE_BUY_CANCELED              ?  TextByLanguage("Отмененная сделка покупки","Canceled buy transaction") :
      type==DEAL_TYPE_SELL_CANCELED             ?  TextByLanguage("Отмененная сделка продажи","Canceled sell transaction") :
      type==DEAL_DIVIDEND                       ?  TextByLanguage("Начисление дивиденда","Dividend operations") :
      type==DEAL_DIVIDEND_FRANKED               ?  TextByLanguage("Начисление франкированного дивиденда","Franked (non-taxable) dividend operations") :
      type==DEAL_TAX                            ?  TextByLanguage("Начисление налога","Tax charges") : 
      TextByLanguage("Неизвестный тип сделки","Unknown deal type")
     );
  }
//+------------------------------------------------------------------+
//| Возвращает тип позиции по типу ордера                            |
//+------------------------------------------------------------------+
ENUM_POSITION_TYPE PositionTypeByOrderType(ENUM_ORDER_TYPE type_order)
  {
   if(
      type_order==ORDER_TYPE_BUY             ||
      type_order==ORDER_TYPE_BUY_LIMIT       ||
      type_order==ORDER_TYPE_BUY_STOP
   #ifdef __MQL5__                           ||
      type_order==ORDER_TYPE_BUY_STOP_LIMIT
   #endif 
     ) return POSITION_TYPE_BUY;
   else if(
      type_order==ORDER_TYPE_SELL            ||
      type_order==ORDER_TYPE_SELL_LIMIT      ||
      type_order==ORDER_TYPE_SELL_STOP
   #ifdef __MQL5__                           ||
      type_order==ORDER_TYPE_SELL_STOP_LIMIT
   #endif 
     ) return POSITION_TYPE_SELL;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
