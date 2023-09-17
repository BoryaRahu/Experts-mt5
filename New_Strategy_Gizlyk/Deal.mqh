//+------------------------------------------------------------------+
//|                                                         Deal.mqh |
//|                                              Copyright 2017, DNG |
//|                                 http://www.mql5.com/ru/users/dng |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, DNG"
#property link      "http://www.mql5.com/ru/users/dng"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <Object.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDeal          :  public CObject
  {
private:
   string               s_Symbol;
   datetime             dt_OpenTime;         // Time of open position
   double               d_OpenPrice;         // Price of opened position
   double               d_SL_Price;          // Stop Loss of position
   double               d_TP_Price;          // Take Profit of position
   ENUM_POSITION_TYPE   e_Direct;            // Direct of opened position
   double               d_ClosePrice;        // Price of close position
   int                  i_Profit;            // Profit of position in pips
//---
   double               d_Point;
   
public:
                     CDeal(string symbol, ENUM_POSITION_TYPE type,datetime time,double open_price,double sl_price, double tp_price);
                    ~CDeal();
   //--- Check status
   bool              IsClosed(void);
   ENUM_POSITION_TYPE Type(void)    {  return e_Direct;    }
   double            GetProfit(void);
   datetime          GetTime(void)  {  return dt_OpenTime;  }
   //---
   void              Tick(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeal::CDeal(string symbol, ENUM_POSITION_TYPE type,datetime time,double open_price,double sl_price,double tp_price) : i_Profit(0),
                                                                                                                       d_ClosePrice(0)
  {
   s_Symbol    =  symbol;
   d_Point     =  SymbolInfoDouble(s_Symbol,SYMBOL_POINT);
   dt_OpenTime =  time;
   d_OpenPrice =  open_price;
   e_Direct    =  type;
   d_SL_Price  =  sl_price;
   d_TP_Price  =  tp_price;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeal::~CDeal()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDeal::IsClosed(void)
  {
   return (d_ClosePrice>0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CDeal::GetProfit(void)
  {
   return (i_Profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDeal::Tick(void)
  {
   if(d_ClosePrice>0)
      return;
   double price=0;
   switch(e_Direct)
     {
      case POSITION_TYPE_BUY:
        price=SymbolInfoDouble(s_Symbol,SYMBOL_BID);
        if(d_SL_Price>0 && d_SL_Price>=price)
          {
           d_ClosePrice=price;
           i_Profit=(int)((d_ClosePrice-d_OpenPrice)/d_Point);
          }
        else
          {
           if(d_TP_Price>0 && d_TP_Price<=price)
             {
              d_ClosePrice=price;
              i_Profit=(int)((d_ClosePrice-d_OpenPrice)/d_Point);
             }
          }
        break;
      case POSITION_TYPE_SELL:
        price=SymbolInfoDouble(s_Symbol,SYMBOL_ASK);
        if(d_SL_Price>0 && d_SL_Price<=price)
          {
           d_ClosePrice=price;
           i_Profit=(int)((d_OpenPrice-d_ClosePrice)/d_Point);
          }
        else
          {
           if(d_TP_Price>0 && d_TP_Price>=price)
             {
              d_ClosePrice=price;
              i_Profit=(int)((d_OpenPrice-d_ClosePrice)/d_Point);
             }
          }
        break;
     }
  }
//+------------------------------------------------------------------+
