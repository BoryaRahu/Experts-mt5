//+------------------------------------------------------------------+
//|                                        BollingerBandsForFlat.mq5 |
//|                                                          Aktiniy |
//|                                                             BBFF |
//+------------------------------------------------------------------+


#property version   "1.03"
#include <Trade\PositionInfo.mqh> CPositionInfo     m_position;
#include<Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
//--- input parameters
input char     time_h_start=17;             // Время начала торговли
input char     time_h_stop=5;               // Время окончания торговли
input int      bands_period=11;             // Период Bullinger Bands
input int      bands_shift=0;               // Сдвиг Bullinger Bands
input double   bands_diviation=2;           // Отклонения Bullinger Bands
input double   div_work=12;                  // Отклонение от сигнала
input double   div_signal=13;                // Занижение основного сигнала
input bool     work_alt=true;               // Работа с позиции в случае наличия противоположного сигнала
input int      take_profit=0;              // Take Profit
input int      stop_loss=0;               // Stop Loss
//input int      FilterCanal=0;               // фильтер шириены канала
//---
input bool     mon=true;                    // Работа в Понедельник
input bool     tue=true;                   // Работа во Вторник
input bool     wen=true;                    // Работа в Среду
input bool     thu=true;                    // Работа в Четверг
input bool     fri=true;                    // Работа в Пятницу
//---
input long     magic_number=65758473787389; 
input double   order_volume=0.01;           // Размер Лота
input int      order_deviation=100;         // Отклонение по открытия позиции
//--- Переменные
CSymbolInfo   a_symbol;
CPositionInfo     m_Position;   // entity for obtaining information on positions
MqlDateTime time_now_str;
datetime time_now_var;
CTrade trade;
int bb_handle,ma_handle,rsi_handle;
double bb_base_line[3];
double bb_upper_line[3];
double bb_lower_line[3];
bool work_day=true;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
 if (!a_symbol.Name(Symbol()))
      return(INIT_FAILED);
      
   RefreshRates();
   
   trade.SetExpertMagicNumber(magic_number);
   trade.SetDeviationInPoints(order_deviation);
   trade.SetTypeFilling(ORDER_FILLING_FOK);
   trade.SetAsyncMode(false);
 //---
  bb_handle=iBands(_Symbol,_Period,bands_period,bands_shift,bands_diviation,PRICE_CLOSE);       // узнаём хендл индикатора Bollinger Bands
   if (bb_handle == INVALID_HANDLE)
   {
      Print("Не удалось создать описатель индикатора bb_handle!");
      return(INIT_FAILED);
   }
   ma_handle=iMA(_Symbol,PERIOD_D1,bands_period,bands_shift,MODE_SMA,PRICE_CLOSE);       // узнаём хендл индикатора Bollinger Bands
    if (ma_handle == INVALID_HANDLE)
   {
      Print("Не удалось создать описатель индикатора ma_handle!");
      return(INIT_FAILED);
   }
   rsi_handle=iRSI(_Symbol,_Period,5,PRICE_CLOSE);       // узнаём хендл индикатора Bollinger Bands.
    if (rsi_handle == INVALID_HANDLE)
   {
      Print("Не удалось создать описатель индикатора rsi_handle!");
      return(INIT_FAILED);
   }
//---


/*
int digits = 1;
   
   if (a_symbol.Digits() == 3 || a_symbol.Digits() == 5)
      digits = 10;
      
   points = a_symbol.Point() * digits;
   eStep  = stop_loss * points;
   
   */
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
 string com="";
if (!RefreshRates())
      return;

 
   
   time_now_var=TimeCurrent(time_now_str);      // текущее время
   bool work=false;
   
      switch(time_now_str.day_of_week)
     {
      case 1: if(mon==false){work_day=false;}
      else {work_day=true;}
      break;
      case 2: if(tue==false){work_day=false;}
      else {work_day=true;}
      break;
      case 3: if(wen==false){work_day=false;}
      else {work_day=true;}
      break;
      case 4: if(thu==false){work_day=false;}
      else {work_day=true;}
      break;
      case 5: if(fri==false){work_day=false;}
      else {work_day=true;}
      break;
     }


 double         _rsi[];
    ArraySetAsSeries(_rsi,true);
   CopyBuffer(rsi_handle,0,0,5,_rsi);
   
   double         _ma[];
    ArraySetAsSeries(_ma,true);
   CopyBuffer(ma_handle,0,0,5,_ma);
   
      double price_ask=SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double price_bid=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      
   
   
   
//--- проверяем время работы
   if(time_h_start>time_h_stop)                  // работа с переходом на следующий день
     {
      if(time_now_str.hour>=time_h_start || time_now_str.hour<=time_h_stop)
        {
         work=true;  
     //  Print ("Работа разрешена1!");                           // передача флага разрешения на работу 
        }
     }
   else                                          // работа в течении дня
     {
      if(time_now_str.hour>=time_h_start && time_now_str.hour<=time_h_stop)
        {
         work=true;    
        }
     }
     

   int pos=PositionsTotal();
   
   
    int posO =0;
    
     for(int i = PositionsTotal() - 1; i >= 0; i--) 
                {
                   if(m_position.SelectByIndex(i)   )  // select a position
                     if(m_position.Symbol()==Symbol())
                         if(m_position.Magic()==magic_number)
                       posO ++;    
                         
                 } 
                 
    
      int i_bl=CopyBuffer(bb_handle,0,0,3,bb_base_line);
      int i_ul=CopyBuffer(bb_handle,1,0,3,bb_upper_line);
      int i_ll=CopyBuffer(bb_handle,2,0,3,bb_lower_line);
      if(i_bl==-1 || i_ul==-1 || i_ll==-1)
        {Alert("Error of copy iBands: base line=",i_bl,", upper band=",i_ul,", lower band=",i_ll);} // проверяем скопированные данные

   
      double bar = 1;
      PositionSelect(_Symbol);
      
  for(int i = PositionsTotal() - 1; i >= 0; i--) 
                {
                   if(m_position.SelectByIndex(i)   )  // select a position
                     if(m_position.Symbol()==Symbol())
                         if(m_position.Magic()==magic_number)
       if(posO >0 && work_alt==true)
        {
        
         if(trade.RequestType()==ORDER_TYPE_BUY)                                                                                                           // если до этого стоял ордер на покупку
            if((a_symbol.Bid()-(div_signal*_Point))>=bb_upper_line[0]-(div_work*_Point) && (a_symbol.Bid()-(div_signal*_Point))<=bb_upper_line[0]+(div_work*_Point)) // сигнал к продаже
              {
              if(!trade.PositionClose(_Symbol,order_deviation))
               Print("PositionClose error 1# Buy",GetLastError()); 
              }
         if(trade.RequestType()==ORDER_TYPE_SELL)                                                                                                          // если до этого стоял ордер на продажу
            if((a_symbol.Ask()+(div_signal*_Point))<=bb_lower_line[0]+(div_work*_Point) && (a_symbol.Ask()+(div_signal*_Point))>=bb_lower_line[0 ]-(div_work*_Point)) // сигнал к покупки
              {
             if(! trade.PositionClose(_Symbol,order_deviation))
               Print("PositionClose error 1# SELL",GetLastError()); 
              }
            }
        }
        
        
        
    if(work==true && work_day==true //&&  (bb_upper_line[0] - bb_lower_line[0] )> FilterCanal*_Point  
     )              // разрешение на работу полученно
     {



  


      if(posO <1)
        {
       if(
       (price_ask-(div_signal*_Point*_Digits))>=bb_upper_line[0]-(div_work*_Point*_Digits) && (price_ask-(div_signal*_Point*_Digits))<=bb_upper_line[0]+(div_work*_Point*_Digits)
      // && _ma[1] >_ma[2]
      // &&_rsi[1]<70
      // && _ma[0] >_ma[1] 
       &&_rsi[0]<_rsi[1]
       )   
           {
           double SL=0;
           double TP=0;
           Print("УСЛОВИЯ НА ПРОДАЖУ ВЫПОЛНЕНЫ");
           if (stop_loss>1) SL=(a_symbol.Bid()+(stop_loss*_Point*_Digits));
           if (stop_loss==1) SL=   a_symbol.Bid()+ ((bb_upper_line[0] - bb_lower_line[0] )*2  )   ;
           if (take_profit>0) TP= (a_symbol.Bid()-(take_profit*_Point*_Digits));
           if(!trade.Sell(order_volume,_Symbol,a_symbol.Bid(),SL,TP,"pos<1_sell"))
                Print("Open .Sell error 1# ",GetLastError()); 
           }
           
           
        if((price_bid+(div_signal*_Point*_Digits))<=bb_lower_line[0]+(div_work*_Point*_Digits) && (price_bid+(div_signal*_Point*_Digits))>=bb_lower_line[0]-(div_work*_Point*_Digits)
        //&&_ma[1]<_ma[2]
        //&&_rsi[1]>30
    //   &&_ma[0]<_ma[1]
        &&_rsi[0]>_rsi[1]
        )  
           {
           double SL=0;
           double TP=0;
           Print("УСЛОВИЯ НА ПОКУПКУ ВЫПОЛНЕНЫ");
           if (stop_loss>0) SL=(a_symbol.Ask()-(stop_loss*_Point*_Digits));
            if (stop_loss==1) SL=a_symbol.Ask() - ((bb_upper_line[0] - bb_lower_line[0])*2  )   ;
            if (take_profit>0) TP=(a_symbol.Ask()+(take_profit*_Point*_Digits));
            if(!trade.Buy(order_volume,_Symbol,a_symbol.Ask(),SL,TP,"pos<1_buy"))
               Print("Open .Buy error 1# ",GetLastError()); 
           }
        }
     
     }
   else
     {
      if(posO >0  )
        {
         //if(trade.RequestType()==ORDER_TYPE_BUY&& (price_bid+(10*_Point)) )  
        //     trade.PositionClose(_Symbol,order_deviation);
        //  if(trade.RequestType()==ORDER_TYPE_SELL&&(price_ask-(10*_Point)) )      
        //     trade.PositionClose(_Symbol,order_deviation);
        }
        
        
        
     }
  }
bool RefreshRates()
{
   if (!a_symbol.RefreshRates())
   {
      Print("не удалось обновить котировки валютной пары!");
      return(false);
   } 
   
   if (a_symbol.Ask() == 0 || a_symbol.Bid() == 0)
      return(false);
      
   return(true);   
}
  
  //+------------------------------------------------------------------+
//| Возвращает true, если появился новый бар для пары символ/период  |
//+------------------------------------------------------------------+
bool isNewBar()
  {


 static datetime PrevBars=0;
   datetime time_0=iTime(Symbol(),PERIOD_M1,0);
   if(time_0==PrevBars)
   {
      return(false);
    PrevBars=time_0;
   
   }
  else 
   return(true);
   
    }
    