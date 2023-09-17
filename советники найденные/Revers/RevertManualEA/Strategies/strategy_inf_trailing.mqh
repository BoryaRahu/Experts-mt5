//+------------------------------------------------------------------+
//|                                                  mystrateges.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Klymenko Roman (needtome@icloud.com)"
#property link      "https://logmy.net"
#define mystrateges_inf_trailing 1

#ifndef mystrateges_core
   #include "strategy.mqh"
#endif

input int         trailingInfAfter=0; // Использовать постоянный трейлинг после N пунктов прибыли
input int         trailingInfValue=0; // Постоянный трейлинг в пунктах
