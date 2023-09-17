//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#define mystrateges_manual_trailing 1

#ifndef mystrateges_core
   #include "strategy.mqh"
#endif

input bool        useStep1=false; // Использовать трейлинг 1
input double      trailing1=1.5; // Множитель для трейлинг 1
input bool        useStep2=false; // Использовать трейлинг 2
input double      trailing2=9; // Множитель для трейлинг 2
input bool        useStep3=false; // Использовать трейлинг 3
input double      trailing3=12.5; // Множитель для трейлинг 3
input bool        useStep4=false; // Использовать трейлинг 4
input double      trailing4=13; // Множитель для трейлинг 4
input bool        useStep5=false; // Использовать трейлинг 5
input double      trailing5=15; // Множитель для трейлинг 5
