//+------------------------------------------------------------------+
//|                                            RevertmeManualEA4.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#define mystrateges_timer 7
#define pdxversion "1.00"
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#property version   pdxversion
#property strict

#include <Arrays\ArrayString.mqh>

struct translate{
   string err1;
   string err2;
   string err3;
   string err4;
   string err5;
   string err6;
   string err7;
   string err8;
   string err9;
   string err64;
   string err65;
   string err128;
   string err129;
   string err130;
   string err131;
   string err132;
   string err133;
   string err134;
   string err135;
   string err136;
   string err137;
   string err138;
   string err139;
   string err140;
   string err141;
   string err145;
   string err146;
   string err147;
   string err148;
   string err0;
   string retcode;
   string retcode10004;
   string retcode10006;
   string retcode10007;
   string retcode10010;
   string retcode10011;
   string retcode10012;
   string retcode10013;
   string retcode10014;
   string retcode10015;
   string retcode10016;
   string retcode10017;
   string retcode10018;
   string retcode10019;
   string retcode10020;
   string retcode10021;
   string retcode10022;
   string retcode10023;
   string retcode10024;
   string retcode10025;
   string retcode10026;
   string retcode10027;
   string retcode10028;
   string retcode10029;
   string retcode10030;
   string retcode10031;
   string retcode10032;
   string retcode10033;
   string retcode10034;
   string retcode10035;
   string retcode10036;
   string retcode10038;
   string retcode10039;
   string retcode10040;
   string retcode10041;
   string retcode10042;
   string retcode10043;
   string retcode10044;
};
translate langs;

enum TypeOfMA //Type of MA
  {
   AMA,//Adaptive Moving Average
   DEMA,// Double Exponential Moving Average
   FraMA,//Fractal Adaptive Moving Average 
   MA,//Moving Average 
   TEMA,//Triple Exponential Moving Average
  }; 
enum TypeOfClose //Type of Close Position
  {
   none,//Ничего не делать
   reverse,//Реверсировка (открыть в противоположном направлении)
   martingale,//Мартингейл (открыть в том же направлении)
  }; 
enum TypeOfStop //Type of Stop Loss
  {
   point,//В пунктах
   percent,//В процентах от цены
   atr,//В процентах от ATR
   zero,//Не ставить стоп
   low1,//По low/high первого бара
   low2,//По low/high второго бара
   buffer0_0,//По значению первого буфера индикатора 1
   buffer1_3,//По значению второго (long) и четвертого (short) буфера индикатора 1
   buffer1_2,//По значению второго (long) и третьего (short) буфера индикатора 1
  }; 
enum TypeOfTake //Type of Take
  {
   point_take,//В пунктах
   multiplier,//Множитель к стопу
  }; 
enum TypeOfAdd //Type of Add Position
  {
   geomet,//В геометрической прогрессии
   arifmet,//В арифметической прогрессии
   even,//Через 1 сделку
   even2,//Через 2 сделки
   even3,//Через 3 сделки
  }; 
enum TypeOfRSI //Type of RSI
  {
   RSI1,//Если curVal <= rsiValMax, то Long
   RSI2,//Если curVal > rsiValMax, то Long
   RSI3,//Если curVal > rsiValMax, то Short
  };
enum TypeOfCCI //Type of CCI
  {
   CCI1,//Если curVal > CCI_FROM_MAX, то Long
   CCI2,//Если curVal > CCI_FROM_MAX, то Short
  };
enum TypeOfMomentum //Type of Momentum
  {
   Momentum1,//Если curVal > MM_VOL_MAX, то Long
   Momentum2,//Если curVal > MM_VOL_MAX, то Short
  };

input int      EA_Magic=777;
sinput string     delimeter_base_01=""; // --- Открытие позиции
input double      addLot=0; //Размер доп. лота при реверсировке и мартингейле
sinput string     delimeter_base_02=""; // --- Сопровождение позиции
input TypeOfClose typeClose=reverse; //Действие при стоп лоссе
input TypeOfAdd   typeAdd=geomet; //Тип приращения объема сделки
input int         maxLotMultiplier=8; //Макс. мильтипликатор лота при реверсировке и мартингейле
input bool        showLoss=true; //Показывать сумму последних убытков при клике на кнопку символа.
input bool        closeAllWarning=true; //Запрашивать подтверждение при нажатии кнопки Закрыть все.

double tradeCorrect;
ushort orders_total=0;
double currHistory;
uint countHistory, countHistoryPros, countHistoryCons;
ulong  ticket_history=0;
string prefix_graph="revertme_";
bool isLongYes;
bool isShortYes;
double curLot=0;
bool lastDirectionIsLong;
double symStop;
double myPoint;
double STP,TKP,RA=0;
bool IsNewBar;
string accCur="";
bool positionExist;
CArrayString curButtons;
string msg_lines[];
uchar lines_size=0;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   tradeCorrect=0;
   pdxInitAll();
//--- create timer
   EventSetTimer(mystrateges_timer);
   pdxTickMulti();
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(reason!=REASON_CHARTCHANGE){
      pdxDeinit();
   }
   ObjectsDeleteAll(0, prefix_graph);
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
      double tmpProfit=0;
      int cntMyPos=OrdersTotal();
      positionExist=false;
      bool positionNew=false;
      
      if(cntMyPos>0){
         for(int ti=cntMyPos-1; ti>=0; ti--){
            if(OrderSelect(ti,SELECT_BY_POS,MODE_TRADES)==false) continue; 
            if( OrderType()==OP_BUY || OrderType()==OP_SELL ){}else{ continue; }

            string curSymbol=OrderSymbol();
            if( OrderMagicNumber()!=EA_Magic ) continue;
            positionExist=true;
            if( OrderOpenTime()>TimeCurrent()-mystrateges_timer ){
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
            if(OrderSelect(ti,SELECT_BY_POS,MODE_TRADES)==false) continue;
            if( OrderType()==OP_BUY || OrderType()==OP_SELL ){}else{ continue; }
            
            string curSymbol=OrderSymbol();
            if( OrderMagicNumber()!=EA_Magic ) continue;
            
            double curProfit=OrderProfit();
            curProfit+=OrderSwap();
            curProfit+=OrderCommission();
            
            
            tmpProfit+=curProfit;
            string symname=curSymbol;
            StringReplace(symname, " ", "___");
            createObject(prefix_graph+symname, 137, curSymbol+": "+DoubleToString(curProfit, 2)+" ("+OrderComment()+")");
            curButtons.Add(prefix_graph+symname);
         }
         for(int ti=0; ti<ObjectsTotal((long) 0); ti++){
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


      pdxTimer();   
  }
//+------------------------------------------------------------------+

void pdxInitAll(){
   init_lang();
   accCur=AccountInfoString(ACCOUNT_CURRENCY);
}
void pdxTickMulti(){
   pdxCheckSLandOrders(true);
   pdxDelSingleOrders();
}
void pdxTimer(){
   pdxTickMulti();
}
void pdxDeinit(){
}


bool pdxCheckSLandOrders(bool allSymbols=false){
   bool isNo;
   bool isTrade=0;
   bool Buy_opened=false;
   bool Sell_opened=false;
   int cntMyPosO=0;
   int cntMyPos=OrdersTotal();
   if(cntMyPos>0){
      double newLot=0;
      double bestPositionBuy=0;
      double bestPositionSell=0;
      double curCur=0;
      double isTake=0;
      for(int ti=cntMyPos-1; ti>=0; ti--){
         if(OrderSelect(ti,SELECT_BY_POS,MODE_TRADES)==false) continue; 
         if( OrderType()==OP_BUY || OrderType()==OP_SELL ){}else{ continue; }

         string curSymbol=OrderSymbol();
         if( !allSymbols && curSymbol!=_Symbol ) continue;
         if( OrderMagicNumber()!=EA_Magic ) continue;
         
         MqlTick latest_price;
         if(!SymbolInfoTick(curSymbol,latest_price) ){
            continue;
         }
         
         curCur= latest_price.ask;
         
         double curStop=OrderStopLoss();
         double curTake=OrderTakeProfit();
         double curOpen=OrderOpenPrice();
         string curComment=OrderComment();
         int curDigits=(int) SymbolInfoInteger(curSymbol, SYMBOL_DIGITS);
         

         switch(typeAdd){
            case geomet:
               newLot=OrderLots()*2+addLot;
               break;
            case arifmet:
               newLot=OrderLots()+curLot+addLot;
               break;
            case even:
               if( StringToInteger(curComment)%2==0 ){
                  newLot=OrderLots()*2+addLot;
               }else{
                  newLot=OrderLots()+addLot;
               }
               break;
            case even2:
               if( StringToInteger(curComment)%3==0 ){
                  newLot=OrderLots()*2+addLot;
               }else{
                  newLot=OrderLots()+addLot;
               }
               break;
            case even3:
               if( StringToInteger(curComment)%4==0 ){
                  newLot=OrderLots()*2+addLot;
               }else{
                  newLot=OrderLots()+addLot;
               }
               break;
         }
         if(StringLen(curComment)){
            curComment=(string) (StringToInteger(curComment)+1);
         }
         
         if(OrderType()==ORDER_TYPE_BUY){
            Buy_opened=true;
            isTrade=1;
            
            if(curCur>curOpen && bestPositionBuy<curOpen ){
               bestPositionBuy=curOpen;
            }

            if(curStop>0 && maxLotMultiplier>0 && StringToInteger(curComment)<=maxLotMultiplier ){
               cntMyPosO=OrdersTotal();
               isNo=true;
               if(cntMyPosO>0){
                  for(int tiO=cntMyPosO-1; tiO>=0; tiO--){
                     if(OrderSelect(tiO,SELECT_BY_POS,MODE_TRADES)==false) continue; 
                     if( OrderType()==OP_BUY || OrderType()==OP_SELL ){ continue; }

                     if( OrderSymbol()!=curSymbol ) continue;
                     if( OrderMagicNumber()!=EA_Magic ) continue;

                     if( typeClose==reverse && OrderType()!=ORDER_TYPE_SELL_STOP ) continue;
                     if( typeClose==martingale && OrderType()!=ORDER_TYPE_BUY_LIMIT ) continue;
                     isNo=false;
                     break;
                  }
               }
               if(isNo){
                  isTake=(curTake-curOpen)+SymbolInfoInteger(curSymbol,SYMBOL_SPREAD)*myPoint;
                  switch(typeClose){
                     case reverse:
                        if(!pdxSendOrder(OP_SELLSTOP, curStop, curOpen, curStop-isTake, newLot, 0, curComment, curSymbol)){
                        }
                        break;
                     case martingale:
                        if(!pdxSendOrder(OP_BUYLIMIT, curStop, curStop-(curOpen-curStop), curStop+isTake, newLot, 0, curComment, curSymbol)){
                        }
                        break;
                  }
               }
            }
            
         }else if(OrderType()==ORDER_TYPE_SELL){
            Sell_opened=true;
            isTrade=1;
            
            if(curCur<curOpen && bestPositionSell>curOpen ){
               bestPositionSell=curOpen;
            }
            
            if(curStop>0 && maxLotMultiplier>0 && StringToInteger(curComment)<=maxLotMultiplier ){
               cntMyPosO=OrdersTotal();
               isNo=true;
               if(cntMyPosO>0){
                  for(int tiO=cntMyPosO-1; tiO>=0; tiO--){
                     if(OrderSelect(tiO,SELECT_BY_POS,MODE_TRADES)==false) continue; 
                     if( OrderType()==OP_BUY || OrderType()==OP_SELL ){ continue; }
                     
                     if( OrderSymbol()!=curSymbol ) continue;
                     if( OrderMagicNumber()!=EA_Magic ) continue;
                     if( typeClose==reverse && OrderType()!=ORDER_TYPE_BUY_STOP ) continue;
                     if( typeClose==martingale && OrderType()!=ORDER_TYPE_SELL_LIMIT ) continue;
                     isNo=false;
                     break;
                  }
               }
               if(isNo){
                  isTake=(curOpen-curTake)+SymbolInfoInteger(curSymbol,SYMBOL_SPREAD)*myPoint;
                  switch(typeClose){
                     case reverse:
                        if(!pdxSendOrder(OP_BUYSTOP, curStop, curOpen, curStop+isTake, newLot, 0, curComment, curSymbol)){
                        }
                        break;
                     case martingale:
                        if(!pdxSendOrder(OP_SELLLIMIT, curStop, curStop+(curStop-curOpen), curStop-isTake, newLot, 0, curComment, curSymbol)){
                        }
                        break;
                  }
               }
            }
            
         }
       }
       if(RA>0 && curCur>0){
         if(bestPositionBuy>0 && curCur>bestPositionBuy+RA*myPoint ){
            pdxStartMainPosition(true);
         }
         if(bestPositionSell>0 && curCur<bestPositionSell-RA*myPoint ){
            pdxStartMainPosition(false);
         }
       }
   }
   
   if(Buy_opened || Sell_opened){
      return true;
   }
   if(isTrade){
      return true;
   }
   return false;
}
void pdxDelSingleOrders(){
   int cntMyPosO=OrdersTotal();
   bool needDel;
   if(cntMyPosO>0){
      for(int ti=cntMyPosO-1; ti>=0; ti--){
         if(OrderSelect(ti,SELECT_BY_POS,MODE_TRADES)==false) continue; 
         if( OrderType()==OP_BUY || OrderType()==OP_SELL ){ continue; }
         
         if( OrderMagicNumber()!=EA_Magic ) continue;
         if( OrderComment()=="1" ) continue;
         
         string curSymb=OrderSymbol();
         needDel=true;
         for(int ti2=cntMyPosO-1; ti2>=0; ti2--){
            if(OrderSelect(ti2,SELECT_BY_POS,MODE_TRADES)==false) continue; 
            if( OrderType()==OP_BUY || OrderType()==OP_SELL ){}else { continue; }
            
            if( OrderSymbol() != curSymb ) continue;
            if( OrderMagicNumber()!=EA_Magic ) continue;
               
            needDel=false;
            break;
         }
         if(needDel){
            if(OrderSelect(ti,SELECT_BY_POS,MODE_TRADES)==false) continue; 
            
            if(!OrderDelete(OrderTicket())){
            }
         }
      }
   }

}

void createObject(string name, int weight, string title){
   if(ObjectFind(0, name)<0){
      long offset= ChartGetInteger(0, CHART_WIDTH_IN_PIXELS)-87;
      long offsetY=0;
      for(int ti=0; ti<ObjectsTotal((long) 0); ti++){
         string objName= ObjectName(0, ti);
         if( StringFind(objName, prefix_graph)<0 ){
            continue;
         }
         long tmpOffset=ObjectGetInteger(0, objName, OBJPROP_YDISTANCE);
         if( tmpOffset>offsetY){
            offsetY=tmpOffset;
         }
      }
      
      for(int ti=0; ti<ObjectsTotal((long) 0); ti++){
         string objName= ObjectName(0, ti);
         if( StringFind(objName, prefix_graph)<0 ){
            continue;
         }
         long tmpOffset=ObjectGetInteger(0, objName, OBJPROP_YDISTANCE);
         if( tmpOffset!=offsetY ){
            continue;
         }
         
         tmpOffset=ObjectGetInteger(0, objName, OBJPROP_XDISTANCE);
         if( tmpOffset>0 && tmpOffset<offset){
            offset=tmpOffset;
         }
      }
      offset-=(weight+1);
      if(offset<0){
         offset=ChartGetInteger(0, CHART_WIDTH_IN_PIXELS)-87;
         offsetY+=25;
         offset-=(weight+1);
      }
  
     ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
     ObjectSetInteger(0,name,OBJPROP_XDISTANCE,offset); 
     ObjectSetInteger(0,name,OBJPROP_YDISTANCE,offsetY); 
     ObjectSetString(0,name,OBJPROP_TEXT, title); 
     ObjectSetInteger(0,name,OBJPROP_XSIZE,weight); 
     ObjectSetInteger(0,name,OBJPROP_FONTSIZE, 8);
     ObjectSetInteger(0,name,OBJPROP_COLOR, clrBlack);
     ObjectSetInteger(0,name,OBJPROP_YSIZE,25); 
     ChartRedraw(0);
  }else{
     ObjectSetString(0,name,OBJPROP_TEXT, title);
  }
  ObjectSetInteger(0,name,OBJPROP_BGCOLOR, clrLightGray);
}

bool pdxSendOrder(int type, double price, double sl, double tp, double volume, ulong position=0, string comment="", string sym=""){
   if( !StringLen(sym) ){
      sym=_Symbol;
   }
   int curDigits=(int) SymbolInfoInteger(sym, SYMBOL_DIGITS);
   if(sl>0){
      sl=NormalizeDouble(sl,curDigits);
   }
   if(tp>0){
      tp=NormalizeDouble(tp,curDigits);
   }
   if(price>0){
      price=NormalizeDouble(price,curDigits);
   }
   
   if(type==ORDER_TYPE_BUY){
      lastDirectionIsLong=true;
   }else if(type==ORDER_TYPE_SELL){
      lastDirectionIsLong=false;
   }

   if(OrderSend(sym, type, volume, price, 100, sl, tp, comment, EA_Magic, 0, clrGreen)<0){
         msgErr(GetLastError());
   }else{
      switch(type){
         case OP_BUY:
            Alert("Order Buy sl",sl," tp",tp," p",price," !!");
            break;
         case OP_SELL:
            Alert("Order Sell sl",sl," tp",tp," p",price," !!");
            break;
         }
         return true;
   }

   return false;
}
void pdxStartMainPosition(bool isLong){
   if(!TKP){
      return;
   }
}

void msgErr(int err, int retcode=0){
   string curErr="";
   switch(err){
      case 1:
         curErr=langs.err1;
         break;
      case 2:
         curErr=langs.err2;
         break;
      case 3:
         curErr=langs.err3;
         break;
      case 4:
         curErr=langs.err4;
         break;
      case 5:
         curErr=langs.err5;
         break;
      case 6:
         curErr=langs.err6;
         break;
      case 7:
         curErr=langs.err7;
         break;
      case 8:
         curErr=langs.err8;
         break;
      case 9:
         curErr=langs.err9;
         break;
      case 64:
         curErr=langs.err64;
         break;
      case 65:
         curErr=langs.err65;
         break;
      case 128:
         curErr=langs.err128;
         break;
      case 129:
         curErr=langs.err129;
         break;
      case 130:
         curErr=langs.err130;
         break;
      case 131:
         curErr=langs.err131;
         break;
      case 132:
         curErr=langs.err132;
         break;
      case 133:
         curErr=langs.err133;
         break;
      case 134:
         curErr=langs.err134;
         break;
      case 135:
         curErr=langs.err135;
         break;
      case 136:
         curErr=langs.err136;
         break;
      case 137:
         curErr=langs.err137;
         break;
      case 138:
         curErr=langs.err138;
         break;
      case 139:
         curErr=langs.err139;
         break;
      case 140:
         curErr=langs.err140;
         break;
      case 141:
         curErr=langs.err141;
         break;
      case 145:
         curErr=langs.err145;
         break;
      case 146:
         curErr=langs.err146;
         break;
      case 147:
         curErr=langs.err147;
         break;
      case 148:
         curErr=langs.err148;
         break;
      default:
         curErr=langs.err0+": "+(string) err;
   }
   if(retcode>0){
      curErr+=" ";
      switch(retcode){
         case 10004:
            curErr+=langs.retcode10004;
            break;
         case 10006:
            curErr+=langs.retcode10006;
            break;
         case 10007:
            curErr+=langs.retcode10007;
            break;
         case 10010:
            curErr+=langs.retcode10010;
            break;
         case 10011:
            curErr+=langs.retcode10011;
            break;
         case 10012:
            curErr+=langs.retcode10012;
            break;
         case 10013:
            curErr+=langs.retcode10013;
            break;
         case 10014:
            curErr+=langs.retcode10014;
            break;
         case 10015:
            curErr+=langs.retcode10015;
            break;
         case 10016:
            curErr+=langs.retcode10016;
            break;
         case 10017:
            curErr+=langs.retcode10017;
            break;
         case 10018:
            curErr+=langs.retcode10018;
            break;
         case 10019:
            curErr+=langs.retcode10019;
            break;
         case 10020:
            curErr+=langs.retcode10020;
            break;
         case 10021:
            curErr+=langs.retcode10021;
            break;
         case 10022:
            curErr+=langs.retcode10022;
            break;
         case 10023:
            curErr+=langs.retcode10023;
            break;
         case 10024:
            curErr+=langs.retcode10024;
            break;
         case 10025:
            curErr+=langs.retcode10025;
            break;
         case 10026:
            curErr+=langs.retcode10026;
            break;
         case 10027:
            curErr+=langs.retcode10027;
            break;
         case 10028:
            curErr+=langs.retcode10028;
            break;
         case 10029:
            curErr+=langs.retcode10029;
            break;
         case 10030:
            curErr+=langs.retcode10030;
            break;
         case 10031:
            curErr+=langs.retcode10031;
            break;
         case 10032:
            curErr+=langs.retcode10032;
            break;
         case 10033:
            curErr+=langs.retcode10033;
            break;
         case 10034:
            curErr+=langs.retcode10034;
            break;
         case 10035:
            curErr+=langs.retcode10035;
            break;
         case 10036:
            curErr+=langs.retcode10036;
            break;
         case 10038:
            curErr+=langs.retcode10038;
            break;
         case 10039:
            curErr+=langs.retcode10039;
            break;
         case 10040:
            curErr+=langs.retcode10040;
            break;
         case 10041:
            curErr+=langs.retcode10041;
            break;
         case 10042:
            curErr+=langs.retcode10042;
            break;
         case 10043:
            curErr+=langs.retcode10043;
            break;
         case 10044:
            curErr+=langs.retcode10044;
            break;
      }
   }
   
   Alert(curErr);
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
            closeAll();
         }else if( StringFind(sparam, prefix_graph)>=0 ){
            string symname=sparam;
            StringReplace(symname, prefix_graph, "");
            StringReplace(symname, "___", " ");
            
            long newChart=ChartOpen(symname, PERIOD_H1);
            
            if( showLoss && newChart>0 ){
               uint totalHistory=OrdersHistoryTotal();
                  
               string msg="";
               ArrayFree(msg_lines);
            
               double currUntilProfit=0;
               double profitHistory=0;
               for(uint j=0;j<totalHistory;j++){
                  if(OrderSelect(j,SELECT_BY_POS,MODE_HISTORY)==false) continue;
                        
                  if(OrderSymbol()==symname ){
                     profitHistory=OrderProfit();
                     profitHistory+=OrderCommission();
                     profitHistory+=OrderSwap();
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

void closeAll(){
   int cntMyPos=OrdersTotal();
   if(cntMyPos>0){
      for(int ti=cntMyPos-1; ti>=0; ti--){
         if(OrderSelect(ti,SELECT_BY_POS,MODE_TRADES)==false) continue; 
         if( OrderMagicNumber()!=EA_Magic ) continue;
         
         if( OrderType()==OP_BUY ){
            MqlTick latest_price;
            if(!SymbolInfoTick(OrderSymbol(),latest_price)){
               Alert(GetLastError());
               return;
            }
            if(!OrderClose(OrderTicket(), OrderLots(),latest_price.bid,100, clrRed)){
            }
         }else if(OrderType()==OP_SELL){
            MqlTick latest_price;
            if(!SymbolInfoTick(OrderSymbol(),latest_price)){
               Alert(GetLastError());
               return;
            }
            if(!OrderClose(OrderTicket(), OrderLots(),latest_price.ask,100, clrRed)){
            }
         }else{
            if(!OrderDelete(OrderTicket())){
            }
         }
                     
      }
   }
   
   ObjectsDeleteAll(0, prefix_graph);
}


void init_lang(){
   int LANG=1;
   if(LANG>1){
      LANG=0;
   }
   switch(LANG){
      case 0:
         langs.err1="No error, but unknown result. (1)";
         langs.err2="General error (2)";
         langs.err3="Incorrect parameters (3)";
         langs.err4="Trading server is busy (4)";
         langs.err5="Old client terminal version (5)";
         langs.err6="No connection to the trading server (6)";
         langs.err7="Not enough rights (7)";
         langs.err8="Too frequent requests (8)";
         langs.err9="Invalid operation disruptive server operation (9)";
         langs.err64="Account blocked (64)";
         langs.err65="Invalid account number (65)";
         langs.err128="Expired waiting period for the transaction (128)";
         langs.err129="Invalid price (129)";
         langs.err130="Wrong stop loss (130)";
         langs.err131="Wrong volume (131)";
         langs.err132="The market is closed (132)";
         langs.err133="Trade is prohibited (133)";
         langs.err134="Not enough money to complete the transaction. (134)";
         langs.err135="Price changed (135)";
         langs.err136="No prices (136)";
         langs.err137="Broker busy (137)";
         langs.err138="New prices (138)";
         langs.err139="The order is blocked and is already being processed (139)";
         langs.err140="Only purchase allowed (140)";
         langs.err141="Too many requests (141)";
         langs.err145="Modification is prohibited because the order is too close to the market. (145)";
         langs.err146="Trading subsystem is busy (146)";
         langs.err147="Using the expiration date of the order is prohibited by the broker (147)";
         langs.err148="The number of open and pending orders has reached the limit set by the broker (148)";
         langs.err0="An error occurred while running the request";
         langs.retcode="Reason";
         langs.retcode10004="Requote";
         langs.retcode10006="Request rejected";
         langs.retcode10007="Request canceled by trader";
         langs.retcode10010="Only part of the request was completed";
         langs.retcode10011="Request processing error";
         langs.retcode10012="Request canceled by timeout";
         langs.retcode10013="Invalid request";
         langs.retcode10014="Invalid volume in the request";
         langs.retcode10015="Invalid price in the request";
         langs.retcode10016="Invalid stops in the request";
         langs.retcode10017="Trade is disabled";
         langs.retcode10018="Market is closed";
         langs.retcode10019="There is not enough money to complete the request";
         langs.retcode10020="Prices changed";
         langs.retcode10021="There are no quotes to process the request";
         langs.retcode10022="Invalid order expiration date in the request";
         langs.retcode10023="Order state changed";
         langs.retcode10024="Too frequent requests";
         langs.retcode10025="No changes in request";
         langs.retcode10026="Autotrading disabled by server";
         langs.retcode10027="Autotrading disabled by client terminal";
         langs.retcode10028="Request locked for processing";
         langs.retcode10029="Order or position frozen";
         langs.retcode10030="Invalid order filling type";
         langs.retcode10031="No connection with the trade server";
         langs.retcode10032="Operation is allowed only for live accounts";
         langs.retcode10033="The number of pending orders has reached the limit";
         langs.retcode10034="The volume of orders and positions for the symbol has reached the limit";
         langs.retcode10035="Incorrect or prohibited order type";
         langs.retcode10036="Position with the specified POSITION_IDENTIFIER has already been closed";
         langs.retcode10038="A close volume exceeds the current position volume";
         langs.retcode10039="A close order already exists for a specified position";
         langs.retcode10040="Number of open items exceeded";
         langs.retcode10041="The pending order activation request is rejected, the order is canceled";
         langs.retcode10042="Only long positions are allowed";
         langs.retcode10043="Only short positions are allowed";
         langs.retcode10044="Only position closing is allowed";
         break;
      case 1:
         langs.err0="Во время выполнения запроса произошла ошибка";
         langs.err1="Нет ошибки, но результат неизвестен (1)";
         langs.err2="Общая ошибка (2)";
         langs.err3="Неправильные параметры (3)";
         langs.err4="Торговый сервер занят (4)";
         langs.err5="Старая версия клиентского терминала (5)";
         langs.err6="Нет связи с торговым сервером (6)";
         langs.err7="Недостаточно прав (7)";
         langs.err8="Слишком частые запросы (8)";
         langs.err9="Недопустимая операция нарушающая функционирование сервера (9)";
         langs.err64="Счет заблокирован (64)";
         langs.err65="Неправильный номер счета (65)";
         langs.err128="Истек срок ожидания совершения сделки (128)";
         langs.err129="Неправильная цена (129)";
         langs.err130="Неправильные стопы (130)";
         langs.err131="Неправильный объем (131)";
         langs.err132="Рынок закрыт (132)";
         langs.err133="Торговля запрещена (133)";
         langs.err134="Недостаточно денег для совершения операции (134)";
         langs.err135="Цена изменилась (135)";
         langs.err136="Нет цен (136)";
         langs.err137="Брокер занят (137)";
         langs.err138="Новые цены (138)";
         langs.err139="Ордер заблокирован и уже обрабатывается (139)";
         langs.err140="Разрешена только покупка (140)";
         langs.err141="Слишком много запросов (141)";
         langs.err145="Модификация запрещена, так как ордер слишком близок к рынку (145)";
         langs.err146="Подсистема торговли занята (146)";
         langs.err147="Использование даты истечения ордера запрещено брокером (147)";
         langs.err148="Количество открытых и отложенных ордеров достигло предела, установленного брокером (148)";
         langs.retcode="Причина";
         langs.retcode10004="Реквота";
         langs.retcode10006="Запрос отклонен";
         langs.retcode10007="Запрос отменен трейдером";
         langs.retcode10010="Заявка выполнена частично";
         langs.retcode10011="Ошибка обработки запроса";
         langs.retcode10012="Запрос отменен по истечению времени";
         langs.retcode10013="Неправильный запрос";
         langs.retcode10014="Неправильный объем в запросе";
         langs.retcode10015="Неправильная цена в запросе";
         langs.retcode10016="Неправильные стопы в запросе";
         langs.retcode10017="Торговля запрещена";
         langs.retcode10018="Рынок закрыт";
         langs.retcode10019="Нет достаточных денежных средств для выполнения запроса";
         langs.retcode10020="Цены изменились";
         langs.retcode10021="Отсутствуют котировки для обработки запроса";
         langs.retcode10022="Неверная дата истечения ордера в запросе";
         langs.retcode10023="Состояние ордера изменилось";
         langs.retcode10024="Слишком частые запросы";
         langs.retcode10025="В запросе нет изменений";
         langs.retcode10026="Автотрейдинг запрещен сервером";
         langs.retcode10027="Автотрейдинг запрещен клиентским терминалом";
         langs.retcode10028="Запрос заблокирован для обработки";
         langs.retcode10029="Ордер или позиция заморожены";
         langs.retcode10030="Указан неподдерживаемый тип исполнения ордера по остатку ";
         langs.retcode10031="Нет соединения с торговым сервером";
         langs.retcode10032="Операция разрешена только для реальных счетов";
         langs.retcode10033="Достигнут лимит на количество отложенных ордеров";
         langs.retcode10034="Достигнут лимит на объем ордеров и позиций для данного символа";
         langs.retcode10035="Неверный или запрещённый тип ордера";
         langs.retcode10036="Позиция с указанным POSITION_IDENTIFIER уже закрыта";
         langs.retcode10038="Закрываемый объем превышает текущий объем позиции";
         langs.retcode10039="Для указанной позиции уже есть ордер на закрытие";
         langs.retcode10040="Количество открытых позиций превышено";
         langs.retcode10041="Запрос на активацию отложенного ордера отклонен, а сам ордер отменен";
         langs.retcode10042="Разрешены только длинные позиции";
         langs.retcode10043="Разрешены только короткие позиции";
         langs.retcode10044="Разрешено только закрывать существующие позиции";
         break;
   }
   

}
