//+------------------------------------------------------------------+
//|                                                        Trade.mqh |
//|                                Copyright 2017, Alexander Fedosov |
//|                           https://www.mql5.com/ru/users/alex2356 |
//+------------------------------------------------------------------+
#property copyright  "Copyright 2017, Alexander Fedosov"
#property link       "https://www.mql5.com/ru/users/alex2356"
#property version    "2.0"
//--- Перечисление для вариантов расчёта лота
enum MarginMode
  {
   FREEMARGIN=0,     //MM Free Margin
   BALANCE,          //MM Balance
   LOT               //Constant Lot
  };
//--- Перечисление вариантов базового лота
enum LotType
  {
   MINLOT=0,
   BASELOT
  };
//+------------------------------------------------------------------+
//| Библиотека торговых операций                                     |
//+------------------------------------------------------------------+
class CTradeBase
  {
private:
   //--- Выбор вариантов расчета базового лота
   MarginMode        m_mm_lot;
   LotType           m_type_lot;
   double            m_base_lot;
   //--- Проскальзывание
   uint              m_deviation;
   ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
   //-- Имя советника
   string            m_ea_name;
   //-- Язык ошибок
   string            m_lang;
   //--- Расчёт размер лота для открывания позиции с маржой lot_margin
   double            GetLotForOpeningPos(string symbol,ENUM_POSITION_TYPE direction,double lot_margin);
   //--- Возвращает тип заполнения
   ENUM_ORDER_TYPE_FILLING GetFilling(void);
   //---
   int               GetDig(string symbol);
   //--- Коррекция размера лота до ближайшего допустимого значения
   bool              LotCorrect(string symbol,ENUM_POSITION_TYPE trade_operation);
   //--- Ограничение размера лота возможностями депозита
   bool              LotFreeMarginCorrect(string symbol,ENUM_POSITION_TYPE trade_operation);
   //--- Расчёт размера лота
   double            LotCount(string symbol,ENUM_POSITION_TYPE directon,double base_lot);
   //--- Коррекция размера отложенного ордера до допустимого значения
   int               StopCorrect(string symbol,int Stop);
   bool              dStopCorrect(string symbol,double &dStopLoss,double &dTakeprofit,ENUM_POSITION_TYPE trade_operation);
   //--- Возврат строкового результата торговой операции по его коду
   string            ResultRetcodeDescription(int retcode);
   //--- Выбор позиции по индексу
   bool              SelectByIndex(const int index);
   //--- position select depending on netting or hedging
   bool              SelectPosition(const string symbol,int MagicNumber);
   //---
   bool              IsHedging(void) const { return(m_margin_mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING); }
public:
                     CTradeBase(void);
                    ~CTradeBase(void);
   //--- Установка варианта расчета лота
   void              SetMM(const MarginMode MM) { m_mm_lot=MM;             }
   //--- Установка варианта лота
   void              SetLotType(const LotType Lot) { m_type_lot=Lot;          }
   //--- Установка имени советника
   void              SetNameEA(const string NameEA) { m_ea_name=NameEA;        }
   //--- Установка языка ошибок
   void              SetLanguage(const string Lang) { m_lang=Lang;             }
   //--- Установка проскальзывания
   void              SetDeviation(const uint Dev) { m_deviation=Dev;      }
   //--- Открытие лонга, стопы в пунктах
   bool              BuyPositionOpen(const string symbol,double Lot,int StopLoss,int Takeprofit,int MagicNumber,string  TradeComm);
   //--- Открытие лонга, стопы в ед.цены
   bool              BuyPositionOpen(const string symbol,double Lot,double dStopLoss,double dTakeprofit,int MagicNumber,string  TradeComm);
   //--- Открытие шорта, стопы в пунктах
   bool              SellPositionOpen(const string symbol,double Lot,int StopLoss,int Takeprofit,int MagicNumber,string  TradeComm);
   //--- Открытие шорта, стопы в ед.цены
   bool              SellPositionOpen(const string symbol,double Lot,double dStopLoss,double dTakeprofit,int MagicNumber,string  TradeComm);
   //--- Модификация длинной позиции в пунктах
   bool              BuyPositionModify(const string symbol,int StopLoss,int Takeprofit);
   //--- Модификация длинной позиции в ед.цены
   bool              BuyPositionModify(const string symbol,double dStopLoss,double dTakeprofit);
   //--- Модификация короткой позиции в пунктах
   bool              SellPositionModify(const string symbol,int StopLoss,int Takeprofit);
   //--- Модификация короткой позиции в ед.цены
   bool              SellPositionModify(const string symbol,double dStopLoss,double dTakeprofit);
   //--- Закрытие позиции по типу
   bool              ClosePositionByType(const string symbol,ENUM_POSITION_TYPE PosType,int MagicNumber);
   //--- Проверка на открытые позиции с магиком 
   bool              IsOpenedByMagic(int MagicNumber);
   //--- Проверка на открытые типа позиции с магиком
   bool              IsOpenedByType(ENUM_POSITION_TYPE PosType,int MagicNumber);
   //--- Проверка на открытые позиции по символу с магиком
   bool              IsOpenedBySymbol(string symbol,int MagicNumber);
   //--- Проверка на допустимый спред на символе
   bool              MaxSpread(string symbol,int MaxLevelSpread);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradeBase::CTradeBase(void): m_mm_lot(LOT),
                              m_type_lot(MINLOT),
                              m_ea_name("EA"),
                              m_lang("en"),
                              m_deviation(20)
  {
   m_margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTradeBase::~CTradeBase(void)
  {
  }
//+------------------------------------------------------------------+
//| Открываем длинную позицию, стопы в пунктах                       |
//+------------------------------------------------------------------+
bool CTradeBase::BuyPositionOpen
(
 const string  symbol,                 // торговая пара сделки
 double        Lot,                    // MM
 int           StopLoss,               // стоплосс в пунктах
 int           Takeprofit,             // тейкпрофит в пунктах
 int           MagicNumber,            // меджик
 string        TradeComm=""            // комментарии
 )
  {
//---
   ENUM_POSITION_TYPE PosType=POSITION_TYPE_BUY;
//----
   double volume=LotCount(symbol,PosType,Lot);
   if(volume<=0)
     {
      Print(__FUNCTION__,"(): Invalid volume for the trade request structure");
      return(false);
     }

//---- Объявление структур торгового запроса и результата торгового запроса
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Объявление структуры результата проверки торгового запроса 
   MqlTradeCheckResult check;

//---- обнуление структур
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);

   long digit;
   double point,Ask;
//----   
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_ASK,Ask))
      return(true);

//---- Инициализация структуры торгового запроса MqlTradeRequest для открывания BUY позиции

   request.type   = ORDER_TYPE_BUY;
   request.price  = Ask;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;
   request.magic  = MagicNumber;
   request.comment= TradeComm;
   request.deviation=m_deviation;
   request.type_filling=GetFilling();
//---- Определение расстояния до стоплосса в единицах ценового графика

   if(StopLoss!=0)
     {
      StopLoss=StopCorrect(symbol,StopLoss);
      if(StopLoss==0)
         return(false);
      double dStopLoss=StopLoss*point*GetDig(symbol);
      request.sl=NormalizeDouble(request.price-dStopLoss,int(digit));
     }
   else
      request.sl=0.0;
//---- Определение расстояния до тейкпрофита единицах ценового графика

   if(Takeprofit!=0)
     {
      Takeprofit=StopCorrect(symbol,Takeprofit);
      if(Takeprofit==0)
         return(false);
      double dTakeprofit=Takeprofit*point*GetDig(symbol);
      request.tp=NormalizeDouble(request.price+dTakeprofit,int(digit));
     }
   else
      request.tp=0.0;

//---- Проверка торгового запроса на корректность
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Incorrect data structure for trade request!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,m_ea_name,": Opening Buy position to ",symbol,"");
   Print(comment);

//---- Открываем BUY позицию и делаем проверку результата торгового запроса
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else if(result.retcode==TRADE_RETCODE_DONE)
     {
      comment="";
      StringConcatenate(comment,m_ea_name,": Buy position to ",symbol," opened.");
      Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Открываем длинную позицию в ед.цены                              |
//+------------------------------------------------------------------+
bool CTradeBase::BuyPositionOpen
(
 const string  symbol,                 // торговая пара сделки
 double        Lot,                    // MM
 double        dStopLoss,              // стоплосс в единицах ценового графика
 double        dTakeprofit,            // тейкпрофит в единицах ценового графика
 int           MagicNumber,            //меджик
 string        TradeComm=""            // комментарии 
 )
  {
//---
   ENUM_POSITION_TYPE PosType=POSITION_TYPE_BUY;

//---- Объявление структур торгового запроса и результата торгового запроса
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Объявление структуры результата проверки торгового запроса 
   MqlTradeCheckResult check;

//---- обнуление структур
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);

   long digit;
   double point,Ask;
//----
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_ASK,Ask))
      return(true);

//---- коррекция расстояний до стоплосса и тейкпрофита в единицах ценового графика
   if(!dStopCorrect(symbol,dStopLoss,dTakeprofit,PosType))
      return(false);
//----
   double volume=LotCount(symbol,PosType,Lot);
   if(volume<=0)
     {
      Print(__FUNCTION__,"(): Invalid volume for the trade request structure");
      return(false);
     }

//---- Инициализация структуры торгового запроса MqlTradeRequest для открывания BUY позиции
   request.type   = ORDER_TYPE_BUY;
   request.price  = Ask;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;
   request.sl=dStopLoss;
   request.tp=dTakeprofit;
   request.deviation=m_deviation;
   request.magic=MagicNumber;
   request.comment=TradeComm;
   request.type_filling=GetFilling();
//---- Проверка торгового запроса на корректность
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Incorrect data structure for trade request!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,"Open Buy position to ",symbol);
   Print(comment);

//---- Открываем BUY позицию и делаем проверку результата торгового запроса
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else if(result.retcode==TRADE_RETCODE_DONE)
     {
      comment="";
      StringConcatenate(comment,m_ea_name,": Buy position to ",symbol," opened.");
      Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Открываем короткую позицию, стопы в пунктах                      |
//+------------------------------------------------------------------+
bool CTradeBase::SellPositionOpen
(
 const string  symbol,                 // торговая пара сделки
 double        Lot,                    // MM
 int           StopLoss,               // стоплосс в пунктах
 int           Takeprofit,             // тейкпрофит в пунктах
 int           MagicNumber,            // меджик
 string        TradeComm=""            // комментарии
 )
  {
//---
   ENUM_POSITION_TYPE PosType=POSITION_TYPE_SELL;
//----
   double volume=LotCount(symbol,PosType,Lot);
   if(volume<=0)
     {
      Print(__FUNCTION__,"(): Invalid volume for the trade request structure");
      return(false);
     }

//---- Объявление структур торгового запроса и результата торгового запроса
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Объявление структуры результата проверки торгового запроса 
   MqlTradeCheckResult check;

//---- обнуление структур
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);

   long digit;
   double point,Bid;
//----
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit)) return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point)) return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_BID,Bid)) return(true);

//---- Инициализация структуры торгового запроса MqlTradeRequest для открывания SELL позиции
   request.type   = ORDER_TYPE_SELL;
   request.price  = Bid;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;
   request.magic=MagicNumber;
   request.comment=TradeComm;
   request.deviation=m_deviation;
   request.type_filling=GetFilling();
//---- Определение расстояния до стоплосса в единицах ценового графика

   if(StopLoss!=0)
     {
      StopLoss=StopCorrect(symbol,StopLoss);
      if(StopLoss==0)
         return(false);
      double dStopLoss=StopLoss*point*GetDig(symbol);
      request.sl=NormalizeDouble(request.price+dStopLoss,int(digit));
     }
   else
      request.sl=0.0;

//---- Определение расстояния до тейкпрофита единицах ценового графика
   if(Takeprofit!=0)
     {
      Takeprofit=StopCorrect(symbol,Takeprofit);
      if(Takeprofit==0)
         return(false);
      double dTakeprofit=Takeprofit*point*GetDig(symbol);
      request.tp=NormalizeDouble(request.price-dTakeprofit,int(digit));
     }
   else
      request.tp=0.0;
//---- Проверка торгового запроса на корректность
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Incorrect data structure for trade request!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,m_ea_name,": Opening Sell position to ",symbol,"");
   Print(comment);

//---- Открываем SELL позицию и делаем проверку результата торгового запроса
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else if(result.retcode==TRADE_RETCODE_DONE)
     {
      comment="";
      StringConcatenate(comment,m_ea_name,": Sell position to ",symbol," opened.");
      Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Открываем короткую позицию                                       |
//+------------------------------------------------------------------+
bool CTradeBase:: SellPositionOpen
(
 const string  symbol,                 // торговая пара сделки
 double        Lot,                    // MM
 double        dStopLoss,              // стоплосс в единицах ценового графика
 double        dTakeprofit,            // тейкпрофит в единицах ценового графика
 int           MagicNumber,            //меджик
 string        TradeComm=""            // комментарии 
 )
  {
//---
   ENUM_POSITION_TYPE PosType=POSITION_TYPE_SELL;
//---- Объявление структур торгового запроса и результата торгового запроса
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Объявление структуры результата проверки торгового запроса 
   MqlTradeCheckResult check;

//---- обнуление структур
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);

   long digit;
   double point,Bid;
//----
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_BID,Bid))
      return(true);

//---- коррекция расстояний до стоплосса и тейкпрофита в единицах ценового графика
   if(!dStopCorrect(symbol,dStopLoss,dTakeprofit,PosType))
      return(false);

//----
   double volume=LotCount(symbol,PosType,Lot);
   if(volume<=0)
     {
      Print(__FUNCTION__,"(): Invalid volume for the trade request structure");
      return(false);
     }

//---- Инициализация структуры торгового запроса MqlTradeRequest для открывания SELL позиции
   request.type   = ORDER_TYPE_SELL;
   request.price  = Bid;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;
   request.sl=dStopLoss;
   request.tp=dTakeprofit;
   request.deviation=m_deviation;
   request.magic=MagicNumber;
   request.comment=TradeComm;
   request.type_filling=GetFilling();
//---- Проверка торгового запроса на корректность
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Incorrect data structure for trade request!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,m_ea_name,": Opening Sell position to ",symbol);
   Print(comment);

//---- Открываем SELL позицию и делаем проверку результата торгового запроса
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else if(result.retcode==TRADE_RETCODE_DONE)
     {
      comment="";
      StringConcatenate(comment,m_ea_name,": Sell position to ",symbol," opened.");
      Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Модифицируем длинную позицию                                     |
//+------------------------------------------------------------------+
bool CTradeBase::BuyPositionModify(const string symbol,int StopLoss,int Takeprofit)
  {
//---

   ENUM_POSITION_TYPE PosType=POSITION_TYPE_BUY;

//---- Проверка на на наличие открытой позиции
   if(!PositionSelect(symbol))
      return(true);

//---- Объявление структур торгового запроса и результата торгового запроса
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Объявление структуры результата проверки торгового запроса 
   MqlTradeCheckResult check;

//---- обнуление структур
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);

   long digit;
   double point,Ask;
//----
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_ASK,Ask))
      return(true);

//---- Инициализация структуры торгового запроса MqlTradeRequest для открывания BUY позиции

   request.type   = ORDER_TYPE_BUY;
   request.action = TRADE_ACTION_SLTP;
   request.symbol = symbol;
   request.type_filling=GetFilling();
   request.deviation=m_deviation;
//---- Определение расстояния до стоплосса в единицах ценового графика

   if(StopLoss)
     {
      StopLoss=StopCorrect(symbol,StopLoss);
      double dStopLoss=StopLoss*point*GetDig(symbol);
      request.sl=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)-dStopLoss,int(digit));
     }
   else
      request.sl=PositionGetDouble(POSITION_SL);

//---- Определение расстояния до тейкпрофита единицах ценового графика
   if(Takeprofit)
     {
      Takeprofit=StopCorrect(symbol,Takeprofit);
      double dTakeprofit=Takeprofit*point*GetDig(symbol);
      request.tp=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)+dTakeprofit,int(digit));
     }
   else
      request.tp=PositionGetDouble(POSITION_TP);

//----   
   if(request.tp==PositionGetDouble(POSITION_TP) && request.sl==PositionGetDouble(POSITION_SL))
      return(true);
//---- Проверка торгового запроса на корректность

   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Incorrect data structure for trade request!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,"Modify Buy position to ",symbol);
   Print(comment);

//---- Модифицируем SELL позицию и делаем проверку результата торгового запроса
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): You can not modify a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else
   if(result.retcode==TRADE_RETCODE_DONE)
     {
      comment="";
      StringConcatenate(comment,"Buy position to ",symbol," modified.");
      Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): You can not modify a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Close specified opened position                                  |
//+------------------------------------------------------------------+
bool CTradeBase::ClosePositionByType(const string symbol,ENUM_POSITION_TYPE PosType,int MagicNumber)
  {
//---- Объявление структур торгового запроса и результата торгового запроса
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Объявление структуры результата проверки торгового запроса 
   MqlTradeCheckResult check;
   bool partial_close=false;
   int  retry_count=10;
   uint retcode=TRADE_RETCODE_REJECT;
//---- обнуление структур
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);
   do
     {
      if(SelectPosition(symbol,MagicNumber))
        {
         if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY && 
            PosType==POSITION_TYPE_BUY
            )
           {
            request.type =ORDER_TYPE_SELL;
            request.price=SymbolInfoDouble(symbol,SYMBOL_BID);
           }
         else if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL && 
            PosType==POSITION_TYPE_SELL
            )
              {
               request.type =ORDER_TYPE_BUY;
               request.price=SymbolInfoDouble(symbol,SYMBOL_ASK);
              }
           }
         else
           {
            //--- position not found
            result.retcode=retcode;
            Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(result.retcode));
            return(false);
           }
         //--- setting request
         request.action   =TRADE_ACTION_DEAL;
         request.symbol   =symbol;
         request.volume   =PositionGetDouble(POSITION_VOLUME);
         request.magic    =MagicNumber;
         request.deviation=m_deviation;
         request.type_filling=GetFilling();
         //--- hedging? just send order
         if(IsHedging())
           {
            request.position=PositionGetInteger(POSITION_TICKET);
            return(OrderSend(request,result));
           }

         //--- check volume
         double max_volume=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
         if(request.volume>max_volume)
           {
            request.volume=max_volume;
            partial_close=true;
           }
         else
            partial_close=false;
         //--- order send
         if(!OrderSend(request,result))
           {
            if(--retry_count!=0) continue;
            if(retcode==TRADE_RETCODE_DONE_PARTIAL)
               result.retcode=retcode;
            Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
            return(false);
           }

         retcode=TRADE_RETCODE_DONE_PARTIAL;
         if(partial_close)
            Sleep(1000);
        }
   while(partial_close);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Модифицируем короткую позицию в пунктах                          |
//+------------------------------------------------------------------+
bool CTradeBase::SellPositionModify
(
 const string symbol,        // торговая пара сделки
 int StopLoss,               // стоплосс в пунктах
 int Takeprofit              // тейкпрофит в пунктах
 )
  {
//---
   ENUM_POSITION_TYPE PosType=POSITION_TYPE_SELL;
//---- Проверка на на наличие открытой позиции
   if(!PositionSelect(symbol))
      return(true);
//---- Объявление структур торгового запроса и результата торгового запроса
   MqlTradeRequest request;
   MqlTradeResult result;

//---- Объявление структуры результата проверки торгового запроса 
   MqlTradeCheckResult check;

//---- обнуление структур
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);
//----
   long digit;
   double point,Bid;
//----
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point))
      return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_BID,Bid))
      return(true);

//---- Инициализация структуры торгового запроса MqlTradeRequest для открывания BUY позиции

   request.position=PositionGetInteger(POSITION_TICKET);
   request.type   = ORDER_TYPE_SELL;
   request.action = TRADE_ACTION_SLTP;
   request.symbol = symbol;
   request.deviation=m_deviation;
   request.type_filling=GetFilling();
//---- Определение расстояния до стоплосса в единицах ценового графика

   if(StopLoss!=0)
     {
      StopLoss=StopCorrect(symbol,StopLoss);
      double dStopLoss=StopLoss*point*GetDig(symbol);
      request.sl=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)+dStopLoss,int(digit));
     }
   else
      request.sl=PositionGetDouble(POSITION_SL);

//---- Определение расстояния до тейкпрофита единицах ценового графика
   if(Takeprofit!=0)
     {
      Takeprofit=StopCorrect(symbol,Takeprofit);
      double dTakeprofit=Takeprofit*point*GetDig(symbol);
      request.tp=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)-dTakeprofit,int(digit));
     }
   else
      request.tp=PositionGetDouble(POSITION_TP);

//----   

   if(request.tp==PositionGetDouble(POSITION_TP) && request.sl==PositionGetDouble(POSITION_SL))
      return(true);
//---- Проверка торгового запроса на корректность

   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Incorrect data structure for trade request!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,"Modify Sell position to ",symbol);
   Print(comment);

//---- Модифицируем SELL позицию и делаем проверку результата торгового запроса
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): You can not modify a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else
   if(result.retcode==TRADE_RETCODE_DONE)
     {
      comment="";
      StringConcatenate(comment,"Sell position to ",symbol," modified.");
      Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): You can not modify a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Проверка на открытые позиций с магиком                           |
//+------------------------------------------------------------------+
bool CTradeBase:: IsOpenedByMagic(int MagicNumber)
  {
   int pos=0;
   uint total=PositionsTotal();
//---
   for(uint i=0; i<total; i++)
     {
      if(SelectByIndex(i))
         if(PositionGetInteger(POSITION_MAGIC)==MagicNumber)
            pos++;
     }
   return((pos>0)?true:false);
  }
//+------------------------------------------------------------------+
//| Проверка на открытые типа позиции с магиком                      |
//+------------------------------------------------------------------+
bool CTradeBase:: IsOpenedByType(ENUM_POSITION_TYPE PosType,int MagicNumber)
  {
   int pos=0;
   uint total=PositionsTotal();
//---
   for(uint i=0; i<total; i++)
     {
      if(SelectByIndex(i))
         if(PositionGetInteger(POSITION_TYPE)==PosType && PositionGetInteger(POSITION_MAGIC)==MagicNumber)
            pos++;
     }
   return((pos>0)?true:false);
  }
//+------------------------------------------------------------------+
//| Проверка на открытые позиции по символу с магиком                |
//+------------------------------------------------------------------+
bool CTradeBase::IsOpenedBySymbol(string symbol,int MagicNumber)
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
   return((pos>0)?true:false);
  }
//+------------------------------------------------------------------+
//| Проверка на спред                                                |
//+------------------------------------------------------------------+
bool   CTradeBase::MaxSpread(string symbol,int MaxLevelSpread)
  {
   if(MaxLevelSpread>0)
     {
      return ((SymbolInfoInteger(symbol,SYMBOL_SPREAD)>MaxLevelSpread)?true:false);
     }
   else
      return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CTradeBase::GetDig(string symbol)
  {
   long digits=SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   return((digits==5 || digits==3 || digits==1)?10:1);
  }
//+------------------------------------------------------------------+
//| расчёт размер лота для открывания позиции с маржой lot_margin    |
//+------------------------------------------------------------------+
double CTradeBase::GetLotForOpeningPos(string symbol,ENUM_POSITION_TYPE direction,double lot_margin)
  {
//----
   double price=0.0,n_margin;
   double LotStep,MaxLot,MinLot;
   if(direction==POSITION_TYPE_BUY)
      if(!SymbolInfoDouble(symbol,SYMBOL_ASK,price))
         return(0);
   if(direction==POSITION_TYPE_SELL)
      if(!SymbolInfoDouble(symbol,SYMBOL_BID,price))
         return(0);
   if(!price)
      return(NULL);

   if(!OrderCalcMargin(ENUM_ORDER_TYPE(direction),symbol,1,price,n_margin) || !n_margin)
      return(0);

   double lot=lot_margin/n_margin;

//---- получение торговых констант   
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP,LotStep))
      return(0);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX,MaxLot))
      return(0);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN,MinLot))
      return(0);

//---- нормирование величины лота до ближайшего стандартного значения 
   lot=LotStep*MathFloor(lot/LotStep);

//---- проверка лота на минимальное допустимое значение
   if(lot<MinLot)
      lot=MinLot;
//---- проверка лота на максимальное допустимое значение       
   if(lot>MaxLot)
      lot=MaxLot;
//----
   return(lot);
  }
//+------------------------------------------------------------------+
//| Возвращает тип заполнения                                        |
//+------------------------------------------------------------------+
ENUM_ORDER_TYPE_FILLING CTradeBase::GetFilling(void)
  {
   uint filling=(uint)SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE);

   if(filling==1)
      return(ORDER_FILLING_FOK);
   else if(filling==2)
      return(ORDER_FILLING_IOC);
   return(false);
  }
//+------------------------------------------------------------------+
//| Расчёт размера лота                                              |  
//+------------------------------------------------------------------+
double CTradeBase:: LotCount(string symbol,ENUM_POSITION_TYPE directon,double base_lot)
  {
//----
   double margin=0.0,Lot=0.0,MinLot=0.0;
   switch(m_type_lot)
     {
      case  0:
         if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN,MinLot))
         return(false);
         Lot=MinLot;
         break;
      case  1:
         Lot=base_lot;
         break;
     }
//--- РАСЧЁТ ВЕЛИЧИНЫ ЛОТА ДЛЯ ОТКРЫВАНИЯ ПОЗИЦИИ
   if(base_lot<0)
      m_base_lot=MathAbs(base_lot);
   else
   switch(m_mm_lot)
     {
      //---- Расчёт лота от свободных средств на счёте
      case  0:
         margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE)*Lot;
         m_base_lot=GetLotForOpeningPos(symbol,directon,margin);
         break;
         //---- Расчёт лота от баланса средств на счёте
      case  1:
         margin=AccountInfoDouble(ACCOUNT_BALANCE)*Lot;
         m_base_lot=GetLotForOpeningPos(symbol,directon,margin);
         break;
         //---- Расчёт лота без изменения
      case  2:
        {
         m_base_lot=MathAbs(base_lot);
         break;
        }
      //---- Расчёт лота от свободных средств на счёте по умолчанию
      default:
        {
         margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE)*Lot;
         m_base_lot=GetLotForOpeningPos(symbol,directon,margin);
        }
     }

//---- нормирование величины лота до ближайшего стандартного значения 
   if(!LotCorrect(symbol,directon)) return(-1);
//----
   return(m_base_lot);
  }
//+------------------------------------------------------------------+
//| коррекция размера лота до ближайшего допустимого значения        |
//+------------------------------------------------------------------+
bool CTradeBase::LotCorrect(string symbol,ENUM_POSITION_TYPE trade_operation)
  {
//---- получение данных для расчёта   
   double Step,MaxLot,MinLot;
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP,Step)) return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX,MaxLot)) return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN,MinLot)) return(false);

//---- нормирование величины лота до ближайшего стандартного значения 
   m_base_lot=Step*MathFloor(m_base_lot/Step);

//---- проверка лота на минимальное допустимое значение
   if(m_base_lot<MinLot)
      m_base_lot=MinLot;
//---- проверка лота на максимальное допустимое значение       
   if(m_base_lot>MaxLot)
      m_base_lot=MaxLot;

//---- проверка средств на достаточность
   if(!LotFreeMarginCorrect(symbol,trade_operation))return(false);
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| ограничение размера лота возможностями депозита                  |
//+------------------------------------------------------------------+
bool CTradeBase::LotFreeMarginCorrect(string symbol,ENUM_POSITION_TYPE trade_operation)
  {
//---- проверка средств на достаточность
   double freemargin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(freemargin<=0) return(false);

//---- получение данных для расчёта   
   double Step,MaxLot,MinLot;
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP,Step)) return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX,MaxLot)) return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN,MinLot)) return(false);

   double ExtremLot=GetLotForOpeningPos(symbol,trade_operation,freemargin);
//---- нормирование величины лота до ближайшего стандартного значения 
   ExtremLot=Step*MathFloor(ExtremLot/Step);

   if(ExtremLot<MinLot)
      return(false);                   // недостаточно денег даже на минимальный лот!
   if(m_base_lot>ExtremLot)
      m_base_lot=ExtremLot;            // урезаем размер лота до того, что есть на депозите!
   if(m_base_lot>MaxLot)
      m_base_lot=MaxLot;               // урезаем размер лота до масимально допустимого
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| коррекция размера отложенного ордера до допустимого значения     |
//+------------------------------------------------------------------+
int CTradeBase::StopCorrect(string symbol,int Stop)
  {
//----
   long Extrem_Stop;
   if(!SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL,Extrem_Stop)) return(false);
   if(Stop<Extrem_Stop)
      Stop=int(Extrem_Stop);
//----
   return(Stop);
  }
//+------------------------------------------------------------------+
//| коррекция размера отложенного ордера до допустимого значения     |
//+------------------------------------------------------------------+
bool CTradeBase::dStopCorrect(string symbol,double &dStopLoss,double &dTakeprofit,ENUM_POSITION_TYPE trade_operation)
  {
//----
   if(!dStopLoss && !dTakeprofit)
      return(true);

   if(dStopLoss<0)
     {
      Print(__FUNCTION__,"(): A negative value stoploss!");
      return(false);
     }

   if(dTakeprofit<0)
     {
      Print(__FUNCTION__,"(): A negative value takeprofit!");
      return(false);
     }
//---- 
   int Stop=0;
   long digit;
   double point,dStop,ExtrStop,ExtrTake;

//---- получаем минимальное расстояние до отложенного ордера 
   Stop=StopCorrect(symbol,Stop);
//----   
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit))
      return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point))
      return(false);
   dStop=Stop*point;

//---- коррекция размера отложенного ордера для лонга
   if(trade_operation==POSITION_TYPE_BUY)
     {
      double Ask;
      if(!SymbolInfoDouble(symbol,SYMBOL_ASK,Ask))
         return(false);

      ExtrStop=NormalizeDouble(Ask-dStop,int(digit));
      ExtrTake=NormalizeDouble(Ask+dStop,int(digit));

      if(dStopLoss>ExtrStop && dStopLoss)
         dStopLoss=ExtrStop;
      if(dTakeprofit<ExtrTake && dTakeprofit)
         dTakeprofit=ExtrTake;
     }

//---- коррекция размера отложенного ордера для шорта
   if(trade_operation==POSITION_TYPE_SELL)
     {
      double Bid;
      if(!SymbolInfoDouble(symbol,SYMBOL_BID,Bid))
         return(false);

      ExtrStop=NormalizeDouble(Bid+dStop,int(digit));
      ExtrTake=NormalizeDouble(Bid-dStop,int(digit));

      if(dStopLoss<ExtrStop && dStopLoss)
         dStopLoss=ExtrStop;
      if(dTakeprofit>ExtrTake && dTakeprofit)
         dTakeprofit=ExtrTake;
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| возврат стрингового результата торговой операции по его коду     |
//+------------------------------------------------------------------+
string CTradeBase::ResultRetcodeDescription(int retcode)
  {
   string str;
//----
   if(m_lang=="en")
     {
      switch(retcode)
        {
         case TRADE_RETCODE_REQUOTE: str="Requote"; break;
         case TRADE_RETCODE_REJECT: str="Request rejected"; break;
         case TRADE_RETCODE_CANCEL: str="Request canceled by trader"; break;
         case TRADE_RETCODE_PLACED: str="Order placed"; break;
         case TRADE_RETCODE_DONE: str="Request completed"; break;
         case TRADE_RETCODE_DONE_PARTIAL: str="Only part of the request was completed"; break;
         case TRADE_RETCODE_ERROR: str="Request processing error"; break;
         case TRADE_RETCODE_TIMEOUT: str="Request canceled by timeout";break;
         case TRADE_RETCODE_INVALID: str="Invalid request"; break;
         case TRADE_RETCODE_INVALID_VOLUME: str="Invalid volume in the request"; break;
         case TRADE_RETCODE_INVALID_PRICE: str="Invalid price in the request"; break;
         case TRADE_RETCODE_INVALID_STOPS: str="Invalid stops in the request"; break;
         case TRADE_RETCODE_TRADE_DISABLED: str="Trade is disabled"; break;
         case TRADE_RETCODE_MARKET_CLOSED: str="Market is closed"; break;
         case TRADE_RETCODE_NO_MONEY: str="There is not enough money to complete the request"; break;
         case TRADE_RETCODE_PRICE_CHANGED: str="Prices changed"; break;
         case TRADE_RETCODE_PRICE_OFF: str="There are no quotes to process the request"; break;
         case TRADE_RETCODE_INVALID_EXPIRATION: str="Invalid order expiration date in the request"; break;
         case TRADE_RETCODE_ORDER_CHANGED: str="Order state changed"; break;
         case TRADE_RETCODE_TOO_MANY_REQUESTS: str="Too frequent requests"; break;
         case TRADE_RETCODE_NO_CHANGES: str="No changes in request"; break;
         case TRADE_RETCODE_SERVER_DISABLES_AT: str="Autotrading disabled by server"; break;
         case TRADE_RETCODE_CLIENT_DISABLES_AT: str="Autotrading disabled by client terminal"; break;
         case TRADE_RETCODE_LOCKED: str="Request locked for processing"; break;
         case TRADE_RETCODE_FROZEN: str="Order or position frozen"; break;
         case TRADE_RETCODE_INVALID_FILL: str="Invalid order filling type"; break;
         case TRADE_RETCODE_CONNECTION: str="No connection with the trade server"; break;
         case TRADE_RETCODE_ONLY_REAL: str="Operation is allowed only for live accounts"; break;
         case TRADE_RETCODE_LIMIT_ORDERS: str="The number of pending orders has reached the limit"; break;
         case TRADE_RETCODE_LIMIT_VOLUME: str="The volume of orders and positions for the symbol has reached the limit"; break;
         default: str="Unknown result";
        }
     }
   else if(m_lang=="ru")
     {
      switch(retcode)
        {
         case TRADE_RETCODE_REQUOTE: str="Реквота"; break;
         case TRADE_RETCODE_REJECT: str="Запрос отвергнут"; break;
         case TRADE_RETCODE_CANCEL: str="Запрос отменен трейдером"; break;
         case TRADE_RETCODE_PLACED: str="Ордер размещен"; break;
         case TRADE_RETCODE_DONE: str="Заявка выполнена"; break;
         case TRADE_RETCODE_DONE_PARTIAL: str="Заявка выполнена частично"; break;
         case TRADE_RETCODE_ERROR: str="Ошибка обработки запроса"; break;
         case TRADE_RETCODE_TIMEOUT: str="Запрос отменен по истечению времени";break;
         case TRADE_RETCODE_INVALID: str="Неправильный запрос"; break;
         case TRADE_RETCODE_INVALID_VOLUME: str="Неправильный объем в запросе"; break;
         case TRADE_RETCODE_INVALID_PRICE: str="Неправильная цена в запросе"; break;
         case TRADE_RETCODE_INVALID_STOPS: str="Неправильные стопы в запросе"; break;
         case TRADE_RETCODE_TRADE_DISABLED: str="Торговля запрещена"; break;
         case TRADE_RETCODE_MARKET_CLOSED: str="Рынок закрыт"; break;
         case TRADE_RETCODE_NO_MONEY: str="Нет достаточных денежных средств для выполнения запроса"; break;
         case TRADE_RETCODE_PRICE_CHANGED: str="Цены изменились"; break;
         case TRADE_RETCODE_PRICE_OFF: str="Отсутствуют котировки для обработки запроса"; break;
         case TRADE_RETCODE_INVALID_EXPIRATION: str="Неверная дата истечения ордера в запросе"; break;
         case TRADE_RETCODE_ORDER_CHANGED: str="Состояние ордера изменилось"; break;
         case TRADE_RETCODE_TOO_MANY_REQUESTS: str="Слишком частые запросы"; break;
         case TRADE_RETCODE_NO_CHANGES: str="В запросе нет изменений"; break;
         case TRADE_RETCODE_SERVER_DISABLES_AT: str="Автотрейдинг запрещен сервером"; break;
         case TRADE_RETCODE_CLIENT_DISABLES_AT: str="Автотрейдинг запрещен клиентским терминалом"; break;
         case TRADE_RETCODE_LOCKED: str="Запрос заблокирован для обработки"; break;
         case TRADE_RETCODE_FROZEN: str="Ордер или позиция заморожены"; break;
         case TRADE_RETCODE_INVALID_FILL: str="Указан неподдерживаемый тип исполнения ордера по остатку "; break;
         case TRADE_RETCODE_CONNECTION: str="Нет соединения с торговым сервером"; break;
         case TRADE_RETCODE_ONLY_REAL: str="Операция разрешена только для реальных счетов"; break;
         case TRADE_RETCODE_LIMIT_ORDERS: str="Достигнут лимит на количество отложенных ордеров"; break;
         case TRADE_RETCODE_LIMIT_VOLUME: str="Достигнут лимит на объем ордеров и позиций для данного символа"; break;
         default: str="Неизвестный результат";
        }
     }
//----
   return(str);
  }
//+------------------------------------------------------------------+
//| Select a position on the index                                   |
//+------------------------------------------------------------------+
bool CTradeBase::SelectByIndex(const int index)
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
//+------------------------------------------------------------------+
//| Position select depending on netting or hedging                  |
//+------------------------------------------------------------------+
bool CTradeBase::SelectPosition(const string symbol,int MagicNumber)
  {
   bool res=false;
//---
   if(IsHedging())
     {
      uint total=PositionsTotal();
      for(uint i=0; i<total; i++)
        {
         string position_symbol=PositionGetSymbol(i);
         if(position_symbol==symbol && MagicNumber==PositionGetInteger(POSITION_MAGIC))
           {
            res=true;
            break;
           }
        }
     }
   else
      res=PositionSelect(symbol);
//---
   return(res);
  }
//+------------------------------------------------------------------+
