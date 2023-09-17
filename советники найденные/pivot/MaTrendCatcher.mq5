//+------------------------------------------------------------------+
//|                                               MaTrendCatcher.mq5 |
//|                                           Copyright 2017, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, denkir"
#property link      "https://login.mql5.com/ru/users/denkir"
#property version   "1.00"
#property indicator_separate_window
//--- число буферов
#define BUF_NUM 3      
#property indicator_buffers BUF_NUM
#property indicator_plots 1   
#property indicator_type1 DRAW_COLOR_HISTOGRAM
#property indicator_color1 clrRed,clrGreen
#property indicator_width1 3 
//---
#include <Indicators\Trend.mqh>
//+------------------------------------------------------------------+
//| Структура индикаторного буфера                                   |
//+------------------------------------------------------------------+
struct SBuffer
  {
   double            data[];
   ENUM_INDEXBUFFER_TYPE type;
  };

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input int InpFastMaPeriod=55;                         // Быстрая МА
input int InpSlowMaPeriod=100;                        // Медленная МА
input ENUM_MA_METHOD InpMaType=MODE_EMA;              // Тип МА
input int InpCutoff=0;                                // Отсечка, пп
input int InpBarsToPlot=100;                          // Баров для отрисовки

//+------------------------------------------------------------------+
//| Globals                                                          |
//+------------------------------------------------------------------+
//---- индикаторные буферы
SBuffer gBuffers[BUF_NUM];
CiMA *gPtrMas[2];
int gBeginBar;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- проверить периоды
   if(InpFastMaPeriod>=InpSlowMaPeriod)
     {
      Print("Неправильно заданы периоды средних!");
      return INIT_FAILED;
     }
//--- буферы
   ENUM_INDEXBUFFER_TYPE buff_types[]=
     {
      INDICATOR_DATA,INDICATOR_COLOR_INDEX,INDICATOR_CALCULATIONS
     };
   for(int buff_idx=0;buff_idx<BUF_NUM;buff_idx++)
     {
      //--- маппинг
      SetIndexBuffer(buff_idx,gBuffers[buff_idx].data,buff_types[buff_idx]);
      //--- пустое значение равно 0
      PlotIndexSetDouble(buff_idx,PLOT_EMPTY_VALUE,0.);
      ArraySetAsSeries(gBuffers[buff_idx].data,true);
     }
//--- цвета
   PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,2);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrGreen);   // нулевой индекс -> зелёный
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,clrRed);     // первый индекс  -> красный
//--- если баров не хватает 
   int bars_num=Bars(_Symbol,_Period);
   if(bars_num<InpBarsToPlot)
      gBeginBar=bars_num-1;
   else
      gBeginBar=InpBarsToPlot-1;
//--- начало отрисовки
   int plot_start=bars_num-gBeginBar-1;
   if(plot_start<0)
      plot_start=0;
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,plot_start);
//--- создать мувинги
   int periods[2];
   periods[0]=InpFastMaPeriod;
   periods[1]=InpSlowMaPeriod;
   for(int ma_idx=0;ma_idx<ArraySize(gPtrMas);ma_idx++)
     {
      if(CheckPointer(gPtrMas[ma_idx])==POINTER_DYNAMIC)
         delete gPtrMas[ma_idx];
      gPtrMas[ma_idx]=new CiMA;
      //--- создание
      if(!gPtrMas[ma_idx].Create(_Symbol,_Period,periods[ma_idx],0,InpMaType,PRICE_CLOSE))
        {
         PrintFormat("Ошибка создания MA!");
         return false;
        }
      //--- размер буфера
      if(!gPtrMas[ma_idx].BufferResize(gBeginBar+1))
        {
         Print("Ошибка изменения размера буфера MA!");
         return false;
        }
     }
//---
   return INIT_SUCCEEDED;
  }
//--------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//--------------------------------------------------------------------+
void OnDeinit(const int _reason)
  {
   for(int ma_idx=0;ma_idx<ArraySize(gPtrMas);ma_idx++)
      if(CheckPointer(gPtrMas[ma_idx])==POINTER_DYNAMIC)
         delete gPtrMas[ma_idx];
  }
static uint cnt=0;// del
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,      // размер массива price[]
                const int prev_calculated,  // обработано баров на предыдущем вызове
                const int begin,            // откуда начинаются значимые данные
                const double& price[]       // массив для расчета
                )
  {
   int limit_bar;
//---
   if(prev_calculated==0)
     {
      limit_bar=gBeginBar;
      if(cnt<2)
         for(int buff_idx=0;buff_idx<BUF_NUM;buff_idx++)
            ArrayInitialize(gBuffers[buff_idx].data,0.);
     }
   else
      limit_bar=rates_total-prev_calculated+1;
//--- проверить значения мувингов
   for(int ma_idx=0;ma_idx<ArraySize(gPtrMas);ma_idx++)
     {
      //--- обновить буфер мувинга
      gPtrMas[ma_idx].Refresh(-1);
      //--- проверить количество рассчитанных данных  
      if(gPtrMas[ma_idx].BarsCalculated()!=rates_total)
        {
         return 0;
        }
     }
//--- обсчёт буферов
   for(int bar=limit_bar;bar>=0;bar--)
     {
      //--- значения мувингов
      double fast_ma_val=gPtrMas[0].Main(bar);
      double slow_ma_val=gPtrMas[1].Main(bar);
      //--- разница мувингов
      gBuffers[2].data[bar]=fast_ma_val-slow_ma_val;
      int pips_between=PointsToPips(gBuffers[2].data[bar]);
      //--- если преодолена отсечка
      if(MathAbs(pips_between)>InpCutoff)
        {
         //--- гистограмма
         if(pips_between>0)
            gBuffers[0].data[bar]=1.;  // uptrend
         else if(pips_between<0)
            gBuffers[0].data[bar]=-1.; // downtrend
         //--- цвет
         gBuffers[1].data[bar]=0.;
         if(bar<gBeginBar)
           {
            int prev_pips_between=PointsToPips(gBuffers[2].data[bar+1]);
            //--- если разница уменьшается
            if(MathAbs(pips_between)<MathAbs(prev_pips_between))
               gBuffers[1].data[bar]=1.;
           }
        }
     }
//--- return value of prev_calculated for next call
   return rates_total;
  }
//+------------------------------------------------------------------+
//| Translate points in pips                                         |
//+------------------------------------------------------------------+
int PointsToPips(const double _points_val)
  {
   int pips_val=WRONG_VALUE;
//---
   if(_Point>0.0)
      pips_val=(int)(MathRound(_points_val/_Point));
//---
   return pips_val;
  }
//+------------------------------------------------------------------+
