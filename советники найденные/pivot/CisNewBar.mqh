//+------------------------------------------------------------------+
//|                                                    CisNewBar.mqh |
//|                                            Copyright 2010, Lizar |
//|                                               Lizar-2010@mail.ru |
//|                                              Revision 2010.09.27 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Class CisNewBar.                                                 |
//| Appointment: Класс функций для определения появления нового бара |
//+------------------------------------------------------------------+
class CisNewBar
  {
protected:
   datetime          m_lastbar_time;   // Время открытия последнего бара

   string            m_symbol;         // Имя инструмента
   ENUM_TIMEFRAMES   m_period;         // Период графика

   uint              m_retcode;        // Код результата определения нового бара 
   int               m_new_bars;       // Количество новых баров
   string            m_comment;        // Комментарий выполнения

public:
   void              CisNewBar();      // Конструктор CisNewBar  
   void              operator=(const CisNewBar &_src_new_bar);

   //--- Методы доступа к защищенным данным:
   uint              GetRetCode() const      {return(m_retcode);     }  // Код результата определения нового бара 
   datetime          GetLastBarTime() const  {return(m_lastbar_time);}  // Время открытия последнего бара
   int               GetNewBars() const      {return(m_new_bars);    }  // Количество новых баров
   string            GetComment() const      {return(m_comment);     }  // Комментарий выполнения
   string            GetSymbol() const       {return(m_symbol);      }  // Имя инструмента
   ENUM_TIMEFRAMES   GetPeriod() const       {return(m_period);      }  // Период графика
   //--- Методы инициализации защищенных данных:
   void              SetLastBarTime(datetime lastbar_time){m_lastbar_time=lastbar_time;                            }
   void              SetSymbol(string symbol)             {m_symbol=(symbol==NULL || symbol=="")?Symbol():symbol;  }
   void              SetPeriod(ENUM_TIMEFRAMES period)    {m_period=(period==PERIOD_CURRENT)?Period():period;      }
   //--- Методы определения нового бара:
   bool              isNewBar(datetime new_Time);                       // Первый тип запроса на появление нового бара.
   int               isNewBar();                                        // Второй тип запроса на появление нового бара. 
  };
//+------------------------------------------------------------------+
//| Конструктор CisNewBar.                                           |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CisNewBar::CisNewBar()
  {
   m_retcode=0;         // Код результата определения нового бара 
   m_lastbar_time=0;    // Время открытия последнего бара
   m_new_bars=0;        // Количество новых баров
   m_comment="";        // Комментарий выполнения
   m_symbol=Symbol();   // Имя инструмента, по умолчанию символ текущего графика
   m_period=Period();   // Период графика, по умолчанию период текущего графика    
  }
//+------------------------------------------------------------------+
//| Оператор присваивания                                            |
//+------------------------------------------------------------------+
void CisNewBar:: operator=(const CisNewBar &_src_new_bar)
  {
   m_lastbar_time=_src_new_bar.m_lastbar_time;   // Время открытия последнего бара
   m_symbol=_src_new_bar.m_symbol;               // Имя инструмента
   m_period=_src_new_bar.m_period;               // Период графика
   m_retcode=_src_new_bar.m_retcode;             // Код результата определения нового бара 
   m_new_bars=_src_new_bar.m_new_bars;           // Количество новых баров
   m_comment=_src_new_bar.m_comment;             // Комментарий выполнения
  }
//+------------------------------------------------------------------+
//| Первый тип запроса на появление нового бара.                     |
//| INPUT:  newbar_time - время открытия предположительно нового бара|
//| OUTPUT: true   - если появился новый бар(ы)                      |
//|         false  - если не появился новый бар или получили ошибку  |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CisNewBar::isNewBar(datetime newbar_time)
  {
//--- Инициализация защищенных переменных
   m_new_bars = 0;      // Количество новых баров
   m_retcode  = 0;      // Код результата определения нового бара: 0 - ошибки нет
   m_comment  =__FUNCTION__+" Проверка появления нового бара завершилась успешно";
//---

//--- На всякий случай проверим: не оказалось ли время предположительно нового бара m_newbar_time меньше старого бара m_lastbar_time? 
   if(m_lastbar_time>newbar_time)
     { // Если новый бар старее старого бара, то выдаем сообщение об ошибке
      m_comment=__FUNCTION__+" Ошибка синхронизации: время предыдущего бара "+TimeToString(m_lastbar_time)+
                ", время запроса нового бара "+TimeToString(newbar_time);
      m_retcode=-1;     // Код результата определения нового бара: возвращаем -1 - ошибка синхронизации
      return(false);
     }
//---

//--- если это первый вызов 
   if(m_lastbar_time==0)
     {
      m_lastbar_time=newbar_time; //--- установим время последнего бара и выйдем
      m_comment=__FUNCTION__+" Инициализация lastbar_time="+TimeToString(m_lastbar_time);
      return(false);
     }
//---

//--- Проверяем появление нового бара: 
   if(m_lastbar_time<newbar_time)
     {
      m_new_bars=1;               // Количество новых баров
      m_lastbar_time=newbar_time; // запоминаем время последнего бара
      return(true);
     }
//---

//--- дошли до этого места - значит бар не новый или ошибка, вернем false
   return(false);
  }
//+------------------------------------------------------------------+
//| Второй тип запроса на появление нового бара.                     |
//| INPUT:  no.                                                      |
//| OUTPUT: m_new_bars - количество новых баров                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
int CisNewBar::isNewBar()
  {
   datetime newbar_time;
   datetime lastbar_time=m_lastbar_time;

//--- Запрашиваем время открытия последнего бара:
   ResetLastError(); // Устанавливает значение предопределенной переменной _LastError в ноль.
   if(!SeriesInfoInteger(m_symbol,m_period,SERIES_LASTBAR_DATE,newbar_time))
     { // Если запрос был неудачным, то выдаем сообщение об ошибке:
      m_retcode=GetLastError();  // Код результата определения нового бара: записываем значение переменной _LastError
      m_comment=__FUNCTION__+" Ошибка при получении времени открытия последнего бара: "+IntegerToString(m_retcode);
      return(0);
     }
//---

//---Далее используем первый тип запроса на появление нового бара для завершения анализа:
   if(!isNewBar(newbar_time)) return(0);

//---Уточним количество новых баров:
   m_new_bars=Bars(m_symbol,m_period,lastbar_time,newbar_time)-1;

//--- дошли до этого места - значит появился новый бар(ы), вернем их количество:
   return(m_new_bars);
  }
//+------------------------------------------------------------------+
