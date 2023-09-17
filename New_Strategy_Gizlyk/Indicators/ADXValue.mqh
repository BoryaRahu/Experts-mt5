//+------------------------------------------------------------------+
//|                                                     ADXValue.mqh |
//|                                              Copyright 2017, DNG |
//|                                 http://www.mql5.com/ru/users/dng |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, DNG"
#property link      "http://www.mql5.com/ru/users/dng"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <Object.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CADXValue      : public CObject
  {
private:
   double            ADX_Value;        //ADX value
   double            ADX_Dinamic;      //Dinamics value of ADX
   double            PDI_Value;        //+DI value
   double            PDI_Dinamic;      //Dinamics value of +DI
   double            NDI_Value;        //-DIvalue
   double            NDI_Dinamic;      //Dinamics value of -DI
   long              Deal_Ticket;      //Ticket of deal 
   
public:
                     CADXValue(double adx_value, double adx_dinamic, double pdi_value, double pdi_dinamic, double ndi_value, double ndi_dinamic, long ticket);
                    ~CADXValue(void);
   //---
   long              GetTicket(void)         {  return Deal_Ticket;     }
   double            GetADXValue(void)       {  return ADX_Value;       }
   double            GetADXDinamic(void)     {  return ADX_Dinamic;     }
   double            GetPDIValue(void)       {  return PDI_Value;       }
   double            GetPDIDinamic(void)     {  return PDI_Dinamic;     }
   double            GetNDIValue(void)       {  return NDI_Value;       }
   double            GetNDIDinamic(void)     {  return NDI_Dinamic;     }
   void              GetValues(double &adx_value, double &adx_dinamic, double &pdi_value, double &pdi_dinamic, double &ndi_value, double &ndi_dinamic);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CADXValue::CADXValue(double adx_value,double adx_dinamic,double pdi_value,double pdi_dinamic,double ndi_value,double ndi_dinamic,long ticket)
  {
   ADX_Value      =  adx_value;
   ADX_Dinamic    =  adx_dinamic;
   PDI_Value      =  pdi_value;
   PDI_Dinamic    =  pdi_dinamic;
   NDI_Value      =  ndi_value;
   NDI_Dinamic    =  ndi_dinamic;
   Deal_Ticket    =  ticket;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CADXValue::~CADXValue()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CADXValue::GetValues(double &adx_value,double &adx_dinamic,double &pdi_value,double &pdi_dinamic,double &ndi_value,double &ndi_dinamic)
  {
   adx_value      =  ADX_Value;
   adx_dinamic    =  ADX_Dinamic;
   pdi_value      =  PDI_Value;
   pdi_dinamic    =  PDI_Dinamic;
   ndi_value      =  NDI_Value;
   ndi_dinamic    =  NDI_Dinamic;
  }
//+------------------------------------------------------------------+
