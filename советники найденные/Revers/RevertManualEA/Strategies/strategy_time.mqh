//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#define mystrateges_time 1

#ifndef mystrateges_core
   #include "strategy.mqh"
#endif

sinput string delimeter_time_01=""; // --- Ограничение по месяцам
input bool     NoJanuary=false; //Не открывать сделки в январе
input bool     NoFebruary=false; //Не открывать сделки в феврале
input bool     NoMarch=false; //Не открывать сделки в марте
input bool     NoApril=false; //Не открывать сделки в апреле
input bool     NoMay=false; //Не открывать сделки в мае
input bool     NoJune=false; //Не открывать сделки в июне
input bool     NoJuly=false; //Не открывать сделки в июле
input bool     NoAugust=false; //Не открывать сделки в августе
input bool     NoSeptember=false; //Не открывать сделки в сентябре
input bool     NoOctober=false; //Не открывать сделки в октябре
input bool     NoNovember=false; //Не открывать сделки в ноябре
input bool     NoDecember=false; //Не открывать сделки в декабре
sinput string delimeter_time_02=""; // --- Ограничение по дням недели
input bool     NoMonday=false; //Не открывать сделки в понедельник
input bool     NoTuesday=false; //Не открывать сделки во вторник
input bool     NoWednesday=false; //Не открывать сделки в среду
input bool     NoThursday=false; //Не открывать сделки в четверг
input bool     NoFriday=false; //Не открывать сделки в пятницу
sinput string delimeter_time_03=""; // --- Ограничение по часам
input bool     NoHour0=false; //Не открывать сделки в полночь
input bool     NoHour1=false; //Не открывать сделки в 1 час ночи
input bool     NoHour2=false; //Не открывать сделки в 2 часа ночи
input bool     NoHour3=false; //Не открывать сделки в 3 часа ночи
input bool     NoHour4=false; //Не открывать сделки в 4 часа утра
input bool     NoHour5=false; //Не открывать сделки в 5 часов утра
input bool     NoHour6=false; //Не открывать сделки в 6 часов утра
input bool     NoHour7=false; //Не открывать сделки в 7 часов утра
input bool     NoHour8=false; //Не открывать сделки в 8 часов утра
input bool     NoHour9=false; //Не открывать сделки в 9 часов утра
input bool     NoHour10=false; //Не открывать сделки в 10 часов утра
input bool     NoHour11=false; //Не открывать сделки в 11 часов утра
input bool     NoHour12=false; //Не открывать сделки в 12 часов дня
input bool     NoHour13=false; //Не открывать сделки в 13 часов дня
input bool     NoHour14=false; //Не открывать сделки в 14 часов дня
input bool     NoHour15=false; //Не открывать сделки в 15 часов дня
input bool     NoHour16=false; //Не открывать сделки в 16 часов дня
input bool     NoHour17=false; //Не открывать сделки в 17 часов вечера
input bool     NoHour18=false; //Не открывать сделки в 18 часов вечера
input bool     NoHour19=false; //Не открывать сделки в 19 часов вечера
input bool     NoHour20=false; //Не открывать сделки в 20 часов вечера
input bool     NoHour21=false; //Не открывать сделки в 21 час вечера
input bool     NoHour22=false; //Не открывать сделки в 22 часа вечера
input bool     NoHour23=false; //Не открывать сделки в 23 часа вечера


class pdx_strat_time:public pdx_strat_base{
public:
   pdx_strat_time();
   ~pdx_strat_time();
   bool skipMe(bool isLong=true);
   void data();
};
pdx_strat_time::pdx_strat_time(){
}
pdx_strat_time::~pdx_strat_time(){
}
void pdx_strat_time::data(){
}
bool pdx_strat_time::skipMe(bool isLong=true){
   MqlDateTime curT;
   TimeCurrent(curT);
   
   if( NoFriday && curT.day_of_week==5 ){
      return true;
   }
   if( NoThursday && curT.day_of_week==4 ){
      return true;
   }
   if( NoWednesday && curT.day_of_week==3 ){
      return true;
   }
   if( NoTuesday && curT.day_of_week==2 ){
      return true;
   }
   if( NoMonday && curT.day_of_week==1 ){
      return true;
   }
   if( NoHour0 && curT.hour==0 ){
      return true;
   }
   if( NoHour1 && curT.hour==1 ){
      return true;
   }
   if( NoHour2 && curT.hour==2 ){
      return true;
   }
   if( NoHour3 && curT.hour==3 ){
      return true;
   }
   if( NoHour4 && curT.hour==4 ){
      return true;
   }
   if( NoHour5 && curT.hour==5 ){
      return true;
   }
   if( NoHour6 && curT.hour==6 ){
      return true;
   }
   if( NoHour7 && curT.hour==7 ){
      return true;
   }
   if( NoHour8 && curT.hour==8 ){
      return true;
   }
   if( NoHour9 && curT.hour==9 ){
      return true;
   }
   if( NoHour10 && curT.hour==10 ){
      return true;
   }
   if( NoHour11 && curT.hour==11 ){
      return true;
   }
   if( NoHour12 && curT.hour==12 ){
      return true;
   }
   if( NoHour13 && curT.hour==13 ){
      return true;
   }
   if( NoHour14 && curT.hour==14 ){
      return true;
   }
   if( NoHour15 && curT.hour==15 ){
      return true;
   }
   if( NoHour16 && curT.hour==16 ){
      return true;
   }
   if( NoHour17 && curT.hour==17 ){
      return true;
   }
   if( NoHour18 && curT.hour==18 ){
      return true;
   }
   if( NoHour19 && curT.hour==19 ){
      return true;
   }
   if( NoHour20 && curT.hour==20 ){
      return true;
   }
   if( NoHour21 && curT.hour==21 ){
      return true;
   }
   if( NoHour22 && curT.hour==22 ){
      return true;
   }
   if( NoHour23 && curT.hour==23 ){
      return true;
   }
   if( NoJanuary && curT.mon==1 ){
      return true;
   }
   if( NoFebruary && curT.mon==2 ){
      return true;
   }
   if( NoMarch && curT.mon==3 ){
      return true;
   }
   if( NoApril && curT.mon==4 ){
      return true;
   }
   if( NoMay && curT.mon==5 ){
      return true;
   }
   if( NoJune && curT.mon==6 ){
      return true;
   }
   if( NoJuly && curT.mon==7 ){
      return true;
   }
   if( NoAugust && curT.mon==8 ){
      return true;
   }
   if( NoSeptember && curT.mon==9 ){
      return true;
   }
   if( NoOctober && curT.mon==10 ){
      return true;
   }
   if( NoNovember && curT.mon==11 ){
      return true;
   }
   if( NoDecember && curT.mon==12 ){
      return true;
   }
   
   return false;
}