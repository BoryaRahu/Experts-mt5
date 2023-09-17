//+------------------------------------------------------------------+
//|                                                 SignalPivots.mqh |
//|                                           Copyright 2017, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, denkir"
#property link      "https://login.mql5.com/ru/users/denkir"
//--- include
#include "..\ExpertUserSignal.mqh"
#include "..\CisNewBar.mqh"
//+------------------------------------------------------------------+
//| Класс CSignalPivots                                              |
//| Цель: Класс торговых сигналов на основе пивотов.                 |
//| Потомок класса CExpertSignal.                                    |
//+------------------------------------------------------------------+
class CSignalPivots : public CExpertUserSignal
  {
   //--- === Data members === --- 
protected:
   //--- индикаторы
   CiCustom          m_pivots;            // "Pivots"   
   CiCustom          m_catcher;           // "MaTrendCatcher"   
   //--- настраиваемые параметры
   bool              m_to_plot_minor;     // отрисовка второстепенных уровней
   double            m_pnt_near;          // допуск 
   double            m_wid_limit;         // лимит по ширине 
   int               m_fast_ma;           // быстрая МА, период
   int               m_slow_ma;           // медленная МА, период
   ENUM_MA_METHOD    m_ma_type;           // тип МА
   int               m_cutoff;            // отсечка, пп
   //--- расчётные
   double            m_pivot_val;         // значение пивота
   double            m_daily_open_pr;     // цена открытия текущего дня   
   CisNewBar         m_day_new_bar;       // новый бар дневного ТФ
   CisNewBar         m_new_bar;           // новый бар текущего ТФ
   double            m_trend_val;         // значение тренда
   double            m_trend_color;       // цвет тренда

   //--- рыночные модели  
   //--- 1) Модель 0 "первое касание уровня PP" (сверху - buy, снизу - sell)
   int               m_pattern_0;         // вес
   bool              m_pattern_0_done;    // признак отработанной модели
   bool              m_is_signal;         // флаг сигнала
   //--- 2) Модель 1 "тренд-флэт-контртренд"  
   int               m_pattern_1;         // вес
   int               m_speedup_allowance; // поправка на ускорение 
   //---
   double            m_signal_result;     // результат сигнала

   //--- === Methods === --- 
public:
   //--- конструктор/деструктор
   void              CSignalPivots(void);
   void             ~CSignalPivots(void){};
   //--- методы установки настраиваемых параметров
   void              ToPlotMinor(const bool _to_plot) {m_to_plot_minor=_to_plot;}
   void              PointsNear(const uint _near_pips);
   void              SpeedupAllowance(const int _speedup_allowance) {m_speedup_allowance=_speedup_allowance;};
   void              WidthLimit(const uint _wid_pips);
   void              FastMa(const int _fast_ma);
   void              SlowMa(const int _slow_ma);
   void              MaType(const ENUM_MA_METHOD _ma_type);
   void              Cutoff(const int _cutoff);
   //--- методы настраивания "весов" рыночных моделей
   void              Pattern_0(int _val) {m_pattern_0=_val;m_pattern_0_done=false;}
   void              Pattern_1(int _val) {m_pattern_1=_val;}

   //--- метод проверки настроек
   virtual bool      ValidationSettings(void);
   //--- метод создания индикатора и таймсерий
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- методы проверки, если модели рынка сформированы
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);
   virtual double    Direction(void);
   double            SignalResult(void) const {return m_signal_result;}

   //--- методы определения уровней входа в рынок
   virtual bool      OpenLongParams(double &price,double &sl,double &tp,datetime &expiration);
   virtual bool      OpenShortParams(double &price,double &sl,double &tp,datetime &expiration);
   //--- методы определения уровней выхода из рынка
   virtual bool      CloseLongParams(double &price);
   virtual bool      CloseShortParams(double &price);

   //---
protected:
   //--- метод инициализации индикатора
   bool              InitCustomIndicator(CIndicators *indicators);
   //--- получение значения уровня пивота
   double            Pivot(void) {return(m_pivots.GetData(0,0));}
   //--- получение значения основного уровня сопротивления
   double            MajorResistance(uint _ind);
   //--- получение значения второстепенного уровня сопротивления
   double            MinorResistance(uint _ind);
   //--- получение значения основного уровня поддержки
   double            MajorSupport(uint _ind);
   //--- получение значения второстепенного уровня поддержки
   double            MinorSupport(uint _ind);
   //---
   void              Print(const double _pr,const ENUM_ORDER_TYPE _sig_type);
  };
//+------------------------------------------------------------------+
//| Конструктор                                                      |
//+------------------------------------------------------------------+
void CSignalPivots::CSignalPivots(void)
  {
   m_pnt_near=m_wid_limit=m_signal_result=0.;
   m_is_signal=false;
//--- инициализация защищённых данных
   m_used_series=USE_SERIES_OPEN+USE_SERIES_HIGH+USE_SERIES_LOW+
                 USE_SERIES_CLOSE+USE_SERIES_TIME;
  }
//+------------------------------------------------------------------+
//| Допуск                                                           |
//+------------------------------------------------------------------+
void CSignalPivots::PointsNear(const uint _near_pips)
  {
   if(_near_pips>0)
      m_pnt_near=m_symbol.Point()*_near_pips;
  }
//+------------------------------------------------------------------+
//| Лимит по ширине                                                  |
//+------------------------------------------------------------------+
void CSignalPivots::WidthLimit(const uint _wid_pips)
  {
   if(_wid_pips>0)
      m_wid_limit=m_symbol.Point()*_wid_pips;
  }
//+------------------------------------------------------------------+
//| Быстрая МА, период                                               |
//+------------------------------------------------------------------+
void CSignalPivots::FastMa(const int _fast_ma)
  {
   if(_fast_ma>0)
      m_fast_ma=_fast_ma;
  }
//+------------------------------------------------------------------+
//| Медленная МА, период                                             |
//+------------------------------------------------------------------+
void CSignalPivots::SlowMa(const int _slow_ma)
  {
   if(_slow_ma>0)
      m_slow_ma=_slow_ma;
  }
//+------------------------------------------------------------------+
//| Лимит по ширине                                                  |
//+------------------------------------------------------------------+
void CSignalPivots::MaType(const ENUM_MA_METHOD _ma_type)
  {
   m_ma_type=_ma_type;
  }
//+------------------------------------------------------------------+
//| Лимит по ширине                                                  |
//+------------------------------------------------------------------+
void CSignalPivots::Cutoff(const int _cutoff)
  {
   if(_cutoff>0)
      m_cutoff=_cutoff;

  }
//+------------------------------------------------------------------+
//| Проверка параметров защищенных данных                            |
//+------------------------------------------------------------------+
bool CSignalPivots::ValidationSettings(void)
  {
//--- validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return false;
//--- проверить символ
   if(m_symbol==NULL)
      return false;
//--- ok
   return true;
  }
//+------------------------------------------------------------------+
//| Создание индикаторов                                             |
//+------------------------------------------------------------------+
bool CSignalPivots::InitIndicators(CIndicators *indicators)
  {
//--- инициализация индикаторов и таймсерий дополнительных фильтров
   if(!CExpertSignal::InitIndicators(indicators))
      return false;
//--- создание и инициализация пользовательского индикатора
   if(!this.InitCustomIndicator(indicators))
      return false;
//--- ok
   return true;
  }
//+------------------------------------------------------------------+
//| Инициализация собственных индикаторов                            |
//+------------------------------------------------------------------+
bool CSignalPivots::InitCustomIndicator(CIndicators *indicators)
  {
//--- добавление "Pivots" в коллекцию
   if(!indicators.Add(GetPointer(m_pivots)))
     {
      PrintFormat(__FUNCTION__+": error adding \"Pivots\"");
      return false;
     }
//--- задание параметров индикатора
   MqlParam parameters[];
   ArrayResize(parameters,41);
   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="Pivots.ex5";
//--- Уровень пивота 
   parameters[1].type=TYPE_STRING;          // описание группы параметров
   parameters[1].string_value="";
   parameters[2].type=TYPE_INT;             // цвет
   parameters[2].integer_value=clrOrangeRed;
   parameters[3].type=TYPE_INT;             // стиль линии
   parameters[3].integer_value=STYLE_SOLID;
   parameters[4].type=TYPE_INT;             // толщина линии
   parameters[4].integer_value=3;
//--- Уровни 0.5   
   parameters[5].type=TYPE_STRING;          // описание группы параметров
   parameters[5].string_value="";
   parameters[6].type=TYPE_INT;             // флаг отображения 
   parameters[6].integer_value=m_to_plot_minor;
   parameters[7].type=TYPE_INT;             // цвет сопротивления 
   parameters[7].integer_value=clrLightSkyBlue;
   parameters[8].type=TYPE_INT;             // цвет поддержки	
   parameters[8].integer_value=clrHotPink;
   parameters[9].type=TYPE_INT;             // стиль линии 
   parameters[9].integer_value=STYLE_DOT;
   parameters[10].type=TYPE_INT;            // толщина линии 
   parameters[10].integer_value=1;
//--- Уровни 1.0   
   parameters[11].type=TYPE_STRING;         // описание группы параметров
   parameters[11].string_value="";
   parameters[12].type=TYPE_INT;            // флаг отображения 
   parameters[12].integer_value=1;
   parameters[13].type=TYPE_INT;            // цвет сопротивления 
   parameters[13].integer_value=clrLightSeaGreen;
   parameters[14].type=TYPE_INT;            // цвет поддержки	
   parameters[14].integer_value=clrPlum;
   parameters[15].type=TYPE_INT;            // стиль линии 
   parameters[15].integer_value=STYLE_SOLID;
   parameters[16].type=TYPE_INT;            // толщина линии 
   parameters[16].integer_value=3;
//--- Уровни 1.5   
   parameters[17].type=TYPE_STRING;         // описание группы параметров
   parameters[17].string_value="";
   parameters[18].type=TYPE_INT;            // флаг отображения 
   parameters[18].integer_value=m_to_plot_minor;
   parameters[19].type=TYPE_INT;            // цвет сопротивления 
   parameters[19].integer_value=clrSteelBlue;
   parameters[20].type=TYPE_INT;            // цвет поддержки	
   parameters[20].integer_value=clrRed;
   parameters[21].type=TYPE_INT;            // стиль линии 
   parameters[21].integer_value=STYLE_DOT;
   parameters[22].type=TYPE_INT;            // толщина линии 
   parameters[22].integer_value=1;
//--- Уровни 2.0   
   parameters[23].type=TYPE_STRING;         // описание группы параметров
   parameters[23].string_value="";
   parameters[24].type=TYPE_INT;            // флаг отображения 
   parameters[24].integer_value=1;
   parameters[25].type=TYPE_INT;            // цвет сопротивления 
   parameters[25].integer_value=clrLightBlue;
   parameters[26].type=TYPE_INT;            // цвет поддержки	
   parameters[26].integer_value=clrPink;
   parameters[27].type=TYPE_INT;            // стиль линии 
   parameters[27].integer_value=STYLE_SOLID;
   parameters[28].type=TYPE_INT;            // толщина линии 
   parameters[28].integer_value=3;
//--- Уровни 2.5   
   parameters[29].type=TYPE_STRING;         // описание группы параметров
   parameters[29].string_value="";
   parameters[30].type=TYPE_INT;            // флаг отображения 
   parameters[30].integer_value=m_to_plot_minor;
   parameters[31].type=TYPE_INT;            // цвет сопротивления 
   parameters[31].integer_value=clrSteelBlue;
   parameters[32].type=TYPE_INT;            // цвет поддержки		  
   parameters[32].integer_value=clrDeepPink;
   parameters[33].type=TYPE_INT;            // стиль линии 
   parameters[33].integer_value=STYLE_DOT;
   parameters[34].type=TYPE_INT;            // толщина линии 
   parameters[34].integer_value=1;
//--- Уровни 3.0   
   parameters[35].type=TYPE_STRING;         // описание группы параметров
   parameters[35].string_value="";
   parameters[36].type=TYPE_INT;            // флаг отображения 
   parameters[36].integer_value=1;
   parameters[37].type=TYPE_INT;            // цвет сопротивления 
   parameters[37].integer_value=clrBlack;
   parameters[38].type=TYPE_INT;            // цвет поддержки		
   parameters[38].integer_value=clrBrown;
   parameters[39].type=TYPE_INT;            // стиль линии 
   parameters[39].integer_value=STYLE_SOLID;
   parameters[40].type=TYPE_INT;            // толщина линии 
   parameters[40].integer_value=3;
//--- инициализация объекта
   if(!m_pivots.Create(m_symbol.Name(),_Period,IND_CUSTOM,ArraySize(parameters),parameters))
     {
      PrintFormat(__FUNCTION__+": error creating \"Pivots\"");
      return false;
     }
//--- количество буферов
   if(!m_pivots.NumBuffers(13))
      return false;
//--- добавление "MaTrendCatcher" в коллекцию
   if(!indicators.Add(GetPointer(m_catcher)))
     {
      PrintFormat(__FUNCTION__+": error adding \"MaTrendCatcher\"");
      return false;
     }
//--- задание параметров индикатора
   ArrayResize(parameters,6);
   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="MaTrendCatcher.ex5";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=m_fast_ma;
   parameters[2].type=TYPE_INT;
   parameters[2].integer_value=m_slow_ma;
   parameters[3].type=TYPE_INT;
   parameters[3].integer_value=m_ma_type;
   parameters[4].type=TYPE_INT;
   parameters[4].integer_value=m_cutoff;
   parameters[5].type=TYPE_INT;
   parameters[5].integer_value=200;
//--- инициализация объекта
   if(!m_catcher.Create(m_symbol.Name(),_Period,IND_CUSTOM,ArraySize(parameters),parameters))
     {
      PrintFormat(__FUNCTION__+": error creating \"MaTrendCatcher\"");
      return false;
     }
//--- количество буферов
   if(!m_catcher.NumBuffers(2))
      return false;
//--- ok
   return true;
  }
//+------------------------------------------------------------------+
//| Получение значения основного уровня сопротивления                |
//+------------------------------------------------------------------+
double CSignalPivots::MajorResistance(uint _ind)
  {
   double res_val=WRONG_VALUE;
//--- если индекс уровня указан верно  
   if(_ind<3)
     {
      uint buff_idx=4*(_ind+1)-1;
      res_val=m_pivots.GetData(buff_idx,0);
     }
//---
   return res_val;
  }
//+------------------------------------------------------------------+
//| Получение значения второстепенного уровня сопротивления          |
//+------------------------------------------------------------------+
double CSignalPivots::MinorResistance(uint _ind)
  {
   double res_val=WRONG_VALUE;
//--- если индекс уровня указан верно  
   if(_ind<3)
     {
      uint buff_idx=4*(_ind+1)-3;
      res_val=m_pivots.GetData(buff_idx,0);
     }
//---
   return res_val;
  }
//+------------------------------------------------------------------+
//| Получение значения основного уровня поддержки                    |
//+------------------------------------------------------------------+
double CSignalPivots::MajorSupport(uint _ind)
  {
   double sup_val=WRONG_VALUE;
//--- если индекс уровня указан верно  
   if(_ind<3)
     {
      uint buff_idx=4*(_ind+1);
      sup_val=m_pivots.GetData(buff_idx,0);
     }
//---
   return sup_val;
  }
//+------------------------------------------------------------------+
//| Получение значения второстепенного уровня поддержки              |
//+------------------------------------------------------------------+
double CSignalPivots::MinorSupport(uint _ind)
  {
   double sup_val=WRONG_VALUE;
//--- если индекс уровня указан верно  
   if(_ind<3)
     {
      uint buff_idx=4*(_ind+1)-2;
      sup_val=m_pivots.GetData(buff_idx,0);
     }
//---
   return sup_val;
  }
//+------------------------------------------------------------------+
//| Вывод на печать состояния сигнала                                |
//+------------------------------------------------------------------+
void CSignalPivots::Print(const double _pr,const ENUM_ORDER_TYPE _sig_type)
  {
   int digs=m_symbol.Digits();
   Print("\n---== Пивот ==---");
   if(_sig_type==ORDER_TYPE_BUY)
      Print("Тип: касание ценой снизу");
   else if(_sig_type==ORDER_TYPE_SELL)
      Print("Тип: касание ценой сверху");
//--- в Журнал      
   PrintFormat("Цена: %0."+IntegerToString(digs)+"f",_pr);
   PrintFormat("Пивот: %0."+IntegerToString(digs)+"f",m_pivot_val);
   PrintFormat("Допуск: %0."+IntegerToString(digs)+"f",m_pnt_near);
   if(m_trend_val!=0.)
     {
      Print("---== Тренд ==---");
      string print_str="Тип: ";
      if(m_trend_val>0.)
         print_str+="бычий";
      else
         print_str+="медвежий";
      Print(print_str);
      print_str="Ускорение: ";
      if(m_trend_color==0.)
         print_str+="есть";
      else
         print_str+="нет";
      Print(print_str+"\n");
     }
  }
//+------------------------------------------------------------------+
//| Проверка условия на покупку                                      |
//+------------------------------------------------------------------+
int CSignalPivots::LongCondition(void)
  {
   int result=0;
//--- если Модель 0 учитывается
   if(IS_PATTERN_USAGE(0))
      //--- если Модель 0 не отработана
      if(!m_pattern_0_done)
        {
         m_is_signal=false;
         //--- если день открылся ниже пивота
         if(m_daily_open_pr<m_pivot_val)
           {
            //--- максимальная цена на прошлом баре
            double last_high=m_high.GetData(1);
            //--- если цена получена
            if(last_high>WRONG_VALUE && last_high<DBL_MAX)
               //--- если было касание снизу (с учётом допуска)
               if(last_high>=(m_pivot_val-m_pnt_near))
                 {
                  result=m_pattern_0;
                  m_is_signal=true;
                  //--- в Журнал
                  this.Print(last_high,ORDER_TYPE_BUY);
                 }
           }
         //--- если Модель 1 учитывается
         if(IS_PATTERN_USAGE(1))
           {
            //--- если на прошлом баре был бычий тренд
            if(m_trend_val>0. && m_trend_val!=EMPTY_VALUE)
              {
               //--- если есть ускорение
               if(m_trend_color==0. && m_trend_color!=EMPTY_VALUE)
                  result+=(m_pattern_1+m_speedup_allowance);
               //--- если нет ускорения
               else
                  result+=(m_pattern_1-m_speedup_allowance);
              }
           }
        }
//---
   return result;
  }
//+------------------------------------------------------------------+
//| Проверка условия на продажу                                      |
//+------------------------------------------------------------------+
int CSignalPivots::ShortCondition(void)
  {
   int result=0;
//--- если Модель 0 учитывается
   if(IS_PATTERN_USAGE(0))
      //--- если Модель 0 не отработана
      if(!m_pattern_0_done)
        {
         //--- если день открылся выше пивота
         if(m_daily_open_pr>m_pivot_val)
           {
            //--- минимальная цена на прошлом баре
            double last_low=m_low.GetData(1);
            //--- если цена получена
            if(last_low>WRONG_VALUE && last_low<DBL_MAX)
               //--- если было касание сверху (с учётом допуска)
               if(last_low<=(m_pivot_val+m_pnt_near))
                 {
                  result=m_pattern_0;
                  m_is_signal=true;
                  //--- в Журнал
                  this.Print(last_low,ORDER_TYPE_SELL);
                 }
           }
         //--- если Модель 1 учитывается
         if(IS_PATTERN_USAGE(1))
           {
            //--- если на прошлом баре был медвежий тренд
            if(m_trend_val<0. && m_trend_val!=EMPTY_VALUE)
              {
               //--- если есть ускорение
               if(m_trend_color==0. && m_trend_color!=EMPTY_VALUE)
                  result+=(m_pattern_1+m_speedup_allowance);
               //--- если нет ускорения
               else
                  result+=(m_pattern_1-m_speedup_allowance);
              }
           }
        }
//---
   return result;
  }
//+------------------------------------------------------------------+
//| Определение "взвешенного" направления                            |
//+------------------------------------------------------------------+
double CSignalPivots::Direction(void)
  {
   double result=0.;
//---
   MqlRates daily_rates[];
   if(CopyRates(_Symbol,PERIOD_D1,0,1,daily_rates)<0)
      return 0.;
//--- если Модель 0 учитывается
   if(IS_PATTERN_USAGE(0))
     {
      //--- если Модель 0 отработана
      if(m_pattern_0_done)
        {
         //--- проверить появление нового дня
         if(m_day_new_bar.isNewBar(daily_rates[0].time))
           {
            //--- сбросить флаг отработки модели
            m_pattern_0_done=false;
            return 0.;
           }
        }
      //--- если Модель 0 не отработана
      else
        {
         //--- цена открытия дня
         if(m_daily_open_pr!=daily_rates[0].open)
            m_daily_open_pr=daily_rates[0].open;
         //--- пивот
         double curr_pivot_val=this.Pivot();
         if(curr_pivot_val>WRONG_VALUE && curr_pivot_val<DBL_MAX)
            if(m_pivot_val!=curr_pivot_val)
              {
               //--- запомнить пивот
               m_pivot_val=curr_pivot_val;
               //--- если задан лимит
               if(m_wid_limit>0.)
                 {
                  //--- расчётный верхний лимит 
                  double norm_upper_limit=m_symbol.NormalizePrice(m_wid_limit+m_pivot_val);
                  //--- фактический верхний лимит
                  double res1_val=this.MajorResistance(0);
                  if(res1_val>WRONG_VALUE && res1_val<DBL_MAX)
                    {
                     //--- если лимит не преодолён 
                     if(res1_val<norm_upper_limit)
                       {
                        //--- Модель 0 отработана
                        m_pattern_0_done=true;
                        //--- в Журнал
                        Print("\n---== Не преодолён верхний лимит ==---");
                        PrintFormat("Расчётный: %0."+IntegerToString(m_symbol.Digits())+"f",norm_upper_limit);
                        PrintFormat("Фактический: %0."+IntegerToString(m_symbol.Digits())+"f",res1_val);
                        //---
                        return 0.;
                       }
                    }
                  //--- расчётный нижний лимит 
                  double norm_lower_limit=m_symbol.NormalizePrice(m_pivot_val-m_wid_limit);
                  //--- фактический нижний лимит
                  double sup1_val=this.MajorSupport(0);
                  if(sup1_val>WRONG_VALUE && sup1_val<DBL_MAX)
                    {
                     //--- если лимит не преодолён 
                     if(norm_lower_limit<sup1_val)
                       {
                        //--- Модель 0 отработана
                        m_pattern_0_done=true;
                        //--- в Журнал
                        Print("\n---== Не преодолён нижний лимит ==---");
                        PrintFormat("Расчётный: %0."+IntegerToString(m_symbol.Digits())+"f",norm_lower_limit);
                        PrintFormat("Фактический: %0."+IntegerToString(m_symbol.Digits())+"f",sup1_val);
                        //---
                        return 0.;
                       }
                    }
                 }
              }
         //--- если Модель 1 учитывается
         if(IS_PATTERN_USAGE(1))
           {
            //--- получить время последнего бара
            datetime last_bar_time=this.Time(0);
            //--- проверить появление нового бара
            if(m_new_bar.isNewBar(last_bar_time))
              {
               m_trend_val=this.m_catcher.GetData(0,0);
               m_trend_color=this.m_catcher.GetData(1,0);
              }
           }

        }
     }
//--- результат
   result=m_weight*(this.LongCondition()-this.ShortCondition());
   double abs_result=MathAbs(result);
//--- если есть какой-то результат
   if(abs_result>0)
      //--- если был сигнал
      if(m_is_signal)
        {
         //--- если результат достаточный
         if(abs_result>=m_threshold_open)
           {
            //--- запомнить результат
            m_signal_result=abs_result;
           }
         //--- если результат недостаточный
         else
           {
            //--- Модель 0 отработана
            m_pattern_0_done=true;
            //--- в Журнал
            Print("\n---== Слабый сигнал ==---");
            PrintFormat("Текущий: %0.2f",result);
            PrintFormat("Порог: %0.d",m_threshold_open);
           }
        }
//---
   return result;
  }
//+------------------------------------------------------------------+
//| Определение торговых уровней для покупки                         |
//+------------------------------------------------------------------+
bool CSignalPivots::OpenLongParams(double &price,double &sl,double &tp,datetime &expiration)
  {
   bool params_set=false;
   sl=tp=WRONG_VALUE;
//--- если Модель 0 учитывается
   if(IS_PATTERN_USAGE(0))
      //--- если Модель 0 не отработана
      if(!m_pattern_0_done)
        {
         //--- цена открытия - по рынку
         double base_price=m_symbol.Ask();
         price=m_symbol.NormalizePrice(base_price-m_price_level*PriceLevelUnit());
         //--- sl-цена - уровень Sup1.0
         sl=this.MajorSupport(0);
         if(sl==WRONG_VALUE || sl==DBL_MAX)
            return false;
         //--- если задана sl-цена
         sl=m_symbol.NormalizePrice(sl);
         //--- tp-цена - уровень Res0.5         
         tp=this.MinorResistance(0);
         if(tp==WRONG_VALUE || tp==DBL_MAX)
            return false;
         //--- если задана tp-цена
         tp=m_symbol.NormalizePrice(tp);
         expiration+=m_expiration*PeriodSeconds(m_period);
         //--- если цены заданы
         params_set=true;
         //--- модель отработана
         m_pattern_0_done=true;
        }
//---
   return params_set;
  }
//+------------------------------------------------------------------+
//| Определение торговых уровней  для продажи                        |
//+------------------------------------------------------------------+
bool CSignalPivots::OpenShortParams(double &price,double &sl,double &tp,datetime &expiration)
  {
   bool params_set=false;
//--- если Модель 0 учитывается
   if(IS_PATTERN_USAGE(0))
      //--- если Модель 0 не отработана
      if(!m_pattern_0_done)
        {
         //--- цена открытия - по рынку
         double base_price=m_symbol.Bid();
         price=m_symbol.NormalizePrice(base_price+m_price_level*PriceLevelUnit());
         //--- sl-цена - уровень Res1.0

         sl=this.MajorResistance(0);
         if(sl==WRONG_VALUE || sl==DBL_MAX)
            return false;
         //--- если задана sl-цена  
         sl=m_symbol.NormalizePrice(sl);
         //--- tp-цена - уровень Sup0.5

         tp=this.MinorSupport(0);
         if(tp==WRONG_VALUE || tp==DBL_MAX)
            return false;
         //--- если задана tp-цена
         tp=m_symbol.NormalizePrice(tp);
         expiration+=m_expiration*PeriodSeconds(m_period);
         //--- если цены заданы
         params_set=true;
         //--- модель отработана
         m_pattern_0_done=true;
        }
//---
   return params_set;
  }
//+------------------------------------------------------------------+
//| Определение торгового уровня для покупки                         |
//+------------------------------------------------------------------+
bool CSignalPivots::CloseLongParams(double &price)
  {
   price=0.;
//--- если Модель 0 учитывается
   if(IS_PATTERN_USAGE(0))
      //--- если Модель 0 не отработана
      if(!m_pattern_0_done)
        {
         price=m_symbol.Bid();
         //--- в Журнал
         Print("\n---== Сигнал на закрытие покупки ==---");
         PrintFormat("Рыночная цена: %0."+IntegerToString(m_symbol.Digits())+"f",price);
         return true;
        }
//--- return the result
   return false;
  }
//+------------------------------------------------------------------+
//| Определение торгового уровня для продажи                         |
//+------------------------------------------------------------------+
bool CSignalPivots::CloseShortParams(double &price)
  {
   price=0.;
//--- если Модель 0 учитывается
   if(IS_PATTERN_USAGE(0))
      //--- если Модель 0 не отработана
      if(!m_pattern_0_done)
        {
         price=m_symbol.Ask();
         //--- в Журнал
         Print("\n---== Сигнал на закрытие продажи ==---");
         PrintFormat("Рыночная цена: %0."+IntegerToString(m_symbol.Digits())+"f",price);
         return true;
        }
//--- return the result
   return false;
  }
//+------------------------------------------------------------------+

//--- [EOF]
