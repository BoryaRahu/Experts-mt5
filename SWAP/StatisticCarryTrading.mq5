//+------------------------------------------------------------------+
//|                                        StatisticCarryTrading.mq5 |
//|                                  Copyright 2012, Ruslan V. Lunev |
//|                              http://www.mql5.com/ru/articles/491 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Ruslan V. Lunev"
#property link      "http://www.mql5.com/ru/articles/491"
#property version   "1.00"

input string secondpair="AUDUSD";
input int p=100;

double open0[];
double open1[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Reading the time series of opening prices
   // for the currency pairs involved
   CopyOpen(_Symbol,PERIOD_D1,0,p+1,open0);
   ArraySetAsSeries(open0,true);
   CopyOpen(secondpair,PERIOD_D1,0,p+1,open1);
   ArraySetAsSeries(open1,true);

   int i=0;

   double pp=p;

   double s1 = 0;
   double s2 = 0;
   double s3 = 0;
   double s4=open1[0]-open1[p];
   double s5=open0[0]-open0[p];

   double averagex = s4 / pp;
   double averagey = s5 / pp;

   for(i=0; i<p; i++) 
     {
      double x0 = open1[i] - open1[i + 1];
      double y0 = open0[i] - open0[i + 1];
      double x1 = x0 - averagex;
      double y1 = y0 - averagey;
      s1 = s1 + x1 * x1;
      s2 = s2 + y1 * y1;
      s3 = s3 + x1 * y1;
     }
   
   // Pearson's linear correlation coefficient
   double r=s3/MathSqrt(s1*s2);

   // Calculation of proportions of opening positions sizes given the contract sizes
   double a = signum(r) * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE) * MathSqrt(s2) 
   / (MathSqrt(s1) * SymbolInfoDouble(secondpair, SYMBOL_TRADE_CONTRACT_SIZE));
   
   // Calculation of the average daily profit
   double b = averagey - averagex * a;

   // Derive the resulting formula of joint price movement
   if(b>0) 
     {
      Print(_Symbol+" = ",a," * "+secondpair+" + ",b);
        } else {
      Print(_Symbol+" = ",a," * "+secondpair+" - ",MathAbs(b));
     }

   a=-a*signum(b);

   // Recommendations
   string recomendation="Buy "+_Symbol;

   if(b<0) 
     {
      recomendation="Sell "+_Symbol;
      if(SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT)<0.0) 
        {
         recomendation="Short positions swap in "+_Symbol+" is negative";
         MessageBox(recomendation,"Not recommended",1);
         return(0);
        }
        } else {
      if(SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG)<0.0) 
        {
         recomendation="Long positions swap in "+_Symbol+" is negative";
         MessageBox(recomendation,"Not recommended",1);
         return(0);
        }
     }

   if(a<0) 
     {
      recomendation=recomendation+"\r\nSell "+a+" "+secondpair;
      if(SymbolInfoDouble(secondpair,SYMBOL_SWAP_SHORT)<0.0) 
        {
         recomendation="Short positions swap in "+secondpair+" is negative";
         MessageBox(recomendation,"Not recommended",1);
         return(0);
        }
        } else {
      recomendation=recomendation+"\r\nBuy "+a+" "+secondpair;
      if(SymbolInfoDouble(secondpair,SYMBOL_SWAP_LONG)<0.0) 
        {
         recomendation="Long positions swap in "+secondpair+" is negative";
         MessageBox(recomendation,"Not recommended",1);
         return(0);
        }
     }

   double profit=MathAbs(b)/SymbolInfoDouble(_Symbol,SYMBOL_POINT);

   if((SymbolInfoInteger(_Symbol,SYMBOL_DIGITS)==5) || (SymbolInfoInteger(_Symbol,SYMBOL_DIGITS)==3)) 
     {
      profit=profit/10;
     }

   recomendation = recomendation + "\r\nCorrelation coefficient: " + r;
   recomendation = recomendation + "\r\nAverage daily profit: "
   + profit + " points";


   MessageBox(recomendation,"Recommendation",1);

   return(0);
  }

// Step function - Signum
double signum(double x) 
  {
   if(x<0.0) 
     {
      return(-1.0);
     }
   if(x==0.0) 
     {
      return(0);
     }
   return(1.0);
  }
//+-----------------------The End ------------------------+
