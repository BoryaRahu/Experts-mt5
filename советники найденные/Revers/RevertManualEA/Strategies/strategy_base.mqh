//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#define SENDME 0
#define mystrateges_core 1

#ifndef mystrateges_no_manual
input string      cmt=""; //Параметры для
#endif
sinput string     delimeter_base_01=""; // --- Открытие позиции
#ifndef mystrateges_no_manual
   input double      Lot=0.01; //Размер лота
#endif
input double      addLot=0; //Размер доп. лота при реверсировке и мартингейле
#ifndef mystrateges_no_manual
   sinput string     forceLongCmt=""; //Открыть сделку в Long с данным комментарием и выйти
   sinput string     forceShortCmt=""; //Открыть сделку в Short с данным комментарием и выйти
   input int         reOpenAfter=0; //Открыть новый ордер через N пунктов в нашу сторону
   input TypeOfStop  TYPE_STOP=point; //Тип стоп лосса
   input double      StopLevel=20; //Стоп лосс
   input TypeOfTake  TYPE_TAKE=point_take; //Тип тейка
   input double      TakeProfit=0; //Тейк-профит
   input bool        goLong=true; //Открывать длинные позиции
   input bool        goShort=true; //Открывать короткие позиции
   input bool        EveryTick=false; //Проверять условия открытия позиции каждый тик
   input bool        SKIP_LESS=false; //Не входить при минимальном стопе
   input double      SYM_STOP=0; //Изменить мин. стоп
   input double      useMyPoint=0; //Использовать данный Point вместо стандартного
#endif
input TypeOfFilling  useORDER_FILLING_RETURN=FOK; //Режим исполнения ордера
sinput string     delimeter_base_02=""; // --- Сопровождение позиции
input TypeOfClose typeClose=reverse; //Действие при стоп лоссе
input TypeOfAdd   typeAdd=geomet; //Тип приращения объема сделки
input int         maxLotMultiplier=8; //Макс. мильтипликатор лота при реверсировке и мартингейле
#ifndef mystrateges_no_manual
   input bool        noOpen=false; // Не открывать первую сделку (только сопровождать)
#endif
input bool     closeAllWarning=true; //Запрашивать подтверждение при нажатии кнопки Закрыть все.

bool isLongYes;
bool isShortYes;
double curLot=0;
bool lastDirectionIsLong;
double symStop;
double myPoint;
double STP,TKP,RA=0;
#ifdef mystrateges_inf_trailing
   double TPV,TPF=0;
#endif
bool IsNewBar;
string accCur="";
bool positionExist;


struct translate{
   string err4752;
   string err4756;
   string err4301;
   string err4302;
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

bool pdxSendOrder(ENUM_TRADE_REQUEST_ACTIONS action, ENUM_ORDER_TYPE type, double price, double sl, double tp, double volume, ulong position=0, string comment="", string sym=""){
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
   
   MqlTradeRequest mrequest;
   MqlTradeResult mresult;
   ZeroMemory(mrequest);
   
   if(type==ORDER_TYPE_BUY){
      lastDirectionIsLong=true;
   }else if(type==ORDER_TYPE_SELL){
      lastDirectionIsLong=false;
   }

   mrequest.action = action;
   mrequest.sl = sl;
   mrequest.tp = tp;
   mrequest.symbol = sym;
   if(position>0){
      mrequest.position = position;
   }
   if(StringLen(comment)){
      mrequest.comment=comment;
   }
   if(action!=TRADE_ACTION_SLTP){
      if(price>0){
         mrequest.price = price;
      }
      if(volume>0){
         mrequest.volume = volume;
      }
      mrequest.type = type;
      mrequest.magic = EA_Magic;
      switch(useORDER_FILLING_RETURN){
         case FOK:
            mrequest.type_filling = ORDER_FILLING_FOK;
            break;
         case RETURN:
            mrequest.type_filling = ORDER_FILLING_RETURN;
            break;
         case IOC:
            mrequest.type_filling = ORDER_FILLING_IOC;
            break;
      }
      mrequest.deviation=100;
   }
   if(OrderSend(mrequest,mresult)){
      if(mresult.retcode==10009 || mresult.retcode==10008){
         if(action!=TRADE_ACTION_SLTP){
            switch(type){
               case ORDER_TYPE_BUY:
                  Alert("Order Buy #:",mresult.order," sl",sl," tp",tp," p",price," !!");
                  break;
               case ORDER_TYPE_SELL:
                  Alert("Order Sell #:",mresult.order," sl",sl," tp",tp," p",price," !!");
                  break;
            }
         }else{
            Alert("Order Modify SL #:",mresult.order," sl",sl," tp",tp," !!");
         }
         if(SENDME){
            SendMail( (string) TimeCurrent() , "YM add SL "+(string) sl+" TP "+(string) tp+" OPEN "+(string) price );
         }
         return true;
      }else{
         msgErr(GetLastError(), mresult.retcode);
      }
   }

   return false;
}
void pdxInitAll(){
   init_lang();
   accCur=AccountInfoString(ACCOUNT_CURRENCY);
}
void pdxInit(){
   myPoint=_Point;
   #ifndef mystrateges_no_manual
      isLongYes=goLong;
      isShortYes=goShort;
      curLot=Lot;
      if(useMyPoint>0){
         myPoint=useMyPoint;
      }
   #endif

   symStop=SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*myPoint;
   #ifndef mystrateges_no_manual
      if(SYM_STOP>0){
         symStop=SYM_STOP*myPoint;
      }
      STP = StopLevel;
      TKP = TakeProfit;
      RA = reOpenAfter;
   #endif
   #ifdef mystrateges_inf_trailing
      TPV = trailingInfValue;
      TPF = trailingInfAfter;
   #endif
   
   if(_Digits==5 || _Digits==3){
      #ifndef mystrateges_no_manual
         if(TYPE_TAKE==point_take){
            TKP*=10;
         }
         if(TYPE_STOP!=percent && TYPE_STOP!=atr){
            STP*=10;
         }
         RA*=10;
      #endif
      #ifdef mystrateges_inf_trailing
         TPV*=10;
         TPF*=10;
      #endif
   }

}
void pdxDeinit(){
   pdxDelStrats();
}
void pdxDelStrats(){
   for( int k=ArraySize(pdxStrats)-1; k>=0; k-- ){
      delete pdxStrats[k];
   }
   ArrayFree(pdxStrats);
}
bool pdxIsNewBar(){
   static datetime Old_Time;
   datetime New_Time[1];

   if(CopyTime(_Symbol,_Period,0,1,New_Time)>0){
      if(Old_Time!=New_Time[0]){
         Old_Time=New_Time[0];
         return true;
      }
   }
   return false;
}
void pdxDelAllOrders(){
   ulong orderTicket;
   int cntMyPosO=OrdersTotal();
   if(cntMyPosO>0){
      for(int ti=cntMyPosO-1; ti>=0; ti--){
         orderTicket=OrderGetTicket(ti);
         if( OrderGetString(ORDER_SYMBOL)!=_Symbol ) continue;
         if( OrderGetInteger(ORDER_MAGIC)!=EA_Magic ) continue;
         
         if( OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_BUY_STOP || OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_BUY_LIMIT ){
            lastDirectionIsLong=false;
         }else{
            lastDirectionIsLong=true;
         }
         
         CTrade Trade;
         Trade.OrderDelete(orderTicket);
      }
   }

}
void pdxDelSingleOrders(){
   ulong orderTicket;
   int cntMyPosO=OrdersTotal();
   int cntMyPos=PositionsTotal();
   bool needDel;
   if(cntMyPosO>0){
      for(int ti=cntMyPosO-1; ti>=0; ti--){
         orderTicket=OrderGetTicket(ti);
         if( OrderGetInteger(ORDER_MAGIC)!=EA_Magic ) continue;
         if( OrderGetString(ORDER_COMMENT)=="1" ) continue;
         
         needDel=true;
         if(cntMyPos>0){
            for(int ti2=cntMyPos-1; ti2>=0; ti2--){
               if( PositionGetSymbol(ti2) != OrderGetString(ORDER_SYMBOL) ) continue;
               if( PositionGetInteger(POSITION_MAGIC)!=EA_Magic ) continue;
               
               needDel=false;
               break;
            }
         }
         if(needDel){
            CTrade Trade;
            Trade.OrderDelete(orderTicket);
         }
      }
   }

}

bool pdxCheckSLandOrders(bool allSymbols=false){
   bool isNo;
   ulong orderTicket;
   bool isTrade=0;
   bool Buy_opened=false;
   bool Sell_opened=false;
   int cntMyPosO=0;
   int cntMyPos=PositionsTotal();
   if(cntMyPos>0){
      double newLot=0;
      double bestPositionBuy=0;
      double bestPositionSell=0;
      double curCur=0;
      double isTake=0;
      for(int ti=cntMyPos-1; ti>=0; ti--){
         string curSymbol=PositionGetSymbol(ti);
         if( !allSymbols && curSymbol!=_Symbol ) continue;
         if( PositionGetInteger(POSITION_MAGIC)!=EA_Magic ) continue;
         
         #ifndef mystrateges_no_manual
            if( StringLen(forceLongCmt) || StringLen(forceShortCmt) ){
               CTrade Trade;
               Trade.PositionClose(PositionGetInteger(POSITION_IDENTIFIER));
               continue;
            }
         #endif
      
         curCur=PositionGetDouble(POSITION_PRICE_CURRENT);
         double curStop=PositionGetDouble(POSITION_SL);
         double curTake=PositionGetDouble(POSITION_TP);
         double curOpen=PositionGetDouble(POSITION_PRICE_OPEN);
         string curComment=PositionGetString(POSITION_COMMENT);
         int curDigits=(int) SymbolInfoInteger(curSymbol, SYMBOL_DIGITS);
         

         switch(typeAdd){
            case geomet:
               newLot=PositionGetDouble(POSITION_VOLUME)*2+addLot;
               break;
            case arifmet:
               newLot=PositionGetDouble(POSITION_VOLUME)+curLot+addLot;
               break;
            case even:
               if( StringToInteger(curComment)%2==0 ){
                  newLot=PositionGetDouble(POSITION_VOLUME)*2+addLot;
               }else{
                  newLot=PositionGetDouble(POSITION_VOLUME)+addLot;
               }
               break;
            case even2:
               if( StringToInteger(curComment)%3==0 ){
                  newLot=PositionGetDouble(POSITION_VOLUME)*2+addLot;
               }else{
                  newLot=PositionGetDouble(POSITION_VOLUME)+addLot;
               }
               break;
            case even3:
               if( StringToInteger(curComment)%4==0 ){
                  newLot=PositionGetDouble(POSITION_VOLUME)*2+addLot;
               }else{
                  newLot=PositionGetDouble(POSITION_VOLUME)+addLot;
               }
               break;
         }
         if(StringLen(curComment)){
            curComment=(string) (StringToInteger(curComment)+1);
         }
         
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY){
            Buy_opened=true;
            isTrade=1;
            
            if(curCur>curOpen && bestPositionBuy<curOpen ){
               bestPositionBuy=curOpen;
            }

            #ifdef mystrateges_inf_trailing
               if( curStop>0 && IsNewBar && TPF>0 && TPV>0){
                  if( curCur>curOpen && (curCur-curOpen)/myPoint > TPF && curStop<curCur - TPV*myPoint ){
                     if(pdxSendOrder(TRADE_ACTION_SLTP, ORDER_TYPE_BUY, 0, curCur - TPV*myPoint, 0, 0, PositionGetInteger(POSITION_IDENTIFIER), "", curSymbol)){
                     }
                  }
               }
            #endif 
            #ifdef mystrateges_manual_trailing
               if(IsNewBar){
                  if( useStep5 && curCur>curOpen+symStop*20 && curStop<NormalizeDouble(curOpen + symStop*trailing5,curDigits) ){
                     if(pdxSendOrder(TRADE_ACTION_SLTP, ORDER_TYPE_BUY, 0, curOpen + symStop*trailing5, curTake + symStop*5, 0, PositionGetInteger(POSITION_IDENTIFIER), "", curSymbol)){
                     }
                  }else if( useStep4 && curCur>curOpen+symStop*17 && curStop<NormalizeDouble(curOpen + symStop*trailing4,curDigits) ){
                     if(pdxSendOrder(TRADE_ACTION_SLTP, ORDER_TYPE_BUY, 0, curOpen + symStop*trailing4, curTake + symStop*10, 0, PositionGetInteger(POSITION_IDENTIFIER), "", curSymbol)){
                     }
                  }else if( useStep3 && curCur>curOpen+symStop*10 && curStop<NormalizeDouble(curOpen + symStop*trailing3,curDigits) ){
                     if(pdxSendOrder(TRADE_ACTION_SLTP, ORDER_TYPE_BUY, 0, curOpen + symStop*trailing3, curTake + symStop*5, 0, PositionGetInteger(POSITION_IDENTIFIER), "", curSymbol)){
                     }
                  }else if( useStep2 && curCur>curOpen+symStop*6 && curStop<NormalizeDouble(curOpen + symStop*trailing2,curDigits) ){
                     if(pdxSendOrder(TRADE_ACTION_SLTP, ORDER_TYPE_BUY, 0, curOpen + symStop*trailing2, curTake + symStop*2.5, 0, PositionGetInteger(POSITION_IDENTIFIER), "", curSymbol)){
                     }
                  }else if( useStep1 && curCur>curOpen+symStop*4 && curStop<NormalizeDouble(curOpen + symStop*trailing1,curDigits) ){
                     if(pdxSendOrder(TRADE_ACTION_SLTP, ORDER_TYPE_BUY, 0, curOpen + symStop*trailing1, curTake + symStop*2.5, 0, PositionGetInteger(POSITION_IDENTIFIER), "", curSymbol)){
                     }
                  }
               }      
            #endif 
                     
            if(curStop>0 && maxLotMultiplier>0 && StringToInteger(curComment)<=maxLotMultiplier ){
               cntMyPosO=OrdersTotal();
               isNo=true;
               if(cntMyPosO>0){
                  for(int tiO=cntMyPosO-1; tiO>=0; tiO--){
                     orderTicket=OrderGetTicket(tiO);
                     if( OrderGetString(ORDER_SYMBOL)!=curSymbol ) continue;
                     if( OrderGetInteger(ORDER_MAGIC)!=EA_Magic ) continue;

                     if( typeClose==reverse && OrderGetInteger(ORDER_TYPE)!=ORDER_TYPE_SELL_STOP ) continue;
                     if( typeClose==martingale && OrderGetInteger(ORDER_TYPE)!=ORDER_TYPE_BUY_LIMIT ) continue;
                     isNo=false;
                     break;
                  }
               }
               if(isNo){
                  #ifndef mystrateges_no_manual
                     if(!TKP || TYPE_STOP==atr ){
                        isTake=(curTake-curOpen)+SymbolInfoInteger(curSymbol,SYMBOL_SPREAD)*myPoint;
                     }else{
                        switch(TYPE_TAKE){
                           case point_take:
                              isTake=TKP*myPoint;
                              break;
                           case multiplier:
                              isTake=(curOpen-curStop)*TKP;
                              break;
                        }
                     }
                  #else 
                     isTake=(curTake-curOpen)+SymbolInfoInteger(curSymbol,SYMBOL_SPREAD)*myPoint;
                  #endif 
                  switch(typeClose){
                     case reverse:
                        if(!pdxSendOrder(TRADE_ACTION_PENDING, ORDER_TYPE_SELL_STOP, curStop, curOpen, curStop-isTake, newLot, 0, curComment, curSymbol)){
                        }
                        break;
                     case martingale:
                        if(!pdxSendOrder(TRADE_ACTION_PENDING, ORDER_TYPE_BUY_LIMIT, curStop, curStop-(curOpen-curStop), curStop+isTake, newLot, 0, curComment, curSymbol)){
                        }
                        break;
                  }
               }
            }
            
         }else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL){
            Sell_opened=true;
            isTrade=1;
            
            if(curCur<curOpen && bestPositionSell>curOpen ){
               bestPositionSell=curOpen;
            }
            
            #ifdef mystrateges_inf_trailing
               if( curStop>0 && IsNewBar && TPF>0 && TPV>0){
                  if(curCur<curOpen && (curOpen-curCur)/myPoint > TPF && curStop>curCur + TPV*myPoint ){
                     if(pdxSendOrder(TRADE_ACTION_SLTP, ORDER_TYPE_BUY, 0, curCur + TPV*myPoint, 0, 0, PositionGetInteger(POSITION_IDENTIFIER), "", curSymbol)){
                     }
                  }
               }
            #endif 

            if(curStop>0 && maxLotMultiplier>0 && StringToInteger(curComment)<=maxLotMultiplier ){
               cntMyPosO=OrdersTotal();
               isNo=true;
               if(cntMyPosO>0){
                  for(int tiO=cntMyPosO-1; tiO>=0; tiO--){
                     orderTicket=OrderGetTicket(tiO);
                     if( OrderGetString(ORDER_SYMBOL)!=curSymbol ) continue;
                     if( OrderGetInteger(ORDER_MAGIC)!=EA_Magic ) continue;
                     if( typeClose==reverse && OrderGetInteger(ORDER_TYPE)!=ORDER_TYPE_BUY_STOP ) continue;
                     if( typeClose==martingale && OrderGetInteger(ORDER_TYPE)!=ORDER_TYPE_SELL_LIMIT ) continue;
                     isNo=false;
                     break;
                  }
               }
               if(isNo){
                  #ifndef mystrateges_no_manual
                     if(!TKP){
                        isTake=(curOpen-curTake)+SymbolInfoInteger(curSymbol,SYMBOL_SPREAD)*myPoint;
                     }else{
                        switch(TYPE_TAKE){
                           case point_take:
                              isTake=TKP*myPoint;
                              break;
                           case multiplier:
                              isTake=(curStop-curOpen)*TKP;
                              break;
                        }
                     }
                  #else 
                     isTake=(curOpen-curTake)+SymbolInfoInteger(curSymbol,SYMBOL_SPREAD)*myPoint;
                  #endif 
                  switch(typeClose){
                     case reverse:
                        if(!pdxSendOrder(TRADE_ACTION_PENDING, ORDER_TYPE_BUY_STOP, curStop, curOpen, curStop+isTake, newLot, 0, curComment, curSymbol)){
                        }
                        break;
                     case martingale:
                        if(!pdxSendOrder(TRADE_ACTION_PENDING, ORDER_TYPE_SELL_LIMIT, curStop, curStop+(curStop-curOpen), curStop-isTake, newLot, 0, curComment, curSymbol)){
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
void pdxStartMainPosition(bool isLong){
   if(!TKP){
      return;
   }
   #ifndef mystrateges_no_manual
      string position_cmt="1";
      
      MqlRates rates[];
      ArraySetAsSeries(rates, true);
      MqlTick latest_price;
      if(!SymbolInfoTick(_Symbol,latest_price)){
         Alert(GetLastError());
         return;
      }
      bool skipMe=false;
      if((isLong && StringLen(forceLongCmt)) || (!isLong && StringLen(forceShortCmt)) ){
         if(isLong && StringLen(forceLongCmt)){
            position_cmt=forceLongCmt;
         }else{
            position_cmt=forceShortCmt;
         }
      }else{
         for( int k=ArraySize(pdxStrats)-1; k>=0; k-- ){
            if( CheckPointer(pdxStrats[k])==POINTER_INVALID ){
               Print("!!!!! Invalid pointer index "+(string) k+" for symbol "+_Symbol);
               SendNotification("!!!!! Invalid pointer index "+(string) k+" for symbol "+_Symbol);
               pdxInitStrats(true);
               Sleep(1000);
            }
            if(!skipMe){
               skipMe=pdxStrats[k].skipMe(isLong);
            }else{
               break;
            }
         }
      }
      if(!skipMe){
         double isTake=0;
         double isStop=0;
         
         double newLot=curLot;
         switch(typeAdd){
            case geomet:
               newLot*=2;
               break;
            case arifmet:
               newLot+=curLot;
               break;
            default:
               break;
         }
         
         
         if(isLong){
            switch(TYPE_STOP){
               case zero:
                  break;
               case point:
                  isStop=latest_price.bid-STP*myPoint;
                  break;
               case percent:
                  isStop=latest_price.bid-latest_price.bid*(STP/100);
                  break;
               case atr:
                  isStop=latest_price.bid-getATR(_Symbol)*(STP/100);
                  break;
               case low1:
                  if(CopyRates(_Symbol, _Period, 0, 2, rates)){
                     isStop=rates[1].low;
                  }
                  break;
               case low2:
                  if(CopyRates(_Symbol, _Period, 0, 3, rates)){
                     isStop=rates[2].low;
                  }
                  break;
            }
            if( isStop>0 && latest_price.bid-isStop < symStop ){
               if(SKIP_LESS){
                  return;
               }else{
                  isStop=latest_price.bid-symStop;
               }
            }
            switch(TYPE_TAKE){
               case point_take:
                  isTake=TKP*myPoint;
                  break;
               case multiplier:
                  isTake=(latest_price.bid-isStop)*TKP;
                  break;
            }
            
            if(!pdxSendOrder(TRADE_ACTION_DEAL, ORDER_TYPE_BUY, latest_price.ask, isStop, latest_price.ask + isTake, curLot,0,position_cmt)){
            }else{
               if(StringLen(position_cmt)){
                  position_cmt=(string) (StringToInteger(position_cmt)+1);
               }
               if(maxLotMultiplier>0){
                  switch(typeClose){
                     case reverse:
                        if(!pdxSendOrder(TRADE_ACTION_PENDING, ORDER_TYPE_SELL_STOP, isStop, latest_price.ask, isStop-isTake, newLot+addLot,0,position_cmt)){
                        }
                        break;
                     case martingale:
                        if(!pdxSendOrder(TRADE_ACTION_PENDING, ORDER_TYPE_BUY_LIMIT, isStop, isStop-(latest_price.ask-isStop), isStop+isTake, newLot+addLot,0,position_cmt)){
                        }
                        break;
                  }
               }
            }
         }else{
            switch(TYPE_STOP){
               case zero:
                  break;
               case point:
                  isStop=latest_price.ask+STP*myPoint;
                  break;
               case percent:
                  isStop=latest_price.ask+latest_price.ask*(STP/100);
                  break;
               case atr:
                  isStop=latest_price.ask+getATR(_Symbol)*(STP/100);
                  break;
               case low1:
                  if(CopyRates(_Symbol, _Period, 0, 2, rates)){
                     isStop=rates[1].high;
                  }
                  break;
               case low2:
                  if(CopyRates(_Symbol, _Period, 0, 3, rates)){
                     isStop=rates[2].high;
                  }
                  break;
            }
            if( isStop>0 && isStop-latest_price.ask < symStop ){
               if(SKIP_LESS){
                  return;
               }else{
                  isStop=latest_price.ask+symStop;
               }
            }
            switch(TYPE_TAKE){
               case point_take:
                  isTake=TKP*myPoint;
                  break;
               case multiplier:
                  isTake=(isStop-latest_price.ask)*TKP;
                  break;
            }
   
            if(!pdxSendOrder(TRADE_ACTION_DEAL, ORDER_TYPE_SELL, latest_price.bid, isStop, latest_price.bid - isTake, curLot,0,position_cmt)){
            }else{
               if(StringLen(position_cmt)){
                  position_cmt=(string) (StringToInteger(position_cmt)+1);
               }
               if(maxLotMultiplier>0){
                  switch(typeClose){
                     case reverse:
                        if(!pdxSendOrder(TRADE_ACTION_PENDING, ORDER_TYPE_BUY_STOP, isStop, isStop - (isStop-latest_price.bid), isStop + isTake, newLot+addLot,0,position_cmt)){
                        }
                        break;
                     case martingale:
                        if(!pdxSendOrder(TRADE_ACTION_PENDING, ORDER_TYPE_SELL_LIMIT, isStop, isStop + (isStop-latest_price.bid), isStop - isTake, newLot+addLot,0,position_cmt)){
                        }
                        break;
                  }
               }
            }
         }
      }
   #endif 
}
void pdxTimer(){
   pdxTickMulti();
}
void pdxTickMulti(){
   pdxCheckSLandOrders(true);
   pdxDelSingleOrders();
}
void pdxTick(){
   #ifndef mystrateges_no_manual
      commentUpdate();
      if( StringLen(forceLongCmt) || StringLen(forceShortCmt) ){
         IsNewBar=true;
      }else{
         IsNewBar=pdxIsNewBar();
      }
      if(!IsNewBar && !EveryTick){
         return;
      }
   #else 
      IsNewBar=pdxIsNewBar();
   #endif 
   
   if(pdxCheckSLandOrders()){
      return;
   }
   for( int k=ArraySize(pdxStrats)-1; k>=0; k-- ){
      if( CheckPointer(pdxStrats[k])==POINTER_INVALID ){
         Print("!!!!! Invalid pointer index "+(string) k+" for symbol "+_Symbol);
         SendNotification("!!!!! Invalid pointer index "+(string) k+" for symbol "+_Symbol);
         pdxInitStrats(true);
         Sleep(1000);
      }
      pdxStrats[k].data();
   }
   pdxDelAllOrders();
   #ifndef mystrateges_no_manual   
      if( noOpen && !StringLen(forceLongCmt) && !StringLen(forceShortCmt) ){
         return;
      }
      
      if(StringLen(forceLongCmt)){
         isLongYes=true;
      }else if(StringLen(forceShortCmt)){
         isLongYes=false;
      }
      if(isLongYes){
         pdxStartMainPosition(true);
      }
      if(StringLen(forceShortCmt)){
         isShortYes=true;
      }else if(StringLen(forceLongCmt)){
         isShortYes=false;
      }
      if(isShortYes){
         pdxStartMainPosition(false);
      }
      if( StringLen(forceLongCmt) || StringLen(forceShortCmt) ){
         ExpertRemove();
      }
   #else 
      return;
   #endif 
}
void commentUpdate(){
   #ifndef mystrateges_no_manual
      string msg;
      string step="";

      double tmpProfit=0;
      int cntMyPos=PositionsTotal();
      positionExist=false;
      if(cntMyPos>0){
         for(int ti=cntMyPos-1; ti>=0; ti--){
            string curSymbol=PositionGetSymbol(ti);
            if( PositionGetInteger(POSITION_MAGIC)!=EA_Magic ) continue;
            if( curSymbol!=_Symbol ) continue;
            positionExist=true;
            break;
         }
         if(positionExist){
            if(ObjectFind(0, prefix_graph+"del")<0){
               createObjectFirst(prefix_graph+"del", 153, "Закрыть");
            }
         }
         for(int ti=cntMyPos-1; ti>=0; ti--){
            string curSymbol=PositionGetSymbol(ti);
            if( PositionGetInteger(POSITION_MAGIC)!=EA_Magic ) continue;
            if( curSymbol!=_Symbol ) continue;
            
            double curProfit=PositionGetDouble(POSITION_PROFIT);
            curProfit+=PositionGetDouble(POSITION_SWAP);
            StringAdd(step, " ("+PositionGetString(POSITION_COMMENT)+")");
            
            tmpProfit+=curProfit;
         }
      }
      if(!positionExist){
         if( ObjectFind(0, prefix_graph+"del")>=0 ){
            ObjectsDeleteAll(0, prefix_graph);
         }
      }else{
         if(tmpProfit!=0){
            ObjectSetString(0,prefix_graph+"del",OBJPROP_TEXT,"Закрыть ("+DoubleToString(tmpProfit, 2)+" "+accCur+")");
         }else{
            ObjectSetString(0,prefix_graph+"del",OBJPROP_TEXT,"Закрыть");
         }
      }
            
      StringAdd(msg, cmt+step);
      
      Comment(msg);
   #endif
}

void msgErr(int err, int retcode=0){
   string curErr="";
   switch(err){
      case 4752:
         curErr=langs.err4752;
         break;
      case 4756:
         curErr=langs.err4756;
         break;
      case 4301:
         curErr=langs.err4301;
         break;
      case 4302:
         curErr=langs.err4302;
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
void createObject(string name, int weight, string title){
   if(ObjectFind(0, name)<0){
      long offset= ChartGetInteger(0, CHART_WIDTH_IN_PIXELS)-87;
      long offsetY=0;
      for(int ti=0; ti<ObjectsTotal(0); ti++){
         string objName= ObjectName(0, ti);
         if( StringFind(objName, prefix_graph)<0 ){
            continue;
         }
         long tmpOffset=ObjectGetInteger(0, objName, OBJPROP_YDISTANCE);
         if( tmpOffset>offsetY){
            offsetY=tmpOffset;
         }
      }
      
      for(int ti=0; ti<ObjectsTotal(0); ti++){
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
     ObjectSetInteger(0,name,OBJPROP_YSIZE,25); 
     ChartRedraw(0);
  }else{
     ObjectSetString(0,name,OBJPROP_TEXT, title);
  }
  ObjectSetInteger(0,name,OBJPROP_BGCOLOR, clrLightGray);
}
void createObjectFirst(string name, int weight, string title){
   if(ObjectFind(0, name)<0){
     ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
     ObjectSetInteger(0,name,OBJPROP_XDISTANCE,111); 
     ObjectSetInteger(0,name,OBJPROP_YDISTANCE,0); 
     ObjectSetString(0,name,OBJPROP_TEXT, title); 
     ObjectSetInteger(0,name,OBJPROP_XSIZE,weight); 
     ObjectSetInteger(0,name,OBJPROP_FONTSIZE, 8);
     ObjectSetInteger(0,name,OBJPROP_YSIZE,25); 
     ChartRedraw(0);
  }else{
     ObjectSetString(0,name,OBJPROP_TEXT, title);
  }
  ObjectSetInteger(0,name,OBJPROP_BGCOLOR, clrLightGray);
}
void closeOne(string symb){
   int cntMyPos=PositionsTotal();
   if(cntMyPos>0){
      for(int ti=cntMyPos-1; ti>=0; ti--){
         string curSymbol=PositionGetSymbol(ti);
         if( PositionGetInteger(POSITION_MAGIC)!=EA_Magic ) continue;
         if( curSymbol != symb ) continue;
                     
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
         if( OrderGetString(ORDER_SYMBOL)!=symb ) continue;
                     
         CTrade Trade;
         Trade.OrderDelete(orderTicket);
      }
   }
   
   ObjectsDeleteAll(0, prefix_graph);
}
double getATR(string name){
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   double atr=0;
   double pre_atr=0;
   int count=0;
   
   // получаем данные о барах за последние 7 дней
   //(с избытком, так как ATR будем считать за 5 дней)
   int copied=CopyRates(name, PERIOD_D1, 0, 7, rates);
   
   // определяем ATR за последние 7 дней без учета
   // слишком больших и слишком маленьких баров
   if(copied>=5){
      for(int j=1; j<copied; j++){
         pre_atr+=rates[j].high-rates[j].low;
      }
      pre_atr/=(copied-1);
   }
   
   //определяем ATR за последние 5 дней или менее с учетом
   // слишком больших и слишком маленьких баров
   // то есть, бары размером более 1.5 ATR за 7 дней
   // и бары размером менее 0.3 ATR за 7 дней
   // отбрасываются
   if(pre_atr>0){
      for(int j=1; j<copied; j++){
         if( rates[j].high-rates[j].low > pre_atr*1.5 ) continue;
         if( rates[j].high-rates[j].low < pre_atr*0.3 ) continue;
               
         if( ++count > 5 ){
            count=5;
            break;
         }
               
         atr+=rates[j].high-rates[j].low;
      }
      // баров среднего размера очень мало
      // поэтому считаем обычный ATR 5
      if(count<2){
         count=0;
         for(int j=1; j<=5; j++){
            ++count;
            atr+=rates[j].high-rates[j].low;
         }
      }
      atr= NormalizeDouble(atr/count, _Digits);
   }
         
   return atr;
}

void init_lang(){
   int LANG=1;
   if(LANG>1){
      LANG=0;
   }
   switch(LANG){
      case 0:
         langs.err4752="Automatic trading for an expert is prohibited (4752).";
         langs.err4756="Failed to send trade request (4756).";
         langs.err4301="Unknown symbol (4301).";
         langs.err4302="The symbol is not selected in MarketWatch (4302).";
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
         langs.err4752="Автоматический трейдинг для эксперта отключен (4752).";
         langs.err4756="Не удалось отправить запрос (4756).";
         langs.err4301="Неизвестный символ (4301).";
         langs.err0="Во время выполнения запроса произошла ошибка";
         langs.err4302="Данный символ не выбран в MarketWatch (4302).";
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
