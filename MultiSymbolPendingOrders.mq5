//+------------------------------------------------------------------+
//|                                     MultiSymbolPendingOrders.mq5 |
//|            Copyright 2013, https://login.mql5.com/ru/users/tol64 |
//|                                  Site, http://tol64.blogspot.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2013, http://tol64.blogspot.com"
#property link        "http://tol64.blogspot.com"
#property description "email: hello.tol64@gmail.com"
#property version     "1.0"
//--- ���������� ��������� ��������
#define NUMBER_OF_SYMBOLS 2
//--- ���������� ����� ����������� ����������
#include <Trade/Trade.mqh>
//--- �������� ������
CTrade   trade;
//--- ���������� ���� ����������
#include "Include/Enums.mqh"
#include "Include/InitializeArrays.mqh"
#include "Include/Errors.mqh"
#include "Include/TradeSignals.mqh"
#include "Include/TradeFunctions.mqh"
#include "Include/ToString.mqh"
#include "Include/Auxiliary.mqh"
//--- ������� ��������� ��������
sinput long       MagicNumber       = 777;      // ���������� �����
sinput int        Deviation         = 10;       // ���������������
//---
sinput string delimeter_00=""; // --------------------------------
sinput string     Symbol_01            ="EURUSD";  // ������ 1
input  bool       TradeInTimeRange_01  =true;      // |     �������� �� ��������� ���������
input  ENUM_HOURS StartTrade_01        = h10;      // |     ��� ������ ��������
input  ENUM_HOURS StopOpenOrders_01    = h17;      // |     ��� ��������� ��������� �������
input  ENUM_HOURS EndTrade_01          = h22;      // |     ��� ��������� ��������
input  double     PendingOrder_01      = 50;       // |     ���������� �����
input  double     TakeProfit_01        = 100;      // |     ���� ������
input  double     StopLoss_01          = 50;       // |     ���� ����
input  double     TrailingStop_01      = 10;       // |     �������� ����
input  bool       Reverse_01           = true;     // |     �������� �������
input  double     Lot_01               = 0.1;      // |     ���
//---
sinput string delimeter_01=""; // --------------------------------
sinput string     Symbol_02            ="AUDUSD";  // ������ 2
input  bool       TradeInTimeRange_02  =true;      // |     �������� �� ��������� ���������
input  ENUM_HOURS StartTrade_02        = h10;      // |     ��� ������ ��������
input  ENUM_HOURS StopOpenOrders_02    = h17;      // |     ��� ��������� ��������� �������
input  ENUM_HOURS EndTrade_02          = h22;      // |     ��� ��������� ��������
input  double     PendingOrder_02      = 50;       // |     ���������� �����
input  double     TakeProfit_02        = 100;      // |     ���� ������
input  double     StopLoss_02          = 50;       // |     ���� ����
input  double     TrailingStop_02      = 10;       // |     �������� ����
input  bool       Reverse_02           = true;     // |     �������� �������
input  double     Lot_02               = 0.1;      // |     ���
//--- ������� ��� �������� ������� ����������
string     Symbols[NUMBER_OF_SYMBOLS];          // ������
bool       TradeInTimeRange[NUMBER_OF_SYMBOLS]; // �������� �� ��������� ���������
ENUM_HOURS StartTrade[NUMBER_OF_SYMBOLS];       // ��� ������ ��������
ENUM_HOURS StopOpenOrders[NUMBER_OF_SYMBOLS];   // ��� ��������� ��������� �������
ENUM_HOURS EndTrade[NUMBER_OF_SYMBOLS];         // ��� ��������� ��������
double     PendingOrder[NUMBER_OF_SYMBOLS];     // ���������� �����
double     TakeProfit[NUMBER_OF_SYMBOLS];       // ���� ������
double     StopLoss[NUMBER_OF_SYMBOLS];         // ���� ����
double     TrailingStop[NUMBER_OF_SYMBOLS];     // �������� ����
bool       Reverse[NUMBER_OF_SYMBOLS];          // �������� �������
double     Lot[NUMBER_OF_SYMBOLS];              // ���

//--- ������ ������� ��� �����������-�������
int spy_indicator_handles[NUMBER_OF_SYMBOLS];
//--- ������� ������ ��� �������� �������� ������� 
struct PriceData
  {
   double            value[];
  };
PriceData open[NUMBER_OF_SYMBOLS];      // ���� �������� ����
PriceData high[NUMBER_OF_SYMBOLS];      // ���� ��������� ����
PriceData low[NUMBER_OF_SYMBOLS];       // ���� �������� ����
PriceData close[NUMBER_OF_SYMBOLS];     // ���� �������� ����
//--- ������� ��� ��������� ������� �������� �������� ����
struct Datetime
  {
   datetime          time[];
  };
Datetime lastbar_time[NUMBER_OF_SYMBOLS];
//--- ������ ��� �������� ������ ���� �� ������ �������
datetime new_bar[NUMBER_OF_SYMBOLS];
//--- ������ ��� �������� ������ ��������� ������ �� ������ �������
ulong last_deal_ticket[NUMBER_OF_SYMBOLS];
//--- ����������� ���������� �������
string comment_top_order    ="top_order";
string comment_bottom_order ="bottom_order";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- ������������� �������� ������� ����������
   InitializeInputParameters();
//--- �������� ������� ���������
   if(!CheckInputParameters())
      return(INIT_PARAMETERS_INCORRECT);
//--- ������������� �������� ������� �����������
   InitializeHandlesArray();
//--- �������� ������ �������
   GetSpyHandles();
//--- �������������� ����� ���
   InitializeNewBarArray();
//--- ������������ ������ �������
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- ������� � ������ ������� ���������������
   Print(GetDeinitReasonText(reason));
//--- ��� �������� � �������
   if(reason==REASON_REMOVE)
     {
      //--- ������ ������ �����������
      for(int s=NUMBER_OF_SYMBOLS-1; s>=0; s--)
         IndicatorRelease(spy_indicator_handles[s]);
     }
  }
//+------------------------------------------------------------------+
//| ��������� �������� �������                                       |
//+------------------------------------------------------------------+
void OnTrade()
  {
//--- �������� ��������� ���������� �������
   ManagePendingOrders();
  }
//+------------------------------------------------------------------+
//| ���������� ���������������� ������� � ������� �������            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // ������������� �������
                  const long &lparam,   // �������� ������� ���� long
                  const double &dparam, // �������� ������� ���� double
                  const string &sparam) // �������� ������� ���� string
  {
//--- ���� ��� ���������������� �������
   if(id>=CHARTEVENT_CUSTOM)
     {
      //--- �����, ���� ��������� ���������
      if(CheckTradingPermission()>0)
         return;
      //--- ���� ���� ������� "���"
      if(lparam==CHARTEVENT_TICK)
        {
         //--- �������� ��������� ���������� �������
         ManagePendingOrders();
         //--- �������� ������� � ������� �� ���
         CheckSignalsAndTrade();
         return;
        }
     }
  }
//+------------------------------------------------------------------+
//| ��������� ������� � ������� �� ������� "����� ���"               |
//+------------------------------------------------------------------+
void CheckSignalsAndTrade()
  {
//--- ��������� �� ���� ��������� ��������
   for(int s=0; s<NUMBER_OF_SYMBOLS; s++)
     {
      //--- ���� �������� �� ����� ������� �� ���������, ������
      if(Symbols[s]=="")
         continue;
      //--- ���� ��� �� �����, ������� � ���������� �������
      if(!CheckNewBar(s))
         continue;
      //--- ���� ���� ����� ���
      else
        {
         //--- ���� ��� ���������� ���������
         if(!IsInTradeTimeRange(s))
           {
            //--- ������� �������
            ClosePosition(s);
            //--- ������ ��� ���������� ������
            DeleteAllPendingOrders(s);
            //--- �������� � ���������� �������
            continue;
           }
         //--- ������� ������ �����
         GetBarsData(s);
         //--- �������� ������� � �������
         TradingBlock(s);
         //--- ���� ������� ��������� �������
         if(Reverse[s])
            //--- ����������� ���� ���� ��� ����������� ������
            ModifyPendingOrderTrailingStop(s);
         //--- ���� �������� ��������� �������
         else
         //--- ����������� ���� ����
            ModifyTrailingStop(s);
        }
     }
  }
//+------------------------------------------------------------------+
//| ��������� ������� ���������                                      |
//+------------------------------------------------------------------+
bool CheckInputParameters()
  {
//--- ��������� �� ���� ��������� ��������
   for(int s=0; s<NUMBER_OF_SYMBOLS; s++)
     {
      //--- ���� ������� ��� ��� �������� �� ��������� ��������� ���������, ��������� � ���������� �������
      if(Symbols[s]=="" || !TradeInTimeRange[s])
         continue;
      //--- �������� ������������ ������� ������ � ��������� ��������
      if(StartTrade[s]>=EndTrade[s])
        {
         Print(Symbols[s],
               ": ��� ������ �������� ("+IntegerToString(StartTrade[s])+") "
               "������ ���� ������ ���� ��������� �������� ("+IntegerToString(EndTrade[s])+")!");
         return(false);
        }
      //--- �������� �������� ����� �� ������� ��� �� 1 ��� �� ������� ��������� ���������� �������.
      //    ��������� ���������� ������� ������ ����������� �� ������� ��� �� 1 ��� �� ��������� ��������.
      if(StopOpenOrders[s]>=EndTrade[s] ||
         StopOpenOrders[s]<=StartTrade[s])
        {
         Print(Symbols[s],
               ": ��� ��������� ��������� ������� ("+IntegerToString(StopOpenOrders[s])+") "
               "������ ���� ������ ���� ��������� ("+IntegerToString(EndTrade[s])+") � "
               "������ ���� ������ ��������  ("+IntegerToString(StartTrade[s])+")!");
         return(false);
        }
     }
//--- ��������� ���������
   return(true);
  }
//+------------------------------------------------------------------+
//| ���������, ��������� �� � �������� ��������� ���������           |
//+------------------------------------------------------------------+
bool IsInTradeTimeRange(int symbol_number)
  {
//--- ���� �������� �������� �� ��������� ���������
   if(TradeInTimeRange[symbol_number])
     {
      //--- ��������� ���� � �������
      MqlDateTime last_date;
      //--- ������� ��������� ������ ���� � �������
      TimeTradeServer(last_date);
      //--- ��� ������������ ���������� ���������
      if(last_date.hour<StartTrade[symbol_number] ||
         last_date.hour>=EndTrade[symbol_number])
         return(false);
     }
//--- � ����������� ��������� ���������
   return(true);
  }
//+------------------------------------------------------------------+
//| ���������, ��������� �� �� ��������� ��������� ��������� ������� |
//+------------------------------------------------------------------+
bool IsInOpenOrdersTimeRange(int symbol_number)
  {
//--- ���� �������� �������� �� ��������� ���������
   if(TradeInTimeRange[symbol_number])
     {
      //--- ��������� ���� � �������
      MqlDateTime last_date; 
      //--- ������� ��������� ������ ���� � �������
      TimeTradeServer(last_date);
      //--- ��� ������������ ���������� ���������
      if(last_date.hour<StartTrade[symbol_number] ||
         last_date.hour>=StopOpenOrders[symbol_number])
         return(false);
     }
//--- � ����������� ��������� ���������
   return(true);
  }
//+------------------------------------------------------------------+
