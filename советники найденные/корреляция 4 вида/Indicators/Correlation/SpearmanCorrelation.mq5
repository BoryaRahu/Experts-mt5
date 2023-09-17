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
#property indicator_color1 clrCrimson
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
#property indicator_label1  "SpearmanCorr"

//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int                  rangeN=10;           //Rang Calc     
//----
double multiply,R2[],TrueRanks[],ExtLineBuffer[];
int    PriceInt[],SortInt[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- memory distribution for variables' arrays   
   ArrayResize(R2,rangeN);
   ArrayResize(PriceInt,rangeN);
   ArrayResize(SortInt,rangeN);
   ArraySetAsSeries(SortInt,true);
   ArrayResize(TrueRanks,rangeN);
//---- initialization of variables
   multiply=MathPow(10,_Digits);
//---- set ExtLineBuffer dynamic array as an indicator buffer
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

   for(int i=limit; i>=0; i--)
     {
      for(int k=0; k<rangeN; k++)
         PriceInt[k]=int(price[i+k]*multiply);

      RankPrices(TrueRanks,PriceInt);
      ExtLineBuffer[i]=SpearmanCalc(R2,rangeN);
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Расчет коэффициента корреляции Спирмена                          |
//+------------------------------------------------------------------+
double SpearmanCalc(double &Ranks[],int N)
  {
//----
   double sumd2=0.0;

   for(int i=0; i<N; i++)
      sumd2+=MathPow(Ranks[i]-i-1,2);

   return(1-6*sumd2/(N*(MathPow(N,2)-1)));
  }
//+------------------------------------------------------------------+
//| Ранжирование цен                                                 |
//+------------------------------------------------------------------+
void RankPrices(double &TrueRanks_[],int &InitialArray[])
  {
//----
   int i,k,m,dublicat,counter,etalon;
   double dcounter,averageRank;

   ArrayCopy(SortInt,InitialArray,0,0,WHOLE_ARRAY);

   for(i=0; i<rangeN; i++)
      TrueRanks_[i]=i+1;

   ArraySort(SortInt);

   for(i=0; i<rangeN-1; i++)
     {
      if(SortInt[i]!=SortInt[i+1])
         continue;

      dublicat=SortInt[i];
      k=i+1;
      counter=1;
      averageRank=i+1;

      while(k<rangeN)
        {
         if(SortInt[k]==dublicat)
           {
            counter++;
            averageRank+=k+1;
            k++;
           }
         else
            break;
        }
      dcounter=counter;
      averageRank=averageRank/dcounter;

      for(m=i; m<k; m++)
         TrueRanks_[m]=averageRank;
      i=k;
     }

   for(i=0; i<rangeN; i++)
     {
      etalon=InitialArray[i];
      k=0;
      while(k<rangeN)
        {
         if(etalon==SortInt[k])
           {
            R2[i]=TrueRanks_[k];
            break;
           }
         k++;
        }
     }
//----
   return;
  }
//+------------------------------------------------------------------+
