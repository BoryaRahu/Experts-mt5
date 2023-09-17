/* 

 - Отправить уведомление на MetaQuotes ID при открытии позиции с данным шагом в цепочке

 */
#define pdxversion "1.10"
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#property version   pdxversion
#define mystrateges_no_manual 1
#define mystrateges_timer 7

#include "Strategies\strategy_inf_trailing.mqh"
#include <Arrays\ArrayString.mqh>

input bool        showLoss=true; //Показывать сумму последних убытков при клике на кнопку символа.
input int      EA_Magic=777;

double tradeCorrect;
bool needHistory=true;
ushort orders_total=0;
double currHistory;
uint countHistory, countHistoryPros, countHistoryCons;
ulong  ticket_history=0;
CArrayString curButtons;
string msg_lines[];
uchar lines_size=0;

string prefix_graph="revertme_";

int OnInit(){
   tradeCorrect=0;
   needHistory=true;
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
   if(reason!=REASON_CHARTCHANGE){
      pdxDeinit();
   }
   
   ObjectsDeleteAll(0, prefix_graph);
   #ifdef mystrateges_timer
      EventKillTimer();
   #endif
}
#ifndef mystrateges_timer
   void OnTick(){
      pdxTick();
   }
#else
   void OnTimer(){
      
      string msg="";
      
      if( needHistory ){
         MqlDateTime curDayBegin;
         TimeToStruct(TimeCurrent(), curDayBegin);
         curDayBegin.hour=0;
         curDayBegin.min=0;
         curDayBegin.sec=0;
         HistorySelect(StructToTime(curDayBegin),TimeCurrent()); 
      }
      uint totalHistory=HistoryDealsTotal();
      currHistory=countHistory=countHistoryPros=countHistoryCons=0;
      for(uint j=0;j<totalHistory;j++){
         if((ticket_history=HistoryDealGetTicket(j))>0 ){
            double profitHistory=HistoryDealGetDouble(ticket_history,DEAL_PROFIT);
            profitHistory+=HistoryDealGetDouble(ticket_history,DEAL_COMMISSION);
            profitHistory+=HistoryDealGetDouble(ticket_history,DEAL_SWAP);
            if(profitHistory!=0){
               countHistory++;
               currHistory+=profitHistory;
               if(profitHistory>0){
                  countHistoryPros++;
               }else{
                  countHistoryCons++;
               }
            }
         }
      }
      if(countHistory>0){
         StringAdd(msg, "Сегодня: " + (string) DoubleToString(currHistory, 2)+" "+accCur+" ("+(string) countHistory+"; "+(string) countHistoryPros+"+; "+(string) countHistoryCons+"-)\r\n");
      }
      
      double tmpProfit=0;
      int cntMyPos=PositionsTotal();
      positionExist=false;
      bool positionNew=false;
      
      if(cntMyPos>0){
         for(int ti=cntMyPos-1; ti>=0; ti--){
            string curSymbol=PositionGetSymbol(ti);
            if( PositionGetInteger(POSITION_MAGIC)!=EA_Magic ) continue;
            positionExist=true;
            if( PositionGetInteger(POSITION_TIME)>TimeCurrent()-mystrateges_timer ){
               positionNew=true;
               break;
            }
         }
         if(positionExist){
            if(positionNew){
               ObjectsDeleteAll(0, prefix_graph);
            }
            if(ObjectFind(0, prefix_graph+"delall")<0){
               createObject(prefix_graph+"delall", 163, "Закрыть все");
            }
         }
         curButtons.Resize(0);
         for(int ti=cntMyPos-1; ti>=0; ti--){
            string curSymbol=PositionGetSymbol(ti);
            if( PositionGetInteger(POSITION_MAGIC)!=EA_Magic ) continue;
            
            double curProfit=PositionGetDouble(POSITION_PROFIT);
            curProfit+=PositionGetDouble(POSITION_SWAP);
            
            tmpProfit+=curProfit;
            string symname=curSymbol;
            StringReplace(symname, " ", "___");
            createObject(prefix_graph+symname, 137, curSymbol+": "+DoubleToString(curProfit, 2)+" ("+PositionGetString(POSITION_COMMENT)+")");
            curButtons.Add(prefix_graph+symname);
         }
         for(int ti=0; ti<ObjectsTotal(0); ti++){
            string objName= ObjectName(0, ti);
            if(objName==prefix_graph+"delall"){
               continue;
            }
            if( StringFind(objName, prefix_graph)<0 ){
               continue;
            }
            bool isNone=true;
            for(int i=0; i<curButtons.Total(); i++){
               if( curButtons.At(i)==objName ){
                  isNone=false;
                  break;
               }
            }
            if(isNone){
               ObjectSetInteger(0,objName,OBJPROP_BGCOLOR, clrLightBlue); 
            }
         }
      }
      if(!positionExist){
         if( ObjectFind(0, prefix_graph+"delall")>=0 ){
            ObjectsDeleteAll(0, prefix_graph);
         }
      }else{
         if(tmpProfit!=0){
            ObjectSetString(0,prefix_graph+"delall",OBJPROP_TEXT,"Закрыть все ("+DoubleToString(tmpProfit, 2)+" "+accCur+")");
         }else{
            ObjectSetString(0,prefix_graph+"delall",OBJPROP_TEXT,"Закрыть все");
         }
      }
      
      if(StringLen(msg)){
         Comment( msg );
      }else{
         Comment("");
      }



      pdxTimer();
   }
#endif

void pdxInitStrats(bool isForce=false){
   if( isForce || ArraySize(pdxStrats)==0 || CheckPointer(pdxStrats[0])==POINTER_INVALID ){
      pdxDelStrats();
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
         if (sparam==prefix_graph+"delall"){
            if( !closeAllWarning || MessageBox("Вы действительно хотите закрыть все сделки, которыми управляет данный советник?", "Закрыть сделки", MB_YESNO)==IDYES){
               closeAll();
            }
         }else if( StringFind(sparam, prefix_graph)>=0 ){
            string symname=sparam;
            StringReplace(symname, prefix_graph, "");
            StringReplace(symname, "___", " ");
            
            long newChart=ChartOpen(symname, PERIOD_H1);
            
            if( showLoss && newChart>0 ){
               HistorySelect(TimeCurrent()-8640000,TimeCurrent());
            
               uint totalHistory=HistoryDealsTotal();
                  
               string msg="";
               ArrayFree(msg_lines);
            
               double currUntilProfit=0;
               double profitHistory=0;
               for(uint j=0;j<totalHistory;j++){
                  if((ticket_history=HistoryDealGetTicket(j))>0 && HistoryDealGetString(ticket_history,DEAL_SYMBOL)==symname){
                     profitHistory=HistoryDealGetDouble(ticket_history,DEAL_PROFIT);
                     profitHistory+=HistoryDealGetDouble(ticket_history,DEAL_COMMISSION);
                     profitHistory+=HistoryDealGetDouble(ticket_history,DEAL_SWAP);
                     if(profitHistory>0){
                        currUntilProfit=0;
                     }else{
                        currUntilProfit+=profitHistory;
                     }
                  }
               }
               StringAdd(msg, DoubleToString(currUntilProfit, 2));
               if(currUntilProfit!=0){
                  StringAdd(msg, " "+accCur);
               }
               msg_lines[ArrayResize(msg_lines,ArraySize(msg_lines)+1)-1]=msg;
                  
                  
               lines_size=(uchar) ArraySize(msg_lines);
               if(lines_size){
                  msg="";
                  for(int j=0; j<lines_size; j++){
                     StringAdd(msg, "\r\n"+msg_lines[j]);
                  }
                  ChartSetString(newChart,CHART_COMMENT,msg);
                       
                  ChartRedraw(newChart);
               }
            
            }
                        
         }
         break;
   }
}
void OnTrade(){
   if(orders_total==PositionsTotal()){
      return;
   }
   if(orders_total>PositionsTotal()){
      needHistory=true;
   }
   orders_total=(ushort) PositionsTotal();
}
void closeAll(){
   int cntMyPos=PositionsTotal();
   if(cntMyPos>0){
      for(int ti=cntMyPos-1; ti>=0; ti--){
         string curSymbol=PositionGetSymbol(ti);
         if( PositionGetInteger(POSITION_MAGIC)!=EA_Magic ) continue;
                     
         CTrade Trade;
         Trade.PositionClose(PositionGetInteger(POSITION_IDENTIFIER));
      }
   }
   ulong orderTicket;
   int cntMyPosO=OrdersTotal();
   if(cntMyPosO>0){
      for(int ti=cntMyPosO-1; ti>=0; ti--){
         orderTicket=OrderGetTicket(ti);
         if( OrderGetInteger(ORDER_MAGIC)!=EA_Magic ) continue;
                     
         CTrade Trade;
         Trade.OrderDelete(orderTicket);
      }
   }
   
   ObjectsDeleteAll(0, prefix_graph);
}
