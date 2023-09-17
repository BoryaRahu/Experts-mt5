// в.2.1
// Изменен исходный мартин на сетку с увеличением ордеров.
// Добавлено изменение ТР и SL последующих ордеров на Delta.

// в.2.2
// Добавлена проверка достаточности загруженной истории для МА
// Изменен расчет автолота
// Изменено отображение спреда для 5-ти знака.

// в.2.4
// Изменен фильтр по спреду на закрытие (кроме ПТ вечером) и открытие отдельно.
// Закрытие по обратному сигналу (и в ПТ по расписанию) не менее Close_Profit

// в.2.5
// Добавлено несколько попыток выставить стопы в случае ошибок при открытии нового ордера.

// в.2.6
// Добавлен флаг активности Close_Profit (true/false)
// Дополнены типы торговли и сделан их вывод на инфопанель.

// в.2.7 

// Сопровождение вручную поставленных ордеров (по флагу)
// Временной фильтр (планировщик по часам торговли). Фильтр по ПН и ПТ имеют больший приоритет.
// При задержке открытия в ПН, в том числе работа запрещена и в ВС (для брокеров, открывающихся в 23:00 ВС)

#property copyright "mod. W_Trader"
#define   EAName    "Suvivor"
#define   VER       "2.7"
#property version   VER 
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum _TradeType
  {
   Full=1,
   OnlyLong=2,
   OnlyShort=3,
   OnlyClose=4,
   StopAll=5
  };

input string       Comm="Survivor";
input _TradeType TradeType=Full; //Тип торговли
bool      Herge           = false;
sinput string    par="----- ПАРАМЕТРЫ СОВЕТНИКА -------";
input int       MAGIC=123456; // Мэджик
input bool      ClosePlacedManuallyOrd=false; //Закрывать и вручную установленные ордераж
extern double   MaxSpread        =       2.0; // Макс. спред на открытие
extern double   MaxSpread_close  =       2.0; // Макс. спред на закрытие
input double    Lots             =    0.01; // Начальный лот
input double    Risk             =       0; // Риск в %% на начальный ордер (0-выкл.)
extern double   Tp               =      50; // Тейкпрофит 
extern double   Sl               =      50; // Стоплосс 
extern double   Step_Input       =      10; // Шаг ордеров (0-выкл.)
input int       MaxOrders        =       5; // Максимальное число открытых ордеров
input double    Lots_exp         =       1; // Множитель ордеров серии

sinput string       _inp1_= "Для первого входа параметры";
sinput string       _BB1_ = "Bollinger Bands";
input int          periodBB1=10;
input int          deviationBB1=2;
input int          bands_shiftBB1=0;
extern int         priceBBUP1  = PRICE_CLOSE;
extern int         priceBBDN1  = PRICE_CLOSE;
input int          CheckBarsBB1= 10;

sinput string       _RSI1_="RSI";
input int          periodRSI1 = 5;
extern int         priceRSI1  = PRICE_CLOSE;
input int          levelRSIsell1= 70;
input int          levelRSIbuy1 = 30;

sinput string       _ADX1_="ADX";
input int          periodADX1 = 7;
extern int         priceADX1  = PRICE_CLOSE;
input int          levelADX1=20;

sinput string       _DM1_="DeMarker";
input int          periodDM1=5;
input double       levelDMsell1= 0.7;
input double       levelDMbuy1 = 0.3;

sinput string       _MA1_ = "MA";
input bool         UseMA1 = true;
input int          MA_Period1=100;
extern int         Ma_shift1         =  0; // сдвиг МА
extern int         Ma_type1          =  0; // тип МА (0..3)
extern int         Ma_price1=PRICE_CLOSE; // вид цены МА (0..6)
extern int         Slippage_MA1=25;

sinput string       _inp2_= "Для последующих входов параметры";
sinput string       _BB2_ = "Bollinger Bands";
input int          periodBB2=10;
input int          deviationBB2=2;
input int          bands_shiftBB2=0;
extern int         priceBBUP2  = PRICE_CLOSE;
extern int         priceBBDN2  = PRICE_CLOSE;
input int          CheckBarsBB2= 10;

sinput string       _RSI2_="RSI";
input int          periodRSI2 = 5;
extern int         priceRSI2  = PRICE_CLOSE;
input int          levelRSIsell2= 70;
input int          levelRSIbuy2 = 30;

sinput string       _ADX2_="ADX";
input int          periodADX2 = 7;
extern int         priceADX2  = PRICE_CLOSE;
input int          levelADX2=20;

sinput string       _DM2_="DeMarker";
input int          periodDM2=5;
input double       levelDMsell2= 0.7;
input double       levelDMbuy2 = 0.3;

sinput string       _MA2_ = "MA";
input bool         UseMA2 = true;
input int          MA_Period2=105;
extern int         Ma_shift2         =  0; // сдвиг МА
extern int         Ma_type2          =  0; // тип МА (0..3)
extern int         Ma_price2=PRICE_CLOSE; // вид цены МА (0..6)
extern int         Slippage_MA2=25;

sinput string       _inp3_="Для реверса параметры";
input bool         Close_Revers=true; // Закрывать все по обратному сигналу
input bool         Close_Profit_Flag=false; // с учетом уровня профита
input double       Close_Profit=0; // Уровень профита
sinput string       _BB3_="Bollinger Bands";
input int          periodBB3=10;
input int          deviationBB3=2;
input int          bands_shiftBB3=0;
extern int         priceBBUP3  = PRICE_CLOSE;
extern int         priceBBDN3  = PRICE_CLOSE;
input int          CheckBarsBB3= 10;

sinput string       _RSI3_="RSI";
input int          periodRSI3 = 5;
extern int         priceRSI3  = PRICE_CLOSE;
input int          levelRSIsell3= 70;
input int          levelRSIbuy3 = 30;

sinput string       _ADX3_="ADX";
input int          periodADX3 = 7;
extern int         priceADX3  = PRICE_CLOSE;
input int          levelADX3=20;

sinput string       _DM3_="DeMarker";
input int          periodDM3=5;
input double       levelDMsell3= 0.7;
input double       levelDMbuy3 = 0.3;

sinput string    IPanel="Инфопанель";
extern bool      ShowInfoPanel=true;
input    color                Col_info=clrSteelBlue;    //Color of infopanel
sinput string t="----------- ТАЙМЕР -----------";
extern int    Start_Monday_Minuts=6;// Пауза (мин.) в торговле на открытии ПН (0-выкл)
input int StartTime           = 0; //Начало работы (ч)
input int EndTime             = 24;//Конец работы (ч)
extern bool   Stop_Friday=false; // Остановка торговли в ПТ
extern string Stop_Time_Friday    ="20:00"; // Время остановки торговли в ПТ (hh:mm)
extern string Close_Time_Friday   ="22:30"; // Время закрытия ордеров в ПТ (hh:mm)
                                            //extern bool   Breakeven=true; // Закрывать ВСЕ только в безубыток в ПТ

//--------------------------------------------------------------------
int prevtime,minstop,ticket,open_timeseria;
double lots,profit,MinPriceBuy,MaxPriceSell;
int mp,orders_buy,orders_sell,pending;string prevbuy,prevsell;
double HistProfitSeria,LastCloseLots,LastCloseProfit; bool trade;
int stoptrade;
double lots_buy,lots_sell,delta,minlot;
bool CloseSignal;
int Trend;
//--------------------------------------------------------------------
//-------------------------------------------------------------------
void Set_gld(string name,double x)
  {
   if(!GlobalVariableCheck(name))GlobalVariableSet(name,x);
   if((  GlobalVariableGet(name)-x)!=0)GlobalVariableSet(name,x);
  }
//-------------------------------------------------------------------
double Gld(string name){return(GlobalVariableGet(name));}
//--------------------------------------------------------------------
double NL(double lt)
  {
   double MaxLots=MarketInfo(Symbol(),MODE_MAXLOT);
   double MinLots=MarketInfo(Symbol(),MODE_MINLOT);
   double StepLots=MarketInfo(Symbol(),MODE_LOTSTEP);
   double lot=NormalizeDouble(lt/StepLots,0)*StepLots;
   if(lot>MaxLots) lot=MaxLots;
   if(lot<MinLots) lot=MinLots;
   return (lot);
  }
double ND(double x){return(NormalizeDouble(x,Digits));}
//--------------------------------------------------------------------
//--------------------------------------------------------------------
double Lots()
  {
   double lot=Lots;
   if(Risk>0)lot=AccountBalance()*Risk/100/Sl/pow(10,_Point)/MarketInfo(_Symbol,MODE_TICKVALUE);
   return(NL(lot));
  }
//-----------------------------------------------------------------------
//+----------------------------------------------------------------------------+
//|  expert initialization function                                            |
//+----------------------------------------------------------------------------+
int init()
  {
   mp=1;
   if(Digits==3 || Digits==5)mp=10;
   Sl*=mp; Tp*=mp;Step_Input*=mp;
   Slippage_MA1*=mp;
   Slippage_MA2*=mp;
   MaxSpread*=mp;
   MaxSpread_close*=mp;
   prevtime=Time[0];
   stoptrade=0;
   delta=MaxSpread;
   CloseSignal=FALSE;
   minlot=MarketInfo(_Symbol,MODE_MINLOT);
   fRectLabelCreate(0,"s_h_i_p",0,0,28,160,20,clrBlue);
   if(ShowInfoPanel) fRectLabelCreate(0,"info_panel",0,0,49,160,175,Col_info);
   if(ShowInfoPanel)
     {
      fRectLabelCreate(0,"hide_i_p",0,1,29,158,18,clrMediumSeaGreen,2,0,clrRed,STYLE_SOLID,1,false,false,true,1);
      fLabelCreate(0,"hide_text",0,80,38,"H I D E",0,"Verdana",7);
      fRectLabelCreate(0,"info_panel",0,0,85,160,240,Col_info);
     }
   else
     {
      fRectLabelCreate(0,"show_i_p",0,1,29,158,18,C'204,113,0',2,0,clrRed,STYLE_SOLID,1,false,false,true,1);
      fLabelCreate(0,"show_text",0,80,38,"S H O W",0,"Verdana",7);
     }

   return(0);
  }
//------------
int deinit()
  {
   Comment("");
   if(ObjectFind("info_panel")>=0) //
      fRectLabelDelete(0,"info_panel");
   if(ObjectFind("s_h_i_p")>=0) //
      fRectLabelDelete(0,"s_h_i_p");
   if(ObjectFind("show_i_p")>=0) //
      fRectLabelDelete(0,"show_i_p");
   if(ObjectFind("hide_i_p")>=0) //
      fRectLabelDelete(0,"hide_i_p");
   if(ObjectFind("show_text")>=0)
      fLabelDelete(0,"show_text");
   if(ObjectFind("hide_text")>=0)
      fLabelDelete(0,"hide_text");

   return(0);
  }
//------------------------------------------------------------------------------
double OnTester()
  {
   double Res=0;
   double MaxDD=TesterStatistics(STAT_EQUITY_DD);
   if(MaxDD!=0)
      Res=TesterStatistics(STAT_PROFIT)/MaxDD;
   return(NormalizeDouble(Res, 2));
  }
//------------------------------------------------------------------------------
int Signal(int i,int periodBB,int deviationBB,int bands_shiftBB,int UPBBprice,int DNBBprice,int CheckBarsBB,
           int periodRSI,int priceRSI,int levelRSIsell,int levelRSIbuy,int periodADX,int priceADX,int levelADX,int periodDM,
           double levelDMsell,double levelDMbuy)
  {
   double adxsell,adxbuy,dm,rsi;
   int BB=GetBB(i,periodBB,deviationBB,bands_shiftBB,UPBBprice,DNBBprice,CheckBarsBB);
//
   HideTestIndicators(1);
   if(BB == 0) return(0);
   if(BB == -1)
     {
      rsi=iRSI(NULL,0,periodRSI,priceRSI,i);
      if(rsi>=levelRSIsell)
        {
         dm=iDeMarker(NULL,0,periodDM,i);
         if(dm>=levelDMsell)
           {
            adxsell=iADX(NULL,0,periodADX,priceADX,MODE_PLUSDI,i);
            HideTestIndicators(0);
            if(adxsell>=levelADX)return(-1);

           }
        }
     }
   HideTestIndicators(1);
   if(BB==1)
     {
      rsi=iRSI(NULL,0,periodRSI,priceRSI,i);
      if(rsi<=levelRSIbuy)
        {
         dm=iDeMarker(NULL,0,periodDM,i);
         if(dm<=levelDMbuy)
           {
            adxbuy=iADX(NULL,0,periodADX,priceADX,MODE_MINUSDI,i);
            HideTestIndicators(0);
            if(adxbuy>=levelADX)return(1);

           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetBB(int ii,int periodBB,int deviationBB,int bands_shiftBB,int uppr,int dnpr,int CheckBarsBB)
  {
   double  bh,bl; int dn=0,up=0;
   int j;
   for(j=ii; j<=ii+CheckBarsBB; j++)
     {
      bh = iBands(NULL,0,periodBB,deviationBB,bands_shiftBB,uppr,MODE_UPPER,j);
      bl = iBands(NULL,0,periodBB,deviationBB,bands_shiftBB,dnpr,MODE_LOWER,j);
      if(Close[j]>=bh) {dn++;break;}
      if(Close[j]<=bl) {up++;break;}
     }
   if(dn>0)return(-1);
   if(up>0)return( 1);
   return(0);
  }
//+----------------------------------------------------------------------------+
int FilterMA(int Ma_Period,int Ma_shift,int Ma_type,int Ma_price,int Slippage_MA)
  {
   double g_iclose_376=iClose(NULL,0,1);
   double g_ima_408=iMA(NULL,0,Ma_Period,Ma_shift,Ma_type,Ma_price,1);

   if( g_iclose_376 > g_ima_408 + Slippage_MA * Point ) return(1);
   if( g_iclose_376 < g_ima_408 - Slippage_MA * Point ) return(-1);

   return(0);
  }
//+----------------------------------------------------------------------------+
bool CheckMaxSpread()
  {
   RefreshRates();
   if(NormalizeDouble(Ask - Bid, Digits)/Point <= MaxSpread) return (TRUE);
//---
   else return (FALSE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckMaxSpreadClose()
  {
   RefreshRates();
   if(NormalizeDouble(Ask - Bid, Digits)/Point <= MaxSpread_close) return (TRUE);
//---
   else return (FALSE);
  }
//+----------------------------------------------------------------------------+
//|  expert start function                                                     |
//+----------------------------------------------------------------------------+
int start()
  {
   int Status,signal,signalrevers,ma1,ma2,spr,i;
   spr=1;
//--- close bar
//   if(Close_Bars_Exit)OrdersCloseTime();
   RefreshRates();Comment("");

   Status=OrdersScaner();
   if(!IsTesting() && (ShowInfoPanel))
     {
      Trend=0;
      ma1=FilterMA(MA_Period1,Ma_shift1,Ma_type1,Ma_price1,Slippage_MA1);
      ma2=FilterMA(MA_Period2,Ma_shift2,Ma_type2,Ma_price2,Slippage_MA2);
      if(Status>0) Trend=ma2;
      else Trend=ma1;
      InfoPanel(); //отображать инфопанель
     }

   if(TradeType==StopAll) { stoptrade=1; return 0;}

   if(Start_Monday_Minuts>0)
      if((DayOfWeek()==1 && TimeCurrent()-iTime(NULL,1440,0)<Start_Monday_Minuts*60)||(DayOfWeek()==7))
        {stoptrade=1; /*Comment("\n ПАУЗА В ТОРГОВЛЕ ",Start_Monday_Minuts,"  минут ");*/return(0);}
   
   if(DayOfWeek()==5)
     {
      Status=OrdersScaner();
      if(Stop_Friday && TimeCurrent()>=StrToTime(Stop_Time_Friday))
        {stoptrade=1; if(Status==0){/*Comment("\n ТОРГОВЛЯ ЗАВЕРШЕНА "); Sleep(3000);*/return(0);}}
      if(Stop_Friday && Status>0 && TimeCurrent()>=StrToTime(Close_Time_Friday))
        {
         if((!Close_Profit_Flag) || (profit>=Close_Profit))
           { CloseAll(); Print("Спред при закрытии ордера= ",NormalizeDouble(Ask-Bid,Digits)/Point); }
         return(0);
        }
     }
 
 //------- new-bar
   if(prevtime==Time[0])return(0);
   prevtime=Time[0];
   stoptrade=0;
   Status=OrdersScaner();
   signal=0;
//--- close signal
   if(Close_Revers && Status>0)
     {
      signalrevers=Signal(1,periodBB3,deviationBB3,bands_shiftBB3,priceBBUP3,priceBBDN3,CheckBarsBB3,
                          periodRSI3,priceRSI3,levelRSIsell3,levelRSIbuy3,periodADX3,priceADX3,levelADX3,periodDM3,
                          levelDMsell3,levelDMbuy3);
      if(orders_buy>0 && signalrevers==-1)
        {
         CloseSignal=TRUE;
         if(!CheckMaxSpreadClose())
           {
            spr=0;PrintFormat("Спред=%.1f для закрытия превышен. Ждем его нормализации...", NormalizeDouble(Ask-Bid,Digits)/Point);if(IsTesting())return(0);
            for(i=0;i<20;i++)
                  if(CheckMaxSpreadClose()) { spr=1; break;}
            else Sleep(500);
            if(spr==1) {Print("Спред нормализовался. Работаем.");}
            else { Print("Спред не нормализовался. Пропускаем."); return 0;}
           }
         if((!Close_Profit_Flag) || (profit>=Close_Profit))
           {
            if(CloseAll()==1){ CloseSignal=FALSE; Status=OrdersScaner();Print("Спред при закрытии ордера= ",NormalizeDouble(Ask-Bid,Digits)/Point);}
           }
         else PrintFormat("Сигнал на закрытие есть, но текущий профит=%.2f меньше необходимого уровня %.2f",profit,Close_Profit);
        }//signal=signalrevers;
      else CloseSignal=FALSE;
      if(orders_sell>0 && signalrevers==1)
        {
         CloseSignal=TRUE;
         if(!CheckMaxSpreadClose())
           {
            spr=0;PrintFormat("Спред=%.1f для закрытия превышен. Ждем его нормализации...",NormalizeDouble(Ask-Bid,Digits)/Point);if(IsTesting())return(0);
            for(i=0;i<20;i++)
                  if(CheckMaxSpreadClose()) { spr=1; break;}
            else Sleep(500);
            if(spr==1) {Print("Спред нормализовался. Работаем.");}
            else { Print("Спред не нормализовался. Пропускаем."); return 0;}
           }
         if((!Close_Profit_Flag) || (profit>=Close_Profit))
           {
            if(CloseAll()==1){ CloseSignal=FALSE; Status=OrdersScaner();Print("Спред при закрытии ордера= ",NormalizeDouble(Ask-Bid,Digits)/Point);}
           }
         else PrintFormat("Сигнал на закрытие есть, но текущий профит=%.2f меньше необходимого уровня %.2f",profit,Close_Profit);
        }//signal=signalrevers;
      else CloseSignal=FALSE;
     }

  
   if(Status==0)
     {// == 0
      signal=Signal(1,periodBB1,deviationBB1,bands_shiftBB1,priceBBUP1,priceBBDN1,CheckBarsBB1,
                    periodRSI1,priceRSI1,levelRSIsell1,levelRSIbuy1,periodADX1,priceADX1,levelADX1,periodDM1,
                    levelDMsell1,levelDMbuy1);
      if(UseMA1)
        {
         if(iBars(_Symbol,PERIOD_CURRENT)<MA_Period1+1)
           {
            Print(Hour(),":",Minute()," | Error: Недостаточно загруженной истории для МА1");
            return 0;
           }
         ma1=FilterMA(MA_Period1,Ma_shift1,Ma_type1,Ma_price1,Slippage_MA1);
         if(signal>0 && ma1<1 ) signal = 0;
         if(signal<0 && ma1>-1) signal = 0;
        }
     }// == 0
   if(Status>0)
     {// > 0
      signal=Signal(1,periodBB2,deviationBB2,bands_shiftBB2,priceBBUP2,priceBBDN2,CheckBarsBB2,
                    periodRSI2,priceRSI2,levelRSIsell2,levelRSIbuy2,periodADX2,priceADX2,levelADX2,periodDM2,
                    levelDMsell2,levelDMbuy2);
      if(UseMA2)
        {
         if(iBars(_Symbol,PERIOD_CURRENT)<MA_Period2+1)
           {
            Print(Hour(),":",Minute()," | Error: Недостаточно загруженной истории для МА2");
            return 0;
           }
         ma2=FilterMA(MA_Period2,Ma_shift2,Ma_type2,Ma_price2,Slippage_MA2);
         if(signal>0 && ma2<1 ) signal = 0;
         if(signal<0 && ma2>-1) signal = 0;
        }
     }// > 0

//--- input
   if(signal==1 && Status<MaxOrders)
     {
      trade=1;
      if(TradeType==OnlyShort) { trade=0; Print("Ордер BUY открыть не удалось - OnlyShort");}
      if(TradeType==OnlyClose) { trade=0; stoptrade=1; Print("Ордер BUY открыть не удалось - OnlyClose");}
      if (!IsTime()) { trade=0; stoptrade=1; Print("Ордер BUY открыть не удалось - запрет работы по расписанию");}
       //-----------------------------------------------------------------
      lots=(Lots()*pow(Lots_exp,orders_buy)>minlot)?NormalizeDouble(Lots()*pow(Lots_exp,orders_buy),2):minlot;
      if(orders_buy>0 && Step_Input>0)
         if(Close[1]>MinPriceBuy-Step_Input*Point)trade=0;
      if((orders_sell>0) && (!Herge)) trade=0;
      if(trade)
        {
         if(!CheckMaxSpread())
           {
            spr=0;PrintFormat("Спред=%.1f для открытия BUY превышен. Ждем его нормализации...", NormalizeDouble(Ask-Bid,Digits)/Point);if(IsTesting())return(0);
            for(i=0;i<20;i++)
                  if(CheckMaxSpread()) { spr=1; break;}
            else Sleep(500);
            if(spr==1) {Print("Спред нормализовался. Работаем.");}
            else { Print("Спред не нормализовался. Пропускаем."); return 0;}
           }
         if(OpenBuyMarket(MAGIC,NL(lots),Sl,Tp,Comm+"_M"+IntegerToString(_Period)+"-"+IntegerToString(orders_buy+1),Blue)>0)
           {//if(OpenPlay)ALERT(1);
            Print("Спред при открытии ордера= ",NormalizeDouble(Ask-Bid,Digits)/Point);
            return(0);
           }
         else {prevtime=Time[1];Print("Error BUY = ",GetLastError());return(0);}
        }
     }
   if(signal==-1 && Status<MaxOrders)
     {
      trade=1;
      if(TradeType==OnlyLong) { trade=0; Print("Ордер SELL открыть не удалось - OnlyLong");}
      if(TradeType==OnlyClose) { trade=0; stoptrade=1; Print("Ордер SELL открыть не удалось - OnlyClose");}
      if (!IsTime()) { trade=0; stoptrade=1; Print("Ордер SELL открыть не удалось - запрет работы по расписанию");}
      lots=(Lots()*pow(Lots_exp,orders_sell)>minlot)?NormalizeDouble(Lots()*pow(Lots_exp,orders_sell),2):minlot;
      if(orders_sell>0 && Step_Input>0)
         if(Close[1]<MaxPriceSell+Step_Input*Point)trade=0;
      if((orders_buy>0) && (!Herge)) trade=0;
      if(trade)
        {
         if(!CheckMaxSpread())
           {
            spr=0;PrintFormat("Спред=%.1f для открытия SELL превышен. Ждем его нормализации...", NormalizeDouble(Ask-Bid,Digits)/Point);if(IsTesting())return(0);
            for(i=0;i<20;i++)
                  if(CheckMaxSpread()) { spr=1; break;}
            else Sleep(500);
            if(spr==1) {Print("Спред нормализовался. Работаем.");}
            else { Print("Спред не нормализовался. Пропускаем."); return 0;}
           }
         if(OpenSellMarket(MAGIC,NL(lots),Sl,Tp,Comm+"_M"+IntegerToString(_Period)+"-"+IntegerToString(orders_sell+1),Red)>0)
           {//if(OpenPlay)ALERT(-1);
            Print("Спред при открытии ордера= ",NormalizeDouble(Ask-Bid,Digits)/Point);
            return(0);
           }
         else {prevtime=Time[1];Print("Error SELL = ",GetLastError());return(0);}
        }
     }
//---   
   return(0);
  }
//--------------------------------------------------------------------
/*void ALERT(int type){
if(type== 1)Alert(" ПОКУПКА ",Symbol()," ПО ЦЕНЕ ",Ask," ВРЕМЯ - ",TimeToStr(TimeCurrent()));
if(type==-1)Alert(" ПРОДАЖА ",Symbol()," ПО ЦЕНЕ ",Bid," ВРЕМЯ - ",TimeToStr(TimeCurrent()));
}*/
//+------------------------------------------------------------------+ 
/*void OrdersCloseTime(){
   //------------------
   int slip=MathCeil(MarketInfo(Symbol(),MODE_SPREAD)*2);
   for (int i=OrdersTotal();i>=1;i--){
         if(OrderSelect(i-1, SELECT_BY_POS, MODE_TRADES)==FALSE)break;
         if(OrderSymbol ()!= Symbol())continue;
         if(OrderMagicNumber()!=MAGIC)continue;
         if(Time[0]-OrderOpenTime()> Period()*60*BarsExit)
           {
            while(IsTradeContextBusy()) Sleep(1000); RefreshRates();
            if(OrderType() == OP_BUY )
             if(OrderClose(OrderTicket(),NL(OrderLots()),Bid,slip,Blue))continue;
            
            if(OrderType() == OP_SELL)
             if(OrderClose(OrderTicket(),NL(OrderLots()),Ask,slip,Red))continue;
            }
        }
}*/
//+------------------------------------------------------------------+ 
int OrdersScaner()
  {
//------------------сканер ордеров ---------      
   orders_buy=0;orders_sell=0;profit=0;MinPriceBuy=0;MaxPriceSell=0;pending=0;
   lots_buy=0; lots_sell=0;
   for(int i=OrdersTotal();i>=1;i--)
     {
      if(OrderSelect(i-1,SELECT_BY_POS,MODE_TRADES)==FALSE)break;
      if(OrderSymbol()!=Symbol())continue;
      if((OrderMagicNumber()!=MAGIC)&&(!ClosePlacedManuallyOrd||OrderMagicNumber()!=0)) continue;
      if(OrderType()>1)pending++;
      if(OrderType()==OP_BUY)
        {
         orders_buy++;
         if(orders_buy==1)MinPriceBuy=OrderOpenPrice();
         if(orders_buy>1 && OrderOpenPrice()<MinPriceBuy)MinPriceBuy=OrderOpenPrice();
         profit+=OrderProfit()+OrderSwap()+OrderCommission();
         lots_buy+=OrderLots();
        }
      if(OrderType()==OP_SELL)
        {
         orders_sell++;
         if(orders_sell==1)MaxPriceSell=OrderOpenPrice();
         if(orders_sell>1 && OrderOpenPrice()>MaxPriceSell)MaxPriceSell=OrderOpenPrice();
         profit+=OrderProfit()+OrderSwap()+OrderCommission();
         lots_sell+=OrderLots();
        }
     }
   int status=orders_buy+orders_sell;
   return(status);
  }
//--------------------------------------------------------------------------------------
int OpenBuyMarket(int Magic,double lot,double SL,double TP,string _comm,color clr)
  {

   if(AccountFreeMarginCheck(Symbol(),OP_BUY,lot)<=0 || GetLastError()==134)/* NOT_ENOUGH_MONEY */
     {
      Print("Нет или не хватает для открытия  свободных средств");
      Comment("Нет или не хватает для открытия  свободных средств"); Sleep(5000);return(0);
     }
   while(IsTradeContextBusy()) Sleep(1000); RefreshRates();
   double ask=NormalizeDouble(Ask,Digits);
   int slip=MathCeil(MarketInfo(Symbol(),MODE_SPREAD)*2);
   ticket=OrderSend(Symbol(),OP_BUY,lot,ask,slip,0,0,_comm,Magic,0,clr);
   if(ticket>0)
     {
      if(SL+TP==0)return(ticket);
      if(OrderSelect(ticket,SELECT_BY_TICKET))
        {
         while(IsTradeContextBusy()) Sleep(1000); RefreshRates();
         double op=OrderOpenPrice(),sl,tp;
         minstop=MarketInfo(Symbol(),MODE_STOPLEVEL);
         if(SL!=0) sl = ND(op-SL*Point); else sl = 0;
         if(TP!=0) tp = ND(op+TP*Point); else tp = 0;
         if(tp!=0)if(tp-Ask<minstop*Point)tp=Ask+minstop*Point;
         if(sl!=0)if(Bid-sl<minstop*Point)sl=Bid-minstop*Point;
         // Несколько попыток выставить стопы
         for(int i=0;i<5;i++)
           {
            if(!OrderModify(ticket,op,sl,tp,0,Blue))
              {
               PrintFormat("Попытка №%d. Не получилось выставить стопы BUY. Ошибка %d",i+1,GetLastError());
               Sleep(1000);
              }
            else return(ticket);
           }
        }
     }
   else { Print("Не получилось открыть BUY ",GetLastError());  return(0);}
   return(ticket);
  }
//----------------------------------------------------------------------------------------
int OpenSellMarket(int Magic,double lot,double SL,double TP,string _comm,color clr)
  {
   if(AccountFreeMarginCheck(Symbol(),OP_SELL,lot)<=0 || GetLastError()==134)/* NOT_ENOUGH_MONEY */
     {
      Print("Нет или не хватает для открытия  свободных средств");
      Comment("Нет или не хватает для открытия  свободных средств"); Sleep(5000);return(0);
     }
   while(IsTradeContextBusy()) Sleep(1000); RefreshRates();
   double bid=NormalizeDouble(Bid,Digits);
   int slip=MathCeil(MarketInfo(Symbol(),MODE_SPREAD)*2);
   ticket=OrderSend(Symbol(),OP_SELL,lot,bid,slip,0,0,_comm,Magic,0,clr);
   if(ticket>0)
     {
      if(SL+TP==0)return(ticket);
      if(OrderSelect(ticket,SELECT_BY_TICKET))
        {
         while(IsTradeContextBusy()) Sleep(1000); RefreshRates();
         double op=OrderOpenPrice(),sl,tp;
         minstop=MarketInfo(Symbol(),MODE_STOPLEVEL);
         if(SL!=0) sl = ND(op+SL*Point); else sl = 0;
         if(TP!=0) tp = ND(op-TP*Point); else tp = 0;
         if(tp!=0)if(Bid-tp<minstop*Point)tp=Bid-minstop*Point;
         if(sl!=0)if(sl-Ask<minstop*Point)sl=Ask+minstop*Point;
         // Несколько попыток выставить стопы
         for(int i=0;i<5;i++)
           {
            if(!OrderModify(ticket,op,sl,tp,0,Red))
              {
               PrintFormat("Попытка №%d. Не получилось выставить стопы SELL. Ошибка %d",i+1,GetLastError());
               Sleep(1000);
              }
            else return(ticket);
           }
        }
     }
   else { Print("Не получилось открыть SELL ",GetLastError()); return(0);}
   return(ticket);
  }
//--------------------------------------------------------------------
//--------------------------------------------------------------------
int CloseAll()
  {
   bool   UseSound=0;
   int    Slippage=5*mp;               // Проскальзывание цены
   int    NumberOfTry=6;               // Количество попыток
   int    PauseAfterError=5;              // Пауза после ошибки в секундах
   color clCloseBuy  = Blue;         // Цвет значка закрытия покупки
   color clCloseSell = Red;          // Цвет значка закрытия продажи
   string NameFileSound="";

   bool   fc;
   double pp;
   int    err,i,it,cnt=0,magic;

   for(i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))// {
         if(OrderSymbol()==Symbol())
           {
            magic=OrderMagicNumber();
            if ((magic==MAGIC)||(ClosePlacedManuallyOrd&&magic==0))
              {
               fc=False;
               for(it=1; it<=NumberOfTry; it++)
                 {
                  while(!IsTradeAllowed()) Sleep(500);
                  RefreshRates();
                  if(OrderType()==OP_BUY)
                    {
                     pp=MarketInfo(OrderSymbol(), MODE_BID);
                     fc=OrderClose(OrderTicket(), OrderLots(), pp, Slippage, clCloseBuy);
                     if(fc) {if(UseSound) PlaySound(NameFileSound); break;}
                     else { err=GetLastError(); Print("Error",err);Sleep(1000*PauseAfterError);}
                    }
                  if(OrderType()==OP_SELL)
                    {
                     pp=MarketInfo(OrderSymbol(), MODE_ASK);
                     fc=OrderClose(OrderTicket(), OrderLots(), pp, Slippage, clCloseSell);
                     if(fc) {if(UseSound) PlaySound(NameFileSound); break;}
                     else {err=GetLastError(); Print("Error",err); Sleep(1000*PauseAfterError);}
                    }
                 }
              }
           }
     }//}
//--------- проверка выполнения закрытия ---------------
   for(i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()!=Symbol()) continue;
      magic=OrderMagicNumber();
      if(magic!=MAGIC) continue;
      if(OrderType()==OP_BUY || OrderType()==OP_SELL)cnt++;
     }
   if(cnt==0)return(1);
   else return (0);
  }
//--------------------------------------------------------------------------------------

bool IsTime ()
{
   MqlDateTime cur_time;
   
   TimeCurrent(cur_time);
   if (((StartTime<EndTime)&&(cur_time.hour>=StartTime) && (cur_time.hour<EndTime))
     ||((StartTime>EndTime)&&(((cur_time.hour>=StartTime) && (cur_time.hour<24))
                            ||((cur_time.hour>=0) && (cur_time.hour<EndTime)))))  return true;
   
   return false;
}

void InfoPanel()
  {

   string trend,Close_Profit_Level;
   
   if(Trend==1) trend="UP";
   else if(Trend==-1) trend="DOWN";
   else trend="NEUTRAL";

   if(Close_Profit_Flag) Close_Profit_Level=DoubleToStr(Close_Profit,2)+" "+AccountCurrency();
   else Close_Profit_Level="NO LEVEL";

   string info_panel=
                     "\n\n"
                     +"\n  ----------------------------------------------"
                     +"\n             "+EAName+", ver: "+(string)VER
                     +"\n  ----------------------------------------------"
                     +"\n Max Spread = "+DoubleToStr(MaxSpread,(mp==10)?0:1)+" pips"
                     +"\n Current Spread: "+DoubleToStr((Ask-Bid)/_Point,(mp==10)?0:1)+" pips";
   if(!CheckMaxSpread()) info_panel=info_panel+" - HIGH !!!";
   else info_panel=info_panel+" - NORMAL";
   info_panel+=
               "\n Trading Lots = "+DoubleToStr(Lots(),2)
               +"\n  ----------------------------------------------"
               +"\n Orders Buy: "+IntegerToString(orders_buy)+".   Sum Lots: "+DoubleToStr(lots_buy,2)
               +"\n Orders Sell: "+IntegerToString(orders_sell)+".    Sum Lots: "+DoubleToStr(lots_sell,2)
               +"\n Total profit: "+DoubleToStr(profit,2)+" "+AccountCurrency()
               +"\n Close Profit Level: "+Close_Profit_Level
               +"\n Trend: "+trend
               +"\n  ----------------------------------------------"
               +"\n  Trade is ";
   if(IsTradeAllowed())
     {
      if (!IsTime()) info_panel+="DENY !!!";
      else 
      switch(TradeType)
        {
         case OnlyLong: info_panel+="ONLY LONG.";break;
         case OnlyShort: info_panel+="ONLY SHORT.";break;
         case OnlyClose: info_panel+="ONLY CLOSE.";break;
         case StopAll: info_panel+="DENY !!!";break;
         default: info_panel+="ALLOW.";
        }
     }
   else    info_panel+="DENY !!!";

   Comment(info_panel);

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam=="show_i_p")
        {
         if(ShowInfoPanel) return;

         if(ObjectFind("show_text")>=0)
            fLabelDelete(0,"show_text");
         if(ObjectFind("show_i_p")>=0) //
            fRectLabelDelete(0,"show_i_p");

         fRectLabelCreate(0,"hide_i_p",0,1,29,158,18,clrMediumSeaGreen,2,0,clrRed,STYLE_SOLID,1,false,false,true,1);
         fLabelCreate(0,"hide_text",0,80,38,"H I D E",0,"Verdana",7);
         fRectLabelCreate(0,"info_panel",0,0,49,160,175,Col_info);

         ShowInfoPanel = true;
         double spread = Ask - Bid;
         InfoPanel();
        }
      if(sparam=="hide_i_p")
        {
         if(!ShowInfoPanel) return;

         if(ObjectFind("hide_text")>=0)
            fLabelDelete(0,"hide_text");
         if(ObjectFind("hide_i_p")>=0) //
            fRectLabelDelete(0,"hide_i_p");

         fRectLabelCreate(0,"show_i_p",0,1,29,158,18,C'204,113,0',2,0,clrRed,STYLE_SOLID,1,false,false,true,1);
         fLabelCreate(0,"show_text",0,80,38,"S H O W",0,"Verdana",7);

         Comment("");
         if(ObjectFind("info_panel")>=0)
            fRectLabelDelete(0,"info_panel");
         ShowInfoPanel=false;
        }
     }
  }
//+------------------------------------------------------------------+ 
//| Создает прямоугольную метку                                      | 
//+------------------------------------------------------------------+ 
bool fRectLabelCreate(const long             chart_ID    = 0,                 // ID графика 
                      const string           name        = "RectLabel",       // имя метки 
                      const int              sub_window  = 0,                 // номер подокна 
                      const int              x           = 0,                 // координата по оси X 
                      const int              y           = 0,                 // координата по оси Y 
                      const int              width       = 50,                // ширина 
                      const int              height      = 18,                // высота 
                      const color            back_clr    = C'236,233,216',    // цвет фона 
                      const ENUM_BORDER_TYPE border      = BORDER_SUNKEN,     // тип границы 
                      const ENUM_BASE_CORNER corner      = CORNER_LEFT_UPPER, // угол графика для привязки 
                      const color            clr         = clrRed,            // цвет плоской границы (Flat) 
                      const ENUM_LINE_STYLE  style       = STYLE_SOLID,       // стиль плоской границы 
                      const int              line_width  = 1,                 // толщина плоской границы 
                      const bool             back        = false,             // на заднем плане 
                      const bool             selection   = false,             // выделить для перемещений 
                      const bool             hidden      = true,              // скрыт в списке объектов 
                      const long             z_order     = 0)                 // приоритет на нажатие мышью 
  {
//--- сбросим значение ошибки 
   ResetLastError();
   if(ObjectFind(chart_ID,name)==0) return true;
//--- создадим прямоугольную метку 
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangular mark! ");
      return(false);
     }
//--- установим координаты метки 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- установим размеры метки 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- установим цвет фона 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- установим тип границы 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
//--- установим угол графика, относительно которого будут определяться координаты точки 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- установим цвет плоской рамки (в режиме Flat) 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- установим стиль линии плоской рамки 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- установим толщину плоской границы 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
//--- отобразим на переднем (false) или заднем (true) плане 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- включим (true) или отключим (false) режим перемещения метки мышью 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- установим приоритет на получение события нажатия мыши на графике 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- успешное выполнение 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Удаляет прямоугольную метку                                      | 
//+------------------------------------------------------------------+ 
bool fRectLabelDelete(const long   chart_ID   = 0,           // ID графика 
                      const string name       = "RectLabel") // имя метки 
  {
//--- сбросим значение ошибки 
   ResetLastError();
//--- удалим метку 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to remove a rectangular mark! ");
      return(false);
     }
//--- успешное выполнение 
   return(true);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ 
//| Создает текстовую метку                                          | 
//+------------------------------------------------------------------+ 
bool fLabelCreate(const long             chart_ID=0,// ID графика 
                  const string            name="Label",             // имя метки 
                  const int               sub_window=0,             // номер подокна 
                  const int               x=0,                      // координата по оси X 
                  const int               y=0,                      // координата по оси Y 
                  const string            text="Label",             // текст 
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // угол графика для привязки 
                  const string            font="Arial",             // шрифт 
                  const int               font_size=10,             // размер шрифта 
                  const color             clr=clrDarkBlue,// цвет 
                  const double            angle=0.0,                // наклон текста 
                  const ENUM_ANCHOR_POINT anchor=ANCHOR_CENTER,     // способ привязки 
                  const bool              back=false,               // на заднем плане 
                  const bool              selection=false,          // выделить для перемещений 
                  const bool              hidden=true,              // скрыт в списке объектов 
                  const long              z_order=0)                // приоритет на нажатие мышью 
  {
//--- сбросим значение ошибки 
   ResetLastError();
   if(ObjectFind(chart_ID,name)==0) return true;
//--- создадим текстовую метку 
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": was unable to create a text label! Error code = ",GetLastError());
      return(false);
     }
//--- установим координаты метки 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- установим угол графика, относительно которого будут определяться координаты точки 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- установим текст 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- установим шрифт текста 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- установим размер шрифта 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- установим угол наклона текста 
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- установим способ привязки 
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- установим цвет 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- отобразим на переднем (false) или заднем (true) плане 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- включим (true) или отключим (false) режим перемещения метки мышью 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- установим приоритет на получение события нажатия мыши на графике 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- успешное выполнение 
   return(true);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ 
//| Удаляет текстовую метку                                          | 
//+------------------------------------------------------------------+ 
bool fLabelDelete(const long   chart_ID=0,// ID графика 
                  const string name="Label") // имя метки 
  {
//--- сбросим значение ошибки 
   ResetLastError();
//--- удалим метку 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to remove the text label! Error code = ",GetLastError());
      return(false);
     }
//--- успешное выполнение 
   return(true);
  }
//+------------------------------------------------------------------+ 
