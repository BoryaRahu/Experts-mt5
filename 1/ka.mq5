//+------------------------------------------------------------------+
//| MoneyMaker.mq5 |
//| Mayorov Maxim |
//| mayorovmp@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Mayorov Maxim"
#property link "mayorovmp@yandex.ru"
#property version "1.00"
#include<Trade\AccountInfo.mqh>
#include<Trade\SymbolInfo.mqh>
#include<Trade\Trade.mqh>
CAccountInfo account;
CSymbolInfo symbol_info;//Класс символа торговой пары
CTrade trade;//Класс для торговых операций
//+------------------------------------------------------------------+
//| Signals
//+------------------------------------------------------------------+
#include"Signals\MovingAverageIntersect.mqh"//+
#include"Signals\MacdIntersect.mqh"//+
#include"Signals\Stochastic.mqh"//+
#include"Signals\AMA.mqh"
#include"Signals\RSI.mqh"
#include"Signals\CCI.mqh"//+
#include"Signals\WPR.mqh"
#include"Signals\BANDS.mqh"
#include"Signals\StdDevChannel.mqh"
#include"Signals\Envelopes.mqh"
#include"Signals\Alligator.mqh"
//+------------------------------------------------------------------+
//| Global variables |
//+------------------------------------------------------------------+
#define SIGNALS_N 11
#define N 1000
ISignal *signals[SIGNALS_N];
OrderType predicts[SIGNALS_N][N];
double asks[N];//Цена продажи
double bids[N];//Цена покупки
int currentTick=0;
MqlTick last_tick;//Получение информации о котировках
//+------------------------------------------------------------------+
//|Инициализация
//+------------------------------------------------------------------+
int OnInit()
 {
 InitSignals();

 InitRulesB();

 InitTrade();
 Print("Init success");
 return(INIT_SUCCEEDED);
 }
64

 void InitSignals()
 {
 signals[0] = (new MovingAverageIntersect());
 signals[1] = (new MacdIntersect());
 signals[2] = (new Stochastic());
 signals[3] = (new AMA());
 signals[4] = (new RSI());
 signals[5] = (new CCI());
 signals[6] = (new WPR());
 signals[7] = (new BANDS());
 signals[8] = (new StdDevChannel());
 signals[9] = (new Envelopes());
 signals[10] = (new Alligator());
}
//+------------------------------------------------------------------+
//| Вспомогательная функция сохранения состояния
//+------------------------------------------------------------------+
void RememberState()
 {
 SymbolInfoTick(Symbol(),last_tick);//Получение информации о текущем тике.
 asks[currentTick % N] = last_tick.ask;
 bids[currentTick % N] = last_tick.bid;
 for(int i=0; i<SIGNALS_N; i++)
 {
 OrderType predict=signals[i].calc();
 predicts[i][currentTick]=predict;
 }
 currentTick = (currentTick + 1)%N;
 }
//+------------------------------------------------------------------+
//|Голосование большинства
//+------------------------------------------------------------------+
int MajorityVote()
{
 int cntSell = 0, cntBuy = 0, cntWait = 0;
 int signalSell = -1, signalBuy = -1, signalWait = -1;
 for(int i=0; i<SIGNALS_N;i++)
 {
 if(predicts[i][(N+currentTick-1)%N] == BUY)
 {
 cntBuy++;
 signalBuy = i;
 }else if(predicts[i][(N+currentTick-1)%N] == SELL)
 {
 cntSell++;
 signalSell = i;
 }
 else
 {
 cntWait++;
 signalWait = i;
 }
 }
 if(cntSell > cntBuy)
 return signalSell;
 if(cntBuy > cntSell )
 return signalBuy;

 return signalWait;
}
65
//+------------------------------------------------------------------+
//|Поиск лучшего сигнала для Правила К
//+------------------------------------------------------------------+
#define K 10
double profits[SIGNALS_N];
int FindBestSignal()
{
 for(int i=0; i<SIGNALS_N;i++)
 {
 profits[i] = 0;
 for(int j = 1; j<= K;j++)
 {
 int oldTick=(N+currentTick-j)%N;
 if(predicts[i][oldTick]==BUY)
 {//Советник просигнализировал о покупке.
 //Купили по цене asks[i]. Продаем по цене last_tick.bid.
 profits[i]+=last_tick.bid-asks[oldTick];
 }
 if(predicts[i][oldTick]==SELL)
 {//Советник просигнализировал о продаже.
 //Продали по цене bids[i]. Покупаем по цене last_tick.ask.
 profits[i]+=last_tick.ask-bids[oldTick];
 }
 }
 }
 int bestSignal=0;
 for(int i=0; i<SIGNALS_N;i++)
 if(profits[i]>profits[bestSignal])
 bestSignal=i;
 return bestSignal;
}
//+------------------------------------------------------------------+
//| Правило К
//+------------------------------------------------------------------+
int RulesK()
 {
 if(currentTick<=K)//Не достаточно истории.
 return -1;

 int bestSignal = FindBestSignal();

 return bestSignal;
 }
//+------------------------------------------------------------------+
//| Правило B |
//+------------------------------------------------------------------+
int tau = 0;
double alfa = 0.5;
double B[SIGNALS_N];//
int RulesB()
 {
 if(currentTick <= tau)//Не достаточно истории.
 return -1;
 for(int i = 0;i < SIGNALS_N; i++)
 {
 double e = 0;
 if(predicts[i][currentTick - tau]==BUY)
 {//Советник просигнализировал о покупке.
 //Купили по цене asks[i]. Продаем по цене last_tick.bid.
 e = last_tick.bid-asks[currentTick - tau];
 }
66
 if(predicts[i][currentTick - tau]==SELL)
 {//Советник просигнализировал о продаже.
 //Продали по цене bids[i]. Покупаем по цене last_tick.ask.
 e = last_tick.ask-bids[currentTick - tau];
 }
 if(e > 0)
 e = 0;

 B[i] = (1 - alfa) * B[i] + alfa * e * e;
 }
 int bestSignal=0;
 for(int i=0; i<SIGNALS_N;i++)
 if(B[i] < B[bestSignal])
 bestSignal=i;
 return bestSignal;
 }

 void InitRulesB()
 {
 for(int i = 0;i < SIGNALS_N; i++)
 B[i] = 0;
 }
//+------------------------------------------------------------------+
//|Вспомогательная функция создания торгового ордера |
//+------------------------------------------------------------------+
OrderType lastOrder=WAIT;
int openPos = 0;
int maxOpenPos = 10;
void MakeOrder(int signal)
 {
 if(signal == -1)return;

 if(predicts[signal][(N+currentTick-1)%N]==BUY)
 {
 if(lastOrder==SELL)
 {
 CloseAllPosition();
 openPos = 0;
 }
 if(openPos > maxOpenPos)
 return;
 if(!trade.Buy(0.01, NULL, 0.0, last_tick.ask - 0.01, last_tick.ask +
0.01))
 {
 //--- сообщим о неудаче
 Print("Метод Buy() потерпел неудачу. Код
возврата=",trade.ResultRetcode(),
 ". Описание кода: ",trade.ResultRetcodeDescription());
 }
 else
 {
 openPos++;
 lastOrder=BUY;
 }
 }
 if(predicts[signal][(N+currentTick-1)%N]==SELL)
 {
 if(lastOrder==BUY)
 {
 CloseAllPosition();
67
 openPos = 0;
 }
 if(openPos > maxOpenPos)
 return;
 if(!trade.Sell(0.01, NULL, 0.0, last_tick.bid + 0.01, last_tick.ask -
0.01))
 {
 //--- сообщим о неудаче
 Print("Метод Sell() потерпел неудачу. Код
возврата=",trade.ResultRetcode(),
 ". Описание кода: ",trade.ResultRetcodeDescription());
 }
 else
 {
 lastOrder=SELL;
 openPos++;
 }

 }
 }
//+------------------------------------------------------------------+
//| Инициализация торговли |
//+------------------------------------------------------------------+
void InitTrade()
 {
//--- установим допустимое проскальзывание в пунктах при совершении
покупки/продажи
 int deviation=10;
 trade.SetDeviationInPoints(deviation);
//--- какую функцию использовать для торговли: true - OrderSendAsync(), false -
OrderSend()
 trade.SetAsyncMode(true);
//---
 }
//+------------------------------------------------------------------+
//| Функция обработки тиков |
//+------------------------------------------------------------------+
void OnTick()
 {
 RememberState();
 //int signal=RulesK();
 int signal = MajorityVote();
 //int signal=RulesB();
 MakeOrder(signal);
 }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
 {
 CloseAllPosition();
 }

void CloseAllPosition()
 {
 while(trade.PositionClose(_Symbol));
 }
//+------------------------------------------------------------------+
68
Интерфейс сигналов
//+------------------------------------------------------------------+
//| ISignal.mqh |
//| Mayorov Maxim |
//| mayorovmp@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Mayorov Maxim"
#property link "mayorovmp@yandex.ru"
#property version "1.00"
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
enum OrderType{
 SELL = 1, //Продажа
 WAIT = 0, //Ожидание
 BUY = -1, //Покупка
};
interface ISignal
 {
public:
 OrderType calc();
 };
Cигналы
//+------------------------------------------------------------------+
//| |
//| Mayorov Maxim |
//| mayorovmp@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Mayorov Maxim"
#property link "mayorovmp@yandex.ru"
#property version "1.00"
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
#include"../ISignal.mqh"
class Alligator : public ISignal
 {
private:
 int h_al;
 double al1_buffer[], al2_buffer[], al3_buffer[], Close[];
public:
 Alligator();
 ~Alligator();
 OrderType calc();
 };
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
Alligator ::Alligator()
 {
 h_al=iAlligator(Symbol(),Period(),13,0,8,0,5,0,MODE_SMMA,PRICE_MEDIAN);
 }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
Alligator ::~Alligator()
 {
 }
//+------------------------------------------------------------------+
OrderType Alligator :: calc()
{
69
 OrderType sig=0;
 if(h_al==INVALID_HANDLE)
 {
 h_al=iAlligator(Symbol(),Period(),13,0,8,0,5,0,MODE_SMMA,PRICE_MEDIAN);
 return(0);
 }
 else
 {
 if(CopyBuffer(h_al,0,0,2,al1_buffer)<2)
 return(0);
 if(CopyBuffer(h_al,1,0,2,al2_buffer)<2)
 return(0);
 if(CopyBuffer(h_al,2,0,2,al3_buffer)<2)
 return(0);
 if(!ArraySetAsSeries(al1_buffer,true))
 return(0);
 if(!ArraySetAsSeries(al2_buffer,true))
 return(0);
 if(!ArraySetAsSeries(al3_buffer,true))
 return(0);
 }
//--- проводим проверку условия и устанавливаем значение для sig
 if(al3_buffer[1]>al2_buffer[1] && al2_buffer[1]>al1_buffer[1])
 sig=1;
 else if(al3_buffer[1]<al2_buffer[1] && al2_buffer[1]<al1_buffer[1])
 sig=-1;
 else sig=0;
//--- возвращаем торговый сигнал
 return(sig);
 }
//+------------------------------------------------------------------+
//| AMA.mqh |
//| Mayorov Maxim |
//| mayorovmp@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Mayorov Maxim"
#property link "mayorovmp@yandex.ru"
#property version "1.00"
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
#include"../ISignal.mqh"
class AMA : public ISignal
 {
private:
 int h_ama;
 double ama_buffer[];
public:
 AMA();
 ~AMA();
 OrderType calc();
 };
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
AMA::AMA()
 {
 h_ama=iAMA(Symbol(),Period(),9,2,30,0,PRICE_CLOSE);
 }
70
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
AMA::~AMA()
 {
 }
//+------------------------------------------------------------------+
OrderType AMA::calc()
{
 OrderType sig=0;
 if(h_ama==INVALID_HANDLE)
 {
 h_ama=iAMA(Symbol(),Period(),9,2,30,0,PRICE_CLOSE);
 return(0);
 }
 else
 {
 if(CopyBuffer(h_ama,0,0,3,ama_buffer)<3)
 return(0);
 if(!ArraySetAsSeries(ama_buffer,true))
 return(0);
 }
//--- проводим проверку условия и устанавливаем значение для sig
 if(ama_buffer[2]<ama_buffer[1])
 sig=1;
 else if(ama_buffer[2]>ama_buffer[1])
 sig=-1;
 else sig=0;
//--- возвращаем торговый сигнал
 return (sig);
}
//+------------------------------------------------------------------+
//| BANDS.mqh |
//| Mayorov Maxim |
//| mayorovmp@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Mayorov Maxim"
#property link "mayorovmp@yandex.ru"
#property version "1.00"
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
#include"../ISignal.mqh"
class BANDS : public ISignal
 {
private:
 int h_bb;
 double bb1_buffer[], bb2_buffer[], Close[];
public:
 BANDS();
 ~BANDS();
 OrderType calc();
 };
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
BANDS::BANDS()
 {
71
 h_bb=iBands(Symbol(),Period(),20,0,2,PRICE_CLOSE);
 }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
BANDS::~BANDS()
 {
 }
//+------------------------------------------------------------------+
OrderType BANDS::calc()
 {
 OrderType sig=0;
 if(h_bb==INVALID_HANDLE)
 {
 h_bb=iBands(Symbol(),Period(),20,0,2,PRICE_CLOSE);
 return(0);
 }
 else
 {
 if(CopyBuffer(h_bb,1,0,2,bb1_buffer)<2)
 return(0);
 if(CopyBuffer(h_bb,2,0,2,bb2_buffer)<2)
 return(0);
 if(CopyClose(Symbol(),Period(),0,3,Close)<3)
 return(0);
 if(!ArraySetAsSeries(bb1_buffer,true))
 return(0);
 if(!ArraySetAsSeries(bb2_buffer,true))
 return(0);
 if(!ArraySetAsSeries(Close,true))
 return(0);
 }
//--- проводим проверку условия и устанавливаем значение для sig
 if(Close[2]<=bb2_buffer[1] && Close[1]>bb2_buffer[1])
 sig=1;
 else if(Close[2]>=bb1_buffer[1] && Close[1]<bb1_buffer[1])
 sig=-1;
 else sig=0;
//--- возвращаем торговый сигнал
 return(sig);
 }
//+------------------------------------------------------------------+
//| CI.mqh |
//| Mayorov Maxim |
//| mayorovmp@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Mayorov Maxim"
#property link "mayorovmp@yandex.ru"
#property version "1.00"
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
#include"../ISignal.mqh"
class CCI : public ISignal
 {
private:
 int h_cci;
 double cci_buffer[];
public:
 CCI();
72
 ~CCI();
 OrderType calc();
 };
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
CCI::CCI()
 {
 h_cci=iCCI(Symbol(),Period(),14,PRICE_TYPICAL);
 }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
CCI::~CCI()
 {
 }
//+------------------------------------------------------------------+
OrderType CCI::calc()
 {
 OrderType sig=0;
 if(h_cci==INVALID_HANDLE)
 {
 h_cci=iCCI(Symbol(),Period(),14,PRICE_TYPICAL);
 return(0);
 }
 else
 {
 if(CopyBuffer(h_cci,0,0,3,cci_buffer)<3)
 return(0);
 if(!ArraySetAsSeries(cci_buffer,true))
 return(0);
 }
//--- проводим проверку условия и устанавливаем значение для sig
 if(cci_buffer[2]<-100 && cci_buffer[1]>-100)
 sig=1;
 else if(cci_buffer[2]>100 && cci_buffer[1]<100)
 sig=-1;
 else sig=0;
//--- возвращаем торговый сигнал
 return(sig);
 }
//+------------------------------------------------------------------+
//| Envelopes.mqh |
//| Mayorov Maxim |
//| mayorovmp@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Mayorov Maxim"
#property link "mayorovmp@yandex.ru"
#property version "1.00"
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
#include"../ISignal.mqh"
class Envelopes : public ISignal
 {
private:
 int h_env;
 double env1_buffer[], env2_buffer[], Close[];
public:
73
 Envelopes();
 ~Envelopes();
 OrderType calc();
 };
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
Envelopes::Envelopes()
 {
 h_env=iEnvelopes(Symbol(),Period(),28,0,MODE_SMA,PRICE_CLOSE,0.1);
 }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
Envelopes::~Envelopes()
 {
 }
//+------------------------------------------------------------------+
OrderType Envelopes::calc()
 {
 OrderType sig=0;
 if(h_env==INVALID_HANDLE)
 {
 h_env=iEnvelopes(Symbol(),Period(),28,0,MODE_SMA,PRICE_CLOSE,0.1);
 return(0);
 }
 else
 {
 if(CopyBuffer(h_env,0,0,2,env1_buffer)<2)
 return(0);
 if(CopyBuffer(h_env,1,0,2,env2_buffer)<2)
 return(0);
 if(CopyClose(Symbol(),Period(),0,3,Close)<3)
 return(0);
 if(!ArraySetAsSeries(env1_buffer,true))
 return(0);
 if(!ArraySetAsSeries(env2_buffer,true))
 return(0);
 if(!ArraySetAsSeries(Close,true))
 return(0);
 }
//--- проводим проверку условия и устанавливаем значение для sig
 if(Close[2]<=env2_buffer[1] && Close[1]>env2_buffer[1])
 sig=1;
 else if(Close[2]>=env1_buffer[1] && Close[1]<env1_buffer[1])
 sig=-1;
 else sig=0;
//--- возвращаем торговый сигнал
 return(sig);
 }
//+------------------------------------------------------------------+
//| MacdIntersect.mqh |
//| Mayorov Maxim |
//| mayorovmp@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Mayorov Maxim"
#property link "mayorovmp@yandex.ru"
#property version "1.00"
//+------------------------------------------------------------------+
//| |
74
//+------------------------------------------------------------------+
#include"../ISignal.mqh"
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
class MacdIntersect : public ISignal
 {
private:
 int h_macd;
 double macd1_buffer[],macd2_buffer[];
public:
 MacdIntersect();
 ~MacdIntersect();
 OrderType calc();
 };
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
MacdIntersect::MacdIntersect()
 {
 h_macd=iMACD(Symbol(),Period(),12,26,9,PRICE_CLOSE);
 }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
MacdIntersect::~MacdIntersect()
 {
 }
//+------------------------------------------------------------------+
OrderType MacdIntersect::calc()
{
 OrderType sig=0;
 if(h_macd==INVALID_HANDLE)
 {
 h_macd=iMACD(Symbol(),Period(),12,26,9,PRICE_CLOSE);
 return OrderType(0);
 }
 else
 {
 if(CopyBuffer(h_macd,0,0,2,macd1_buffer)<2)
 return OrderType(0);
 if(CopyBuffer(h_macd,1,0,3,macd2_buffer)<3)
 return OrderType(0);
 if(!ArraySetAsSeries(macd1_buffer,true))
 return OrderType(0);
 if(!ArraySetAsSeries(macd2_buffer,true))
 return OrderType(0);
 }
//--- проводим проверку условия и устанавливаем значение для sig
 if(macd2_buffer[2]>macd1_buffer[1] && macd2_buffer[1]<macd1_buffer[1])
 sig=1;
 else if(macd2_buffer[2]<macd1_buffer[1] && macd2_buffer[1]>macd1_buffer[1])
 sig=-1;
 else sig=0;
//--- возвращаем торговый сигнал
 return (sig);
}
75
//+------------------------------------------------------------------+
//| Signal_1.mqh |
//| Mayorov Maxim |
//| mayorovmp@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Mayorov Maxim"
#property link "mayorovmp@yandex.ru"
#property version "1.00"
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
#include"../ISignal.mqh"
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
class MovingAverageIntersect:public ISignal
 {
private:
 int h_ma1,h_ma2;
 double ma1_buffer[],ma2_buffer[];
public:
 MovingAverageIntersect();
 ~MovingAverageIntersect();
 OrderType calc();
 };
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
MovingAverageIntersect::MovingAverageIntersect()
 {
 h_ma1=iMA(Symbol(),Period(),8,0,MODE_SMA,PRICE_CLOSE);
 h_ma2=iMA(Symbol(),Period(),16,0,MODE_SMA,PRICE_CLOSE);
 }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
MovingAverageIntersect::~MovingAverageIntersect()
 {
 }
//+------------------------------------------------------------------+
OrderType MovingAverageIntersect::calc()
{
//--- ноль означает отсутствие сигнала
 OrderType sig=0;
//--- проверим хендлы индикаторов
 if(h_ma1==INVALID_HANDLE)//--- если хэндл невалидный
 {
 //--- создадим его снова
 h_ma1=iMA(Symbol(),Period(),8,0,MODE_SMA,PRICE_CLOSE);
 //--- выходим из функции
 return(0);
 }
 else //--- если хэндл валидный
 {
 //--- копируем значения из индикатора в массив
 if(CopyBuffer(h_ma1,0,0,3,ma1_buffer)<3) //--- и если данных меньше
требуемых
 //--- выходим из функции
 return(0);
76
 //--- зададим индексацию в массиве как таймсерию
 if(!ArraySetAsSeries(ma1_buffer,true))
 //--- в случае ошибки индексации выходим из функции
 return(0);
 }
 if(h_ma2==INVALID_HANDLE)//--- если хэндл невалидный
 {
 //--- создадим его снова
 h_ma2=iMA(Symbol(),Period(),16,0,MODE_SMA,PRICE_CLOSE);
 //--- выходим из функции
 return(0);
 }
 else //--- если хэндл валидный
 {
 //--- копируем значения из индикатора в массив
 if(CopyBuffer(h_ma2,0,0,2,ma2_buffer)<2) //--- и если данных меньше
требуемых
 //--- выходим из функции
 return(0);
 //--- зададим индексацию в массиве как таймсерию
 if(!ArraySetAsSeries(ma1_buffer,true))
 //--- в случае ошибки индексации выходим из функции
 return(0);
 }
//--- проводим проверку условия и устанавливаем значение для sig
 if(ma1_buffer[2]<ma2_buffer[1] && ma1_buffer[1]>ma2_buffer[1])
 sig=1;
 else if(ma1_buffer[2]>ma2_buffer[1] && ma1_buffer[1]<ma2_buffer[1])
 sig=-1;
 else sig=0;

//--- возвращаем торговый сигнал
 return (sig);
 }
//+------------------------------------------------------------------+
//| RSI.mqh |
//| Mayorov Maxim |
//| mayorovmp@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Mayorov Maxim"
#property link "mayorovmp@yandex.ru"
#property version "1.00"
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
#include"../ISignal.mqh"
class RSI : public ISignal
 {
private:
 int h_rsi;
 double rsi_buffer[];
public:
 RSI();
 ~RSI();
 OrderType calc();
 };
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
RSI::RSI()
77
 {
 h_rsi=iRSI(Symbol(),Period(),14,PRICE_CLOSE);
 }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
RSI::~RSI()
 {
 }
//+------------------------------------------------------------------+
OrderType RSI::calc()
{
OrderType sig=0;
 if(h_rsi==INVALID_HANDLE)
 {
 h_rsi=iRSI(Symbol(),Period(),14,PRICE_CLOSE);
 return(0);
 }
 else
 {
 if(CopyBuffer(h_rsi,0,0,3,rsi_buffer)<3)
 return(0);
 if(!ArraySetAsSeries(rsi_buffer,true))
 return(0);
 }
//--- проводим проверку условия и устанавливаем значение для sig
 if(rsi_buffer[2]<30 && rsi_buffer[1]>30)
 sig=1;
 else if(rsi_buffer[2]>70 && rsi_buffer[1]<70)
 sig=-1;
 else sig=0;
//--- возвращаем торговый сигнал
 return(sig);
}
//+------------------------------------------------------------------+
//| StdDevChannel.mqh |
//| Mayorov Maxim |
//| mayorovmp@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Mayorov Maxim"
#property link "mayorovmp@yandex.ru"
#property version "1.00"
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
#include"../ISignal.mqh"
class StdDevChannel : public ISignal
 {
private:
 int h_sdc;
 double sdc1_buffer[], sdc2_buffer[], Close[];
public:
 StdDevChannel();
 ~StdDevChannel();
 OrderType calc();
 };
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
78
StdDevChannel::StdDevChannel()
 {
 h_sdc=iCustom(Symbol(),Period(),"Examples\\StdDev",14,0,MODE_SMA,PRICE_CLOSE
,2.0);
 }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
StdDevChannel::~StdDevChannel()
 {
 }
//+------------------------------------------------------------------+
OrderType StdDevChannel:: calc()
 {
 OrderType sig=0;
 if(h_sdc==INVALID_HANDLE)
 {
 h_sdc=iCustom(Symbol(),Period(),"Examples\\StdDev",14,0,MODE_SMA,PRICE_CL
OSE,2.0);
 return(0);
 }
 else
 {
 if(CopyBuffer(h_sdc,0,0,2,sdc1_buffer)<2)
 return(0);
 if(CopyBuffer(h_sdc,1,0,2,sdc2_buffer)<2)
 return(0);
 if(CopyClose(Symbol(),Period(),0,3,Close)<3)
 return(0);
 if(!ArraySetAsSeries(sdc1_buffer,true))
 return(0);
 if(!ArraySetAsSeries(sdc2_buffer,true))
 return(0);
 if(!ArraySetAsSeries(Close,true))
 return(0);
 }
//--- проводим проверку условия и устанавливаем значение для sig
 if(Close[2]<=sdc2_buffer[1] && Close[1]>sdc2_buffer[1])
 sig=1;
 else if(Close[2]>=sdc1_buffer[1] && Close[1]<sdc1_buffer[1])
 sig=-1;
 else sig=0;
//--- возвращаем торговый сигнал
 return(sig);
 }
//+------------------------------------------------------------------+
//| Stochastic.mqh |
//| Mayorov Maxim |
//| mayorovmp@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Mayorov Maxim"
#property link "mayorovmp@yandex.ru"
#property version "1.00"
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
#include"../ISignal.mqh"
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
79
class Stochastic : public ISignal
 {
private:
 double stoh_buffer[];
 int h_stoh;
public:
 Stochastic();
 ~Stochastic();
 OrderType calc();
 };
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
Stochastic::Stochastic()
 {
 h_stoh=iStochastic(Symbol(),Period(),5,3,3,MODE_SMA,STO_LOWHIGH);
 }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
Stochastic::~Stochastic()
 {
 }
//+------------------------------------------------------------------+
OrderType Stochastic:: calc()
{
OrderType sig=0;
 if(h_stoh==INVALID_HANDLE)
 {
 h_stoh=iStochastic(Symbol(),Period(),5,3,3,MODE_SMA,STO_LOWHIGH);
 return OrderType(0);
 }
 else
 {
 if(CopyBuffer(h_stoh,0,0,3,stoh_buffer)<3)
 return OrderType(0);
 if(!ArraySetAsSeries(stoh_buffer,true))
 return OrderType(0);
 }
//--- проводим проверку условия и устанавливаем значение для sig
 if(stoh_buffer[2]<20 && stoh_buffer[1]>20)
 sig=1;
 else if(stoh_buffer[2]>80 && stoh_buffer[1]<80)
 sig=-1;
 else sig=0;
//--- возвращаем торговый сигнал
 return (sig);
}
//+------------------------------------------------------------------+
//| WPR.mqh |
//| Mayorov Maxim |
//| mayorovmp@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Mayorov Maxim"
#property link "mayorovmp@yandex.ru"
#property version "1.00"
80
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
#include"../ISignal.mqh"
class WPR : public ISignal
 {
private:
 int h_wpr;
 double wpr_buffer[];
public:
 WPR();
 ~WPR();
 OrderType calc();
 };
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
WPR::WPR()
 {
 h_wpr=iWPR(Symbol(),Period(),14);
 }
//+------------------------------------------------------------------+
//| |
//+------------------------------------------------------------------+
WPR::~WPR()
 {
 }
//+------------------------------------------------------------------+
OrderType WPR::calc()
 {
 OrderType sig=0;
 if(h_wpr==INVALID_HANDLE)
 {
 h_wpr=iWPR(Symbol(),Period(),14);
 return(0);
 }
 else
 {
 if(CopyBuffer(h_wpr,0,0,3,wpr_buffer)<3)
 return(0);
 if(!ArraySetAsSeries(wpr_buffer,true))
 return(0);
 }
//--- проводим проверку условия и устанавливаем значение для sig
 if(wpr_buffer[2]<-80 && wpr_buffer[1]>-80)
 sig=1;
 else if(wpr_buffer[2]>-20 && wpr_buffer[1]<-20)
 sig=-1;
 else sig=0;
//--- возвращаем торговый сигнал
 return(sig);
 }
