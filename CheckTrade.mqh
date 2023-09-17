//+------------------------------------------------------------------+
//|                                                   CheckTrade.mqh |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CheckTrade
  {
private:

public:
                     CheckTrade();
                    ~CheckTrade();
int                  OnCheckTradeInit(double   lot);
int                  OnCheckTradeTick(double   lot, double spread);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CheckTrade::CheckTrade()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CheckTrade::~CheckTrade()
  {
  }
//+------------------------------------------------------------------+
int CheckTrade::OnCheckTradeInit(double   lot){  
if((ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE)==ACCOUNT_TRADE_MODE_REAL){  
  int mb=MessageBox("Run the advisor on a real account?","Message Box",MB_YESNO|MB_ICONQUESTION);      
  if(mb==IDNO) return(0);     
 } 
if(!TerminalInfoInteger(TERMINAL_CONNECTED)){
Alert("No connection to the trade server");
return(0);
}else{
if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)){
Alert("Trade for this account is prohibited");
return(0);
  }
 } 
  if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT)){
      Alert("Trade with the help of experts for the account is prohibited");
   return(0);
  }
   if(lot<SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN)||lot>SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX)){ 
 Alert("Lot is not correct!!!");      
      return(0);
}
   return(INIT_SUCCEEDED);

}

int CheckTrade::OnCheckTradeTick(double   lot,double spread){
if(!TerminalInfoInteger(TERMINAL_CONNECTED)){
Alert("No connection to the trade server");
return(0);
}
if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){ 
Alert("Auto Trade Permission Off!");
return(0);
}   
if(!MQLInfoInteger(MQL_TRADE_ALLOWED)){
Alert("Automatic trading is prohibited in the properties of the expert ",__FILE__);
return(0);
}
if((ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)==ACCOUNT_STOPOUT_MODE_PERCENT){
if(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)!=0&&AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)
<=AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL)){
Alert("Margin Call!!!");
return(0);
}} 
if((ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)==ACCOUNT_STOPOUT_MODE_MONEY){
if(AccountInfoDouble(ACCOUNT_EQUITY)<=AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL)){
Alert("Margin Call!!!"); 
return(0); 
}}
if((ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)==ACCOUNT_STOPOUT_MODE_PERCENT){
if(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)!=0&&AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)
<=AccountInfoDouble(ACCOUNT_MARGIN_SO_SO)){
Alert("Stop Out!!!");
return(0);
}} 
if((ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)==ACCOUNT_STOPOUT_MODE_MONEY){
if(AccountInfoDouble(ACCOUNT_EQUITY)<=AccountInfoDouble(ACCOUNT_MARGIN_SO_SO)){
Alert("Stop Out!!!");
return(0);
}}
 double margin;
 MqlTick last_tick;
 ResetLastError();
 if(SymbolInfoTick(Symbol(),last_tick))
     {            
      if(OrderCalcMargin(ORDER_TYPE_BUY,Symbol(),lot,last_tick.ask,margin))
        {
     if(margin>AccountInfoDouble(ACCOUNT_MARGIN_FREE)){
      Alert("Not enough money in the account!");
      return(0);     
     }}
     }else{
      Print(GetLastError());
     }
double _spread=
SymbolInfoInteger(Symbol(),SYMBOL_SPREAD)*MathPow(10,-SymbolInfoInteger(Symbol(),SYMBOL_DIGITS))/MathPow(10,-4); 
 if(_spread>spread){
 Alert("Too big spread!");
 return(0);
 }
if((ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(Symbol(),SYMBOL_TRADE_MODE)!=SYMBOL_TRADE_MODE_FULL){
Alert("Restrictions on trading operations!");
return(0);
}
if(Bars(Symbol(), 0)<100)  
     {
      Alert("In the chart little bars, Expert will not work!!");
      return(0);
     } 
     
     return(1);    
}