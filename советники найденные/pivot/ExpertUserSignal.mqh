//+------------------------------------------------------------------+
//|                                             ExpertUserSignal.mqh |
//|                                           Copyright 2017, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, denkir"
#property link      "https://login.mql5.com/ru/users/denkir"
//---
#include <Expert\ExpertSignal.mqh>
//+------------------------------------------------------------------+
//| Class CExpertSignal.                                             |
//| Purpose: Base class trading signals.                             |
//| Derives from class CExpertBase.                                  |
//+------------------------------------------------------------------+
class CExpertUserSignal : public CExpertSignal
  {
   //--- === Data members === --- 
private:

   //--- === Methods === --- 
public:
   //--- конструктор/деструктор
   void              CExpertUserSignal(void){};
   void             ~CExpertUserSignal(void){};
   //--- get-методы
   double            GetDirection(void) const {return m_direction;}
   CArrayObj*        GetFilters(void) {return GetPointer(m_filters);}
  };

//+------------------------------------------------------------------+
