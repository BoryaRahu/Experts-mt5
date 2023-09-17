//+------------------------------------------------------------------+
//|                                                 PivotsExpert.mqh |
//|                                           Copyright 2017, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, denkir"
#property link      "https://login.mql5.com/ru/users/denkir"
//--- include
#include "..\ExpertUserSignal.mqh"
#include "..\CisNewBar.mqh"
#include <Expert\Expert.mqh>
//+------------------------------------------------------------------+
//| Класс CPivotsExpert.                                       |
//| Цель: Класс для советника, торгующего по равноудалённому каналу. |
//| Потомок класса CExpert.                                          |
//+------------------------------------------------------------------+
class CPivotsExpert : public CExpert
  {
   //--- === Data members === --- 
private:
   ENUM_TIMEFRAMES   m_active_tf;            // активный ТФ
   CisNewBar         m_minute_new_bar;       // новый бар минутного ТФ

   //--- === Methods === --- 
public:
   //--- конструктор/деструктор
   void              CPivotsExpert(void){m_active_tf=PERIOD_M1;};
   void             ~CPivotsExpert(void){};
   //--- инициализация
   bool              Init(bool every_tick,ulong magic);

protected:
   //--- главный обработчик
   virtual bool      Processing(void);
   //--- trade open positions processing
   virtual bool      OpenLong(double price,double sl,double tp);
   virtual bool      OpenShort(double price,double sl,double tp);
private:
   double            LotCoefficient(void);
   //---
   double            NormalLot(const double _lot);
  };
//+------------------------------------------------------------------+
//| Инициализация                                                    |
//+------------------------------------------------------------------+
bool CPivotsExpert::Init(bool every_tick,ulong magic)
  {

//--- родительский класс
   if(!CExpert::Init(Symbol(),Period(),every_tick,magic))
     {
      PrintFormat(__FUNCTION__+": не инициализирован родительский класс!");
      return false;
     }
//--- изменение активного ТФ 
   if(!this.Period(m_active_tf))
     {
      PrintFormat(__FUNCTION__+": не задан активный ТФ!");
      return false;
     }
//--- новый бар
   m_minute_new_bar.SetPeriod(m_active_tf);
   m_minute_new_bar.SetLastBarTime(0);
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Главный модуль                                                   |
//+------------------------------------------------------------------+
bool CPivotsExpert::Processing(void)
  {
//--- новый бар на минутках
   if(!m_minute_new_bar.isNewBar())
      return false;
//--- расчёт направления
   m_signal.SetDirection();
//--- если позиции нет
   if(!this.SelectPosition())
     {
      //--- модуль открытия позиции
      if(this.CheckOpen())
         return true;
     }
//--- если позиция есть 
   else
     {
      //--- модуль закрытия позиции
      if(this.CheckClose())
         return true;
     }
//--- если нет торговых операций
   return false;
  }
//+------------------------------------------------------------------+
//| Long position open or limit/stop order set                       |
//+------------------------------------------------------------------+
bool CPivotsExpert::OpenLong(double price,double sl,double tp)
  {
   if(price==EMPTY_VALUE)
      return(false);
//--- get lot for open
   double lot_coeff=this.LotCoefficient();
   double lot=LotOpenLong(price,sl);
   lot=this.NormalLot(lot_coeff*lot);
//--- check lot for open
   lot=LotCheck(lot,price,ORDER_TYPE_BUY);
   if(lot==0.0)
      return(false);
//---
   return(m_trade.Buy(lot,price,sl,tp));
  }
//+------------------------------------------------------------------+
//| Short position open or limit/stop order set                      |
//+------------------------------------------------------------------+
bool CPivotsExpert::OpenShort(double price,double sl,double tp)
  {
   if(price==EMPTY_VALUE)
      return(false);
//--- get lot for open
   double lot_coeff=this.LotCoefficient();
   double lot=LotOpenShort(price,sl);
   lot=this.NormalLot(lot_coeff*lot);
//--- check lot for open
   lot=LotCheck(lot,price,ORDER_TYPE_SELL);
   if(lot==0.0)
      return(false);
//---
   return(m_trade.Sell(lot,price,sl,tp));
  }
//+------------------------------------------------------------------+
//| Коэффициент лота                                                 |
//+------------------------------------------------------------------+
double CPivotsExpert::LotCoefficient(void)
  {
   double lot_coeff=1.;
//--- общий сигнал
   CExpertUserSignal *ptr_signal=this.Signal();
   if(CheckPointer(ptr_signal)==POINTER_DYNAMIC)
     {
      double dir_val=ptr_signal.GetDirection();
      lot_coeff=NormalizeDouble(MathAbs(dir_val/100.),2);
     }
//---
   return lot_coeff;
  }
//+------------------------------------------------------------------+
//| Lot normalization by symbol properties                           |
//+------------------------------------------------------------------+
double CPivotsExpert::NormalLot(const double _lot)
  {
   double ll=WRONG_VALUE;
//---
   int k=0;
   ll=_lot;
   double ls=m_symbol.LotsStep();
   if(ls<=0.001) k=3; else if(ls<=0.01) k=2; else if(ls<=0.1) k=1;
   ll=NormalizeDouble(MathMin(m_symbol.LotsMax(),MathMax(m_symbol.LotsMin(),ll)),k);
//----
   return ll;
  }
//+------------------------------------------------------------------+
//--- [EOF]
