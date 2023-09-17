//+------------------------------------------------------------------+
//|                                      ExpMartin_v5 - трал с бу.mq4 
//|      переворотный мартин SL (канал переворота), ТР, производится перевод в бу на размер СЛ + Not_Loss (ЖАДНОСТЬ) в пипсах пятизнак
//       далее тралы: простой, по теням свечей, АТР, ФРАКТАЛ, МА - разместить в маркете
//+------------------------------------------------------------------+
#property copyright "Copyright 14 декабря 2020, ROMANBEST"
#property link      "http://www.metaquotes.net"
//----

extern string TF = " Торговый ТФ и время ";
extern ENUM_TIMEFRAMES timeframe_BARS = 5;
// время торгов, заканчивает работу в 22, то есть в 22 часа и после советник не выставляет новых ордеров и ждет рабочего времени - 2 часа
extern bool Use_Time=true;
extern int HourStart=8; // время начала работы советника в часах по времени терминала - может быть от 0 до 23
extern int HourEnd=22; // время окончания работы советника в часах по времени терминала
extern int MinStart =30;
extern int MinEnd   =40;

extern string АТР = " Period_ATR на D1 ";
// если юзать АТР, то СЛ и ТР делать -1
extern int    Period_ATR   = 14;  // период_АТР, делать -1 при конкретном использовании СЛ и ТР (уровень ограничения убытков)
extern int    Percent_ATR  = 30;  // Percent_ATR, делать -1 при использовании СЛ и ТР (процент в настоящих процентах - дневного расчетного диапазона по АТР)
extern double k=1.0;              // и фиксации прибыли  ТР=к*СЛ

extern string мартин_и_тралы = " параметры мартина и трала ";
extern double       Lots  =0.01;    //стартовый лот
extern double     Factor  =2.0;     //множитель лота
extern int         Limit  =55;      //ограничение количества умножений лота
extern int      StopLoss  =270,     //CЛ, если на АТР, то делать -1
                TakeProfit=540;     // ТР, если на АТР, то делать -1 
extern int    TrailingStop=60;      //ТРАЛЛ простой - если 0, то тралл по теням свечей 
extern int    Not_Loss    =50;      //цена (ЖАДНОСТЬ) перевода в бу  от цены открытия
extern int     SPREAD_MAX =50;      //размер спреда для стоп-торгов
extern int     StartType  =0;       //тип стартового ордера, 0-BUY, 1-SELL
extern int         Magic  =10;      //индивидуальный номер эксперта
//----
double lots_step;
static datetime prevtime = 0, prevtime_tral = 0;       // по ценам открытия
//----
int ticket_buy;
int ticket_sell;
int lots_digits;

double MINLOT,MAXLOT;


double Lots_New;                    // Количество лотов для новых ордеров

double vpoint;
int vdigits;
double Dig;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
  
   string Symb   =Symbol();                    // Финансовый инструм.
   double One_Lot=MarketInfo(Symb,MODE_MARGINREQUIRED);//Стоим. 1 лота
   double Min_Lot=MarketInfo(Symb,MODE_MINLOT);// Мин. размер. лотов
   double Max_Lot =MarketInfo(Symbol(),MODE_MAXLOT);
   double Step   =MarketInfo(Symb,MODE_LOTSTEP);//Шаг изменен размера
   double LotVal =MarketInfo(Symbol(),MODE_TICKVALUE);//стоимость 1 пункта для 1 лота
   if (_Digits == 5) Dig = 100000;
    if (_Digits == 3) Dig = 1000;
   if (_Digits == 4 || _Digits == 2) Dig = 10000;
   
   MINLOT = MarketInfo(Symbol(),MODE_MINLOT);
   MAXLOT = MarketInfo(Symbol(),MODE_MAXLOT);  
   //double vbid    = MarketInfo(Symbol(),MODE_BID); 
   //double vask    = MarketInfo(Symbol(),MODE_ASK); 
   vpoint  = MarketInfo(Symbol(),MODE_POINT); 
   vdigits = (int)MarketInfo(Symbol(),MODE_DIGITS); 
   int    vspread = (int)MarketInfo(Symbol(),MODE_SPREAD);
   int    STOPLEVEL = (int)MarketInfo(Symbol(),MODE_STOPLEVEL); 
   ticket_buy=-1;
   ticket_sell=-1;
//----
   lots_step=MarketInfo(Symbol(),MODE_LOTSTEP);
//----
   if(lots_step==0.01)
      lots_digits=2;
//----
   if(lots_step==0.1)
      lots_digits=1;
//----
   if(lots_step==1.0)
      lots_digits=0;
//----
   for(int pos=OrdersTotal()-1;pos>=0;pos--)
      if(OrderSelect(pos,SELECT_BY_POS)==true)
         if(OrderMagicNumber()==Magic)
            if(OrderSymbol()==Symbol())
              {
               if(OrderType()==OP_BUY)
                 {
                  ticket_buy=OrderTicket();
                  break;
                 }
               //----
               if(OrderType()==OP_SELL)
                 {
                  ticket_sell=OrderTicket();
                  break;
                 }
              }
              
              
   Print(" vpoint = ", vpoint," vdigits = ", vdigits); 
   Print(" MAXLOT = ", MAXLOT," MINLOT = ", MINLOT); 
   Print(" spread = ", vspread," STOPLEVEL = ", STOPLEVEL); 
   //   ---  РАСЧЕТ  ПЕРЕВОРОТНОГО КАНАЛА (SL) в пипсах размеров СЛ, ТР  ---
//- для всех символов 
 if (Percent_ATR > 0 && Period_ATR > 0)
  {  
   Print(" канал SL равен ", NormalizeDouble(Percent_ATR*(iATR(_Symbol,PERIOD_D1,Period_ATR,0)*Dig)/100,0),
         " TP = ", NormalizeDouble(Percent_ATR*(iATR(_Symbol,PERIOD_D1,Period_ATR,0)*Dig)/100*k,0)); 
 //  Print(" MarketInfo(Symbol(),MODE_STOPLEVEL) = ",  MarketInfo(Symbol(),MODE_STOPLEVEL), 
 //        " MarketInfo(Symbol(),MODE_SPREAD) = ", MarketInfo(Symbol(),MODE_SPREAD));   
  }
  
                 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {return(0);}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
  
   //---
   double SL, TP, price;
   double lots;
   double lots_test;
//----
   int slip;
   int ticket;
   int pos;
//----
   bool res;
   
 // ограничение входа при большой спреде 
    if (MarketInfo(Symbol(),MODE_SPREAD) > SPREAD_MAX)
      {
       Print ("спред большой не закрываем = ", MarketInfo(Symbol(),MODE_SPREAD));
       return(0); // при не НОРМАЛЬНОМ СПРЕДЕ НЕ ИГРАЕМ
      } 

 /*     // ограничение входа при превышении количества переворотов 
    if (STOP_LOSS(Magic) > Limit)
      {
       Print (" превышение кол-ва переворотов на ", Symbol(), " не торгуем с магиком = ", STOP_LOSS(Magic) );
       return(0); 
      } 
*/    

//   ---  РАСЧЕТ  ПЕРЕВОРОТНОГО КАНАЛА (SL) в пипсах размеров СЛ, ТР  ---
//- для всех символов 
 if (Percent_ATR > 0 && Period_ATR > 0)
  { 
   SL=NormalizeDouble(Percent_ATR*(iATR(_Symbol,PERIOD_D1,Period_ATR,0)*Dig)/100,0);   
   TP=NormalizeDouble(SL*k,0);
   Print(" канал SL равен ",SL," TP = ", TP); 
 //  Print(" MarketInfo(Symbol(),MODE_STOPLEVEL) = ",  MarketInfo(Symbol(),MODE_STOPLEVEL), 
 //        " MarketInfo(Symbol(),MODE_SPREAD) = ", MarketInfo(Symbol(),MODE_SPREAD));   
  }
  
//----обслуживание виртуальных стопов ордера BUY (перевод в бу, трал и закрытие)
   if(ticket_buy>0)
      if(OrderSelect(ticket_buy,SELECT_BY_TICKET)==true)
         if(OrderCloseTime()==0)
          { 
        //    Print(" OrderTicket() = ", OrderTicket()); 
           // ПЕРВАЯ МОДИФИКАЦИЯ -  перевод в бу ЯВНОМ StopLoss и  TakeProfit
         if (StopLoss > 0 && TakeProfit > 0 && Percent_ATR <= 0 && Period_ATR <= 0) 
           if(OrderOpenPrice()+StopLoss*Point + Not_Loss*Point + MarketInfo(Symbol(),MODE_STOPLEVEL)*Point + 2*MarketInfo(Symbol(),MODE_SPREAD)*Point
             <=MarketInfo(Symbol(),MODE_BID)&& OrderStopLoss() == 0)
              {
               price=MarketInfo(Symbol(),MODE_BID);
               slip=MarketInfo(Symbol(),MODE_SPREAD)*2;
              // return(OrderClose(ticket_buy,OrderLots(),price,slip,Blue)); ЗДЕСЬ МОДИФИКАЦИЯ В БУ
               res=OrderModify(OrderTicket(),OrderOpenPrice(), NormalizeDouble (OrderOpenPrice() + StopLoss*Point + Not_Loss*Point,Digits),
                               NormalizeDouble (OrderOpenPrice()+ StopLoss*Point + Not_Loss*Point + TakeProfit*Point,Digits),
                               0,clrGold);              
             //  (Bid-Point*Not_Loss,Digits),OrderTakeProfit(),0,clrGold); 
               if(!res) 
                 Print("Ошибка перевода в бу бай ордера. Код ошибки = ",GetLastError()); 
               else 
                 Print("Цена Stop Loss бай ордера ордера успешно переведена в бу."); 
              }               
      
       // ПЕРЕВОД В БУ при Percent_ATR и  Period_ATR
        if (Percent_ATR > 0 && Period_ATR > 0 && StopLoss <= 0 && TakeProfit <= 0)         
         if(OrderOpenPrice()+SL*Point + Not_Loss*Point + MarketInfo(Symbol(),MODE_STOPLEVEL)*Point + 2*MarketInfo(Symbol(),MODE_SPREAD)*Point
             <=MarketInfo(Symbol(),MODE_BID)&& OrderStopLoss() == 0)
              {
               price=MarketInfo(Symbol(),MODE_BID);
               slip=MarketInfo(Symbol(),MODE_SPREAD)*2;
              // return(OrderClose(ticket_buy,OrderLots(),price,slip,Blue)); ЗДЕСЬ МОДИФИКАЦИЯ В БУ
               res=OrderModify(OrderTicket(),OrderOpenPrice(), NormalizeDouble (OrderOpenPrice() + SL*Point + Not_Loss*Point,Digits),
                               NormalizeDouble (OrderOpenPrice() + SL*Point + Not_Loss*Point + TP*Point,Digits),
                               0,clrGold);              
             //  (Bid-Point*Not_Loss,Digits),OrderTakeProfit(),0,clrGold); 
               if(!res) 
                 Print("Ошибка перевода в бу бай ордера. Код ошибки=",GetLastError()); 
               else 
                 Print("Цена Stop Loss бай ордера ордера успешно переведена в бу."); 
              } 
              
              
//--- модифицирует цену Stop Loss бай ордера на покупку  
 if (OrderStopLoss() > 0 && TrailingStop > 0) // если уже переведен в бу
   //if(TrailingStop>0) //  при простом трале
     { 
      
      if(Bid-OrderOpenPrice()>Point*TrailingStop)// && OrderStopLoss() > 0) 
        { 
         if(OrderStopLoss()<Bid-Point*TrailingStop) 
           { 
            res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid-Point*TrailingStop,Digits),OrderTakeProfit(),0,clrGold); 
            if(!res) 
               Print("Ошибка модификации бай ордера. Код ошибки=",GetLastError()); 
            else 
               Print("Цена Stop Loss бай ордера ордера успешно модифицирована."); 
           } 
        } 
      } 
  
 // ТРАЛ ПО ТЕНЯМ СВЕЧЕЙ 
  if (OrderStopLoss() > 0 && TrailingStop == 0) // если уже переведен в бу // по теням свечей void TrailingByShadows(int ticket,int tmfrm,int bars_n, int indent,bool trlinloss=false)
     {
        //if (OrderStopLoss() <= OrderOpenPrice() )  
        if(iTime(Symbol(),PERIOD_M1,0) == prevtime_tral) return(0);         //ждем нового бара на signal_period
          { 
           prevtime_tral = iTime(Symbol(),PERIOD_M1,0);                    //если появился новый бар, включаемся 
          // Print("OrderStopLoss() buy = ", OrderStopLoss()); 
           TrailingByShadows(OrderTicket(), 1, 1, 0, false);   
          } 
     } 
 }
    
    
              
              
//----   ЗАКРЫТИЕ BUY   ---------------
   if(ticket_buy>0)
      if(OrderSelect(ticket_buy,SELECT_BY_TICKET)==true)
       {
         //Print(" 1. Закрытие бай, канал SL равен ",SL," TP = ", TP); 
        // ЗАКРЫТИЕ ПРИ ЯВНОМ ИСПОЛЬЗОВАНИИ STOP_LOSSA
        if (StopLoss > 0 && Percent_ATR <= 0 && Period_ATR <= 0) 
         if(OrderOpenPrice()-StopLoss*Point>=MarketInfo(Symbol(),MODE_BID))
            if(OrderCloseTime()==0)
              {
               price=MarketInfo(Symbol(),MODE_BID);
               slip=MarketInfo(Symbol(),MODE_SPREAD)*2;
               return(OrderClose(ticket_buy,OrderLots(),price,slip,clrGray));         
              }
       // ЗАКРЫТИЕ ПРИ ИСПОЛЬЗОВАНИИ КАНАЛА ОТ АТР    
        if (Percent_ATR > 0 && Period_ATR > 0 && StopLoss <= 0) 
         if(OrderOpenPrice()-SL*Point>=MarketInfo(Symbol(),MODE_BID))
         
           
            if(OrderCloseTime()==0)
              {
               Print("Закрытие бай, канал SL равен ",SL," TP = ", TP);
               price=MarketInfo(Symbol(),MODE_BID);
               slip=MarketInfo(Symbol(),MODE_SPREAD)*2;
               return(OrderClose(ticket_buy,OrderLots(),price,slip,clrGray));         
              }     
              
       }        
//----





//----обслуживание виртуальных стопов ордера SELL (перевод в бу, трал и закрытие)
 //  if(ticket_sell>0)
 //   { 
 //     Print(" ticket_sell: ", ticket_sell);
 //     Print("  MarketInfo(Symbol(),MODE_STOPLEVEL): ",  MarketInfo(Symbol(),MODE_STOPLEVEL));
 //     Print("  MarketInfo(Symbol(),MODE_SPREAD): ",  MarketInfo(Symbol(),MODE_SPREAD));
  //  }
      
       
   if(ticket_sell>0)
      if(OrderSelect(ticket_sell,SELECT_BY_TICKET)==true)
         if(OrderCloseTime()==0)
          {
           // ПЕРВАЯ МОДИФИКАЦИЯ -  перевод в бу
           if (StopLoss > 0 && TakeProfit > 0 && Percent_ATR <= 0 && Period_ATR <= 0) 
            if(OrderOpenPrice()-StopLoss*Point - Not_Loss*Point - MarketInfo(Symbol(),MODE_STOPLEVEL)*Point - 2*MarketInfo(Symbol(),MODE_SPREAD)*Point>=
               MarketInfo(Symbol(),MODE_ASK) && OrderStopLoss() == 0)
              {
               price=MarketInfo(Symbol(),MODE_ASK);
               slip=MarketInfo(Symbol(),MODE_SPREAD)*2;
              // return(OrderClose(ticket_sell,OrderLots(),price,slip,Red));
               Print(" ticket_sell: ", ticket_sell); 
               Print(" цена переноса в БУ селл ордера: ",NormalizeDouble(OrderOpenPrice() - StopLoss*Point - Not_Loss*Point,Digits)); 
               res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(OrderOpenPrice() - StopLoss*Point - Not_Loss*Point,Digits),
                                 NormalizeDouble (OrderOpenPrice()  - StopLoss*Point - Not_Loss*Point - TakeProfit*Point,Digits)
                                 ,0,clrLightSalmon);
              // (Ask+Point*Not_Loss,Digits),OrderTakeProfit(),0,clrLightSalmon); 
               if(!res) 
                 Print("Ошибка переноса в БУ селл ордера. Код ошибки = ",GetLastError()); 
               else 
                 Print("Цена Stop Loss селл ПОЗИЦИИ переведена в бу "); 
              } 
             
          // ПЕРЕВОД В БУ при Percent_ATR и  Period_ATR
          if (Percent_ATR > 0 && Period_ATR > 0 && StopLoss <= 0 && TakeProfit <= 0)   
            if(OrderOpenPrice() - SL*Point - Not_Loss*Point - MarketInfo(Symbol(),MODE_STOPLEVEL)*Point - 2*MarketInfo(Symbol(),MODE_SPREAD)*Point >=
                MarketInfo(Symbol(),MODE_ASK) && OrderStopLoss() == 0)
              {
               price=MarketInfo(Symbol(),MODE_ASK);
               slip=MarketInfo(Symbol(),MODE_SPREAD)*2;
              // return(OrderClose(ticket_buy,OrderLots(),price,slip,Blue)); ЗДЕСЬ МОДИФИКАЦИЯ В БУ
               res=OrderModify(OrderTicket(),OrderOpenPrice(), NormalizeDouble (OrderOpenPrice() - SL*Point - Not_Loss*Point,Digits),
                               NormalizeDouble (OrderOpenPrice() - SL*Point - Not_Loss*Point - TP*Point,Digits),
                               0,clrLightSalmon);              
             //  (Bid-Point*Not_Loss,Digits),OrderTakeProfit(),0,clrGold); 
               if(!res) 
                 Print("Ошибка перевода в бу SELL ПОЗИЦИИ. Код ошибки=",GetLastError()); 
               else 
                 Print("Цена Stop Loss СЕЛЛ ПОЗИЦИИ успешно переведена в бу."); 
              }                 
              
              
              
           //ПОСЛЕДУЮЩИЕ модифи цен Stop Loss селл ордера   
  if (OrderStopLoss() > 0 && TrailingStop > 0) // если уже переведен в бу         
 //  if(TrailingStop>0) 
     { 
      
      if(OrderOpenPrice()-Ask > Point*TrailingStop) // && OrderStopLoss() > 0) 
        { 
         if(OrderStopLoss()>Ask+Point*TrailingStop) 
           { 
            res=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Ask+Point*TrailingStop,Digits),OrderTakeProfit(),0,clrLightSalmon); 
            if(!res) 
               Print("Ошибка модификации селл ордера. Код ошибки = ",GetLastError()); 
            else 
               Print("Цена Stop Loss sell ордера ордера успешно модифицирована."); 
           } 
        } 
      } 
   if (OrderStopLoss() > 0 && TrailingStop == 0)              // по теням свечей  void TrailingByShadows(int ticket,int tmfrm,int bars_n, int indent,bool trlinloss=false)
     { 
      //if (OrderStopLoss() > 0)        
        if(iTime(Symbol(),PERIOD_M1,0) == prevtime_tral) return(0);          //ждем нового бара на signal_period
          { 
           prevtime_tral = iTime(Symbol(),PERIOD_M1,0);                      //если появился новый бар, включаемся 
         //  Print("OrderStopLoss() sell = ", OrderStopLoss());
           TrailingByShadows(OrderTicket(), 1, 1, 0, false);   
          }      
     }     
   }
//----
   if(ticket_sell>0)
      if(OrderSelect(ticket_sell,SELECT_BY_TICKET)==true)
        {
      // ЗАКРЫТИЕ ПРИ ЯВНОМ ИСПОЛЬЗОВАНИИ STOP_LOSSA
        if (StopLoss > 0 && Percent_ATR <= 0 && Period_ATR <= 0) 
         if(OrderCloseTime()==0)
            if(OrderOpenPrice()+StopLoss*Point<=MarketInfo(Symbol(),MODE_ASK))
              {
               price=MarketInfo(Symbol(),MODE_ASK);
               slip=MarketInfo(Symbol(),MODE_SPREAD)*2;
               return(OrderClose(ticket_sell,OrderLots(),price,slip,clrGray));
              }
              
      // ЗАКРЫТИЕ ПРИ ИСПОЛЬЗОВАНИИ КАНАЛА ОТ АТР    
        if (Percent_ATR > 0 && Period_ATR > 0 && StopLoss <= 0) 
          if(OrderCloseTime()==0)
            if(OrderOpenPrice() + SL*Point <= MarketInfo(Symbol(),MODE_ASK))
              {
               Print("Закрытие sell, канал SL равен ",SL," TP = ", TP);
               price=MarketInfo(Symbol(),MODE_ASK);
               slip=MarketInfo(Symbol(),MODE_SPREAD)*2;
               return(OrderClose(ticket_sell,OrderLots(),price,slip,clrGray));
              }          
          }              
              
//----


//__Время и условия работы________
//  ограничение входа в рынок по времени 
   bool time_trade=false;
   if(Use_Time==false) {time_trade=true;}
  // if(Use_Time==true && Hour()>=HourStart && Hour()<HourEnd) {time_trade=true;}
   
 // ограничение входа при большой спреде 
    if (MarketInfo(Symbol(),MODE_SPREAD) > SPREAD_MAX)
      {
       Print ("спред большой не входим = ", MarketInfo(Symbol(),MODE_SPREAD));
       return(0); // при не НОРМАЛЬНОМ СПРЕДЕ НЕ ИГРАЕМ
      }   
   
//     if(iTime(Symbol(),PERIOD_M1,0) == prevtime) return(0);          //ждем нового бара на signal_period
//     prevtime = iTime(Symbol(),PERIOD_M1,0);                    //если появился новый бар, включаемся 

//----открыть стартовый ордер BUY
  if(Use_Time==true && Hour()>=HourStart && Minute() >= MinStart && Minute() <= MinEnd && Hour() < HourEnd) {time_trade=true;}
   if(StartType==0 && time_trade==true)
      if(ticket_buy<0)
         if(ticket_sell<0)
           {
            if (MarketInfo(Symbol(),MODE_SPREAD) > SPREAD_MAX) return(0); // при не НОРМАЛЬНОМ СПРЕДЕ НЕ ИГРАЕМ
            
            ticket=OpenBuy(Lots);
            //----
            if(ticket>0)
               ticket_buy=ticket;
           }
//----
time_trade=false;
//----открыть НОВЫЙ ордер BUY при профите ордера BUY
  if(Use_Time==true && Hour()>=HourStart && Minute() >= MinStart && Minute() <= MinEnd && Hour() < HourEnd) {time_trade=true;}
   if(ticket_buy>0 && time_trade==true)
      if(ticket_sell<0)
         if(OrderSelect(ticket_buy,SELECT_BY_TICKET)==true)
            if(OrderCloseTime()>0)
               if(OrderProfit() + OrderSwap() + OrderCommission() > 0.0)
                 {
                  if (MarketInfo(Symbol(),MODE_SPREAD) > SPREAD_MAX) return(0); // при не НОРМАЛЬНОМ СПРЕДЕ НЕ ИГРАЕМ
            if (DistMarketAndPos(Symbol(),-1,-1) < 40) 
              {
                Print (" ближайшая позиция меньше 40 пипсов - не входим = ", DistMarketAndPos(Symbol(),-1,-1));
                return (0);
              }  
                  ticket=OpenBuy(Lots);
                  //----
                  if(ticket>0)
                     ticket_buy=ticket;
                 }
//----


time_trade=false;


//----открыть НОВЫЙ ордер SELL при лоссе прошлой позиции BUY
  if(Use_Time==true && Hour()>=HourStart && Hour() < HourEnd) {time_trade=true;}
   if(ticket_buy>0 && time_trade==true)
      if(ticket_sell<0)
         if(OrderSelect(ticket_buy,SELECT_BY_TICKET)==true)
            if(OrderCloseTime()>0)
               if(OrderProfit() + OrderSwap() + OrderCommission() <0.0)
                 {
                  lots=NormalizeDouble(MathCeil((OrderLots()*Factor)/lots_step)*lots_step,lots_digits);
                  lots_test=Lots;
                  //----
                  for(pos=0;pos<Limit;pos++)
                     lots_test=NormalizeDouble(MathCeil((lots_test*Factor)/lots_step)*lots_step,lots_digits);
                  //----
                  if(lots_test<lots)
                     lots=Lots;
                  //----
                  if (MarketInfo(Symbol(),MODE_SPREAD) > SPREAD_MAX) return(0); // при не НОРМАЛЬНОМ СПРЕДЕ НЕ ИГРАЕМ
                  ticket=OpenSell(lots);
                  //----
                  if(ticket>0)
                    {
                     ticket_sell=ticket;
                     ticket_buy=-1;
                    }
                 }
//----




time_trade=false;

//----открыть стартовый ордер SELL
  if(Use_Time==true && Hour()>=HourStart && Minute() >= MinStart && Minute() <= MinEnd && Hour() < HourEnd) {time_trade=true;}
   if(StartType==1 && time_trade==true)
      if(ticket_buy<0)
         if(ticket_sell<0)
           {
            ticket=OpenSell(Lots);
            //----
            if(ticket>0)
               ticket_sell=ticket;
           }
//----

time_trade=false;
//----открыть НОВЫЙ ордер SELL при профите ордера SELL
  if(Use_Time==true && Hour()>=HourStart && Minute() >= MinStart && Minute() <= MinEnd && Hour() < HourEnd) {time_trade=true;}
   if(ticket_buy<0 && time_trade==true)
      if(ticket_sell>0)
         if(OrderSelect(ticket_sell,SELECT_BY_TICKET)==true)
            if(OrderCloseTime()>0)
               if(OrderProfit()+ OrderSwap() + OrderCommission() > 0.0)
                 {
                 if (DistMarketAndPos(Symbol(),-1,-1) < 40) 
                   {
                    Print (" ближайшая позиция меньше 40 пипсов - не входим = ", DistMarketAndPos(Symbol(),-1,-1));
                    return (0);
                   }  
                  ticket=OpenSell(Lots);
                  //----
                  if(ticket>0)
                     ticket_sell=ticket;
                 }
//----

   time_trade=false;
//----открыть НОВЫЙ ордер BUY при losse pos SELL
 if(Use_Time==true && Hour()>=HourStart && Hour() < HourEnd) {time_trade=true;}
   if(ticket_buy<0 && time_trade==true)
      if(ticket_sell>0)
         if(OrderSelect(ticket_sell,SELECT_BY_TICKET)==true)
            if(OrderCloseTime()>0)
               if(OrderProfit()+ OrderSwap() + OrderCommission() < 0.0)
                 {
                  lots=NormalizeDouble(MathCeil((OrderLots()*Factor)/lots_step)*lots_step,lots_digits);
                  lots_test=Lots;
                  //----
                  for(pos=0;pos<Limit;pos++)
                     lots_test=NormalizeDouble(MathCeil((lots_test*Factor)/lots_step)*lots_step,lots_digits);
                  //----
                  if(lots_test<lots)
                     lots=Lots;
                  //----
                  ticket=OpenBuy(lots);
                  //----
                  if(ticket>0)
                    {
                     ticket_buy=ticket;
                     ticket_sell=-1;
                    }
                 }
//----

   return(0);
  }
//+------------------------------------------------------------------+
//| открыть ордер BUY                                                |
//+------------------------------------------------------------------+
int OpenBuy(double lots)
  {
   double price;
//----
   int slip,err; //check;
//----
   price=MarketInfo(Symbol(),MODE_ASK);
   slip=MarketInfo(Symbol(),MODE_SPREAD)*2;
//----
   err = OrderSend(Symbol(),OP_BUY,lots,price,slip,0.0,0.0,"",Magic,0,Blue);
   
   if(err<0 && GetLastError() == 134)
     {
      Print(" OrderSend()-  Ошибка OP_BUY =  "+GetLastError(), " lot = ", lots);   
      err = OrderSend(Symbol(),OP_BUY,0.01,price,slip,0.0,0.0," открытие после БИГ ЛОССА на БИГ ЛОТЕ ",Magic,0,Blue);      
     }
   return(err);
   
  }
  
//+------------------------------------------------------------------+
//| открыть ордер SELL                                               |
//+------------------------------------------------------------------+
int OpenSell(double lots)
  {
   double price;
//----
   int slip,err; //check;
//----
   price=MarketInfo(Symbol(),MODE_BID);
   slip=MarketInfo(Symbol(),MODE_SPREAD)*2;
//----
    err = OrderSend(Symbol(),OP_SELL,lots,price,slip,0.0,0.0,"   ",Magic,0,Red);
   
   if(err<0 && GetLastError() == 134)
     {
      Print(" OrderSend()-  Ошибка OP_SELL =  "+GetLastError(), " lot = ", lots);   
      err = OrderSend(Symbol(),OP_SELL,0.01,price,slip,0.0,0.0," открытие после БИГ ЛОССА на БИГ ЛОТЕ ",Magic,0,Red);
     }
   return(err);

  }
//+------------------------------------------------------------------+

//   ------------------   ТРАЛЫ ----------------------


void TrailingByShadows(int ticket,int tmfrm,int bars_n, int indent,bool trlinloss=false)
   {  
   
   int i; // counter
   double new_extremum=0;
   
   // проверяем переданные значения
   if ((bars_n<1) || (indent<0) || (ticket==0) || ((tmfrm!=1) && (tmfrm!=5) && (tmfrm!=15) && (tmfrm!=30) && (tmfrm!=60) && (tmfrm!=240) && (tmfrm!=1440) && (tmfrm!=10080) && (tmfrm!=43200)) || (!OrderSelect(ticket,SELECT_BY_TICKET)))
      {
      Print("Трейлинг функцией TrailingByShadows() невозможен из-за некорректности значений переданных ей аргументов.");
      return;
      } 
   
   // если длинная позиция (OP_BUY), находим минимум bars_n свечей
   if (OrderType()==OP_BUY)
      {
      for(i=1;i<=bars_n;i++)
         {
         if (i==1) new_extremum = iLow(Symbol(),tmfrm,i);
         else 
         if (new_extremum>iLow(Symbol(),tmfrm,i)) new_extremum = iLow(Symbol(),tmfrm,i);
         }         
      
      // если тралим и в зоне убытков
      if (trlinloss==true)
         {
         // если найденное значение "лучше" текущего стоплосса позиции, переносим 
         if ((((new_extremum - indent*Point)>OrderStopLoss()) || (OrderStopLoss()==0)) && (new_extremum - indent*Point<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         if (!OrderModify(ticket,OrderOpenPrice(),new_extremum - indent*Point,OrderTakeProfit(),OrderExpiration(),clrYellow))            
         Print("Не удалось модифицировать ордер №",OrderTicket(),". Ошибка: ",GetLastError());
         }
      else
         {
         // если новый стоплосс не только лучше предыдущего, но и курса открытия позиции
         if ((((new_extremum - indent*Point)>OrderStopLoss()) || (OrderStopLoss()==0)) && ((new_extremum - indent*Point)>OrderOpenPrice()) && (new_extremum - indent*Point<Bid-MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         if (!OrderModify(ticket,OrderOpenPrice(),new_extremum-indent*Point,OrderTakeProfit(),OrderExpiration(),clrYellow))
         Print("Не удалось модифицировать ордер №",OrderTicket(),". Ошибка: ",GetLastError());
         }
      }
      
   // если короткая позиция (OP_SELL), находим минимум bars_n свечей
   if (OrderType()==OP_SELL)
      {
      for(i=1;i<=bars_n;i++)
         {
         if (i==1) new_extremum = iHigh(Symbol(),tmfrm,i);
         else 
         if (new_extremum<iHigh(Symbol(),tmfrm,i)) new_extremum = iHigh(Symbol(),tmfrm,i);
         }         
           
      // если тралим и в зоне убытков
      if (trlinloss==true)
         {
         // если найденное значение "лучше" текущего стоплосса позиции, переносим 
         if ((((new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point)<OrderStopLoss()) || (OrderStopLoss()==0)) && (new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         if (!OrderModify(ticket,OrderOpenPrice(),new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration(),clrYellow))
         Print("Не удалось модифицировать ордер №",OrderTicket(),". Ошибка: ",GetLastError());
         }
      else
         {
         // если новый стоплосс не только лучше предыдущего, но и курса открытия позиции
         if ((((new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point)<OrderStopLoss()) || (OrderStopLoss()==0)) && ((new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point)<OrderOpenPrice()) && (new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point>Ask+MarketInfo(Symbol(),MODE_STOPLEVEL)*Point))
         if (!OrderModify(ticket,OrderOpenPrice(),new_extremum + (indent + MarketInfo(Symbol(),MODE_SPREAD))*Point,OrderTakeProfit(),OrderExpiration(),clrYellow))
         Print("Не удалось модифицировать ордер №",OrderTicket(),". Ошибка: ",GetLastError());
         }      
      }      
   }
//+------------------------------------------------------------------+


//+----------------------------------------------------------------------------+
//|  Автор    : Ким Игорь В. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  Версия   : 19.02.2008                                                     |
//|  Описание : Возвращает расстояние в пунктах между рынком и ближайшей       |
//|             позицей                                                        |
//+----------------------------------------------------------------------------+
//|  Параметры:                                                                |
//|    sy - наименование инструмента   ("" или NULL - текущий символ)          |
//|    op - торговая операция          (    -1      - любая позиция)           |
//|    mn - MagicNumber                (    -1      - любой магик)             |
//+----------------------------------------------------------------------------+
int DistMarketAndPos(string sy="", int op=-1, int mn=-1) {
  double d, p;
  int i, k=OrdersTotal(), r=1000000;

  if (sy=="" || sy=="0") sy=Symbol();
  p=MarketInfo(sy, MODE_POINT);
  if (p==0) if (StringFind(sy, "JPY")<0) p=0.00001; else p=0.001;
  for (i=0; i<k; i++) {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
      if ((OrderSymbol()==sy) && (op<0 || OrderType()==op)) {
        if (mn<0 || OrderMagicNumber()==mn) {
          if (OrderType()==OP_BUY) {
            d=MathAbs(MarketInfo(sy, MODE_ASK)-OrderOpenPrice())/p;
            if (r>d) r=NormalizeDouble(d, 0);
          }
          if (OrderType()==OP_SELL) {
            d=MathAbs(OrderOpenPrice()-MarketInfo(sy, MODE_BID))/p;
            if (r>d) r=NormalizeDouble(d, 0);
          }
        }
      }
    }
  }
  return(r);
}




int STOP_LOSS(int Magic)
{
   int n=0;  // кол-во идущих подряд свежих закрытых убыточных позиций для расчета АКТУАЛЬНОГО размера СЛ 
 //  double _SL = stoploss; // исходное значение 
   int  col=0;   
 
   for(int i=1; i<=OrdersHistoryTotal(); i++) // цикл сначала к свежей      
   {
      if (OrderSelect(i-1, SELECT_BY_POS,MODE_HISTORY))
      {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
         {
            if (OrderProfit()<0)                                                                                                  
              {                
               //_SL = _SL +  ШАГ_УВЕЛИЧЕНИЯ_СЛ;      // накрутили СЛ           
               n++;                                 // увеличивает счетчик кол-ва поз при лоссе  
               //Print(" профит меньше нуля ЗНАЧЕНИЕ СЛ в цикле, _SL = ", _SL, " n++  = ", n,  " OrderProfit() = ", OrderProfit());            
              }
              
            if (OrderProfit() >= 0)     
            {
               //_SL = stoploss; // при профите  выводим в стартовое значение
               n=0;            // при профите сбрасываем счетчик позиций и начинаем заново    
               //Print(" профит больше нуля ЗНАЧЕНИЕ СЛ в цикле, _SL = ", _SL, " n++  = ", n, " OrderProfit() = ", OrderProfit());          
            }
         }
      }
   }
   if (n>5) Print(" кол-во СВЕЖИХ переворотов на ",Symbol(), " и магике: ",Magic, " равно ", n);
   return(n);   
}  
