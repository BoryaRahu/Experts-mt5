//************************************************************************************************/

//************************************************************************************************/

#include <Trade\PositionInfo.mqh> CPositionInfo     m_position;
#include <Trade\OrderInfo.mqh> COrderInfo     m_order;
#include <Trade\Trade.mqh> CTrade trade;
#include <Trade\AccountInfo.mqh>  CAccountInfo   AI;  
#include <Trade\SymbolInfo.mqh>
COrderInfo        m_Order;   // entity for obtaining information on positions
CPositionInfo     m_Position;   // entity for obtaining information on positions
CTrade            m_Trade;      // entity for execution of trades
CSymbolInfo       m_symbol;  
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/

input int           PointStep                 = 20 ; 
input double        iStartLots          = 0.01;     // Start lot
input ulong          iMagicNumber        = -1;      // Magic Number (in number)
input int          iSlippage           = 30;       // Slippage (in pips)
input int          MaxOrderAver        = 0;
input int          MaxOrderPyramid     = 6;
input bool         COMENT              = false; 
//---
enum t
  {
   b=1,     // по экстремумам свечей
   c=2,     // по фракталам
   d=3,     // по индикатору ATR
   e=4,     // по индикатору Parabolic
   f=5,     // по индикатору МА
   g=6,     // % от профита
   i=7,     // по пунктам
  };
  
 input  double procdeltassell =10; 
 input  double procdeltassbuy =10; 
input bool    VirtualTrailingStop=false; 
//виртуальный трейлингстоп
input t        parameters_trailing  =3;                        //метод трала
input  int     delta                =5;                            // отступ от расчетного уровня стоплосса
input          ENUM_TIMEFRAMES TF_Tralling=0;      // таймфрейм индикаторов (0-текущий)
input  int     StepTrall            =5;                        // шаг перемещения стоплосс
input  int          StartTrall           =  0 ;                       // минимальная прибыль трала в пунктах
color          text_color           =clrGreen;     //цвет вывода информации
sinput string Advanced_Options="";
input int     period_ATR=14;//Период ATR (метод 3)
input  double        koef = 100;
input double    Step=50000; //Parabolic Step (метод 4)
input double    Maximum=0.2; //Parabolic Maximum (метод 4)
  // int     iMagicNumber= -1;//с каким магиком тралить (-1 все)
extern bool    GeneralNoLoss=false;   // трал от точки безубытка
extern bool    DrawArrow=false;   // показывать метки безубытка и стопов
//+------------------MACD------------------------------------------------+
input ENUM_TIMEFRAMES  Fast_period=0; ;
input int ema_period=12;
input int low_ema_period=26;
input int signal_period=9;

input ENUM_APPLIED_PRICE applied_priceS=PRICE_CLOSE;



input int ma_period=34;//период МА (метод 5)
input ENUM_MA_METHOD ma_method=MODE_SMA; // метод усреднения  (метод 5)
input ENUM_APPLIED_PRICE applied_price=PRICE_CLOSE;    // тип цены  (метод 5)

input double PercetnProfit=50;//процент от профита (метод 6)



double eStep = 0;
int    HighBig ,LowBig, HighLitl,LowLitl, MA,handleClose, rsi, handle , MidlBig , MACD,STOC , JMAhandle, JMAhandlebig, MAbig ,JMAhandleM ,JMAhandlel ,Envelop ,EJMAhandle;
int STOPLEVEL;
double Bid,Ask,SLB=0,SLS=0;
int slippage=100;
int maHandle;    // хэндл индикатора Moving Average
double maVal[] , hiMACD;  // динамический массив для хранения значений индикатора Moving Average для каждого бара
int atrHandle;    // хэндл индикатора Moving Average
double atrVal[];  // динамический массив для хранения значений индикатора Moving Average для каждого бара
int sarHandle;    // хэндл индикатора Moving Average
double sarVal[];  // динамический массив для хранения значений индикатора Moving Average для каждого бара
//+------------------------------------------------------------------+
//| Структура сигнала                                                |
//+------------------------------------------------------------------+
struct sSignal
  {
   bool              Buy;    // сигнал на покупку
   bool              Sell;   // сигнал на продажу
  };
  struct rSignal
  {
   bool              Buy;    // сигнал на покупку
   bool              Sell;   // сигнал на продажу
  };
   struct pSignal
  {
   bool              Buy;    // сигнал на покупку
   bool              Sell;   // сигнал на продажу
  };
MqlTradeRequest   request;  // параметры торгового запроса
MqlTradeResult   result;    // результат торгового запроса
MqlTradeCheckResult check;
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
int OnInit()
  {
  
   
  
   
   eStep  = Step * _Point*_Digits ;
   
  double  MABuffer[];
  double  _MAbig[];
    HighBig=iMA(_Symbol,NULL,ema_period,1,MODE_EMA,PRICE_HIGH); 
  LowBig =iMA(_Symbol,NULL,ema_period,1,MODE_EMA,PRICE_LOW); 
  trade.SetTypeFillingBySymbol(m_symbol.Name());
  hiMACD = iMACD(_Symbol,Fast_period,ema_period,low_ema_period,signal_period,applied_priceS); 
   
     if(VirtualTrailingStop) GeneralNoLoss=true;
   string txt;
   switch(parameters_trailing)
     {
      case 1: // по экстремумам свечей
         StringConcatenate(txt,"по свечам ",StrPer(TF_Tralling)," +- ",delta);
         break;
      case 2: // по фракталам
         StringConcatenate(txt,"по фракталам ",StrPer(TF_Tralling)," +- ",delta);
         break;
      case 3: // по индикатору ATR
         StringConcatenate(txt,"по ATR (",IntegerToString(period_ATR),") ",StrPer(TF_Tralling),"+- ",delta);
         atrHandle=iATR(_Symbol,TF_Tralling,period_ATR);
         break;
      case 4: // по индикатору Parabolic
         StringConcatenate(txt,"по параболику (",DoubleToString(Step,2)," ",DoubleToString(Maximum,2),") ",StrPer(TF_Tralling)," +- ",delta);
         sarHandle=iSAR(_Symbol,TF_Tralling,Step,Maximum);
         break;
      case 5: // по индикатору МА
         StringConcatenate(txt,"по MA (",ma_period," ",ma_method," ",applied_price,") ",StrPer(TF_Tralling)," +- ",delta);
         maHandle=iMA(_Symbol,TF_Tralling,ma_period,0,ma_method,applied_price);
         break;
      case 6: // % от профита
         StringConcatenate(txt," ",DoubleToString(PercetnProfit,2),"% от профита)");
         break;
      default: // по пунктам
         StringConcatenate(txt,"по пунктам ",delta," п");
         break;
     }
   if(VirtualTrailingStop)
     {
      StringConcatenate(txt,"Виртуальный трал ",txt);
     }
   else
     {
      StringConcatenate(txt,"Tрал ",txt);
     }
   DrawLABEL(3,"cm 3",txt,5,30,text_color,ANCHOR_RIGHT);
   
  
  if ( COMENT) Comment("");
   trade.LogLevel(LOG_LEVEL_ERRORS);
   trade.SetExpertMagicNumber(iMagicNumber);
   trade.SetDeviationInPoints(iSlippage);
   trade.SetMarginMode();
   trade.SetTypeFillingBySymbol(Symbol());

   return(INIT_SUCCEEDED);
  }
//************************************************************************************************/
//*                                    
//+------------------------------------------------------------------+
//| Генератор сигналов       покупка для первого                                        |
//+------------------------------------------------------------------+
sSignal Buy_or_Sell()
  {
   sSignal res={false,false};
//--- индикаторные буферы 
  
  
     double         _Macd[];
    ArraySetAsSeries(_Macd,true);
   CopyBuffer(hiMACD,0,0,3,_Macd);
   MqlRates rates[];
   CopyRates(Symbol(),PERIOD_CURRENT,0,5,rates);
  
   MqlTick tick;
   if(!SymbolInfoTick(Symbol(),tick))
      Print("SymbolInfoTick() failed, error = ",GetLastError());

 double p = PointStep * _Point;
   
   //if((tick.bid - tick.ask) / 3 < p  && rates[1].close <rates[1].open)
     
      if(  rates[2].high-rates[2].low < rates[1].high-rates[1].low
     && rates[1].close <rates[1].open
      )
      
     res.Sell=true;
     
      
   if((  rates[2].high-rates[2].low < rates[1].high-rates[1].low
     && rates[1].close >rates[1].open
      )

   )
      res.Buy=true; 
//---
   return(res);
  }
 
//************************************************************************************************/

void OnTick()
  {
   double p = PointStep * _Point;
   bool CloseBuy=false;
   bool CloseSell=false;
   double
   BuyPriceMax=0,BuyPriceMin=0,BuyPriceMaxLot=0,BuyPriceMinLot=0,
   SelPriceMin=0,SelPriceMax=0,SelPriceMinLot=0,SelPriceMaxLot=0 ,MaxLot=0
   , BuyPriceMaxSL=0 ,SellPriceMinSL=0, BuyPriceMinSL=0 ,SellPriceMaxSL=0 , LastSelPriceMax=0,LastBuyPriceMax=0   ;

   ulong
   BuyPriceMaxTic=0,BuyPriceMinTic=0,SelPriceMaxTic=0,SelPriceMinTic=0 , LastSelPriceMaxTic=0,LastBuyPriceMaxTic=0 ;

   double
   op=0,lt=0,tp=0, sl=0;

   ulong    tk=0;
   int b=0,s=0;
   int bs=0,ss=0,Stopbs=0,Stopss=0; 
   
double Equity= AccountInfoDouble(ACCOUNT_EQUITY);//надо минусовать комисионные и swap для получения  htfkmyjq equiti
double Balance=AccountInfoDouble(ACCOUNT_BALANCE);
    
 //********************************************************
//  УСЛОВИЯ 
//*************************************************************//   
     
    
   double         UpLitl[];
   double         DownLityl[];
   double         UpBig[];
   double         DownBig[];
   double IMA[];
   double _MAbig[];
   double _JMAhandlebig[];
  
  
  
  
   ArraySetAsSeries(_JMAhandlebig,true);
   CopyBuffer(JMAhandlebig,0,0,3,_JMAhandlebig);
   
   
   ArraySetAsSeries(_MAbig,true);
   CopyBuffer(MAbig,0,0,3,_MAbig);
   
   

   ArraySetAsSeries(UpBig,true);
   CopyBuffer(HighBig,0,0,4,UpBig);
   
   ArraySetAsSeries(DownBig,true);
   CopyBuffer(LowBig,0,0,4,DownBig);
 double   AwerageBuyPrice=0,AwerageSelPrice=0, PartCloseSelPrice=0,PartCloseBuyPrice =0 , SelClose=0 , BuyClose=0, BuyAver=0 , SelAver=0   ;  

  
  double TPS = TOTAL_PROFIT_OF_OPEN_POSITIONS_SELL();
  double TPB =  TOTAL_PROFIT_OF_OPEN_POSITIONS_BUY();    
  double TPP =TOTAL_PROFIT_OF_OPEN_POSITIONS();
   double SL = 0;
  double TLB = 0;
  double TLS = 0;
  double SSL= 0;   
  double BSS = 0;
  double BLL = 0;
  double SLL= 0;      
  double OPlast = 0;                            // unnormalized SL value      
  datetime   TIMElast=0;
   
   string txt;
  
  int total=PositionsTotal();
  int totalORD=OrdersTotal();
  double d = NormalizeDouble(delta*_Point,_Digits);
  double ProcCanal = NormalizeDouble((UpBig[1] - DownBig[1]) /100 ,3);
  double deltas = (ProcCanal*koef) ;
  
  
  
  
    double procdeltasell = NormalizeDouble( d/100 *procdeltassell *_Point ,_Digits);
    double procdeltabay  = NormalizeDouble( d/100 *procdeltassbuy *_Point ,_Digits);
 //  NormalizeDouble(d + (10*_Point),_Digits)) 
  
  
  
   /*
   StringConcatenate(txt,"Balance ",DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2));
   DrawLABEL(2,"cm Balance",txt,5,20,Lime,ANCHOR_RIGHT);
   
   StringConcatenate(txt,"Equity ",DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2));
   DrawLABEL(2,"cm Equity",txt,5,35,Lime,ANCHOR_RIGHT);
   StringConcatenate(txt,"Profit BUY ",DoubleToString(TPB,2));
   DrawLABEL(2,"Profit BUY",txt,5,50,Lime,ANCHOR_RIGHT);
   StringConcatenate(txt,"Profit SELL ",DoubleToString(TPS  ,2));
   DrawLABEL(2,"Profit SELL",txt,5,65,Lime,ANCHOR_RIGHT);
  
*/
//*************************************************************//
  MqlRates rates[];
   CopyRates(Symbol(),PERIOD_CURRENT,0,2,rates);
  
   MqlTick tick;
   if(!SymbolInfoTick(Symbol(),tick))
    Print("SymbolInfoTick() failed, error = ",GetLastError());
    
     bool buycheck = false;
    bool Sellcheck = false;
   
     
      for(int k=totalORD-1; k>=0; k--)
      if(m_position.SelectByIndex(k))
       
         if(m_position.Symbol()==Symbol())
            if(m_position.Magic()==iMagicNumber)
            
            { 
           
                  if(m_order.OrderType()== ORDER_TYPE_BUY_LIMIT)
                    {  
                    BLL++;
                    }
                   if(m_order.OrderType()==ORDER_TYPE_BUY_STOP)
                    {  
                    BSS++;
                    }
                    if(m_order.OrderType()==ORDER_TYPE_SELL_LIMIT)
                    {  
                    SLL++;
                    }
                     if(m_order.OrderType()==ORDER_TYPE_SELL_STOP)
                    {  
                    SSL++;
                    }
            }
         
    
    
  
    
    
    
    
    
    
      ENUM_ORDER_TYPE order_type =WRONG_VALUE ;  
   for(int k=total-1; k>=0; k--)
      if(m_position.SelectByIndex(k))
       
         if(m_position.Symbol()==Symbol())
            if(m_position.Magic()==iMagicNumber)

            
               if(m_position.PositionType()==POSITION_TYPE_BUY || m_position.PositionType()==POSITION_TYPE_SELL)
                 {

                  op=NormalizeDouble(m_position.PriceOpen(),Digits());
                  lt=NormalizeDouble(m_position.Volume(),3);
                  tk=m_position.Ticket();
                  TLB=NormalizeDouble(m_position.Volume(),3);
                  TLS=NormalizeDouble(m_position.Volume(),3); 
       datetime   TIME = m_position.Time();
                  MaxLot=lt;
                  
                
                     if(TIME>TIMElast)
                       {
                
                        TIMElast=TIME;
                        OPlast = op ;                       
                       }
                       
                       
                  if(m_position.PositionType()==POSITION_TYPE_BUY)
                    {
                     bs++;
                     TLB++;
                     BuyAver=op*lt;
                     BuyAver++;
                    
                     
                    
                     
                     if(op>BuyPriceMax || BuyPriceMax==0)
                       {
                       
                        BuyPriceMax    = op;
                        BuyPriceMaxLot = lt;
                        BuyPriceMaxTic = tk;
                        BuyPriceMaxSL  = sl;
                        
                       }
                     if(op<BuyPriceMin || BuyPriceMin==0)
                       {
                        BuyPriceMin    = op;
                        BuyPriceMinLot = lt;
                        BuyPriceMinTic = tk;
                       }
                    }
                  // ===
                  if(m_position.PositionType()==POSITION_TYPE_SELL)
                    {
                     ss++;
                     TLS++;
                     SelAver=op*lt;
                     SelAver++;
                     
               
                     if(op>SelPriceMax || SelPriceMax==0)
                       {
                       
                        SelPriceMax    = op;
                        SelPriceMaxLot = lt;
                        SelPriceMaxTic = tk;
                       }
                     if(op<SelPriceMin || SelPriceMin==0)
                       {
                        SelPriceMin    = op;
                        SelPriceMinLot = lt;
                        SelPriceMinTic = tk;
                        SellPriceMinSL = sl;
                       }
                    }
                    
                    
              if(tick.ask  > OPlast+ d ||  tick.ask  < OPlast - NormalizeDouble(d - ( procdeltabay *_Point),_Digits))   buycheck = true;
              if(tick.bid  > OPlast+ d ||  tick.bid  < OPlast - NormalizeDouble(d + (procdeltasell*_Point),_Digits))   Sellcheck = true;
              
             // if(tick.ask  > op ||  tick.ask  < OPlast - NormalizeDouble(d - (10*_Point),_Digits))   buycheck = true;
             // if(tick.bid  > OPlast+ d ||  tick.bid  < OPlast - NormalizeDouble (d+ (10*_Point),_Digits))   Sellcheck = true;       
          }
 
 /*
 for(int  i=total-1;  i>=0;  i--)
  
   {
      ulong ticket = OrderGetTicket(i);
      if(!OrderSelect(ticket))continue;
      ulong magic = OrderGetInteger(ORDER_MAGIC);
      double price = OrderGetDouble(ORDER_PRICE_OPEN); 
      double slO =OrderGetDouble(ORDER_SL);
   // if(iMagicNumber != ExpertMagic())continue;
      string symbol = OrderGetString(ORDER_SYMBOL);
      if(m_position.Symbol() != Symbol())continue;
      
      ENUM_ORDER_TYPE order_type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      
      if(order_type == ORDER_TYPE_BUY_STOP)
      {
      
        Stopbs++;
       if( ss == 0) DeleteAllPendingOrdersBUY();
       if(slO == 0)
         if(! trade.OrderModify(ticket,price ,SelPriceMin, 0, 0, 0))
           Print("OrderModify Stop Buy error #",GetLastError());
       
      }
       if(order_type == ORDER_TYPE_SELL_STOP)
      {
        Stopss++;
       if( bs == 0 ) DeleteAllPendingOrdersSELL();
        if(slO == 0 ) 
          if(! trade.OrderModify(ticket,price ,BuyPriceMin, 0, 0, 0))
           Print("OrderModify Stop Sell error #",GetLastError());
      } 
      
    }   
    */
 
//*************************************************************//
//           Закрытие  ордеров по тралу по атр
//*************************************************************//     
if ( COMENT)
{
      StringConcatenate(txt,"Profit TOTAL ",DoubleToString(TPP  ,2));
   DrawLABEL(2,"Profit SELLccc",txt,5,85,Lime,ANCHOR_RIGHT);
   
   StringConcatenate(txt,"TLB ",DoubleToString(TPB  ,3));
   DrawLABEL(2,"TLB",txt,5,100,Lime,ANCHOR_RIGHT);
  StringConcatenate(txt," TLS ",DoubleToString( TPS ,3));
 DrawLABEL(2," TLS",txt,5,115,Lime,ANCHOR_RIGHT);
    StringConcatenate(txt,"Profit TOTAL ",DoubleToString(TPP  ,2));
   DrawLABEL(2,"Profit SELLccc",txt,5,85,Lime,ANCHOR_RIGHT);
 }
       
//*************************************************************//
//           Закрытие  ордеров по тралу по атр
//*************************************************************//     

   
long OT;
   int n=0;
   double OOP=0;
   
   StringConcatenate(txt,"Balance ",DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2));
   DrawLABEL(2,"cm Balance",txt,5,20,Lime,ANCHOR_RIGHT);
   StringConcatenate(txt,"Equity ",DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2));
   DrawLABEL(2,"cm Equity",txt,5,35,Lime,ANCHOR_RIGHT);
//----
   if(!VirtualTrailingStop) STOPLEVEL=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
  // double sl,SL;
   Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   int i;
   double PB=0,PS=0,OL=0,NLb=0,NLs=0,LS=0,LB=0;
//----
   for(i=0; i<PositionsTotal(); i++)
     {
     
      if(_Symbol==PositionGetSymbol(i))
        {
       //  Print("111111111111111111111111111111111"); 
       //  if(iMagicNumber==OrderGetInteger(ORDER_MAGIC) ||iMagicNumber==-1)
        //   {
            
           
            OL  = PositionGetDouble(POSITION_VOLUME);
            OOP = PositionGetDouble(POSITION_PRICE_OPEN);
            OT  = PositionGetInteger(POSITION_TYPE);
            if(OT==POSITION_TYPE_BUY ) {PB += OOP*OL; LB+=OL; b++;}
            if(OT==POSITION_TYPE_SELL) {PS += OOP*OL; LS+=OL; s++;}
        //   }
        }
     }
//----
   if(LB!=0)
     {
      NLb=PB/LB;
      ARROW("cm_NL_Buy",NLb,clrAqua);
     }
   if(LS!=0)
     {
      NLs=PS/LS;
      ARROW("cm_NL_Sell",NLs,clrRed);
     }
//----
   request.symbol=_Symbol;
   for(i=0; i<PositionsTotal(); i++)
     {
      if(_Symbol==PositionGetSymbol(i))
        {
       //  if(iMagicNumber==OrderGetInteger(ORDER_MAGIC) || iMagicNumber ==-1)
      //     {
            OL  = PositionGetDouble(POSITION_VOLUME);
            OOP = PositionGetDouble(POSITION_PRICE_OPEN);
            OT  = PositionGetInteger(POSITION_TYPE);
            sl=PositionGetDouble(POSITION_SL);
            if(OT==POSITION_TYPE_BUY &&  ss==0 && 1==0 )
            
              { 
              
               if(VirtualTrailingStop)
                 {
                 
                  SL=SlLastBar(POSITION_TYPE_BUY,Bid,NLb);
                  if(SL!=-1 && NLb+StartTrall*_Point<SL && SLB<SL) SLB=SL;
                  if(SLB!=0)
                    {
                     HLINE("cm_slb",SLB,clrAqua);
                     if(Bid<=SLB)
                       {
                        request.deviation=slippage;
                        request.volume=PositionGetDouble(POSITION_VOLUME);
                        request.position=PositionGetInteger(POSITION_TICKET);
                        request.action=TRADE_ACTION_DEAL;
                        request.type_filling=ORDER_FILLING_FOK;
                        request.type=ORDER_TYPE_SELL;
                        request.price=Bid;
                        request.comment="";
                        if(!OrderSend(request,result)) Print("error ",GetLastError());
                       }
                    }
                  }
               else
                 {
                // Print("222222222222222222"); 
                  SL=SlLastBar(POSITION_TYPE_BUY,Bid,OOP);
                  if(SL!=-1 && sl+StepTrall*_Point<SL && SL>=OOP+StartTrall*_Point)
                    {
                     request.action    = TRADE_ACTION_SLTP;
                     request.position  = PositionGetInteger(POSITION_TICKET);
                     request.sl        = SL;
                     request.tp        = PositionGetDouble(POSITION_TP);
                     if(!OrderSend(request,result)) Print("error ",GetLastError());
                    }
                 }
              }
            if(OT==POSITION_TYPE_SELL&& bs==0&& 1==0)
              {
               if(VirtualTrailingStop)
                 {
                  SL=SlLastBar(POSITION_TYPE_SELL,Ask,NLs);
                  if(SL!=-1 && (SLS==0 || SLS>SL) && SL<=NLs-StartTrall*_Point) SLS=SL;
                  if(SLS!=0)
                    {
                     HLINE("cm_sls",SLS,clrRed);
                     if(Ask>=SLS)
                       {
                        request.volume=PositionGetDouble(POSITION_VOLUME);
                        request.position=PositionGetInteger(POSITION_TICKET);
                        request.action=TRADE_ACTION_DEAL;
                        request.type_filling=ORDER_FILLING_FOK;
                        request.type=ORDER_TYPE_BUY;
                        request.price=Ask;
                        request.comment="";
                        if(!OrderSend(request,result)) Print("error ",GetLastError());
                       }
                    }
                 }
               else
                 {
                  SL=SlLastBar(POSITION_TYPE_SELL,Ask,OOP);
                  if(SL!=-1 && (sl==0 || sl-StepTrall*_Point>SL) && SL<=OOP-StartTrall*_Point)
                    {
                     request.action    = TRADE_ACTION_SLTP;
                     request.position  = PositionGetInteger(POSITION_TICKET);
                     request.sl        = SL;
                     request.tp        = PositionGetDouble(POSITION_TP);
                     if(OrderCheck(request,check)) if(!OrderSend(request,result)) Print("error ",GetLastError());
                     else Print("error ",GetLastError());
                    }
                 }
              }
           }
       // }
     }

   if(b==0)
     {
      SLB=0;
      ObjectDelete(0,"cm SLb");
      ObjectDelete(0,"cm_SLb");
      ObjectDelete(0,"cm_slb");
     }
   if(s==0)
     {
      SLS=0;
      ObjectDelete(0,"cm SLs");
      ObjectDelete(0,"cm_SLs");
      ObjectDelete(0,"cm_sls");
     }
/*
   
    if (Equity -1 >Balance)    
        {
        DeleteAllPendingOrdersSELL();
        DeleteAllPendingOrdersBUY();
        
        if ( (BuyPriceMax + BuyPriceMin) /2 > tick.ask ) CloseAllSell();
        if ( (SelPriceMin + SelPriceMax ) /2  <  tick.bid) CloseAllBuy();
        
         }
 */
 //если все ордера закрылись по стоплосу то противоположные закрываються 
    
    /*
    if (Equity  < Balance)    
        {
       
        if ( ss > 1 && bs==0 ) CloseAllSell();
        if (ss ==0 && bs> 1 ) CloseAllBuy();
        
         }
 
 */
 
 
 
 
 
 
 
 
 
 
//*************************************************************//
double BuyLot=0,SelLot=0,Lot=0 ;
BuyLot=iStartLots ;
SelLot=iStartLots ;

//*************************************************************//
//  BuyStop SellLimit сверху
//*************************************************************//
sSignal signal=Buy_or_Sell();


//*****************************ВЫСТАВЛЕНИЕ ОТЛОЖЕННЫХ ВВЕРХ********************************//    
  
  if(bs == 0 && ss==0  &&  Equity==Balance  && signal.Buy  )
  {
  if(!trade.Buy (NormalizeDouble(iStartLots ,2 )))
                  Print("OrderSend error 1# Buy",GetLastError());   
  }
    
                            if (buycheck)
                             {
                              if(!trade.Buy (NormalizeDouble(iStartLots ,2 )))
                               Print("OrderSend error 2   # Buy",GetLastError());   
                             }
                
                
                            if ( Sellcheck )          
                             {
                              if(!trade.Sell (NormalizeDouble(iStartLots ,2 )))
                               Print("OrderSend error 2   # Buy",GetLastError());   
                             }       
            
 

//*************************************************************/  
 if (isNewBar() && Equity -10 >Balance && ss>0 && bs>0 )    
        {
        
      
           
            
            
        if (Equity > Balance +(Balance*iStartLots)
        // TOTAL_PROFIT_OF_OPEN_POSITIONS_SELL()+10 < TOTAL_PROFIT_OF_OPEN_POSITIONS_BUY()
         )
             
              { 
               for(int i = PositionsTotal() - 1; i >= 0; i--) 
                {
                   if(m_position.SelectByIndex(i)   )  // select a position
                     if(m_position.Symbol()==Symbol())
                        // if(m_position.Magic()==iMagicNumber)
                           if(m_position.PositionType()==POSITION_TYPE_SELL)
                           {
                          trade.PositionClose(m_position.Ticket()); // then delete it --period
          //  Sleep(100); // Relax for 100 ms
           // ChartWrite("Positions", "Positions " + (string)PositionsTotal(), 100, 80, 20, PositionsColor); //Re write number of positions on the chart
                            }
           
              Print("CLOSE ALL SELL"); 
                } 
        }
      if (Equity > Balance +(Balance*iStartLots)
        // TOTAL_PROFIT_OF_OPEN_POSITIONS_SELL() >  TOTAL_PROFIT_OF_OPEN_POSITIONS_BUY() +10
        )
              { 
               for(int i = PositionsTotal() - 1; i >= 0; i--) 
                {
                   if(m_position.SelectByIndex(i)   )  // select a position
                     if(m_position.Symbol()==Symbol())
                        // if(m_position.Magic()==iMagicNumber)
                           if(m_position.PositionType()==POSITION_TYPE_BUY)
                           {
                          trade.PositionClose(m_position.Ticket()); // then delete it --period
          //  Sleep(100); // Relax for 100 ms
           // ChartWrite("Positions", "Positions " + (string)PositionsTotal(), 100, 80, 20, PositionsColor); //Re write number of positions on the chart
                            }
                         Print("CLOSE ALL BUY"); 
                 }
              } 
         } 

     
  }
     
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
void OnDeinit(const int reason)
  {
 

ObjectsDeleteAll (0, -1, -1);


 ObjectsDeleteAll(0,"cm");
   Comment("");
   if(parameters_trailing==3) IndicatorRelease(atrHandle);
   if(parameters_trailing==4) IndicatorRelease(sarHandle);
   if(parameters_trailing==5) IndicatorRelease(maHandle);
   IndicatorRelease(MACD);
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
bool CheckVolumeValue(double volume)
  {
//--- минимально допустимый объем для торговых операций
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
      return(false);

//--- максимально допустимый объем для торговых операций
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
      return(false);

//--- получим минимальную градацию объема
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
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
    
    
    double SlLastBar(int tip,double price,double OOP)
  {
   double prc=0;
   int i;
   string txt;
   switch(parameters_trailing)
     {
      case 1: // по экстремумам свечей
         if(tip==POSITION_TYPE_BUY)
           {
            for(i=1; i<500; i++)
              {
               prc=NormalizeDouble(iLow(Symbol(),TF_Tralling,i)-delta*_Point,_Digits);
               if(prc!=0) if(price-STOPLEVEL*_Point>prc) break;
               else prc=0;
              }
            StringConcatenate(txt,"SL Buy candle ",DoubleToString(prc,_Digits));
           }
         if(tip==POSITION_TYPE_SELL)
           {
            for(i=1; i<500; i++)
              {
               prc=NormalizeDouble(iHigh(Symbol(),TF_Tralling,i)+delta*_Point,_Digits);
               if(prc!=0) if(price+STOPLEVEL*_Point<prc) break;
               else prc=0;
              }
            StringConcatenate(txt,"SL Sell candle ",DoubleToString(prc,_Digits));
           }
         break;

      case 2: // по фракталам
         if(tip==POSITION_TYPE_BUY)
           {
            for(i=2; i<100; i++)
              {
               if(iLow(Symbol(),TF_Tralling,i)<iLow(Symbol(),TF_Tralling,i+1) && 
                  iLow(Symbol(),TF_Tralling,i)<iLow(Symbol(),TF_Tralling,i-1) && 
                  iLow(Symbol(),TF_Tralling,i)<iLow(Symbol(),TF_Tralling,i+2))
                 {
                  prc=iLow(Symbol(),TF_Tralling,i);
                  if(prc!=0)
                    {
                     prc=NormalizeDouble(prc-delta*_Point,_Digits);
                     if(price-STOPLEVEL*_Point>prc) break;
                    }
                  else prc=0;
                 }
              }
            StringConcatenate(txt,"SL Buy Fractals ",DoubleToString(prc,_Digits));
           }
         if(tip==POSITION_TYPE_SELL)
           {
            for(i=2; i<100; i++)
              {
               if(iHigh(Symbol(),TF_Tralling,i)>iHigh(Symbol(),TF_Tralling,i+1) && 
                  iHigh(Symbol(),TF_Tralling,i)>iHigh(Symbol(),TF_Tralling,i-1) && 
                  iHigh(Symbol(),TF_Tralling,i)>iHigh(Symbol(),TF_Tralling,i+2))
                 {
                  prc=_iHigh(Symbol(),TF_Tralling,i);
                  if(prc!=0)
                    {
                     prc=NormalizeDouble(prc+delta*_Point,_Digits);
                     if(price+STOPLEVEL*_Point<prc) break;
                    }
                  else prc=0;
                 }
              }
            StringConcatenate(txt,"SL Sell Fractals ",DoubleToString(prc,_Digits));
           }
         break;
      case 3: // по индикатору ATR
         ArraySetAsSeries(atrVal,true);
         if(CopyBuffer(atrHandle,0,0,3,atrVal)<0)
           {
            StringConcatenate(txt,"Ошибка ATR :",GetLastError());
            prc=-1;
            break;
           }
         prc=atrVal[1];
         if(tip==POSITION_TYPE_BUY)
           {
            prc=NormalizeDouble(Bid-prc-delta*_Point,_Digits);
            StringConcatenate(txt,"SL Buy ATR ",DoubleToString(prc,_Digits));
           }
         if(tip==POSITION_TYPE_SELL)
           {
            prc=NormalizeDouble(Ask+prc+delta*_Point,_Digits);
            StringConcatenate(txt,"SL Buy ATR ",DoubleToString(prc,_Digits));
           }
         break;

      case 4: // по индикатору Parabolic
         ArraySetAsSeries(sarVal,true);
         if(CopyBuffer(sarHandle,0,0,3,sarVal)<0)
           {
            StringConcatenate(txt,"Ошибка Parabolic SAR :",GetLastError());
            prc=-1;
            break;
           }
         prc=sarVal[1];
         if(tip==POSITION_TYPE_BUY)
           {
            prc=NormalizeDouble(prc-delta*_Point,_Digits);
            if(price-STOPLEVEL*_Point<prc) prc=0;
            StringConcatenate(txt,"SL Buy Parabolic ",DoubleToString(prc,_Digits));
           }
         if(tip==POSITION_TYPE_SELL)
           {
            prc=NormalizeDouble(prc+delta*_Point,_Digits);
            if(price+STOPLEVEL*_Point>prc) prc=0;
            StringConcatenate(txt,"SL Buy Parabolic ",DoubleToString(prc,_Digits));
           }
         break;

      case 5: // по индикатору МА
         ArraySetAsSeries(maVal,true);
         if(CopyBuffer(maHandle,0,0,3,maVal)<0)
           {
            StringConcatenate(txt,"Ошибка Moving Average :",GetLastError());
            prc=-1;
            break;
           }
         prc=maVal[1];
         if(tip==POSITION_TYPE_BUY)
           {
            prc=NormalizeDouble(prc-delta*_Point,_Digits);
            if(price-STOPLEVEL*_Point<prc) prc=0;
            StringConcatenate(txt,"SL Buy MA ",DoubleToString(prc,_Digits));
           }
         if(tip==POSITION_TYPE_SELL)
           {
            prc=NormalizeDouble(prc+delta*_Point,_Digits);
            if(price+STOPLEVEL*_Point>prc) prc=0;
            StringConcatenate(txt,"SL Sell MA ",DoubleToString(prc,_Digits));
           }
         break;
      case 6: // % от профита
         if(tip==POSITION_TYPE_BUY)
           {
            prc=NormalizeDouble(OOP+(price-OOP)/100*PercetnProfit,_Digits);
            StringConcatenate(txt,"SL Buy % ",DoubleToString(prc,_Digits));
           }
         if(tip==POSITION_TYPE_SELL)
           {
            prc=NormalizeDouble(OOP-(OOP-price)/100*PercetnProfit,_Digits);
            StringConcatenate(txt,"SL Sell % ",DoubleToString(prc,_Digits));
           }
         break;
      default: // по пунктам
         if(tip==POSITION_TYPE_BUY)
           {
            prc=NormalizeDouble(price-delta*_Point,_Digits);
            StringConcatenate(txt,"SL Buy pips ",DoubleToString(prc,_Digits));
           }
         if(tip==POSITION_TYPE_SELL)
           {
            prc=NormalizeDouble(price+delta*_Point,_Digits);
            StringConcatenate(txt,"SL Sell pips ",DoubleToString(prc,_Digits));
           }
         break;
     }
   if(tip==POSITION_TYPE_BUY)
     {
      ARROW("cm_SLb",prc,clrGray);
      DrawLABEL(3,"cm SLb",txt,5,50,Color(prc>OOP,clrGreen,clrGray),ANCHOR_RIGHT);
     }
   if(tip==POSITION_TYPE_SELL)
     {
      ARROW("cm_SLs",prc,clrGray);
      DrawLABEL(3,"cm SLs",txt,5,70,Color(prc<OOP,clrRed,clrGray),ANCHOR_RIGHT);
     }
   return(prc);
  }
//--------------------------------------------------------------------
string StrPer(int per)
  {
   if(per==PERIOD_CURRENT) per=Period();
   if(per > 0 && per < 31) return("M"+IntegerToString(per));
   if(per == PERIOD_H1) return("H1");
   if(per == PERIOD_H2) return("H2");
   if(per == PERIOD_H3) return("M3");
   if(per == PERIOD_H4) return("M4");
   if(per == PERIOD_H6) return("M6");
   if(per == PERIOD_H8) return("M8");
   if(per == PERIOD_H12) return("M12");
   if(per == PERIOD_D1) return("D1");
   if(per == PERIOD_W1) return("W1");
   if(per == PERIOD_MN1) return("MN1");
   return("ошибка периода");
  }
//+------------------------------------------------------------------+
void HLINE(string Name,double Price,color c)
  {
   ObjectDelete(0,Name);
   ObjectCreate(0,Name,OBJ_HLINE,0,0,Price,0,0,0,0);
   ObjectSetInteger(0,Name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,Name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,Name,OBJPROP_COLOR,c);
   ObjectSetInteger(0,Name,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,Name,OBJPROP_WIDTH,1);
  }
//+------------------------------------------------------------------+
void ARROW(string Name,double Price,color c)
  {
   if(!DrawArrow) return;
   ObjectDelete(0,Name);
   ObjectCreate(0,Name,OBJ_ARROW_RIGHT_PRICE,0,TimeCurrent(),Price,0,0,0,0);
   ObjectSetInteger(0,Name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,Name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,Name,OBJPROP_COLOR,c);
   ObjectSetInteger(0,Name,OBJPROP_WIDTH,1);
  }
//--------------------------------------------------------------------
void DrawLABEL(int c,string name,string text,int X,int Y,color clr,int ANCHOR=ANCHOR_LEFT,int FONTSIZE=8)
  {
   if(ObjectFind(0,name)==-1)
     {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,c);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,X);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,Y);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,FONTSIZE);
      ObjectSetString(0,name,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,ANCHOR);
     }
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
  }
//--------------------------------------------------------------------
color Color(bool P,color c1,color c2)
  {
   if(P) return(c1);
   return(c2);
  }

//--------------------------------------------------------------------
double _iLow(string symbol,ENUM_TIMEFRAMES tf,int index)
  {
   if(index < 0) return(-1);
   double Arr[];
   if(CopyLow(symbol,tf, index, 1, Arr)>0) return(Arr[0]);
   else return(-1);
  }
//--------------------------------------------------------------------
double _iHigh(string symbol,ENUM_TIMEFRAMES tf,int index)
  {
   if(index < 0) return(-1);
   double Arr[];
   if(CopyHigh(symbol,tf, index, 1, Arr)>0) return(Arr[0]);
   else return(-1);
  }


void CloseAllPosition()
{
for(int i =PositionsTotal()-1; i>=0; i--)
           {
           ulong ticket =  PositionGetTicket(i);
           trade.PositionClose(ticket,30);
           }
 }     
 

 

 
 
 
 
 
 
 void CloseAllPositions()
{ 
double TBP = TOTAL_PROFIT_OF_OPEN_POSITIONS_BUY() ;
double TSP = TOTAL_PROFIT_OF_OPEN_POSITIONS_SELL() ;
double op=NormalizeDouble(m_position.PriceOpen(),Digits());
MqlTick tick;
   if(!SymbolInfoTick(Symbol(),tick))
      Print("SymbolInfoTick() failed, error close all = ",GetLastError());
      
for(int i =PositionsTotal()-1; i>=0; i--)
           {
             
                if(  m_position.PositionType()==POSITION_TYPE_BUY) 
                {
                 if( op > tick.bid)
                  {
                 ulong ticket =  PositionGetTicket(i);
                 trade.PositionClose(ticket,30);
                  }
                }
                
                if(m_position.PositionType()==POSITION_TYPE_SELL) 
                { if( op < tick.ask)
                  {
                  ulong ticket =  PositionGetTicket(i);
                 trade.PositionClose(ticket,30);
                 } 
                } 
                
          }           
 }
 
  
 void CloseAllPositionsSell()
{ 
for(int i = PositionsTotal()-1; i>=0; i--)
           {
             
                if(m_position.PositionType()==POSITION_TYPE_SELL) 
                {
                  ulong ticket =  PositionGetTicket(i);
                 trade.PositionClose(ticket,30);
                }
           }           
 }     
 
 void CloseAllPositionsBuy()
{ 
for(int i =PositionsTotal()-1; i>=0; i--)
           {
             
                if(m_position.PositionType()==POSITION_TYPE_BUY) 
                {
                  ulong ticket =  PositionGetTicket(i);
                 trade.PositionClose(ticket,30);
                }
           }           
 } 
 
//+------------------------------------------------------------------+
//| TOTAL_PROFIT_OF_OPEN_POSITIONS                                   |
//+------------------------------------------------------------------+

double TOTAL_PROFIT_OF_OPEN_POSITIONS_BUY()
  {
   double Total_Profit=0;
   double deal_commission=0;
   double deal_fee=0;
   double deal_profit=0;
   ulong    tk=0;
   int total=PositionsTotal();
   for(int i=0; i<total; i++)
     {
      ulong  position_ticket=PositionGetTicket(i);                                      // ticket of the position
      ulong  magic=PositionGetInteger(POSITION_MAGIC);                                  // MagicNumber of the position
      string comment=PositionGetString(POSITION_COMMENT);                               // position comment
      long   position_ID=PositionGetInteger(POSITION_IDENTIFIER);                         // Identifier of the position
      tk=m_position.Ticket();
    //  if(magic==EXPERT_MAGIC || comment==IntegerToString(EXPERT_MAGIC))
     if(m_position.PositionType()==POSITION_TYPE_BUY) 
        {
       //  HistorySelect(0,TimeCurrent());
    //     int deals=HistoryOrdersTotal();
         for(int j=OrdersTotal()-1; j>=0; j--)
           {
          //  ulong deal_ticket=HistoryDealGetTicket(j);
            if(HistoryDealGetInteger(tk,DEAL_POSITION_ID) == position_ID)
              {
               deal_profit=HistoryDealGetDouble(tk, DEAL_PROFIT);
               deal_commission=HistoryDealGetDouble(tk, DEAL_COMMISSION)*2;
               deal_fee=HistoryDealGetDouble(tk, DEAL_FEE);
               break;
              }
           }
         Total_Profit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP) + deal_profit + deal_commission + deal_fee;
        }
     }
   return(Total_Profit);
  }
//+------------------------------------------------------------------+
//| TOTAL_PROFIT_OF_OPEN_POSITIONS                                   |
//+------------------------------------------------------------------+
double TOTAL_PROFIT_OF_OPEN_POSITIONS_SELL()
   {
   double Total_Profit=0;
   double deal_commission=0;
   double deal_fee=0;
   double deal_profit=0;
   ulong    tk=0;
   int total=PositionsTotal();
   for(int i=0; i<total; i++)
     {
      ulong  position_ticket=PositionGetTicket(i);                                      // ticket of the position
      ulong  magic=PositionGetInteger(POSITION_MAGIC);                                  // MagicNumber of the position
      string comment=PositionGetString(POSITION_COMMENT);                               // position comment
      long   position_ID=PositionGetInteger(POSITION_IDENTIFIER);                         // Identifier of the position
      tk=m_position.Ticket();
    //  if(magic==EXPERT_MAGIC || comment==IntegerToString(EXPERT_MAGIC))
     if(m_position.PositionType()==POSITION_TYPE_SELL) 
        {
       //  HistorySelect(0,TimeCurrent());
    //     int deals=HistoryOrdersTotal();
         for(int j=total-1; j>=0; j--)
           {
          //  ulong deal_ticket=HistoryDealGetTicket(j);
            if(HistoryDealGetInteger(tk,DEAL_POSITION_ID) == position_ID)
              {
               deal_profit=HistoryDealGetDouble(tk, DEAL_PROFIT);
               deal_commission=HistoryDealGetDouble(tk, DEAL_COMMISSION)*2;
               deal_fee=HistoryDealGetDouble(tk, DEAL_FEE);
               break;
              }
           }
         Total_Profit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP) + deal_profit + deal_commission + deal_fee;
        }
     }
   return(Total_Profit);
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/

//+------------------------------------------------------------------+
                                                                 
double TOTAL_PROFIT_OF_OPEN_POSITIONS()

   {
   double Total_Profit=0;
   double deal_commission=0;
   double deal_fee=0;
   double deal_profit=0;
   ulong    tk=0;
   int total=PositionsTotal();
   for(int i=0; i<total; i++)
     {
      ulong  position_ticket=PositionGetTicket(i);                                      // ticket of the position
      ulong  magic=PositionGetInteger(POSITION_MAGIC);                                  // MagicNumber of the position
      string comment=PositionGetString(POSITION_COMMENT);                               // position comment
      long   position_ID=PositionGetInteger(POSITION_IDENTIFIER);                         // Identifier of the position
      tk=m_position.Ticket();
    //  if(magic==EXPERT_MAGIC || comment==IntegerToString(EXPERT_MAGIC))
     if(m_position.PositionType()==POSITION_TYPE_SELL|| m_position.PositionType()==POSITION_TYPE_BUY ) 
        {
       //  HistorySelect(0,TimeCurrent());
    //     int deals=HistoryOrdersTotal();
         for(int j=total-1; j>=0; j--)
           {
          //  ulong deal_ticket=HistoryDealGetTicket(j);
            if(HistoryDealGetInteger(tk,DEAL_POSITION_ID) == position_ID)
              {
               deal_profit=HistoryDealGetDouble(tk, DEAL_PROFIT);
               deal_commission=HistoryDealGetDouble(tk, DEAL_COMMISSION)*2;
               deal_fee=HistoryDealGetDouble(tk, DEAL_FEE);
               break;
              }
           }
         Total_Profit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP) + deal_profit + deal_commission + deal_fee;
        }
     }
   return(Total_Profit);
  }

//+------------------------------------------------------------------+
//| Удаляет все отложенные ордера BUY                                   |
//+------------------------------------------------------------------+
void DeleteAllPendingOrdersBUY()
  {
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(!OrderSelect(ticket))continue;
      ulong magic = OrderGetInteger(ORDER_MAGIC);
     // if(iMagicNumber != ExpertMagic())continue;
      string symbol = OrderGetString(ORDER_SYMBOL);
      if(m_position.Symbol() != Symbol())continue;
      ENUM_ORDER_TYPE order_type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      
      if(order_type == ORDER_TYPE_BUY_STOP || order_type == ORDER_TYPE_BUY_LIMIT )
      {
        trade.OrderDelete(ticket);
      }

    }   
   }  
//+------------------------------------------------------------------+
//| Удаляет все отложенные ордера  SELL                                  |
//+------------------------------------------------------------------+
void DeleteAllPendingOrdersSELL()
  {
   for(int i = OrdersTotal()-1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(!OrderSelect(ticket))continue;
      ulong magic = OrderGetInteger(ORDER_MAGIC);
     // if(iMagicNumber != ExpertMagic())continue;
      string symbol = OrderGetString(ORDER_SYMBOL);
      if(m_position.Symbol() != Symbol())continue;
      ENUM_ORDER_TYPE order_type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      
      if(order_type == ORDER_TYPE_SELL_STOP|| order_type == ORDER_TYPE_SELL_LIMIT )
      {
        trade.OrderDelete(ticket);
      }

    }   
   } 
   
   void CloseAllBuy()
  {
   for(int i=PositionsTotal()-1; i>=0; i--) // returns the number of current positions
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
     // if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
     //    if(m_position.Symbol()==m_symbol.Name()// && m_position.Magic()==Magic
     //    )
   ///      Print(11111111111111111111111);
            trade.PositionClose(m_position.Symbol()); // close a position by the specified m_symbol
  }
  
   void CloseAllSell()
  {
   for(int i=PositionsTotal()-1; i>=0; i--) // returns the number of current positions
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
    //  if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
   //      if(m_position.Symbol()==m_symbol.Name()// && m_position.Magic()==Magic
    //     )  
         
        // Print(11111111111111111111111);
          if(!trade.PositionClose(m_position.Symbol()))
          Print("OrderClose Sell error #",GetLastError());  // close a position by the specified m_symbol
  }
//+------------------------------------------------------------------+
