//+------------------------------------------------------------------+
//| Resistance Breakout EA |
//| by ChatGPT 2023 |
//| https://github.com/ChatGPT|
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>
//--- input parameters
input double LotSize = 0.01; // Fixed lot size
input double VolatilityPercent = 2.5; // Volatility percentage for lot size calculation
input double TakeProfitPips = 50; // Take profit in pips
input double StopLossPips = 25; // Stop loss in pips
input int MaxAttempts = 3; // Maximum number of attempts to open position
input int BreakoutPeriod = 24; // Period for calculating the breakout level
input double Slippage = 3; // Maximum slippage allowed in pips
input double magiknumber = 345;
CTrade trade;
//--- variables
bool buy_trade_opened = false; // Buy trade opened flag
bool sell_trade_opened = false; // Sell trade opened flag
double buy_trade_open_price = 0; // Buy trade open price
double sell_trade_open_price = 0; // Sell trade open price
double last_support = 0; // Last support level
double last_resistance = 0; // Last resistance level

//+------------------------------------------------------------------+
//| Expert initialization function |
//+------------------------------------------------------------------+
int OnInit()
{


//--- set stop levels for the symbol
double stop_level = StopLossPips * Point();
double freeze_level = stop_level + Slippage * Point();

//--- set the indicator to the chart
string indicator_name = "PivotPointsUniversal";


return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert tick function |
//+------------------------------------------------------------------+
void OnTick()
{
double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);

//--- check if buy trade should be opened
if(!buy_trade_opened)
{
//--- calculate support level
double current_support = iATR(_Symbol, PERIOD_CURRENT, 14);
  //--- check if support level is broken
  if(price > current_support)
  {
     //--- check maximum number of attempts
     if(OrdersTotal() < MaxAttempts)
     {
        //--- calculate lot size based on volatility
        double atr = iATR(_Symbol, PERIOD_CURRENT, 14);
         double AccountFreeMargin=AccountInfoDouble(ACCOUNT_MARGIN);
        double lot_size = AccountFreeMargin * VolatilityPercent / 100 / (atr * 10);
        
        //--- open buy
         //--- open buy trade
    int ticket = trade.Buy( lot_size, _Symbol, price ,price - StopLossPips * Point(), price + TakeProfitPips * Point(),"Resistance Breakout EA");
   // OrderSend(_Symbol, OP_BUY, lot_size, price, Slippage, price - StopLossPips * Point(), price + TakeProfitPips * Point(), "Resistance Breakout EA", MAGIC_NUMBER, 0, Green);
    if(ticket > 0)
    {
        //--- trade opened successfully
        buy_trade_opened = true;
        buy_trade_open_price = price;
    }
    else
    {
        //--- failed to open trade
        Print("Failed to open buy trade: Error ", GetLastError());
    }
 }
 }
}

//--- check if sell trade should be opened
if(!sell_trade_opened)
{
//--- calculate resistance level
double current_resistance = iATR(_Symbol, PERIOD_CURRENT, 14);

//--- check if resistance level is broken
if(price < current_resistance)
{
//--- check maximum number of attempts
if(OrdersTotal() < MaxAttempts)
{
//--- calculate lot size based on volatility
double atr = iATR(_Symbol, PERIOD_CURRENT, 14);
double AccountFreeMargin=AccountInfoDouble(ACCOUNT_MARGIN);
double lot_size = AccountFreeMargin * VolatilityPercent / 100 / (atr * 10);
}
}
}
}
