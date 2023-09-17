//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "NPM23"
#property link      "https://alpari.com/ru/investor/pamm/355130/"
//#property version   "14.00" 
#property strict

#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
CTrade  m_trade;
//CHistoryOrderInfo myhistory;
//CPositionInfo myposition;
CDealInfo mydeal;

sinput string     t="----------- ТАЙМЕР -----------";
input int        Start_Monday_Minuts=6;        // пауза в торговле на открытии понедельника. 0-выкл
input string     Stop_Time_Friday    ="23:31"; // время остановки торговли в пятницу (hh:mm) ""-выкл
input string     Close_Time_Friday   ="23:50"; // время закрытия ордеров в пятницу (hh:mm) ""-выкл

sinput string      _inp1_= "Для первого входа параметры";
sinput string      _BB1_ = "Bollinger Bands";
input int         periodBB1=10;
input double      deviationBB1=1;
input int         bands_shiftBB1=0;
input ENUM_APPLIED_PRICE priceBBUP1  = PRICE_CLOSE;
input ENUM_APPLIED_PRICE priceBBDN1  = PRICE_CLOSE;
input int         CheckBarsBB1=10;

sinput string      _RSI1_="RSI";
input int         periodRSI1=10;
input ENUM_APPLIED_PRICE priceRSI1=PRICE_CLOSE;
input int         levelRSIsell1= 70;
input int         levelRSIbuy1 = 30;

sinput string      _ADX1_="ADX";
input int         periodADX1=3;
input int         levelADX1=5;

sinput string      _DM1_="DeMarker";
input int         periodDM1=1;
input double      levelDMsell1= 0.3;
input double      levelDMbuy1 = 0.7;

sinput string      _MA1_="MA";
input bool        UseMA1=true;
input int         MA_Period1=550;
input int        Ma_shift1=0; // сдвиг ма
input ENUM_MA_METHOD        Ma_type1=MODE_EMA; // тип ма
input ENUM_APPLIED_PRICE Ma_price1=PRICE_MEDIAN; // вид цены ма (7 видов)
input int        Slippage_MA1=25;

sinput string      _inp2_= "Для последующих входов параметры";
sinput string      _BB2_ = "Bollinger Bands";
input int         periodBB2=10;
input double         deviationBB2=1;
input int         bands_shiftBB2=0;
input ENUM_APPLIED_PRICE priceBBUP2  = PRICE_CLOSE;
input ENUM_APPLIED_PRICE priceBBDN2  = PRICE_CLOSE;
input int         CheckBarsBB2=10;

sinput string      _RSI2_="RSI";
input int         periodRSI2=8;
input ENUM_APPLIED_PRICE priceRSI2=PRICE_CLOSE;
input int         levelRSIsell2= 70;
input int         levelRSIbuy2 = 30;

sinput string      _ADX2_="ADX";
input int         periodADX2=10;
input int         levelADX2=5;

sinput string      _DM2_="DeMarker";
input int         periodDM2=1;
input double      levelDMsell2= 0.7;
input double      levelDMbuy2 = 0.3;

sinput string      _MA2_="MA";
input bool        UseMA2=true;
input int         MA_Period2=750;
input int        Ma_shift2=1; // сдвиг ма
input ENUM_MA_METHOD        Ma_type2=MODE_EMA; // тип ма
input ENUM_APPLIED_PRICE Ma_price2=PRICE_OPEN; // вид цены ма (7 видов)
input int        Slippage_MA2=70;

sinput string      _inp3_= "Для реверса параметры";
sinput string      _BB3_ = "Bollinger Bands";
input int         periodBB3=10;
input double         deviationBB3=2;
input int         bands_shiftBB3=0;
input ENUM_APPLIED_PRICE priceBBUP3  = PRICE_CLOSE;
input ENUM_APPLIED_PRICE priceBBDN3  = PRICE_CLOSE;
input int         CheckBarsBB3=10;

sinput string      _RSI3_="RSI";
input int         periodRSI3=8;
input ENUM_APPLIED_PRICE priceRSI3=PRICE_CLOSE;
input int         levelRSIsell3= 70;
input int         levelRSIbuy3 = 30;

sinput string      _ADX3_="ADX";
input int         periodADX3=1;
input int         levelADX3=10;

sinput string      _DM3_="DeMarker";
input int         periodDM3=1;
input double      levelDMsell3= 0.7;
input double      levelDMbuy3 = 0.3;

sinput string      par="----- ПАРАМЕТРЫ СОВЕТНИКА -------";
input double      Lots             =    0.01;
input double      Risk             =       0;
input int         MaxSpread        =       50;
input bool       Close_Revers=true;// закрывать все по обратному сигналу
input int        _Step_Input=0;
// отступать на лучшую цену при повторном входе 0-выкл.  

sinput string     S_11="<== TP/SL Settings ==>";             // >     >     >
input int        Sl               =      190;
input int        Tp               =      11;
input int        TP_SL_ATR_Period     = 300;         //TP/SL ATR Period
input double     TP_ATR_Multiplier      = 0;         //Dynamic TP: ATR Multiplier
input double     SL_ATR_Multiplier      = 0;         //Dynamic SL: ATR Multiplier

sinput string      MM_type="---- ВЫБОР СПОСОБА ММ 0-выкл, 1 - по сделке, 2 - по серии -------";
input int         Martin_Type=0;
//0- выкл. 1- наращивать лот по убытку в сделке, 2 - по убытку в серии
input double       Lots_exp=0;
// множитель ордеров серии
input int         MaxOrders=8;
// максимальное число открытых ордеров
sinput ulong        MAGIC=326753;
sinput string      OrdersComment="Survivor 1.3.7";
input ulong     MAXdeviation=20;  //Проскальзывание(*5)
input ENUM_TIMEFRAMES  Period_Indicators=PERIOD_M5;
//--------------------------------------------------------------------
enum Tick_generation_mode
  {
   Every_tick,//Все тики
   Open_prices_only,//Только цены открытия
  };
sinput Tick_generation_mode T_mode=Open_prices_only;//Режим работы советника на счете и при тестировании.
//--------------------------------------------------------------------
MqlRates mrate[];           // Будет содержать цены закрытия для каждого бара
MqlTick last_tick;
//--------------------------------------------------------------------
datetime prevtime=0,open_timeseria=0,tmC=0;
ulong    myTicket=0;
double   lots_=0,profit=0,MinPriceBuy=0,MaxPriceSell=0;
long     minstop=0,spread=0;
int      mp=1,orders_buy=0,orders_sell=0,pending=0,iMaxSpread=0;
int      Status=0,signal=0,signal_1=0,signal_2=0,signalrevers=0,ma=0,spr,stoptrade=0;
double   HistProfitSeria=0,LastCloseLots=0,LastCloseProfit=0;
bool     trade=true,IsNewBar=true;
int      SlipMA1=0,SlipMA2=0,Step_Input=0;
double   TakeProfit=0,StopLoss=0,ATR=0;
int      ATRhandle=0,RSI1handle=0,RSI2handle=0,RSI3handle=0,DM1handle=0,DM2handle=0,DM3handle=0,ADX1handle=0,ADX2handle=0,ADX3handle=0,BB1handle=0,BB2handle=0,BB3handle=0,MA1handle=0,MA2handle=0;
double   ATRarray[],adxsellarray[],adxbuyarray[],dmarray[],rsiarray[],bharray[],blarray[],MAarray[];
//+----------------------------------------------------------------------------+
int  _DayOfWeek=0;
//+----------------------------------------------------------------------------+
//|  expert initialization function                                            |
//+----------------------------------------------------------------------------+
int OnInit()
  {
   TesterHideIndicators(false);
   ATRhandle=iATR(NULL,Period_Indicators,TP_SL_ATR_Period);
   if(ATRhandle<0)
     {
      Print("Error creating ATRhandle indicator");
      return(false);
     }
   ArraySetAsSeries(ATRarray,true);
   BB1handle=iBands(NULL,Period_Indicators,periodBB1,bands_shiftBB1,deviationBB1,priceBBUP1);
   if(BB1handle<0)
     {
      Print("Error creating BB1 indicator");
      return(false);
     }
   BB2handle=iBands(NULL,Period_Indicators,periodBB2,bands_shiftBB2,deviationBB2,priceBBUP2);
   if(BB2handle<0)
     {
      Print("Error creating BB2 indicator");
      return(false);
     }
   BB3handle=iBands(NULL,Period_Indicators,periodBB3,bands_shiftBB3,deviationBB3,priceBBUP3);
   if(BB3handle<0)
     {
      Print("Error creating BB3 indicator");
      return(false);
     }
   ArraySetAsSeries(bharray,true);
   ArraySetAsSeries(blarray,true);
   RSI1handle=iRSI(NULL,Period_Indicators,periodRSI1,priceRSI1);
   if(RSI1handle<0)
     {
      Print("Error creating RSIhandle1 indicator");
      return(false);
     }
   RSI2handle=iRSI(NULL,Period_Indicators,periodRSI2,priceRSI2);
   if(RSI2handle<0)
     {
      Print("Error creating RSIhandle2 indicator");
      return(false);
     }
   RSI3handle=iRSI(NULL,Period_Indicators,periodRSI3,priceRSI3);
   if(RSI3handle<0)
     {
      Print("Error creating RSIhandle3 indicator");
      return(false);
     }
   ArraySetAsSeries(rsiarray,true);
   DM1handle=iDeMarker(NULL,Period_Indicators,periodDM1);
   if(DM1handle<0)
     {
      Print("Error creating dmhandle1 indicator");
      return(false);
     }
   DM2handle=iDeMarker(NULL,Period_Indicators,periodDM2);
   if(DM2handle<0)
     {
      Print("Error creating dmhandle2 indicator");
      return(false);
     }
   DM3handle=iDeMarker(NULL,Period_Indicators,periodDM3);
   if(DM3handle<0)
     {
      Print("Error creating dmhandle3 indicator");
      return(false);
     }
   ArraySetAsSeries(dmarray,true);
   ADX1handle=iADX(NULL,Period_Indicators,periodADX1);
   if(ADX1handle<0)
     {
      Print("Error creating ADX1 indicator");
      return(false);
     }
   ADX2handle=iADX(NULL,Period_Indicators,periodADX2);
   if(ADX2handle<0)
     {
      Print("Error creating ADX2 indicator");
      return(false);
     }
   ADX3handle=iADX(NULL,Period_Indicators,periodADX3);
   if(ADX3handle<0)
     {
      Print("Error creating ADX3 indicator");
      return(false);
     }
   ArraySetAsSeries(adxsellarray,true);
   ArraySetAsSeries(adxbuyarray,true);
   MA1handle=iMA(NULL,Period_Indicators,MA_Period1,Ma_shift1,Ma_type1,Ma_price1);
   if(MA1handle<0)
     {
      Print("Error creating iMA1 indicator");
      return(false);
     }
   MA2handle=iMA(NULL,Period_Indicators,MA_Period2,Ma_shift2,Ma_type2,Ma_price2);
   if(MA2handle<0)
     {
      Print("Error creating iMA2 indicator");
      return(false);
     }
   ArraySetAsSeries(MAarray,true);

// Установим индексацию в массивах котировок как в таймсериях(справа налево т.е. 0, 1, 2, 3 и т.д.).
   ArraySetAsSeries(mrate,true);
//---
   TakeProfit=Tp; StopLoss=Sl;SlipMA1=Slippage_MA1;SlipMA2=Slippage_MA2;Step_Input=_Step_Input;iMaxSpread=MaxSpread;

   if(_Digits==3 || _Digits==5) mp=10;
   StopLoss  *=mp;
   TakeProfit*=mp;
   Step_Input*=mp;
   SlipMA1   *=mp;
   SlipMA2   *=mp;
   iMaxSpread*=mp;

   m_trade.SetDeviationInPoints(MAXdeviation);

//Print(TakeProfit + "/"+ StopLoss);
   return(INIT_SUCCEEDED);
  }
//------------
void OnDeinit(const int reason)
  {
   IndicatorRelease(ATRhandle);
   IndicatorRelease(BB1handle);IndicatorRelease(BB2handle);IndicatorRelease(BB3handle);
   IndicatorRelease(RSI1handle);IndicatorRelease(RSI2handle);IndicatorRelease(RSI3handle);
   IndicatorRelease(DM1handle);IndicatorRelease(DM2handle);IndicatorRelease(DM3handle);
   IndicatorRelease(ADX1handle);IndicatorRelease(ADX2handle);IndicatorRelease(ADX3handle);
   IndicatorRelease(MA1handle);IndicatorRelease(MA2handle);
  }
//+----------------------------------------------------------------------------+
//|  expert start function                                                     |
//+----------------------------------------------------------------------------+
void OnTick()
  {
//--- Достаточно ли количество баров для работы
   if(Bars(_Symbol,Period_Indicators)<MA_Period1)
     {
      Alert("The chart has fewer bars than MA_Period1, the adviser will not work!!");
      return;
     }
   if(T_mode==Open_prices_only)
     {
      f_NewBar();
      //--- советник должен проверять условия совершения новой торговой операции только при новом баре
      if(IsNewBar==false)
        {
         return;
        }
     }
   stoptrade=0;

   Comment("");
   tmC=TimeCurrent();
   MqlDateTime tm;
   if(!TimeToStruct(tmC,tm))
     {
      Print("TimeToStruct() failed, ERR:",GetLastError());
      return;
     }
   _DayOfWeek=tm.day_of_week;

   if(Start_Monday_Minuts>0)
     {
      if(_DayOfWeek==1 && TimeCurrent()-iTime(NULL,PERIOD_D1,0)<Start_Monday_Minuts*60)
        {
         Comment("\n ПАУЗА В ТОРГОВЛЕ ",Start_Monday_Minuts,"  минут ");
         return;
        }
     }

   if(_DayOfWeek==5)
     {
      Status=OrdersScaner();
      if(Stop_Time_Friday!="" && (TimeCurrent()>=StringToTime(Stop_Time_Friday)))
        {
         stoptrade=1;
         if(Status==0)
           {Comment("\n ТОРГОВЛЯ ЗАВЕРШЕНА "); Sleep(3000);return;}
        }
      if(Close_Time_Friday!="" && Status>0 && TimeCurrent()>=StringToTime(Close_Time_Friday)){CloseAll();return;}
     }
//.......................    
   Status=OrdersScaner();
   signal=0;
//--- close signal
   if(Close_Revers && Status>0)
     {
      signalrevers=0;
      signalrevers=Signal(1,BB3handle,CheckBarsBB3,
                          RSI3handle,levelRSIsell3,levelRSIbuy3,ADX3handle,levelADX3,DM3handle,
                          levelDMsell3,levelDMbuy3);
      if(orders_buy >0 && signalrevers==-1){if(CloseAll()==1)Status=OrdersScaner();}//signal=signalrevers;
      if(orders_sell>0 && signalrevers== 1){if(CloseAll()==1)Status=OrdersScaner();}//signal=signalrevers;
     }

   if(stoptrade==1)return;
//.......................
   Status=OrdersScaner();
   if(Status==0)
     {// == 0 
      signal_1=0;
      signal_1=Signal(1,BB1handle,CheckBarsBB1,
                      RSI1handle,levelRSIsell1,levelRSIbuy1,ADX1handle,levelADX1,DM1handle,
                      levelDMsell1,levelDMbuy1);
      if(UseMA1)
        {
         ma=FilterMA(MA1handle,SlipMA1);
         if(signal_1>0 && ma<1 ) signal_1 = 0;
         if(signal_1<0 && ma>-1) signal_1 = 0;
        }
     }// == 0
   Status=OrdersScaner();
   if(Status>0)
     {// > 0
      signal_2=0;
      signal_2=Signal(1,BB2handle,CheckBarsBB2,
                      RSI2handle,levelRSIsell2,levelRSIbuy2,ADX2handle,levelADX2,DM2handle,
                      levelDMsell2,levelDMbuy2);
      if(UseMA2)
        {
         ma=FilterMA(MA2handle,SlipMA2);
         if(signal_2>0 && ma<1 ) signal_2 = 0;
         if(signal_2<0 && ma>-1) signal_2 = 0;
        }
     }// > 0

   if(TP_ATR_Multiplier>0 || SL_ATR_Multiplier>0)
     {
      //--- Используя хэндл индикатора, копируем новые значения индикаторных буферов в массив для ATR
      if(CopyBuffer(ATRhandle,0,0,3,ATRarray)<0)
        {
         Alert("Ошибка копирования буферов индикатора ATR - номер ошибки:",GetLastError(),"!!");
         return;
        }
      ATR=NormalizeDouble(ATRarray[1],_Digits);
      if(TP_ATR_Multiplier>0) TakeProfit=MathMax(ATR*TP_ATR_Multiplier/_Point,SymbolInfoInteger(Symbol(),SYMBOL_TRADE_STOPS_LEVEL));
      if(SL_ATR_Multiplier>0) StopLoss=MathMax(ATR*SL_ATR_Multiplier/_Point,SymbolInfoInteger(Symbol(),SYMBOL_TRADE_STOPS_LEVEL));
     }

//--- input---------------------|
   Status=OrdersScaner();
   if(Status==0)signal=signal_1;
   if(Status>0)signal=signal_2;
   if(signal==1 && Status<MaxOrders)
     {
      //-----------------------------------------------------------------
      if(Martin_Type==0) lots_=AutoMM_Count();
      else
        {
         SeriaHistory(open_timeseria);
         if(Martin_Type==2)
           {
            if(HistProfitSeria<0)
              {
               if(LastCloseProfit<0)lots_=LastCloseLots*Lots_exp;
               else lots_=LastCloseLots;
              }
            else {lots_=AutoMM_Count(); open_timeseria=TimeCurrent();}
           }
         if(Martin_Type==1)
           {
            if(LastCloseProfit<0)lots_=LastCloseLots*Lots_exp;
            else {lots_=AutoMM_Count(); open_timeseria=TimeCurrent();}
           }
        }
      //--- Получить исторические данные последних 3-х баров
      if(CopyRates(_Symbol,_Period,0,3,mrate)<0)
        {
         Alert("Ошибка копирования исторических данных в mrate- ошибка:",GetLastError(),"!!");
         return;
        }
      trade=true;
      if(orders_buy>0 && Step_Input>0)if(mrate[1].close>MinPriceBuy-Step_Input*_Point)trade=false; //if(MinPriceBuy-Step_Input*Point < Ask) trade=0;
      if(orders_sell>0) trade=false;
      if(trade)
        {
         spread=SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
         if(spread>iMaxSpread)
           {
            Print("Текущий Спред ",spread," больше MAXspread ",iMaxSpread);
            return;
           }
         if(OpenBuyMarket(MAGIC,lots_)>0) return;
        }
     }
   if(signal==-1 && Status<MaxOrders)
     {
      if(Martin_Type==0)lots_=AutoMM_Count();
      else
        {
         SeriaHistory(open_timeseria);
         if(Martin_Type==2)
           {
            if(HistProfitSeria<0)
              {
               if(LastCloseProfit<0)lots_=LastCloseLots*Lots_exp;
               else lots_=LastCloseLots;
              }
            else {lots_=AutoMM_Count(); open_timeseria=TimeCurrent();}
           }
         if(Martin_Type==1)
           {
            if(LastCloseProfit<0)lots_=LastCloseLots*Lots_exp;
            else {lots_=AutoMM_Count(); open_timeseria=TimeCurrent();}
           }
        }
      //--- Получить исторические данные последних 3-х баров
      if(CopyRates(_Symbol,_Period,0,3,mrate)<0)
        {
         Alert("Ошибка копирования исторических данных в mrate- ошибка:",GetLastError(),"!!");
         return;
        }
      trade=true;
      if(orders_sell>0 && Step_Input>0)if(mrate[1].close<MaxPriceSell+Step_Input*_Point)trade=false; //if(MaxPriceSell+Step_Input*Point > Bid)trade=0;
      if(orders_buy>0)trade=false;
      if(trade)
        {
         spread=SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
         if(spread>iMaxSpread)
           {
            Print("Текущий Спред ",spread," больше MAXspread ",iMaxSpread);
            return;
           }
         if(OpenSellMarket(MAGIC,lots_)>0) return;
        }
     }
   if(_LastError!=0) Print("OnTick()(поиск ошибок в завершение)Error ",_LastError);ResetLastError();
//---   
   return;
  }
//+------------------------------------------------------------------+++++++++++++++++++++++++++----------------------------------------------------------|
bool f_NewBar()
  {
// Для сохранения значения времени бара мы используем static-переменную Old_Time.
// При каждом выполнении функции OnTick мы будем сравнивать время текущего бара с сохраненным временем.
// Если они не равны, это означает, что начал строится новый бар.

   static datetime Old_Time;
   datetime New_Time[1];
   IsNewBar=false;
// копируем время текущего бара в элемент New_Time[0]
   int copied=CopyTime(_Symbol,_Period,0,1,New_Time);
   if(copied>0) // ok, успешно скопировано
     {
      if(Old_Time!=New_Time[0]) // если старое время не равно времени нового бара
        {
         IsNewBar=true;   // новый бар
         if(MQL5InfoInteger(MQL5_DEBUGGING)) Print("Новый бар",New_Time[0],"старый бар",Old_Time); //для режима отладки, если он включен
         Old_Time=New_Time[0];   // сохраняем время бара
        }
     }
   else
     {
      Alert("Ошибка копирования времени, номер ошибки =",GetLastError());
     }
   return(IsNewBar);
  }
//-------------------------------------------------------------------
void Set_gld(string name,double x)
  {
   if(!GlobalVariableCheck(name))GlobalVariableSet(name,x);
   if((GlobalVariableGet(name)-x)!=0)GlobalVariableSet(name,x);
  }
//-------------------------------------------------------------------
double Gld(string name){return(GlobalVariableGet(name));}
//--------------------------------------------------------------------
//+------------------------------------------------------------------+
double AutoMM_Count()
  { //Расчет лота при указании процента риска в настройках.

   if(Risk == 0) return(Lots);

   double lot=Lots;
   double TickValue=0;
   int a=0;
   do
     {
      TickValue=SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE);
      a++;
      if(TickValue==0) Sleep(500);
     }
   while(TickValue==0 && a<10);
   if(TickValue==0) { Print("TickValue Error"); lot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN); return(lot); }

   lot=((AccountInfoDouble(ACCOUNT_BALANCE)-AccountInfoDouble(ACCOUNT_CREDIT))*(Risk/100))/StopLoss/TickValue;
   lot=MathFloor(lot/SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP)) *SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP); //округление полученного лота вниз
   lot=MathMin(MathMax(lot,SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN)),SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX)); //сравнение полученнго лота с минимальным/максимальным.

   return (lot);
  }
//----------------------------------------------------------------------------------
double SeriaHistory(datetime OpenTimeSeria)
  {
   datetime time=0,OrderCloseTime=0;  int orders_seria=0;  HistProfitSeria=0;
   LastCloseLots=0; LastCloseProfit=0;
   if(OpenTimeSeria==0)return(0);// no seria
   else
     {
      if(!HistorySelect(TimeCurrent()-PeriodSeconds(PERIOD_W1),TimeCurrent()))
        {Print("История не выбранна ",GetLastError());}
      for(int i=HistoryDealsTotal();i>=1;i--)
        {
         if(mydeal.SelectByIndex(i-1))
            myTicket=mydeal.Ticket();
         if(mydeal.Symbol()!=_Symbol)continue;
         if(mydeal.Magic()!=MAGIC)continue;
         if(HistoryDealGetInteger(myTicket,DEAL_ENTRY)==DEAL_ENTRY_OUT)
            OrderCloseTime=mydeal.Time();
           {
            if(OrderCloseTime<=OpenTimeSeria)continue;
           }
         if(mydeal.DealType()<=1)
           {
            orders_seria++;
            HistProfitSeria+=mydeal.Profit()+mydeal.Swap();
            if(OrderCloseTime>time)
              {
               time=OrderCloseTime;
               LastCloseLots=mydeal.Volume();
               LastCloseProfit=mydeal.Profit()-mydeal.Swap();
              }
           }
        }
     }

//Print(" Последний профит ",LastCloseProfit); 
   return(HistProfitSeria);
  }
//-----------------------------------------------------------------------

//------------------------------------------------------------------------------
int Signal(int i,int BBhandle,int CheckBarsBB,
           int rsihandle,int levelRSIsell,int levelRSIbuy,int adxhandle,int levelADX,int dmhandle,
           double levelDMsell,double levelDMbuy)
  {
   int BB=0;
   BB=GetBB(i,BBhandle,CheckBarsBB);

   if(BB == 0) return(0);
   if(BB == -1)
     {
      int RSIbuffer=CopyBuffer(rsihandle,0,0,3,rsiarray);
      if(RSIbuffer<0)
        {
         Print("Ошибка копирования буферов индикатора RSI - номер ошибки:",GetLastError(),"!!");
         return(-1);
        }
      if(rsiarray[i]>=levelRSIsell)
        {
         if(CopyBuffer(dmhandle,0,0,3,dmarray)<0)
           {
            Print("Ошибка копирования буферов индикатора iDeMarker - номер ошибки:",GetLastError(),"!!");
            return(-1);
           }
         if(dmarray[i]>=levelDMsell)
           {
            if(CopyBuffer(adxhandle,1,0,3,adxsellarray)<0)
              {
               Print("Ошибка копирования буферов индикатора ADXplus - номер ошибки:",GetLastError(),"!!");
               return(-1);
              }
            if(adxsellarray[i]>=levelADX)return(-1);

           }
        }
     }
   if(BB==1)
     {
      int RSIbuffer=CopyBuffer(rsihandle,0,0,3,rsiarray);
      if(RSIbuffer<0)
        {
         Print("Ошибка копирования буферов индикатора RSI - номер ошибки:",GetLastError(),"!!");
         return(-1);
        }
      if(rsiarray[i]<=levelRSIbuy)
        {
         if(CopyBuffer(dmhandle,0,0,3,dmarray)<0)
           {
            Print("Ошибка копирования буферов индикатора iDeMarke - номер ошибки:",GetLastError(),"!!");
            return(-1);
           }
         if(dmarray[i]<=levelDMbuy)
           {
            if(CopyBuffer(adxhandle,2,0,3,adxbuyarray)<0)
              {
               Print("Ошибка копирования буферов индикатора ADXmin - номер ошибки:",GetLastError(),"!!");
               return(-1);
              }
            if(adxbuyarray[i]>=levelADX)return(1);
           }
        }
     }
   return(0);
  }
//------------------------------------------------------------------------------
int GetBB(int ii,int BBhandle,int CheckBarsBB)
  {
   int dn=0,up=0;
   int j;
   int countBB=ii+CheckBarsBB+1;
// массив котировок
   ArraySetAsSeries(mrate,true);
//--- Получить исторические данные последних баров
   if(CopyRates(_Symbol,_Period,0,countBB,mrate)<0)
     {
      Alert("Ошибка копирования исторических данных mrateGetBB- ошибка:",GetLastError(),"!!");
      return(-1);
     }
   for(j=ii; j<=ii+CheckBarsBB; j++)
     {
      if(CopyBuffer(BBhandle,1,0,countBB,bharray)<0)
        {
         Print("Ошибка копирования буферов индикатора BBbh - номер ошибки:",GetLastError(),"!!");
         return(-1);
        }
      if(CopyBuffer(BBhandle,2,0,countBB,blarray)<0)
        {
         Print("Ошибка копирования буферов индикатора BBbl - номер ошибки:",GetLastError(),"!!");
         return(-1);
        }
      if(mrate[j].close>=bharray[j]) {dn++;break;}
      if(mrate[j].close<=blarray[j]) {up++;break;}
     }
   if(dn>0)return(-1);
   if(up>0)return( 1);
   return(0);
  }
//+----------------------------------------------------------------------------+
int FilterMA(int MAhandle,int Slippage_MA)
  {
   double g_iclose_376=iClose(NULL,0,1);

   if(CopyBuffer(MAhandle,0,0,3,MAarray)<0)
     {
      Print("Ошибка копирования буферов индикатора MA - номер ошибки:",GetLastError(),"!!");
      return(-1);
     }

   double g_ima_408=MAarray[1];

   if( g_iclose_376 > g_ima_408 + Slippage_MA * _Point ) return(1);
   if( g_iclose_376 < g_ima_408 - Slippage_MA * _Point ) return(-1);

   return(0);
  }
//+------------------------------------------------------------------+ 
int OrdersScaner()
  { //------------------сканер ордеров ---------   
   myTicket=0;int status;
   orders_buy=0;orders_sell=0;//profit=0;
   MinPriceBuy=0;MaxPriceSell=0;//pending=0;
   int pTotal=PositionsTotal();
   for(int i=pTotal-1;i>=0;i--)
     {
      if((myTicket=PositionGetTicket(i))>0)
        {
         if(PositionGetSymbol(i)==_Symbol)
           {
            if(PositionGetInteger(POSITION_MAGIC)==MAGIC)
              {
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                 {
                  orders_buy++;
                  if(orders_buy==1) MinPriceBuy=PositionGetDouble(POSITION_PRICE_OPEN);
                  if(orders_buy>1 && PositionGetDouble(POSITION_PRICE_OPEN)<MinPriceBuy) MinPriceBuy=PositionGetDouble(POSITION_PRICE_OPEN);
                 }
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                 {
                  orders_sell++;
                  if(orders_sell==1) MaxPriceSell=PositionGetDouble(POSITION_PRICE_OPEN);
                  if(orders_sell>1 && PositionGetDouble(POSITION_PRICE_OPEN)>MaxPriceSell) MaxPriceSell=PositionGetDouble(POSITION_PRICE_OPEN);
                 }
              }
           }
        }
     }
   status=orders_buy+orders_sell;
   return(status);
  }
//--------------------------------------------------------------------------------------
ulong OpenBuyMarket(ulong Magic,double lot)
  {
   double AID=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(AID<10)
     {
/* NOT_ENOUGH_MONEY */
      Print("Нет или не хватает для открытия  свободных средств");
      Comment("Нет или не хватает для открытия  свободных средств"); Sleep(5000);return(0);
     }

// while(IsTradeContextBusy()) Sleep(1000); RefreshRates();
   SymbolInfoTick(_Symbol,last_tick);
   double Ask=last_tick.ask,Bid=last_tick.bid;
   myTicket=0;
// for(int i=0; i<=5; i++)
//   {
   double tp=0,sl=0;
   if(StopLoss!=0) sl=NormalizeDouble(Ask-StopLoss*_Point,_Digits); //else sl = 0;
   if(TakeProfit!=0) tp=NormalizeDouble(Ask+TakeProfit*_Point,_Digits); //else tp = 0;
   m_trade.SetExpertMagicNumber(Magic);
   if(!m_trade.Buy(lot,_Symbol,0,sl,tp,OrdersComment+"|BUY_"+IntegerToString(orders_buy+1)))
      Print("Expert name: ",__FILE__,"Ошибка открытия ордера на покупку! #",GetLastError(),",реткод ",m_trade.CheckResultRetcode());
   else myTicket=m_trade.ResultOrder();
   Print("Expert name: ",__FILE__,", Открыта сделка ","|BUY_"+IntegerToString(orders_buy+1)," с магиком №: ",IntegerToString(m_trade.RequestMagic()),", Cпред ",SymbolInfoInteger(_Symbol,SYMBOL_SPREAD),",тикет ",myTicket
         ,",реткод ",m_trade.ResultRetcode());
//  }

//OrdersScaner();
   return(myTicket);
  }
//----------------------------------------------------------------------------------------
ulong OpenSellMarket(ulong Magic,double lot)
  {
   double AID=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(AID<10)
     {
/* NOT_ENOUGH_MONEY */
      Print("Нет или не хватает для открытия  свободных средств");
      Comment("Нет или не хватает для открытия  свободных средств"); Sleep(5000);return(0);
     }

// while(IsTradeContextBusy()) Sleep(1000); RefreshRates();
   SymbolInfoTick(_Symbol,last_tick);
   double Ask=last_tick.ask,Bid=last_tick.bid;
   myTicket=0;
//   for(int i=0; i<=5; i++)
//   {
   double tp=0,sl=0;
   if(StopLoss!=0) sl=NormalizeDouble(Bid+StopLoss*_Point,_Digits); //else sl = 0;
   if(TakeProfit!=0) tp=NormalizeDouble(Bid-TakeProfit*_Point,_Digits); //else tp = 0;
   m_trade.SetExpertMagicNumber(Magic);
   if(!m_trade.Sell(lot,_Symbol,0,sl,tp,OrdersComment+"|SELL_"+IntegerToString(orders_sell+1)))
      Print("Expert name: ",__FILE__,"Ошибка открытия ордера на продажу ! #",GetLastError(),",реткод ",m_trade.CheckResultRetcode());
   else myTicket=m_trade.ResultOrder();
   Print("Expert name: ",__FILE__,", Открыта сделка ","|SELL_"+IntegerToString(orders_sell+1)," с магиком №: ",IntegerToString(m_trade.RequestMagic()),", Cпред ",SymbolInfoInteger(_Symbol,SYMBOL_SPREAD),",тикет ",myTicket
         ,",реткод ",m_trade.ResultRetcode());
//     }

// OrdersScaner();
   return(myTicket);
  }
//--------------------------------------------------------------------
//--------------------------------------------------------------------
int CloseAll()
  {// функция КИМА ему респект
//Print("ЗАКРЫВАЕМ ВСЕ ПОЗЫ"); 
   int    NumberOfTry=6;               // Количество попыток
   int    PauseAfterError=5;              // Пауза после ошибки в секундах
   int    i,it,cnt=0;
   bool   fc;
   ulong  magic=0;
   myTicket=0;
   for(i=PositionsTotal()-1; i>=0; i--)
     {
      if((myTicket=PositionGetTicket(i))>0)
        {
         if(PositionGetSymbol(i)==_Symbol)
           {
            magic=PositionGetInteger(POSITION_MAGIC);
            if(magic==MAGIC)
              {
               for(it=1; it<=NumberOfTry; it++)
                 {
                  if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                    {
                     fc=m_trade.PositionClose(myTicket,MAXdeviation);
                     if(fc) {Print(__FUNCTION__," Закрыта позиция Buy"); break;}
                     else Print("Ошибка закрытия позиции на покупку через CloseAll() #",GetLastError());Sleep(1000*PauseAfterError);
                    }
                  if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                    {
                     fc=m_trade.PositionClose(myTicket,MAXdeviation);
                     if(fc) {Print(__FUNCTION__," Закрыта позиция Sell"); break;}
                     else Print("Ошибка закрытия позиции на продажу через CloseAll() #",GetLastError());Sleep(1000*PauseAfterError);
                    }
                 }
              }
           }
        }
     }
//--------- проверка выполнения закрытия ---------------
   for(i=PositionsTotal()-1; i>=0; i--)
     {
      if(PositionGetSymbol(i)!=_Symbol) continue;
      magic=PositionGetInteger(POSITION_MAGIC);
      if(magic!=MAGIC) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY || PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)cnt++;
     }
   if(cnt==0)return(1);
   else return (0);
  }
//--------------------------------------------------------------------------------------
