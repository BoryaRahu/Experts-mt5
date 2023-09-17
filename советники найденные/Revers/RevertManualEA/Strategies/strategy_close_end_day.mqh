//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#define mystrateges_close_end_day 1

#ifndef mystrateges_core
   #include "strategy.mqh"
#endif

sinput string     delimeter_base_03=""; // --- Закрытие позиции
input bool        CloseBadEndDay=true; //Закрывать убыточные позиции в CloseBadOnTime часов
input int         CloseBadOnTime=24; //#1 Закрывать убыточные позиции в, час
input int         CloseBadOnTime2=24; //#2 Закрывать убыточные позиции в, час
