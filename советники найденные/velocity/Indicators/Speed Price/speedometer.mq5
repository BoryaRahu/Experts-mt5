//+------------------------------------------------------------------+
//|                                                   Speedometr.mq5 |
//|                                              Copyright 2016, AM2 |
//|                                      http://www.forexsystems.biz |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, AM2"
#property link      "http://www.forexsystems.biz"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_plots 0

input int              FontSize     = 12;                   // Размер шрифта
input string           FontName     = "Trebuchet";              // Наименование шрифта
input color            ClrLabel     = clrBlack;             // Цвет метки - путь цены в пунктах
input int              SpeedSound=100;                      // Оповещение превышения скорости
input ENUM_BASE_CORNER Corner=CORNER_RIGHT_UPPER;           // Угол для вывода информации

bool one=true;
double LastBid,LastAsk;
ulong LastTime=TimeCurrent(),T=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Comment("");
   ObjectDelete(0,"Label1");
   ObjectDelete(0,"Label2");
   ObjectDelete(0,"Label3");
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
//---
   double speed1=0,speed2=0,way1=0,way2=0,Bid=0,Ask=0;
   ulong dt=0;

   T=GetMicrosecondCount();
   Bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   Ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);

   if(LastBid!=Bid || LastAsk!=Ask)
     {
      dt=T-LastTime;
      way1=(Ask-LastAsk)/_Point;
      way2=(Bid-LastBid)/_Point;
      speed1=way1/dt;
      speed2=way2/dt;

      // Mетки в правой половине графика
      if(Corner==CORNER_RIGHT_UPPER || Corner==CORNER_RIGHT_LOWER)
        {
         PutLabel("Label1","Speed Ask: "+(string)NormalizeDouble(speed1*1000000,2),150,30,ClrLabel);
         PutLabel("Label2","Speed Bid: "+(string)NormalizeDouble(speed2*1000000,2),150,60,ClrLabel);
         PutLabel("Label3","Speed Avrg: "+(string)NormalizeDouble((speed1+speed2)/2*1000000,2),150,90,ClrLabel);
        }
      else // Mетки в левой половине графика
        {
         PutLabel("Label1","Speed Ask: "+(string)NormalizeDouble(speed1*1000000,2),20,30,ClrLabel);
         PutLabel("Label2","Speed Bid: "+(string)NormalizeDouble(speed2*1000000,2),20,60,ClrLabel);
         PutLabel("Label3","Speed Avrg: "+(string)NormalizeDouble((speed1+speed2)/2*1000000,2),20,90,ClrLabel);
        }
     }

   LastTime=T;
   LastBid=Bid;
   LastAsk=Ask;

   if(MathAbs(speed1*1000000)<SpeedSound)
      one=true;
// Оповещения при включенной опции AlertOn
   if((MathAbs(speed1*1000000)>SpeedSound && one))
     {
      Print("Скорость выше "+(string)SpeedSound+" пунктов в секунду!");
      //SendNotification("Скорость выше: "+(string)SpeedSound+" пунктов в секунду!");
      //SendMail("Сигнал индикатора","Скорость выше: "+(string)SpeedSound+" пунктов в секунду!");
      one=false;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Установка меток                                                 |
//+------------------------------------------------------------------+
void PutLabel(string name,string text,int x,int y,color clr)
  {
   ObjectDelete(0,name);
//--- создадим текстовую метку
   ObjectCreate(0,name,OBJ_LABEL,0,0,0);
//--- установим координаты метки
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
//--- установим угол графика, относительно которого будут определяться координаты точки
   ObjectSetInteger(0,name,OBJPROP_CORNER,Corner);
//--- установим текст
   ObjectSetString(0,name,OBJPROP_TEXT,text);
//--- установим шрифт текста
   ObjectSetString(0,name,OBJPROP_FONT,FontName);
//--- установим размер шрифта
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FontSize);
//--- установим цвет
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
  }
//+------------------------------------------------------------------+
