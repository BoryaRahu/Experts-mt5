//+------------------------------------------------------------------+
//|                                           MoneySizeOptimized.mqh |
//|                   Copyright 2009-2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertMoney.mqh>
#include <Trade\DealInfo.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Trading with 'Shannon Entropy' optimized trade volume      |
//| Type=Money                                                       |
//| Name=SE                                                          |
//| Class=CMoneySE                                                   |
//| Page=money_se                                                    |
//| Parameter=ScaleFactor,int,3,Scale factor                         |
//| Parameter=Percent,double,10.0,Percent                            |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CMoneySE.                                                  |
//| Purpose: Class of money management with 'Shannon Entropy' optimized volume.          |
//|              Derives from class CExpertMoney.                    |
//+------------------------------------------------------------------+
class CMoneySE : public CExpertMoney
  {
protected:
   int               m_scale_factor;

public:
   double            m_absolute_condition;
   
                     CMoneySE(void);
                    ~CMoneySE(void);
   //---
   void              ScaleFactor(int scale_factor) { m_scale_factor=scale_factor; }
   void              AbsoluteCondition(double absolute_condition) { m_absolute_condition=absolute_condition; }
   virtual bool      ValidationSettings(void);
   //---
   virtual double    CheckOpenLong(double price,double sl);
   virtual double    CheckOpenShort(double price,double sl);

protected:
   double            Optimize(double lots);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CMoneySE::CMoneySE(void) : m_scale_factor(3.0),
                                 m_absolute_condition(50.0)
                                 
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
void CMoneySE::~CMoneySE(void)
  {
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CMoneySE::ValidationSettings(void)
  {
   if(!CExpertMoney::ValidationSettings())
      return(false);
//--- initial data checks
   if(m_scale_factor<=0)
     {
      printf(__FUNCTION__+": scale factor must be greater then 0");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Getting lot size for open long position.                         |
//+------------------------------------------------------------------+
double CMoneySE::CheckOpenLong(double price,double sl)
  {
   if(m_symbol==NULL)
      return(0.0);
//--- select lot size
   double lot;
   if(price==0.0)
      lot=m_account.MaxLotCheck(m_symbol.Name(),ORDER_TYPE_BUY,m_symbol.Ask(),m_percent);
   else
      lot=m_account.MaxLotCheck(m_symbol.Name(),ORDER_TYPE_BUY,price,m_percent);
//--- return trading volume
   return(Optimize(lot));
  }
//+------------------------------------------------------------------+
//| Getting lot size for open short position.                        |
//+------------------------------------------------------------------+
double CMoneySE::CheckOpenShort(double price,double sl)
  {
   if(m_symbol==NULL)
      return(0.0);
//--- select lot size
   double lot;
   if(price==0.0)
      lot=m_account.MaxLotCheck(m_symbol.Name(),ORDER_TYPE_SELL,m_symbol.Bid(),m_percent);
   else
      lot=m_account.MaxLotCheck(m_symbol.Name(),ORDER_TYPE_SELL,price,m_percent);
//--- return trading volume
   return(Optimize(lot));
  }
//+------------------------------------------------------------------+
//| Optimizing lot size for open.                                    |
//+------------------------------------------------------------------+
double CMoneySE::Optimize(double lots)
  {
   double lot=lots;
   
      //--- normalize lot size based on magnitude of condition
      lot*=(20*m_scale_factor/fmax(20.0,((100.0-m_absolute_condition)/100.0)*20.0*m_scale_factor*m_scale_factor));
      
      //--- reduce lot based on number of losses orders without a break
      if(m_scale_factor>0)
      {
         //--- select history for access
         HistorySelect(0,TimeCurrent());
         //---
         int       orders=HistoryDealsTotal();  // total history deals
         int       losses=0;                    // number of consequent losing orders
         CDealInfo deal;
         //---
         for(int i=orders-1;i>=0;i--)
         {
            deal.Ticket(HistoryDealGetTicket(i));
            if(deal.Ticket()==0)
            {
               Print("CMoneySE::Optimize: HistoryDealGetTicket failed, no trade history");
               break;
            }
            //--- check symbol
            if(deal.Symbol()!=m_symbol.Name())
               continue;
            //--- check profit
            double profit=deal.Profit();
            if(profit>0.0)
               break;
            if(profit<0.0)
               losses++;
         }
         //---
         if(losses>1){
         lot*=m_scale_factor;
         lot/=(losses+m_scale_factor);
         lot=NormalizeDouble(lot,2);}
      }
      //--- normalize and check limits
      double stepvol=m_symbol.LotsStep();
      lot=stepvol*NormalizeDouble(lot/stepvol,0);
      //---
      double minvol=m_symbol.LotsMin();
      if(lot<minvol){ lot=minvol; }
      //---
      double maxvol=m_symbol.LotsMax();
      if(lot>maxvol){ lot=maxvol; }
//---
   return(lot);
  }
//+------------------------------------------------------------------+
