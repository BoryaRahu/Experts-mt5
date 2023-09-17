//+------------------------------------------------------------------+
//|                                          SpearmanCorrelation.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                           https://www.mql5.com/ru/users/alex2356 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com/ru/users/alex2356"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window 
//---- number of the indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
#property indicator_minimum -1
#property indicator_maximum 1
//+------------------------------------------------------------------+
//|  Indicator drawing parameters                                    |
//+------------------------------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- dodger blue color is used for the indicator line
#property indicator_color1 clrBlueViolet
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1  2
//---- the indicator horizontal levels parameters
#property indicator_level1  +0.75
#property indicator_level2  -0.75
#property indicator_levelcolor DodgerBlue
#property indicator_levelstyle STYLE_DOT
//---- displaying the indicator label
#property indicator_label1  "PearsonCorr"
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int                  rangeN=10;           //Rang Calc      
//----
double ExtLineBuffer[],PriceInt[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArrayResize(PriceInt,rangeN);
   ArrayInitialize(PriceInt,0.0);
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rangeN);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(ExtLineBuffer,true);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const int begin,          // bars reliable counting beginning index
                const double &price[]
                )

  {
   if(rates_total<rangeN+begin)
      return(0);
   int limit;

   if(prev_calculated>rates_total || prev_calculated<=0)
     {
      limit=rates_total-2-rangeN-begin;
      if(begin>0)
         PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rangeN+begin);
     }
   else
      limit=rates_total-prev_calculated;

   ArraySetAsSeries(price,true);

   for(int i=0; i<=limit; i++)
     {
      for(int k=0; k<rangeN; k++)
         PriceInt[k]=price[k+i];
      ExtLineBuffer[i]=PearsonCalc(PriceInt,rangeN);
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Расчет числителя формулы                                         |
//+------------------------------------------------------------------+
double Numerator(double &Ranks[],int N)
  {
//----
   double Y[],dx[],dy[],mx=0.0,my=0.0,sum=0.0,sm=0.0;
   ArrayResize(Y,N);
   ArrayResize(dx,N);
   ArrayResize(dy,N);

   int n=N;
   for(int i=0; i<N; i++)
     {
      Y[i]=n;
      n--;
     }

   mx=Average(Y);
   my=Average(Ranks);

   for(int j=0;j<N;j++)
     {
      dx[j]=Y[j]-mx;
      dy[j]=Ranks[j]-my;
      sm+=dx[j]*dy[j];
     }
   return sm;
  }
//+------------------------------------------------------------------+
//| Расчет знаменателя формулы                                       |
//+------------------------------------------------------------------+
double Denominator(double &Ranks[],int N)
  {
//----
   double Y[],dx2[],dy2[],mx=0.0,my=0.0,sum=0.0,smx2=0.0,smy2=0.0;
   ArrayResize(Y,N);
   ArrayResize(dx2,N);
   ArrayResize(dy2,N);

   int n=N;
   for(int i=0; i<N; i++)
     {
      Y[i]=n;
      n--;
     }

   mx=Average(Y);
   my=Average(Ranks);

   for(int j=0;j<N;j++)
     {
      dx2[j]=MathPow(Y[j]-mx,2);
      dy2[j]=MathPow(Ranks[j]-my,2);
      smx2+=dx2[j];
      smy2+=dy2[j];
     }
   return(MathSqrt(smx2*smy2));
  }
//+------------------------------------------------------------------+
//| Расчет коэффициента корреляции Пирсона                           |
//+------------------------------------------------------------------+
double PearsonCalc(double &Ranks[],int N)
  {
   double ch,zn;
   ch=Numerator(Ranks,N);
   zn=Denominator(Ranks,N);
   return (ch/zn);
  }
//+------------------------------------------------------------------+
//| Cреднее арифметическое по всей выборке                           |
//+------------------------------------------------------------------+
double Average(double &arr[])
  {
   int size=ArraySize(arr);
   double Sum=0.0;
   for(int i=0; i<size; i++)
      Sum+=arr[i];
   return(Sum/size);
  }
//+------------------------------------------------------------------+
