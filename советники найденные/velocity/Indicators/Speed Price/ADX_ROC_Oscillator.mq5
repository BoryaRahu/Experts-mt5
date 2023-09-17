//+------------------------------------------------------------------+
//|                                           ADX_ROC_Oscillator.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "ADX ROC Oscillator"
#property description "This oscillator is trying to distinguish fast"
#property description "moving market (Strong Trend) from slow moving one."
#property description "Calculates the difference between the current value"
#property description "of ADX indicator and its value N periods ago."
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   4
//--- plot Fast
#property indicator_label1  "Fast"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Middle
#property indicator_label2  "Middle"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Slow
#property indicator_label3  "Slow"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot ARXROC
#property indicator_label4  "ARXROC"
#property indicator_type4   DRAW_COLOR_HISTOGRAM
#property indicator_color4  clrGreen,clrBlue,clrRed,clrDarkGray
#property indicator_style4  STYLE_SOLID
#property indicator_width4  8
//--- input parameters
input uint     InpPeriodADX   =  14;   // ADX period
input uint     InpPeriodROC   =  1;    // ROC period
input double   InpLevFast     =  4.0;  // Fast threshold
input double   InpLevSlow     =  2.5;  // Slow threshold
//--- indicator buffers
double         BufferFast[];
double         BufferMiddle[];
double         BufferSlow[];
double         BufferADXROC[];
double         BufferColors[];
double         BufferADX[];
//--- global variables
double         level_fast;
double         level_slow;
int            period_adx;
int            period_roc;
int            handle_adx;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_adx=int(InpPeriodADX<1 ? 1 : InpPeriodADX);
   period_roc=int(InpPeriodROC<1 ? 1 : InpPeriodROC);
   level_fast=(InpLevFast);
   level_slow=(InpLevSlow>=level_fast ? level_fast-0.1 : InpLevSlow);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferFast,INDICATOR_DATA);
   SetIndexBuffer(1,BufferMiddle,INDICATOR_DATA);
   SetIndexBuffer(2,BufferSlow,INDICATOR_DATA);
   SetIndexBuffer(3,BufferADXROC,INDICATOR_DATA);
   SetIndexBuffer(4,BufferColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,BufferADX,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,32);
   PlotIndexSetInteger(1,PLOT_ARROW,32);
   PlotIndexSetInteger(2,PLOT_ARROW,32);
//--- setting plot buffer parameters
   PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferFast,true);
   ArraySetAsSeries(BufferMiddle,true);
   ArraySetAsSeries(BufferSlow,true);
   ArraySetAsSeries(BufferADXROC,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(BufferADX,true);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"ADX ROC Osc("+(string)period_adx+","+(string)period_roc+","+DoubleToString(level_fast,1)+","+DoubleToString(level_slow,1)+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetInteger(INDICATOR_LEVELS,4);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,level_fast);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,level_slow);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,-level_slow);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,-level_fast);
//--- create ADX handles
   ResetLastError();
   handle_adx=iADX(NULL,PERIOD_CURRENT,period_adx);
   if(handle_adx==INVALID_HANDLE)
     {
      Print("The iADX(",(string)period_adx,") object was not created: Error ",GetLastError());
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
//--- Проверка количества доступных баров
   if(rates_total<fmax(period_roc,4)) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_roc-1;
      ArrayInitialize(BufferFast,EMPTY_VALUE);
      ArrayInitialize(BufferMiddle,EMPTY_VALUE);
      ArrayInitialize(BufferSlow,EMPTY_VALUE);
      ArrayInitialize(BufferADXROC,EMPTY_VALUE);
      ArrayInitialize(BufferColors,3);
      ArrayInitialize(BufferADX,0);
     }
//--- Подготовка данных
   int count=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(handle_adx,MAIN_LINE,0,count,BufferADX);
   if(copied!=count) return 0;

//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      BufferADXROC[i]=BufferADX[i]-BufferADX[i+period_roc];
      double diff=fabs(BufferADXROC[i]);
      BufferColors[i]=3;
      if(diff>=level_fast)
        {
         BufferFast[i]=BufferADXROC[i];
         BufferColors[i]=0;
        }
      else
        {
         if(diff<=level_slow)
           {
            BufferSlow[i]=BufferADXROC[i];
            BufferColors[i]=2;
           }
         else
           {
            BufferMiddle[i]=BufferADXROC[i];
            BufferColors[i]=1;
           }
        }
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
