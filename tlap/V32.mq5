/*

*/
//+------------------------------------------------------------------+

//#property strict
//#property icon "graphics/tio_logo.ico"
//#property link "https://tlap.com"
//#property copyright "tlap.com"


/* Здесь у нас то, что надо менять постоянно */
const string version = "32";
#define SETS_NUM 22
bool use_license = 0;
const long account = 2087097;
string bot_name = "TLAP CAPITAL v" + version;
string comment = "TIO";

//+------------------------------------------------------------------+
#define Alert PrintTmp
#define Print PrintTmp
void PrintTmp( string ) {}
#include "logic/MT4Orders.mqh" // если есть #include <Trade/Trade.mqh>, вставить эту строчку ПОСЛЕ
#undef Print
#undef Alert
#include "logic/settings.mqh"
#include "logic/time_control.mqh"
#include "logic/filters.mqh"
#include "init/initialize.mqh"
#include "logic/main.mqh"
#include "logic/recovery.mqh"
#include "logic/indicators.mqh"
#include "sets/sets.mqh"
#include "logic/Comment.mqh"
#include "logic/info_show.mqh"
#include "graphics/logo.mqh"

//panel init
CComment comment_;

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
#ifdef __MQL5__
   MT4ORDERS::OrderSend_MaxPause = 180000000; // Таймаут три минуты.
#endif //__MQL5__
   return init_ea();
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   comment_.Destroy(); //--- remove panel
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   tick_handler();
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
   double dd = TesterStatistics(STAT_EQUITY_DD);
   if(dd > 0.0)
      return TesterStatistics(STAT_PROFIT) / dd;
   return 0.0;
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| OnChartEvent                                                     |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   int res=comment_.OnChartEvent(id, lparam, dparam, sparam);
//--- move panel event
   if(res==EVENT_MOVE)
      return;
//--- change background color
   if(res==EVENT_CHANGE)
      comment_.Show();
  }
//+------------------------------------------------------------------+
//| OnTimer                                                          |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(!is_test || visual_mode)
     {
      refresh_panel();
     }
  }
//+------------------------------------------------------------------+
