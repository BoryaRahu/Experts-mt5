//+------------------------------------------------------------------+
//|                                                          CAM.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Coordinated ADX and MACD indicator"
#property description "As described in the article \"The CAM Indicator For Trends And Countertrends\""
#property description "by Barbara Star. January 2018 Issue of S&C Magazin."

#property indicator_chart_window
#property indicator_buffers 11
#property indicator_plots   5
//--- plot Uptrend
#property indicator_label1  "Uptrend"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Downtrend
#property indicator_label2  "Downtrend"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Pullback
#property indicator_label3  "Pullback"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrOrange
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot Counter trend
#property indicator_label4  "Counter trend"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrBlue
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- plot Candle
#property indicator_label5  "Open;High;Low;Close"
#property indicator_type5   DRAW_COLOR_CANDLES
#property indicator_color5  clrGreen,clrRed,clrOrange,clrBlue,clrGray
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//--- input parameters
input uint     InpPeriodADX   =  10;   // ADX period
input uint     InpPeriodFast  =  12;   // MACD Fast EMA period
input uint     InpPeriodSlow  =  26;   // MACD Slow EMA period
//--- indicator buffers
double         BufferUT[];
double         BufferDT[];
double         BufferPB[];
double         BufferCT[];
double         BufferCandleO[];
double         BufferCandleH[];
double         BufferCandleL[];
double         BufferCandleC[];
double         BufferColors[];
double         BufferADX[];
double         BufferMACD[];
//--- global variables
int            period_adx;
int            period_fast;
int            period_slow;
int            period_max;
int            handle_adx;
int            handle_macd;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_adx=int(InpPeriodADX<1 ? 1 : InpPeriodADX);
   period_fast=int(InpPeriodFast<1 ? 1 : InpPeriodFast);
   period_slow=int(InpPeriodSlow==period_fast ? period_fast+1 : InpPeriodSlow<1 ? 1 : InpPeriodSlow);
   period_max=fmax(period_adx,fmax(period_fast,period_slow));
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUT,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDT,INDICATOR_DATA);
   SetIndexBuffer(2,BufferPB,INDICATOR_DATA);
   SetIndexBuffer(3,BufferCT,INDICATOR_DATA);
   SetIndexBuffer(4,BufferCandleO,INDICATOR_DATA);
   SetIndexBuffer(5,BufferCandleH,INDICATOR_DATA);
   SetIndexBuffer(6,BufferCandleL,INDICATOR_DATA);
   SetIndexBuffer(7,BufferCandleC,INDICATOR_DATA);
   SetIndexBuffer(8,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(9,BufferADX,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,BufferMACD,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   for(int i=0;i<4;i++)
      PlotIndexSetInteger(i,PLOT_ARROW,158);
   IndicatorSetString(INDICATOR_SHORTNAME,"CAM("+(string)period_adx+","+(string)period_fast+","+(string)period_slow+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting plot buffer parameters
   PlotIndexSetInteger(4,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferUT,true);
   ArraySetAsSeries(BufferDT,true);
   ArraySetAsSeries(BufferPB,true);
   ArraySetAsSeries(BufferCT,true);
   ArraySetAsSeries(BufferCandleO,true);
   ArraySetAsSeries(BufferCandleH,true);
   ArraySetAsSeries(BufferCandleL,true);
   ArraySetAsSeries(BufferCandleC,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferADX,true);
   ArraySetAsSeries(BufferMACD,true);
//--- create handles
   ResetLastError();
   handle_adx=iADX(NULL,PERIOD_CURRENT,period_adx);
   if(handle_adx==INVALID_HANDLE)
     {
      Print("The iADX(",(string)period_adx,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_macd=iMACD(NULL,PERIOD_CURRENT,period_fast,period_slow,1,PRICE_CLOSE);
   if(handle_macd==INVALID_HANDLE)
     {
      Print("The iMACD(",(string)period_fast,",",(string)period_slow,"1) object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_max,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-2;
      ArrayInitialize(BufferUT,EMPTY_VALUE);
      ArrayInitialize(BufferDT,EMPTY_VALUE);
      ArrayInitialize(BufferPB,EMPTY_VALUE);
      ArrayInitialize(BufferCT,EMPTY_VALUE);
      ArrayInitialize(BufferCandleO,EMPTY_VALUE);
      ArrayInitialize(BufferCandleH,EMPTY_VALUE);
      ArrayInitialize(BufferCandleL,EMPTY_VALUE);
      ArrayInitialize(BufferCandleC,EMPTY_VALUE);
      ArrayInitialize(BufferColors,4);
      ArrayInitialize(BufferADX,0);
      ArrayInitialize(BufferMACD,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_adx,MAIN_LINE,0,count,BufferADX);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_macd,MAIN_LINE,0,count,BufferMACD);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0; i--)
     {
      BufferUT[i]=BufferDT[i]=BufferPB[i]=BufferCT[i]=EMPTY_VALUE;
      BufferCandleO[i]=open[i];
      BufferCandleH[i]=high[i];
      BufferCandleL[i]=low[i];
      BufferCandleC[i]=close[i];
      int status=CheckStatus(i);
      BufferColors[i]=status;
      if(status==0)
         BufferUT[i]=open[i];
      else if(status==1)
         BufferDT[i]=open[i];
      else if(status==2)
         BufferPB[i]=open[i];
      else if(status==3)
         BufferCT[i]=open[i];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Проверяет соотношение линий                                      |
//+------------------------------------------------------------------+
int CheckStatus(const int shift)
  {
   return
   (
    BufferADX[shift]>=BufferADX[shift+1] && BufferMACD[shift]>BufferMACD[shift+1] ? 0 :
    BufferADX[shift]<=BufferADX[shift+1] && BufferMACD[shift]<BufferMACD[shift+1] ? 1 :
    BufferADX[shift]>=BufferADX[shift+1] && BufferMACD[shift]<BufferMACD[shift+1] ? 2 :
    BufferADX[shift]<=BufferADX[shift+1] && BufferMACD[shift]>BufferMACD[shift+1] ? 3 : 4
    );
  }
//+------------------------------------------------------------------+
