/* 

- добавлен вывод в комментарии к графику шага текущей сделки, текущую прибыль по позиции
- добавлена кнопка закрытия позиции


сумму убытков до первой прибыли, итого сумму по всем позициям данного инструмента

 */
#define pdxversion "1.20"
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#property version   pdxversion
#include "Strategies\strategy_ma.mqh"
#include "Strategies\strategy_adx.mqh"
#include "Strategies\strategy_sar_ma.mqh"
#include "Strategies\strategy_cci.mqh"
#include "Strategies\strategy_bb.mqh"
#include "Strategies\strategy_macd.mqh"
#include "Strategies\strategy_momentum.mqh"
#include "Strategies\strategy_rsi.mqh"
#include "Strategies\strategy_wpr.mqh"
#include "Strategies\strategy_time.mqh"
#include "Strategies\strategy_candle.mqh"

input int      EA_Magic=682938471;

string prefix_graph="revertmeall_";

int OnInit(){
   pdxInitAll();
   #ifndef mystrateges_no_manual
      pdxInitStrats();
      pdxInit();
   #endif
   #ifdef mystrateges_timer
      EventSetTimer(mystrateges_timer);
      pdxTickMulti();
   #endif
   return(0);
}
void OnDeinit(const int reason){
   ObjectsDeleteAll(0, prefix_graph);
   if(reason!=REASON_CHARTCHANGE){
      pdxDeinit();
   }
}
void OnTick(){
   pdxTick();
}
void pdxInitStrats(bool isForce=false){
   if( isForce || ArraySize(pdxStrats)==0 || CheckPointer(pdxStrats[0])==POINTER_INVALID ){
      pdxDelStrats();
      pdxStrats[ArrayResize(pdxStrats,ArraySize(pdxStrats)+1)-1]=new pdx_strat_ama(_Period);
      pdxStrats[ArrayResize(pdxStrats,ArraySize(pdxStrats)+1)-1]=new pdx_strat_adx(_Period);
      pdxStrats[ArrayResize(pdxStrats,ArraySize(pdxStrats)+1)-1]=new pdx_strat_sar_ma(_Period);
      pdxStrats[ArrayResize(pdxStrats,ArraySize(pdxStrats)+1)-1]=new pdx_strat_cci(CCI_Timeframe);
      pdxStrats[ArrayResize(pdxStrats,ArraySize(pdxStrats)+1)-1]=new pdx_strat_bb(_Period);
      pdxStrats[ArrayResize(pdxStrats,ArraySize(pdxStrats)+1)-1]=new pdx_strat_macd(_Period);
      pdxStrats[ArrayResize(pdxStrats,ArraySize(pdxStrats)+1)-1]=new pdx_strat_momentum(_Period);
      pdxStrats[ArrayResize(pdxStrats,ArraySize(pdxStrats)+1)-1]=new pdx_strat_rsi(_Period);
      pdxStrats[ArrayResize(pdxStrats,ArraySize(pdxStrats)+1)-1]=new pdx_strat_wpr(_Period);
      pdxStrats[ArrayResize(pdxStrats,ArraySize(pdxStrats)+1)-1]=new pdx_strat_candle(_Period);
      pdxStrats[ArrayResize(pdxStrats,ArraySize(pdxStrats)+1)-1]=new pdx_strat_time();
   }
}

void OnChartEvent(const int id,         // event ID   
                  const long& lparam,   // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
{
   string text="";
   switch(id){
      case CHARTEVENT_OBJECT_CLICK:
         if (sparam==prefix_graph+"del"){
            if( !closeAllWarning || MessageBox("Вы действительно хотите закрыть позицию по данному символу?", "Закрыть позицию", MB_YESNO)==IDYES){
               closeOne(_Symbol);
            }
         }
         break;
   }
}