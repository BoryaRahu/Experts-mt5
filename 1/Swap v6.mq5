
   

#include <Trade\Trade.mqh> CTrade trade;
#include <Trade\PositionInfo.mqh> CPositionInfo     m_position;
#include <Trade\OrderInfo.mqh> COrderInfo     m_order;
#include <StdLibErr.mqh>
   
   //INPUTS
   input ulong iMagicNumber = 60;
   input double        KoefLots          = 1;     // Множитель Start lot min=1
   input string   TradeSymbols         = "AUDCAD|AUDJPY|AUDNZD|AUDUSD|EURUSD";   //Symbol(s) or ALL or CURRENT
   input int      RSIPeriods        = 20;       //RSIPeriods
   input ENUM_TIMEFRAMES      period = PERIOD_CURRENT; 
   input bool filerTime  = true;
   input bool filerRSI  = false;
   input uchar    Hhour=22; 

    string   AllSymbolsString1  =  "US500|BRENT|XTIUSD|COPPER|WIG20|AFRICA40|ITALY40|#EURBUND|#EURBOBL|#EURBUXL|#EURSCHA|JP225|XAGUSD|XAUUSD";
    // нет торгов |#EURBUND|#EURBOBL|#EURBUXL|#EURSCHA|JP225
    // лот 1  |WIG20|AFRICA40|ITALY40|#EURBUND|#EURBOBL|#EURBUXL|#EURSCHA|JP225|COPPER|BRENT|XTIUSD|
   //SMALL_S2Y|US30|USTEC|КДОРРЕЛЯЦИЯ ГЫ500    |FRANCE40 CORRELECIA ITALIA 
   //SPAIN35||UK100|CHINA50
   // маленькая прибыл    |AUS200 |DE40|HK50|NAT.GAS|STOXX50|SWISS20
   
   
  string   AllSymbolsString           = "AUDCHF|AUDCAD|AUDJPY|AUDNZD|AUDUSD|CADJPY|EURAUD|EURCAD|EURGBP|EURJPY|EURNZD|EURUSD|GBPAUD|GBPCAD|GBPJPY|GBPNZD|GBPUSD|NZDCAD|NZDJPY|NZDUSD|USDCAD|USDCHF|USDJPY";
  /*usdjpy


EURNOK
EURSEK
EURPLN
EURSGD
EURTRY
EURZAR
GBPAUD
AUDUSD
GBPCAD
XAUUSD
GBPCHF
GBPCZK
GBPDKK
GBPHKD
GBPHUF
GBPJPY
GBPNOK
GBPNZD
GBPPLN
GBPSEK
GBPTRY
GBPZAR
NZDCAR
NZDCHF
NZDJPY
NZDSGD
USDCNH
USDCZK
USDDKK
USDHKD
USDHUF
USDMXN
USDNOK
USDPLN
USDRUB
USDSEK
USDSGD
USDTRY
USDZAR
XAGUSD
GBPUSD
*/

   struct NextOpen
  {
   string            Symbols;  // симбол сделки
   double            Volume;  // обьем сделки
   string            TradeDirectionS;  // направление
  };
   int    count=0;
  NextOpen arr[];
  int    size=200;
   int      NumberOfTradeableSymbols;              
   string   SymbolArray[];                        
   int      TicksReceivedCount         = 0;     

COrderInfo        m_Order;   // entity for obtaining information on positions
CTrade            m_Trade;      // entity for execution of trades
CPositionInfo     m_Position;   // entity for obtaining information on positions

   //INDICATOR HANDLES
   int handle_rsi[];  
   //Place additional indicator handles here as required 
   
    double
   op=0,lt=0;

   ulong    tk=0;
   
    datetime   TIMElast=0;
     double OPlast = 0;
       double
       
   BuyPriceMax=0,BuyPriceMin=0,BuyPriceMaxLot=0,BuyPriceMinLot=0,
   SelPriceMin=0,SelPriceMax=0,SelPriceMinLot=0,SelPriceMaxLot=0 ,MaxLot=0
   , BuyPriceMaxSL=0 ,SellPriceMinSL=0, BuyPriceMinSL=0 ,SellPriceMaxSL=0 , LastSelPriceMax=0,LastBuyPriceMax=0   ;
   //OPEN TRADE ARRAYS
   ulong    OpenTradeOrderTicket[];    //To store 'order' ticket for trades
   //Place additional trade arrays here as required to assist with open trade management
   
   int OnInit()
   {
   
    ArrayResize(arr,size);
     string TradeSymbolsToUse1 = "";
      trade.SetExpertMagicNumber(iMagicNumber);
      
       string TradeSymbolsToUse = "";
       
      if(TradeSymbols == "INDEX")  //Override TradeSymbols input variable and use the current chart symbol only
      {
         TradeSymbolsToUse1 = AllSymbolsString1;
         
         
         //CONVERT TradeSymbolsToUse TO THE STRING ARRAY SymbolArray
         NumberOfTradeableSymbols = StringSplit(TradeSymbolsToUse1, '|', SymbolArray);
         
         Print("EA will process INDEX: ", TradeSymbolsToUse1);
        }
      else
      {  
        
         
         if(TradeSymbols == "ALL")
        
            TradeSymbolsToUse = AllSymbolsString;
         else
            TradeSymbolsToUse = TradeSymbols;
         
         //CONVERT TradeSymbolsToUse TO THE STRING ARRAY SymbolArray
         NumberOfTradeableSymbols = StringSplit(TradeSymbolsToUse, '|', SymbolArray);
         
         Print("EA will process: ", TradeSymbolsToUse);
      }
      
      //RESIZE OPEN TRADE ARRAYS (based on how many symbols are being traded)
      ResizeCoreArrays();
      
      //RESIZE INDICATOR HANDLE ARRAYS
      ResizeIndicatorHandleArrays();
      
      Print("All arrays sized to accomodate ", NumberOfTradeableSymbols, " symbols");
      
      //INITIALIZE ARAYS
      for(int SymbolLoop=0; SymbolLoop < NumberOfTradeableSymbols; SymbolLoop++)
         OpenTradeOrderTicket[SymbolLoop] = 0;
      
      //INSTANTIATE INDICATOR HANDLES
      if(!SetUpIndicatorHandles())
         return(INIT_FAILED); 
      
      return(INIT_SUCCEEDED);     
   }
   
   void OnDeinit(const int reason)
   {
      Comment("\n\rMulti-Symbol EA Stopped");
   }

   void OnTick()
   {
      TicksReceivedCount++;
      string indicatorMetrics = "";

   MqlDateTime str1;
  TimeToStruct(TimeTradeServer(),str1);
 // Print (str1.hour);
MqlDateTime curDay;
      TimeCurrent(curDay);
      MqlDateTime curDayFrom;
      datetime dfrom;
      datetime dto;
      
 
 
  
      //LOOP THROUGH EACH SYMBOL TO CHECK FOR ENTRIES AND EXITS, AND THEN OPEN/CLOSE TRADES AS APPROPRIATE
      for(int SymbolLoop = 0; SymbolLoop < NumberOfTradeableSymbols; SymbolLoop++)
      {
         string CurrentIndicatorValues; //passed by ref below
         string CurrentSymbol = SymbolArray[SymbolLoop];
         bool sessionData=SymbolInfoSessionTrade(CurrentSymbol, (ENUM_DAY_OF_WEEK) curDay.day_of_week, 0, dfrom, dto);   
      
      int size=PositionsTotal();
    
            ENUM_ORDER_TYPE order_type =WRONG_VALUE ;  
            for(int k=size-1; k>=0; k--)
              if(m_position.SelectByIndex(k))
               if(m_position.Symbol()==CurrentSymbol)
                if(m_position.Magic()==iMagicNumber)
                 if(m_position.PositionType()==POSITION_TYPE_BUY || m_position.PositionType()==POSITION_TYPE_SELL)
                 {                           
                 count++;
                  if(m_position.PositionType()==POSITION_TYPE_BUY) arr[count].TradeDirectionS="LONG";
                  if( m_position.PositionType()==POSITION_TYPE_SELL)arr[count].TradeDirectionS="SHORT";
                  arr[count].Volume=NormalizeDouble(m_position.Volume(),3);
                  arr[count].Symbols=CurrentSymbol;                 
                  tk=m_position.Ticket();   
                  Print("Posicii¡on add en array ",arr[count].Symbols," Volume = ",arr[count].Volume,"TradeDirection ",arr[count].TradeDirectionS);
                 }
       
       if ( IsSessionClose(CurrentSymbol)  && filerTime   )
            {                    
                   if(!trade.PositionClose(m_position.Ticket())); // close a position by the specified m_symbol
                       Print(CurrentSymbol+ arr[count].TradeDirectionS+ "TradeDirection #",GetLastError());  // close a position by the specified m_sym             
            }
   
    if ( IsSessionOpen(CurrentSymbol) && !IsSessionClose(CurrentSymbol) && str1.hour<Hhour 
           ) 
    
      { 
       /*      ///v5
         if(count>0)
         { 
         for(int i=count-1; i>=0; i--)
           {     
          ProcessTradeOpen(arr[count].Symbols, arr[count].TradeDirectionS);
          count--;
            }
          
          }   
      */  
         
         
        if(count==0)
         {  
           
         //GET OPEN SIGNAL (BOLLINGER BANDS SIMPLY USED AS AN EXAMPLE)
         string OpenSignalStatus = GetBBandsOpenSignalStatus(SymbolLoop, CurrentIndicatorValues);      
         StringConcatenate(indicatorMetrics, indicatorMetrics, SymbolArray[SymbolLoop], "  |  ", CurrentIndicatorValues, "  |  OPEN_STATUS=", OpenSignalStatus, "  |  ");
         
         //GET CLOSE SIGNAL (BOLLINGER BANDS SIMPLY USED AS AN EXAMPLE)
         string CloseSignalStatus = GetBBandsCloseSignalStatus(SymbolLoop);
         StringConcatenate(indicatorMetrics, indicatorMetrics, "CLOSE_STATUS=", CloseSignalStatus, "\n\r");
         
         string CloseSignalStatusSWAP =  GetSWAPSignalStatus(SymbolLoop);
         StringConcatenate(indicatorMetrics, indicatorMetrics, "CLOSE_STATUS SWAPS =", CloseSignalStatus, "\n\r");
   

     //    (int SymbolLoop, string CloseDirection)
         if(str1.hour <= 1 && str1.min > Hhour)
         //PROCESS TRADE OPENS
         if((OpenSignalStatus == "LONG" || OpenSignalStatus == "SHORT") && OpenTradeOrderTicket[SymbolLoop] == 0 && str1.hour<Hhour    )
            ProcessTradeOpen(SymbolLoop, OpenSignalStatus);
          
          
         //PROCESS TRADE CLOSURES
         else if( filerRSI &&   (CloseSignalStatus == "CLOSE_LONG" || CloseSignalStatus == "CLOSE_SHORT") //&& OpenTradeOrderTicket[SymbolLoop] != 0
         ) ProcessTradeClose(SymbolLoop, CloseSignalStatus) ;
            
         //PROCESS TRADE CLOSURES SWAP
       if((CloseSignalStatusSWAP == "CLOSE_LONG" || CloseSignalStatusSWAP == "CLOSE_SHORT") //&& OpenTradeOrderTicket[SymbolLoop] != 0
         ) ProcessTradeClose(SymbolLoop, CloseSignalStatusSWAP) ;   
         }   
            
        
            
            
        }    
      }

     
      //OUTPUT INFORMATION AND METRICS TO THE CHART (No point wasting time on this code if in the Strategy Tester)
      if(!MQLInfoInteger(MQL_TESTER))
         OutputStatusToChart(indicatorMetrics);  
         
         
         
          
   }
   
   
   
   
   bool LoadArrayFromFile(string FileName,double &Array[])
  {
//--- Открытие файла
   int h=FileOpen(FileName,FILE_BIN|FILE_READ);
   if(h==-1) return(false); // Ошибка открытия файла
//--- Чтение файла
   int Size=FileReadInteger(h,INT_VALUE); // Чтение количества элементов массива
   ArrayResize(Array,Size); // Изменение размера массива. 
                            // У одномерного массива размер первого измерения равен количеству элементов массива.
   FileReadArray(h,Array); // Чтение массива из файла
//--- Закрытие файла
   FileClose(h);
   return(true); // Чтение выполнено
  }
  
  
  
  
   
   void ResizeCoreArrays()
   {
      ArrayResize(OpenTradeOrderTicket, NumberOfTradeableSymbols);
      //Add other trade arrays here as required
   }
 
   void ResizeIndicatorHandleArrays()
   {
      //Indicator Handles
      ArrayResize(handle_rsi, NumberOfTradeableSymbols);
      //Add other indicators here as required by your EA
   }
   
   //SET UP REQUIRED INDICATOR HANDLES (arrays because of multi-symbol capability in EA)
   bool SetUpIndicatorHandles()
   {  
      //Bollinger Bands
      for(int SymbolLoop=0; SymbolLoop < NumberOfTradeableSymbols; SymbolLoop++)
      {
         //Reset any previous error codes so that only gets set if problem setting up indicator handle
         ResetLastError();
      
         handle_rsi[SymbolLoop] = iRSI(SymbolArray[SymbolLoop], period,RSIPeriods, PRICE_CLOSE);
         
         if(handle_rsi[SymbolLoop] == INVALID_HANDLE) 
         { 
            string outputMessage = "";
            
            if(GetLastError() == 4302)
               outputMessage = "Symbol needs to be added to the MarketWatch";
            else
               StringConcatenate(outputMessage, "(error code ", GetLastError(), ")");
  
            MessageBox("Failed to create handle of the iBands indicator for " + SymbolArray[SymbolLoop] + "/" + EnumToString(Period()) + "\n\r\n\r" + 
                        outputMessage +
                        "\n\r\n\rEA will now terminate.");
                         
            //Don't proceed
            return false;
         } 
         
         Print("Handle for iRSI / ", SymbolArray[SymbolLoop], " / ", EnumToString(Period()), " successfully created");
      }
      
      //All completed without errors so return true
      return true;
   }
   
   string GetBBandsOpenSignalStatus(int SymbolLoop, string& signalDiagnosticMetrics)
   {
      string CurrentSymbol = SymbolArray[SymbolLoop];
       int b=0,s=0;
      //Need to copy values from indicator buffers to local buffers
      int    numValuesNeeded = 3;
      double bufferUpper[];
     // double bufferLower[];
      
      bool fillSuccessUpper = tlamCopyBuffer(handle_rsi[SymbolLoop], MAIN_LINE, bufferUpper, numValuesNeeded, CurrentSymbol, "RSI");
   //   bool fillSuccessLower = tlamCopyBuffer(handle_rsi[SymbolLoop], LOWER_BAND, bufferLower, numValuesNeeded, CurrentSymbol, "RSI");
      
      if(fillSuccessUpper == false  )
         return("FILL_ERROR");     //No need to log error here. Already done from tlamCopyBuffer() function
      
      double CurrentBBandsUpper0 = bufferUpper[0];
      double CurrentBBandsUpper1 = bufferUpper[1];
      
      double CurrentClose = iClose(CurrentSymbol, Period(), 0);
      
      //Print(" CurrentBBandsUpper0 "+ DoubleToString (CurrentBBandsUpper0,2 )+ "CurrentBBandsUpper1"+  DoubleToString (CurrentBBandsUpper1,2 ) );
       
      //SET METRICS FOR BBANDS WHICH GET RETURNED TO CALLING FUNCTION BY REF FOR OUTPUT TO CHART
      StringConcatenate(signalDiagnosticMetrics, "UPPER=", DoubleToString(CurrentBBandsUpper0, (int)SymbolInfoInteger(CurrentSymbol, SYMBOL_DIGITS)), "  |  LOWER=", DoubleToString(CurrentBBandsUpper1, (int)SymbolInfoInteger(CurrentSymbol, SYMBOL_DIGITS)), "  |  CLOSE=" + DoubleToString(CurrentClose, (int)SymbolInfoInteger(CurrentSymbol, SYMBOL_DIGITS)));
    
      
       
       
       int total=PositionsTotal();
    
      ENUM_ORDER_TYPE order_type =WRONG_VALUE ;  
   for(int k=total-1; k>=0; k--)
      if(m_position.SelectByIndex(k))     
         if(m_position.Symbol()==CurrentSymbol)
            if(m_position.Magic()==iMagicNumber)
               if(m_position.PositionType()==POSITION_TYPE_BUY || m_position.PositionType()==POSITION_TYPE_SELL)
                 {
                  op=NormalizeDouble(m_position.PriceOpen(),Digits());
                  lt=NormalizeDouble(m_position.Volume(),3);
                  tk=m_position.Ticket();
                  if(m_position.PositionType()==POSITION_TYPE_BUY)
                    {
                     b++;
                     if(op>BuyPriceMax || BuyPriceMax==0)
                       {
                       
                        BuyPriceMax    = op;
                        BuyPriceMaxLot = lt;
                        
                       }
                     if(op<BuyPriceMin || BuyPriceMin==0)
                       {
                        BuyPriceMin    = op;
                        BuyPriceMinLot = lt;
                       }
                    }
                  // ===
                  if(m_position.PositionType()==POSITION_TYPE_SELL)
                    {
                     s++;                   
               
                     if(op>SelPriceMax || SelPriceMax==0)
                       {
                       
                        SelPriceMax    = op;
                        SelPriceMaxLot = lt;
                       }
                     if(op<SelPriceMin || SelPriceMin==0)
                       {
                        SelPriceMin    = op;
                        SelPriceMinLot = lt;
                       }
                    }
                    
        }
     // Print(DoubleToString(SymbolInfoDouble(CurrentSymbol,SYMBOL_SWAP_LONG),2));
      
      //INSERT YOUR OWN ENTRY LOGIC HERE
    //  e.g.
      if(s==0  &&  SymbolInfoDouble(CurrentSymbol,SYMBOL_SWAP_LONG)>0.0    && ((CurrentBBandsUpper1 > 70  && CurrentBBandsUpper0 < 70) || !filerRSI)     )
         return("SHORT");
      else if(b==0 && SymbolInfoDouble(CurrentSymbol,SYMBOL_SWAP_SHORT)>0.0 && ((CurrentBBandsUpper0 > 30  && CurrentBBandsUpper1 < 30) || !filerRSI )   )
         return("LONG");
      else
      
           return("NO_TRADE");
   }
   
   string GetBBandsCloseSignalStatus(int SymbolLoop)
   {
      string CurrentSymbol = SymbolArray[SymbolLoop];
      
      //Need to copy values from indicator buffers to local buffers
      int    numValuesNeeded = 3;
      double bufferUpper[];
      //double bufferLower[];
      
      bool fillSuccessUpper = tlamCopyBuffer(handle_rsi[SymbolLoop], MAIN_LINE, bufferUpper, numValuesNeeded, CurrentSymbol, "BBANDS");
     // bool fillSuccessLower = tlamCopyBuffer(handle_rsi[SymbolLoop], LOWER_BAND, bufferLower, numValuesNeeded, CurrentSymbol, "BBANDS");
      
      if(fillSuccessUpper == false  )
         return("FILL_ERROR");     //No need to log error here. Already done from tlamCopyBuffer() function
      
      double CurrentBBandsUpper0 = bufferUpper[0];
      double CurrentBBandsUpper1 = bufferUpper[1];
      
      double CurrentClose = iClose(CurrentSymbol, Period(), 0);
       
     
      //INSERT YOUR OWN ENTRY LOGIC HERE
    //  e.g.
   // Print (DoubleToString(CurrentBBandsUpper0,2)  +DoubleToString(CurrentBBandsUpper1,2) ) ;
      if(CurrentBBandsUpper1 < 30  && CurrentBBandsUpper0 > 30  ) 
         return("CLOSE_SHORT"); 
     else if(CurrentBBandsUpper0 < 70  && CurrentBBandsUpper1 > 70) 
        return("CLOSE_LONG");
      else
           return("NO_CLOSE_SIGNAL");
   }
   
   bool tlamCopyBuffer(int ind_handle,            // handle of the indicator 
                       int buffer_num,            // for indicators with multiple buffers
                       double &localArray[],      // local array 
                       int numBarsRequired,       // number of values to copy 
                       string symbolDescription,  
                       string indDesc)
   {
      
      int availableBars;
      bool success = false;
      int failureCount = 0;
      
      //Sometimes a delay in prices coming through can cause failure, so allow 3 attempts
      while(!success)
      {
         availableBars = BarsCalculated(ind_handle);
         
         if(availableBars < numBarsRequired)
         {
            failureCount++;
            
            if(failureCount >= 3)
            {
               Print("Failed to calculate sufficient bars in tlamCopyBuffer() after ", failureCount, " attempts (", symbolDescription, "/", indDesc, " - Required=", numBarsRequired, " Available=", availableBars, ")");
               return(false);
            }
            
            Print("Attempt ", failureCount, ": Insufficient bars calculated for ", symbolDescription, "/", indDesc, "(Required=", numBarsRequired, " Available=", availableBars, ")");
            
            //Sleep for 0.1s to allow time for price data to become usable
            Sleep(100);
         }
         else
         {
            success = true;
            
            if(failureCount > 0) //only write success message if previous failures registered
               Print("Succeeded on attempt ", failureCount+1);
         }
      }
       
      ResetLastError(); 
      
      int numAvailableBars = CopyBuffer(ind_handle, buffer_num, 0, numBarsRequired, localArray);
      
      if(numAvailableBars != numBarsRequired) 
      { 
         Print("Failed to copy data from indicator with error code ", GetLastError(), ". Bars required = ", numBarsRequired, " but bars copied = ", numAvailableBars);
         return(false); 
      } 
      
      //Ensure that elements indexed like in a timeseries (with index 0 being the current, 1 being one bar back in time etc.)
      ArraySetAsSeries(localArray, true);
      
      return(true); 
   }
   
   void ProcessTradeOpen(int SymbolLoop, string TradeDirection)
   { 
      string CurrentSymbol = SymbolArray[SymbolLoop];
      double ContractSize=SymbolInfoDouble(CurrentSymbol,SYMBOL_VOLUME_MIN);
      
      
      if(TradeDirection == "LONG")   
         {
         if(!trade.Buy (ContractSize,CurrentSymbol))        
                  Print("OrderSend error 1# Buy",GetLastError()); 
             Print("Short positions swap > 0.0 in "+CurrentSymbol+" Open Buy" +"Lot==" +DoubleToString(ContractSize,2) );  
         }
     else if(TradeDirection == "SHORT")   
         {
         if(!trade.Sell (ContractSize,CurrentSymbol))        
                  Print("OrderSend error 1# Sell",GetLastError()); 
             Print("Buy positions swap > 0.0 in "+CurrentSymbol+" Open Sell" +"Lot==" +DoubleToString(ContractSize,2) );  
         }
          

   }
   
   void ProcessTradeClose(int SymbolLoop, string CloseDirection)
   {
      string CurrentSymbol = SymbolArray[SymbolLoop];
         
        int b=0,s=0;
       int total=PositionsTotal();
    
      ENUM_ORDER_TYPE order_type =WRONG_VALUE ;  
   for(int k=total-1; k>=0; k--)
      if(m_position.SelectByIndex(k))     
         
            if(m_position.Magic()==iMagicNumber)

            if(m_position.Symbol()==CurrentSymbol)
               if(m_position.PositionType()==POSITION_TYPE_BUY || m_position.PositionType()==POSITION_TYPE_SELL)
                 {

                  op=NormalizeDouble(m_position.PriceOpen(),Digits());
                  lt=NormalizeDouble(m_position.Volume(),3);
                  tk=m_position.Ticket();
                 
                                             
                  if(m_position.PositionType()==POSITION_TYPE_BUY)
                    {
                     b++;
                     if(op>BuyPriceMax || BuyPriceMax==0)
                       {
                       
                        BuyPriceMax    = op;
                        BuyPriceMaxLot = lt;
                        
                       }
                     if(op<BuyPriceMin || BuyPriceMin==0)
                       {
                        BuyPriceMin    = op;
                        BuyPriceMinLot = lt;
                       }
                    }
                  // ===
                  if(m_position.PositionType()==POSITION_TYPE_SELL)
                    {
                     s++;                   
               
                     if(op>SelPriceMax || SelPriceMax==0)
                       {
                       
                        SelPriceMax    = op;
                        SelPriceMaxLot = lt;
                       }
                     if(op<SelPriceMin || SelPriceMin==0)
                       {
                        SelPriceMin    = op;
                        SelPriceMinLot = lt;
                       }
                    }
                    
        }
      
      
      if(CloseDirection == "CLOSE_LONG" && b>0)   
         {        
     Print(CurrentSymbol+  "  Close  Buy " );         
     
      ENUM_ORDER_TYPE order_type =WRONG_VALUE ;  
      for(int k=total-1; k>=0; k--)
      if(m_position.SelectByIndex(k))
       if(m_position.PositionType()==POSITION_TYPE_BUY)
            if(m_position.Magic()==iMagicNumber)
            if(m_position.Symbol()==CurrentSymbol)
             if(!trade.PositionClose(m_position.Symbol())); // close a position by the specified m_symbol
            Print(CurrentSymbol+  "OrderClose Buy error #",GetLastError());            
         }
     else if(CloseDirection == "CLOSE_SHORT"&& s>0) 
         {
         Print(CurrentSymbol+  "  Close  Sell " );   
        
      ENUM_ORDER_TYPE order_type =WRONG_VALUE ;  
      for(int k=total-1; k>=0; k--)
      if(m_position.SelectByIndex(k))
       if(m_position.PositionType()==POSITION_TYPE_SELL)
         if(m_position.Symbol()==CurrentSymbol)
            if(m_position.Magic()==iMagicNumber)
             if(!trade.PositionClose(m_position.Symbol())); // close a position by the specified m_symbol
            Print(CurrentSymbol+  "OrderClose Sell error #",GetLastError());            
         }   
                    
      
   }
   
   string GetSWAPSignalStatus(int SymbolLoop)
   {
      string CurrentSymbol = SymbolArray[SymbolLoop];
      
      //Need to copy values from indicator buffers to local buffers
    
   
      double CurrentClose = iClose(CurrentSymbol, Period(), 0);

      if (SymbolInfoDouble(CurrentSymbol,SYMBOL_SWAP_LONG)<0.0)
         return("CLOSE_SHORT"); 
         
     else if(SymbolInfoDouble(CurrentSymbol,SYMBOL_SWAP_SHORT)<0.0)
         return("CLOSE_LONG");
      else
          return("NO_CLOSE_SIGNAL");
   }
 
   
   
   void OutputStatusToChart(string additionalMetrics)
   {      
      //GET GMT OFFSET OF MT5 SERVER
      double offsetInHours = (TimeCurrent() - TimeGMT()) / 3600.0;
 
      //SYMBOLS BEING TRADED
      string symbolsText = "SYMBOLS BEING TRADED: ";
      for(int SymbolLoop=0; SymbolLoop < NumberOfTradeableSymbols; SymbolLoop++)
         StringConcatenate(symbolsText, symbolsText, " ", SymbolArray[SymbolLoop]);
      
      Comment("\n\rMT5 SERVER TIME: ", TimeCurrent(), " (OPERATING AT UTC/GMT", StringFormat("%+.1f", offsetInHours), ")\n\r\n\r",
               Symbol(), " TICKS RECEIVED: ", TicksReceivedCount, "\n\r\n\r",
               symbolsText,
               "\n\r\n\r", additionalMetrics);
   }
 bool IsSessionOpen(string SymbolS)

{

   MqlDateTime dt; datetime tc=TimeTradeServer(dt);

   // проверяем время торгов по инструменту

   datetime t=(datetime)SymbolInfoInteger(SymbolS, SYMBOL_EXPIRATION_TIME);

   if (tc>t && t>0) return(false);

   t=(datetime)SymbolInfoInteger(SymbolS, SYMBOL_START_TIME);

   if (tc<t && t>0) return(false);
   
   if (tc<t && t>0) return(false);  // подождать 1 минуту от начала ссесии
   
   // проверяем сессии инструмента

   datetime ds=tc/(60*60*24); ds*=(60*60*24); // начало сегодня

   datetime sec=tc-ds; // число секунд от начала дня

   bool b=false;

   for (int aa=0; aa<10; aa++) // подразумеваем, что админ сделал не более 10 сессий в сутки

   {

      datetime fs, ts;

      if (!SymbolInfoSessionTrade(SymbolS, (ENUM_DAY_OF_WEEK)dt.day_of_week, aa, fs, ts)) break; // данные сессии

      if (sec>=fs && sec<=ts) return(true);

   }

   return(false);

}

bool IsSessionClose(string SymbolS)

{

   MqlDateTime dt; datetime tc=TimeTradeServer(dt);

   // проверяем время торгов по инструменту

   datetime t=(datetime)SymbolInfoInteger(SymbolS, SYMBOL_EXPIRATION_TIME);

   if (tc>t && t>0) return(false);

   t=(datetime)SymbolInfoInteger(SymbolS, SYMBOL_START_TIME);

   if (tc<t && t>0) return(false);

   // проверяем сессии инструмента

   datetime ds=tc/(60*60*24); ds*=(60*60*24); // начало сегодня

   datetime sec=tc-ds; // число секунд от начала дня

   bool b=false;

   for (int aa=0; aa<10; aa++) // подразумеваем, что админ сделал не более 10 сессий в сутки

   {

      datetime fs, ts;

      if (!SymbolInfoSessionTrade(SymbolS, (ENUM_DAY_OF_WEEK)dt.day_of_week, aa, fs, ts)) break; // данные сессии

      if (//sec>=fs &&
       sec+200>=ts) return(true);

   }

   return(false);

}
  
  
bool IsSessionCloses(string SymbolS)

{

   MqlDateTime dt; datetime tc=TimeTradeServer(dt);

   // проверяем время торгов по инструменту

   datetime t=(datetime)SymbolInfoInteger(SymbolS, SYMBOL_EXPIRATION_TIME);
datetime sec=200;
      if (//sec>=fs &&
       t-200 >= tc) return(true);

   

   return(false);

}
