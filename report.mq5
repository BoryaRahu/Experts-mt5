//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2010, CompanyName |
//|                                       http://www.companyname.net
//https://www.mql5.com/ru/articles/61  |
//+------------------------------------------------------------------+
#define timeout 10           // время ожидания обновления графика
#define Picture1_width 800   // максимальная ширина графика баланса в отчете
#define Picture2_width 800   // ширина графика цены в отчете
#define Picture2_height 600  // высота графика цены в отчете
#define Axis_Width 59        // ширина оси ординат (в пикселях)

#property script_show_inputs // запрашивать входные параметры 
//+------------------------------------------------------------------+
// перечисление отчетных интервалов
//+------------------------------------------------------------------+
enum report_periods
  {
   All_periods,
   Last_day,
   Last_week,
   Last_month,
   Last_year
  };
// запрос отчетного интервала
input report_periods ReportPeriod=0;
//+------------------------------------------------------------------+
//|  Функция Start()                                                 |
//+------------------------------------------------------------------+
void OnStart()
  {
   datetime StartTime=0;             // начало отчетного интервала
   datetime EndTime=TimeCurrent();   // конец отчетного интервала

                                     // вычисление начала отчетного интервала
   switch(ReportPeriod)
     {
      case 1:
         StartTime=EndTime-86400;    // день
         break;
      case 2:
         StartTime=EndTime-604800;   // неделя
         break;
      case 3:
         StartTime=EndTime-2592000;  // месяц
         break;
      case 4:
         StartTime=EndTime-31536000; // год
         break;
     }
// если ни один из вариантов не выполнен, StartTime=0 (весь период)

   int total_deals_number;  // количество сделок исторических данных
   int file_handle;         // файловый указатель
   int i,j;                 // счетчики цикла 
   int symb_total;          // количество инструментов, по котовым велась торговля
   int symb_pointer;        // указатель на текущий инструмент
   char deal_status[];      // статус сделки (обработана/необработана)
   ulong ticket;            // тикет сделки
   long hChart;             // идентификатор графика

   double balance;           // текущее значение баланса
   double balance_prev;      // предыдущее значение баланса
   double lot_current;       // объем текущей сделки
   double lots_list[];       // список открытых объемов по инструментам
   double current_swap;      // своп текущей сделки
   double current_profit;    // прибыль текущей сделки
   double max_val,min_val;   // максимальное и минимальное значение

   string symb_list[];       // список инструментов, по которым велась торговля
   string in_table_volume;   // объем входа в позицию
   string in_table_time;     // время входа в позицию
   string in_table_price;    // цена входа в позицию
   string out_table_volume;  // объем выхода из позиции
   string out_table_time;    // время выхода из позиции
   string out_table_price;   // цена выхода из позиции
   string out_table_swap;    // своп выхода из позиции
   string out_table_profit;  // прибыль выхода из позиции

   bool symb_flag;           // признак того, что инструмент есть в списке

   datetime time_prev;           // предыдущее значение времени 
   datetime time_curr;           // текущее значение времени
   datetime position_StartTime;  // время первого входа в позицию
   datetime position_EndTime;    // время последнего выхода из позиции

   ENUM_TIMEFRAMES Picture1_period;  // период графика баланса

                                     // открытие нового графика и указание его свойств
   hChart=ChartOpen(Symbol(),0);
   ChartSetInteger(hChart,CHART_MODE,CHART_BARS);            // график в виде баров
   ChartSetInteger(hChart,CHART_AUTOSCROLL,true);            // автопрокрутка включена
   ChartSetInteger(hChart,CHART_COLOR_BACKGROUND,White);     // фон белый
   ChartSetInteger(hChart,CHART_COLOR_FOREGROUND,Black);     // оси и надписи черные
   ChartSetInteger(hChart,CHART_SHOW_OHLC,false);            // OHLC не показывать
   ChartSetInteger(hChart,CHART_SHOW_BID_LINE,true);         // линию BID показывать
   ChartSetInteger(hChart,CHART_SHOW_ASK_LINE,false);        // линию ASK не показывать
   ChartSetInteger(hChart,CHART_SHOW_LAST_LINE,false);       // линию LAST не показывать
   ChartSetInteger(hChart,CHART_SHOW_GRID,true);             // сетку показывать
   ChartSetInteger(hChart,CHART_SHOW_PERIOD_SEP,true);       // разделители периодов показывать
   ChartSetInteger(hChart,CHART_COLOR_GRID,LightGray);       // сетка светло-серая
   ChartSetInteger(hChart,CHART_COLOR_CHART_LINE,Black);     // линии графика черные
   ChartSetInteger(hChart,CHART_COLOR_CHART_UP,Black);       // восходящие бары черные
   ChartSetInteger(hChart,CHART_COLOR_CHART_DOWN,Black);     // нисходящие бары черные
   ChartSetInteger(hChart,CHART_COLOR_BID,Gray);             // линия BID серая
   ChartSetInteger(hChart,CHART_COLOR_VOLUME,Green);         // объемы и уровни ордеров зеленые
   ChartSetInteger(hChart,CHART_COLOR_STOP_LEVEL,Red);       // уровни SL и TP красные
   ChartSetString(hChart,CHART_COMMENT,ChartSymbol(hChart)); // в комментарии - инструмент
   ChartScreenShot(hChart,"picture2.gif",Picture2_width,Picture2_height); // запись картинки - графика цены

// запрос истории сделок за весь период
   HistorySelect(0,TimeCurrent());

// открытие файла отчета
   file_handle=FileOpen("report.html",FILE_WRITE|FILE_ANSI);

// запись в файл начала html-файла
   FileWrite(file_handle,"<html>"+
                           "<head>"+
                              "<title>Expert Trade Report</title>"+
                           "</head>"+
                              "<body bgcolor='#EFEFEF'>"+
                              "<center>"+
                              "<h2>Trade Report</h2>"+
                              "<table align='center' border='1' bgcolor='#FFFFFF' bordercolor='#7F7FFF' cellspacing='0' cellpadding='0'>"+
                                 "<tr>"+
                                    "<th rowspan=2>SYMBOL</th>"+
                                    "<th rowspan=2>Direction</th>"+
                                    "<th colspan=3>Open</th>"+
                                    "<th colspan=3>Close</th>"+
                                    "<th rowspan=2>Swap</th>"+
                                    "<th rowspan=2>Profit</th>"+
                                 "</tr>"+
                                 "<tr>"+
                                    "<th>Volume</th>"+
                                    "<th>Time</th>"+
                                    "<th>Price</th>"+
                                    "<th>Volume</th>"+
                                    "<th>Time</th>"+
                                    "<th>Price</th>"+
                                 "</tr>");

// количество сделок на истории
   total_deals_number=HistoryDealsTotal();

// установка размеров массивов списка инструментов, списка объемов, статусов сделок
   ArrayResize(symb_list,total_deals_number);
   ArrayResize(lots_list,total_deals_number);
   ArrayResize(deal_status,total_deals_number);

// присвоение всем элементам массива значения 0 - сделки не обработаны
   ArrayInitialize(deal_status,0);

   balance=0;       // начальный баланс
   balance_prev=0;  // предыдущий баланс
   symb_total=0;    // количество инструментов в списке

                    // перебор всех сделок на истории
   for(i=0;i<total_deals_number;i++)
     {
      //выбор сделки, получение тикета
      ticket=HistoryDealGetTicket(i);
      // изменение баланса
      balance+=HistoryDealGetDouble(ticket,DEAL_PROFIT);
      // чтение времени сделки
      time_curr=HistoryDealGetInteger(ticket,DEAL_TIME);
      // если это первая сделка
      if(i==0)
        {
         // если отчетный период начинается раньше первой сделки,
         // то начало отчетного периода будет с первой сделки
         if(StartTime<time_curr) StartTime=time_curr;
         // если отчетный период заканчивается позже текущего времени,
         // то конец отчетного периода соответствует текущему времени
         if(EndTime>TimeCurrent()) EndTime=TimeCurrent();
         // начальные значения максимального и минимального баланса
         // равны текущему балансу
         max_val=balance;
         min_val=balance;
         // определение периода графика баланса в зависимости от 
         // продолжительности отчетного интервала
         Picture1_period=PERIOD_M1;
         if(EndTime-StartTime>(Picture1_width-Axis_Width))        Picture1_period=PERIOD_M2;
         if(EndTime-StartTime>(Picture1_width-Axis_Width)*120)    Picture1_period=PERIOD_M3;
         if(EndTime-StartTime>(Picture1_width-Axis_Width)*180)    Picture1_period=PERIOD_M4;
         if(EndTime-StartTime>(Picture1_width-Axis_Width)*240)    Picture1_period=PERIOD_M5;
         if(EndTime-StartTime>(Picture1_width-Axis_Width)*300)    Picture1_period=PERIOD_M6;
         if(EndTime-StartTime>(Picture1_width-Axis_Width)*360)    Picture1_period=PERIOD_M10;
         if(EndTime-StartTime>(Picture1_width-Axis_Width)*600)    Picture1_period=PERIOD_M12;
         if(EndTime-StartTime>(Picture1_width-Axis_Width)*720)    Picture1_period=PERIOD_M15;
         if(EndTime-StartTime>(Picture1_width-Axis_Width)*900)    Picture1_period=PERIOD_M20;
         if(EndTime-StartTime>(Picture1_width-Axis_Width)*1200)   Picture1_period=PERIOD_M30;
         if(EndTime-StartTime>(Picture1_width-Axis_Width)*1800)   Picture1_period=PERIOD_H1;
         if(EndTime-StartTime>(Picture1_width-Axis_Width)*3600)   Picture1_period=PERIOD_H2;
         if(EndTime-StartTime>(Picture1_width-Axis_Width)*7200)   Picture1_period=PERIOD_H3;
         if(EndTime-StartTime>(Picture1_width-Axis_Width)*10800)  Picture1_period=PERIOD_H4;
         if(EndTime-StartTime>(Picture1_width-Axis_Width)*14400)  Picture1_period=PERIOD_H6;
         if(EndTime-StartTime>(Picture1_width-Axis_Width)*21600)  Picture1_period=PERIOD_H8;
         if(EndTime-StartTime>(Picture1_width-Axis_Width)*28800)  Picture1_period=PERIOD_H12;
         if(EndTime-StartTime>(Picture1_width-Axis_Width)*43200)  Picture1_period=PERIOD_D1;
         if(EndTime-StartTime>(Picture1_width-Axis_Width)*86400)  Picture1_period=PERIOD_W1;
         if(EndTime-StartTime>(Picture1_width-Axis_Width)*604800) Picture1_period=PERIOD_MN1;
         // изменение периода открытого графика
         ChartSetSymbolPeriod(hChart,Symbol(),Picture1_period);
        }
      else
      // если это не первая сделка
        {
         // рисование линии баланса, если сделка попадает в отчетный интервал
         // и указание свойств линии баланса
         if(time_curr>=StartTime && time_prev<=EndTime)
           {
            ObjectCreate(hChart,IntegerToString(i),OBJ_TREND,0,time_prev,balance_prev,time_curr,balance);
            ObjectSetInteger(hChart,IntegerToString(i),OBJPROP_COLOR,Green);
            // если оба конца линии попадают в отчетный интервал,
            // то она будет "толстой"
            if(time_prev>=StartTime && time_curr<=EndTime) ObjectSetInteger(hChart,IntegerToString(i),OBJPROP_WIDTH,2);
           }
         // если новое значение баланса выходит за диапазон
         // минимального и максимального значения, то их скорректировать
         if(balance<min_val) min_val=balance;
         if(balance>max_val) max_val=balance;
        }
      // изменение предидущего значения времени
      time_prev=time_curr;

      // если эта сделка еще не обработана
      if(deal_status[i]<127)
        {
         // если эта сделка - начисление баланса
         if(HistoryDealGetInteger(ticket,DEAL_TYPE)==DEAL_TYPE_BALANCE)
           {
            // если она попадает в отчетный интервал - запись строки в файл
            if(time_curr>=StartTime && time_curr<=EndTime) 
            FileWrite(file_handle,"<tr><td colspan='9'>Balance:</td><td align='right'>",HistoryDealGetDouble(ticket,DEAL_PROFIT),"</td></tr>");
            // пометка сделки как обработанной
            deal_status[i]=127;
           }
         // если это сделка покупки или продажи
         if(HistoryDealGetInteger(ticket,DEAL_TYPE)==DEAL_TYPE_BUY || HistoryDealGetInteger(ticket,DEAL_TYPE)==DEAL_TYPE_SELL)
           {
            // проверка, есть ли в списке инструментов инструмент этой сделки
            symb_flag=false;
            for(j=0;j<symb_total;j++)
              {
               if(symb_list[j]==HistoryDealGetString(ticket,DEAL_SYMBOL))
                 {
                  symb_flag=true;
                  symb_pointer=j;
                 }
              }
            // если в списке инструментов нет инструмента этой сделки
            if(symb_flag==false)
              {
               symb_list[symb_total]=HistoryDealGetString(ticket,DEAL_SYMBOL);
               lots_list[symb_total]=0;
               symb_pointer=symb_total;
               symb_total++;
              }
            // установка начального значения для времени начала сделки
            position_StartTime=time_curr;
            // установка начального значения для времени конца сделки
            position_EndTime=time_curr;
            // формирование строки в отчете - инструмент, направление позиции, начало таблицы для объемов для входов в рынок
            if(HistoryDealGetInteger(ticket,DEAL_TYPE)==DEAL_TYPE_BUY)
               StringConcatenate(in_table_volume,"<tr><td align='left'>",symb_list[symb_pointer],
               "</td><td align='center'><img src='buy.gif'></td><td><table border='1' width='100%' bgcolor='#FFFFFF' bordercolor='#DFDFFF'>");

            if(HistoryDealGetInteger(ticket,DEAL_TYPE)==DEAL_TYPE_SELL)
               StringConcatenate(in_table_volume,"<tr><td align='left'>",symb_list[symb_pointer],
               "</td><td align='center'><img src='sell.gif'></td><td><table border='1' width='100%' bgcolor='#FFFFFF' bordercolor='#DFDFFF'>");
            // формирование начала таблицы времени для входов в рынок
            in_table_time="<td><table border='1' width='100%' bgcolor='#FFFFFF' bordercolor='#DFDFFF'>";
            // формирование начала таблицы цен для входов в рынок
            in_table_price="<td><table border='1' width='100%' bgcolor='#FFFFFF' bordercolor='#DFDFFF'>";
            // формирование начала таблицы объемов для выходов из рынка
            out_table_volume="<td><table border='1' width='100%' bgcolor='#FFFFFF' bordercolor='#DFDFFF'>";
            // формирование начала таблицы времени для выходов из рынка
            out_table_time="<td><table border='1' width='100%' bgcolor='#FFFFFF' bordercolor='#DFDFFF'>";
            // формирование начала таблицы цен для выходов из рынка
            out_table_price="<td><table border='1' width='100%' bgcolor='#FFFFFF' bordercolor='#DFDFFF'>";
            // формирование начала таблицы свопов для выходов из рынка
            out_table_swap="<td><table border='1' width='100%' bgcolor='#FFFFFF' bordercolor='#DFDFFF'>";
            // формирование начала таблицы прибыли для выходов из рынка
            out_table_profit="<td><table border='1' width='100%' bgcolor='#FFFFFF' bordercolor='#DFDFFF'>";
            // перебор всех сделок для данной позиции начиная с текущей (пока позиция не будет закрыта)
            for(j=i;j<total_deals_number;j++)
              {
               // если сделка не обработана - обработать
               if(deal_status[j]<127)
                 {
                  // выбор сделки, получение тикета
                  ticket=HistoryDealGetTicket(j);
                  // если инструмент сделки совпадает с инструментом позиции, которая обрабатывается
                  if(symb_list[symb_pointer]==HistoryDealGetString(ticket,DEAL_SYMBOL))
                    {
                     // получение времени сделки
                     time_curr=HistoryDealGetInteger(ticket,DEAL_TIME);
                     // если время сделки выходит за пределы диапазона времени позиции
                     // - расширить время позиции
                     if(time_curr<position_StartTime) position_StartTime=time_curr;
                     if(time_curr>position_EndTime) position_EndTime=time_curr;
                     // получение объема сделки
                     lot_current=HistoryDealGetDouble(ticket,DEAL_VOLUME);
                     // если эта сделка - покупка
                     if(HistoryDealGetInteger(ticket,DEAL_TYPE)==DEAL_TYPE_BUY)
                       {
                        // если уже открыта позиция на продажу - то это будет выход из рынка
                        if(NormalizeDouble(lots_list[symb_pointer],2)<0)
                          {
                           // если объем покупки больше, чем объем открытой короткой позиции - то это переворот
                           if(NormalizeDouble(lot_current+lots_list[symb_pointer],2)>0)
                             {
                              // формирование таблицы объемов для выхода из рынка - указание только того объема, который был у открытой короткой позиции
                              StringConcatenate(out_table_volume,out_table_volume,
                              "<tr><td align=right>",DoubleToString(-lots_list[symb_pointer],2),"</td></tr>");
                              // пометка позиции как частично обработанной
                              deal_status[j]=1;
                             }
                           else
                             {
                              // если объем покупки равен или меньше объема открытой короткой позиции - то это частичное или полное закрытие
                              // формирование таблицы объемов для выхода из рынка
                              StringConcatenate(out_table_volume,out_table_volume,"<tr><td align='right'>",DoubleToString(lot_current,2),"</td></tr>");
                              // пометка сделки как обработанной
                              deal_status[j]=127;
                             }
                           // формироваине таблицы времени для выходов из рынка
                           StringConcatenate(out_table_time,out_table_time,"<tr><td align='center'>",
                           TimeToString(time_curr,TIME_DATE|TIME_SECONDS),"</td></tr>");
                           // формирование таблицы цен для выходов из рынка
                           StringConcatenate(out_table_price,out_table_price,"<tr><td align='center'>",
                           DoubleToString(HistoryDealGetDouble(ticket,DEAL_PRICE),
                           (int)SymbolInfoInteger(symb_list[symb_pointer],SYMBOL_DIGITS)),
                           "</td></tr>");
                           // получение свопа текущей сделки
                           current_swap=HistoryDealGetDouble(ticket,DEAL_SWAP);
                           // если своп равен нулю - формирование пустой строки таблицы свопов для выхода из рынка
                           if(NormalizeDouble(current_swap,2)==0) StringConcatenate(out_table_swap,out_table_swap,"<tr></tr>");
                           // иначе формирование строки со свопом в таблице свопов для выхода из рынка
                           else StringConcatenate(out_table_swap,out_table_swap,"<tr><td align='right'>",DoubleToString(current_swap,2),"</td></tr>");
                           // получение профита текущей сделки
                           current_profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
                           // если прибыль отрицательная (убыток) - отображается в таблице прибыли для выхода из рынка красным цветом
                           if(NormalizeDouble(current_profit,2)<0) StringConcatenate(out_table_profit,out_table_profit,
                           "<tr><td align='right'><SPAN style='COLOR: #EF0000'>",DoubleToString(current_profit,2),"</SPAN></td></tr>");
                           // иначе - отображается зеленым цветом
                           else StringConcatenate(out_table_profit,out_table_profit,
                           "<tr><td align=right><SPAN style='COLOR: #00EF00'>",DoubleToString(current_profit,2),"</SPAN></td></tr>");
                          }
                        else
                        // если уже открыта позиция на покупку - это будет вход в рынок
                          {
                           // если эта сделка уже частично обработана (был переворот)
                           if(deal_status[j]==1)
                             {
                              // формирование таблицы объемов входов в рынок (заносится объем, образовавшийся после переворота)
                              StringConcatenate(in_table_volume,in_table_volume,
                              "<tr><td align=right>",DoubleToString(lots_list[symb_pointer],2),"</td></tr>");
                              // компенсация изменения объема, которая будет произведена (объем этой сделки уже учтен ранее)
                              lots_list[symb_pointer]-=lot_current;
                             }
                           // если эта сделка еще не обрабатывалась, формирование таблицы объемов для входов в рынок
                           else StringConcatenate(in_table_volume,in_table_volume,"<tr><td align='right'>",
                                DoubleToString(lot_current,2),"</td></tr>");
                           // формирование таблицы времени входов в рынок
                           StringConcatenate(in_table_time,in_table_time,"<tr><td align='center'>",
                           TimeToString(time_curr,TIME_DATE|TIME_SECONDS),"</td></tr>");
                           // формирование таблицы цен входов в рынок
                           StringConcatenate(in_table_price,in_table_price,"<tr><td align='center'>",
                           DoubleToString(HistoryDealGetDouble(ticket,DEAL_PRICE),
                           (int)SymbolInfoInteger(symb_list[symb_pointer],SYMBOL_DIGITS)),"</td></tr>");
                           // пометка сделки как обработанной
                           deal_status[j]=127;
                          }
                        // изменение объема позиции по текущему инструменту с учетом объема текущей сделки
                        lots_list[symb_pointer]+=lot_current;
                        // если объем открытой позиции по текущему инструменту стал равен нулю - позиция закрыта
                        if(NormalizeDouble(lots_list[symb_pointer],2)==0 || deal_status[j]==1) break;
                       }
                     // если эта сделка - продажа
                     if(HistoryDealGetInteger(ticket,DEAL_TYPE)==DEAL_TYPE_SELL)
                       {
                        // если уже открыта позиция на покупку - то это будет выход из рынка
                        if(NormalizeDouble(lots_list[symb_pointer],2)>0)
                          {
                           // если объем продажи больше, чем объем открытой длинной позиции - то это переворот
                           if(NormalizeDouble(lot_current-lots_list[symb_pointer],2)>0)
                             {
                              // формирование таблицы объемов для выхода из рынка - указание только того объема, который был у открытой длинной позиции
                              StringConcatenate(out_table_volume,out_table_volume,
                              "<tr><td align='right'>",DoubleToString(lots_list[symb_pointer],2),"</td></tr>");
                              // пометка позиции как частично обработанной
                              deal_status[j]=1;
                             }
                           else
                             {
                              // если объем продажи равен или меньше объема открытой длинной позиции - то это частичное или полное закрытие
                              // формирование таблицы объемов для выхода из рынка
                              StringConcatenate(out_table_volume,out_table_volume,"<tr><td align='right'>",DoubleToString(lot_current,2),"</td></tr>");
                              // пометка сделки как обработанной
                              deal_status[j]=127;
                             }
                           // формироваине таблицы времени для выходов из рынка
                           StringConcatenate(out_table_time,out_table_time,
                           "<tr><td align='center'>",TimeToString(time_curr,TIME_DATE|TIME_SECONDS),"</td></tr>");
                           // формирование таблицы цен для выходов из рынка
                           StringConcatenate(out_table_price,out_table_price,
                           "<tr><td align=center>",
                           DoubleToString(HistoryDealGetDouble(ticket,DEAL_PRICE),
                           (int)SymbolInfoInteger(symb_list[symb_pointer],SYMBOL_DIGITS)),"</td></tr>");
                           // получение свопа текущей сделки
                           current_swap=HistoryDealGetDouble(ticket,DEAL_SWAP);
                           // если своп равен нулю - формирование пустой строки таблицы свопов для выхода из рынка
                           if(NormalizeDouble(current_swap,2)==0) StringConcatenate(out_table_swap,out_table_swap,"<tr></tr>");
                           // иначе формирование строки со свопом в таблице свопов для выхода из рынка
                           else StringConcatenate(out_table_swap,out_table_swap,"<tr><td align='right'>",DoubleToString(current_swap,2),"</td></tr>");
                           // получение профита текущей сделки
                           current_profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
                           // если прибыль отрицательная (убыток) - отображается в таблице прибыли для выхода из рынка красным цветом
                           if(NormalizeDouble(current_profit,2)<0) StringConcatenate(out_table_profit,out_table_profit,
                           "<tr><td align=right><SPAN style='COLOR: #EF0000'>",
                           DoubleToString(current_profit,2),"</SPAN></td></tr>");
                           // иначе - отображается зеленым цветом
                           else StringConcatenate(out_table_profit,out_table_profit,
                           "<tr><td align=right><SPAN style='COLOR: #00EF00'>",DoubleToString(current_profit,2),"</SPAN></td></tr>");
                          }
                        else
                        // если уже открыта позиция на продажу - это будет вход в рынок
                          {
                           // если эта сделка уже частично обработана (был переворот)
                           if(deal_status[j]==1)
                             {
                              // формирование таблицы объемов входов в рынок (заносится объем, образовавшийся после переворота)
                              StringConcatenate(in_table_volume,in_table_volume,
                              "<tr><td align='right'>",DoubleToString(-lots_list[symb_pointer],2),"</td></tr>");
                              // компенсация изменения объема, которое будет произведено (объем этой сделки уже учтен ранее)
                              lots_list[symb_pointer]+=lot_current;
                             }
                           // если эта сделка еще не обрабатывалась, формирование таблицы объемов для входов в рынок
                           else StringConcatenate(in_table_volume,in_table_volume,
                           "<tr><td align='right'>",DoubleToString(lot_current,2),"</td></tr>");
                           // формирование таблицы времени входов в рынок
                           StringConcatenate(in_table_time,in_table_time,
                           "<tr><td align='center'>",
                           TimeToString(time_curr,TIME_DATE|TIME_SECONDS),
                           "</td></tr>");
                           // формирование таблицы цен входов в рынок
                           StringConcatenate(in_table_price,in_table_price,
                           "<tr><td align='center'>",
                           DoubleToString(HistoryDealGetDouble(ticket,DEAL_PRICE),
                           (int)SymbolInfoInteger(symb_list[symb_pointer],SYMBOL_DIGITS)),"</td></tr>");
                           // пометка сделки как обработанной
                           deal_status[j]=127;
                          }
                        // изменение объема позиции по текущему инструменту с учетом объема текущей сделки
                        lots_list[symb_pointer]-=lot_current;
                        // если объем открытой позиции по текущему инструменту стал равен нулю - позиция закрыта
                        if(NormalizeDouble(lots_list[symb_pointer],2)==0 || deal_status[j]==1) break;
                       }
                    }
                 }
              }
            // если интервал времени позиции накладывается на отчетный интервал - позиция выводится в отчет
            if(position_EndTime>=StartTime && position_StartTime<=EndTime) FileWrite(file_handle,
            in_table_volume,"</table></td>",
            in_table_time,"</table></td>",
            in_table_price,"</table></td>",
            out_table_volume,"</table></td>",
            out_table_time,"</table></td>",
            out_table_price,"</table></td>",
            out_table_swap,"</table></td>",
            out_table_profit,"</table></td></tr>");
           }
        }
      // изменение баланса
      balance_prev=balance;
     }
// формирование конца html-файла
   FileWrite(file_handle,
         "</table><br><br>"+
            "<h2>Balance Chart</h2><img src='picture1.gif'><br><br><br>"+
            "<h2>Price Chart</h2><img src='picture2.gif'>"+
         "</center>"+
         "</body>"+
   "</html>");
// закрытие файла
   FileClose(file_handle);

// получение текущего времени
   time_curr=TimeCurrent();
// ожидание обновления графика
   while(SeriesInfoInteger(Symbol(),Picture1_period,SERIES_BARS_COUNT)==0 && TimeCurrent()-time_curr<timeout) Sleep(1000);
// указание максимального и минимального значения для графика баланса (10% отступ от верхней и нижней границы)
   ChartSetDouble(hChart,CHART_FIXED_MAX,max_val+(max_val-min_val)/10);
   ChartSetDouble(hChart,CHART_FIXED_MIN,min_val-(max_val-min_val)/10);
// указание свойств графика баланса
   ChartSetInteger(hChart,CHART_MODE,CHART_LINE);                 // график в виде линии
   ChartSetInteger(hChart,CHART_FOREGROUND,false);                // график на переднем плане
   ChartSetInteger(hChart,CHART_SHOW_BID_LINE,false);             // линию BID не показывать
   ChartSetInteger(hChart,CHART_COLOR_VOLUME,White);              // объемы и уровни ордеров белые
   ChartSetInteger(hChart,CHART_COLOR_STOP_LEVEL,White);          // уровни SL и TP белые
   ChartSetInteger(hChart,CHART_SHOW_GRID,true);                  // сетку показывать
   ChartSetInteger(hChart,CHART_COLOR_GRID,LightGray);            // сетка светло-серая
   ChartSetInteger(hChart,CHART_SHOW_PERIOD_SEP,false);           // разделители периодов не показывать
   ChartSetInteger(hChart,CHART_SHOW_VOLUMES,CHART_VOLUME_HIDE);  // объемы не показывать
   ChartSetInteger(hChart,CHART_COLOR_CHART_LINE,White);          // график белый
   ChartSetInteger(hChart,CHART_SCALE,0);                         // масштаб минимальный
   ChartSetInteger(hChart,CHART_SCALEFIX,true);                   // фиксированный масштаб по вертикали
   ChartSetInteger(hChart,CHART_SHIFT,false);                     // смещения графика нет
   ChartSetInteger(hChart,CHART_AUTOSCROLL,true);                 // автопрокрутка включена
   ChartSetString(hChart,CHART_COMMENT,"BALANCE");                // комментарий на графике
   ChartRedraw(hChart);                                           // перерисовка графика баланса
   Sleep(8000);
// запись картинки - графика баланса
   ChartScreenShot(hChart,"picture1.gif",
   (int)(EndTime-StartTime)/PeriodSeconds(Picture1_period),
   (int)(EndTime-StartTime)/PeriodSeconds(Picture1_period)/2,
   ALIGN_RIGHT);
// удаление всех объектов с графика баланса
   ObjectsDeleteAll(hChart);
// закрытие графика
   ChartClose(hChart);
// если разрешена публикация отчета - отправка по FTP-протоколу
// html-файла и двух картинок - графика цены и баланса
   if(TerminalInfoInteger(TERMINAL_FTP_ENABLED))
     {
      SendFTP("report.html");
      SendFTP("picture1.gif");
      SendFTP("picture2.gif");
     }
  }
//+------------------------------------------------------------------+
