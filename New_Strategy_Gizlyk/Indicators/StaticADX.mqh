//+------------------------------------------------------------------+
//|                                                    StaticADX.mqh |
//|                                              Copyright 2017, DNG |
//|                                 http://www.mql5.com/ru/users/dng |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, DNG"
#property link      "http://www.mql5.com/ru/users/dng"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "ADX.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class C_ProfitData
  {
   public:
   double         Value;
   double         LongProfit[3]/*UppositePosition*/[3]/*Upposite Direct*/[3]/*ADX position*/[3]/*ADX direct*/;
   double         ShortProfit[3]/*UppositePosition*/[3]/*Upposite Direct*/[3]/*ADX position*/[3]/*ADX direct*/;
   
                  C_ProfitData(void) 
                  {  ArrayInitialize(LongProfit,0); ArrayInitialize(ShortProfit,0);  }
                 ~C_ProfitData(void) {};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CStaticADX  :  CObject
  {
private:
   CADX             *DataArray;
   
   double            d_Step;           //Step in values Array
   C_ProfitData     *PDI[][3];         //Array of values
   C_ProfitData     *NDI[][3];         //Array of values
   
   bool              AdValues(double adx_value, double adx_dinamic, double pdi_value, double pdi_dinamic, double ndi_value, double ndi_dinamic, double profit, ENUM_POSITION_TYPE type);
   int               GetPDIIndex(double value);
   int               GetNDIIndex(double value);
   bool              Sort(void);
   
public:
                     CStaticADX(CADX *data, double step);
                    ~CStaticADX();
   bool              Ad(long ticket, double profit, ENUM_POSITION_TYPE type);
   string            HTML_header(void);
   string            HTML_body(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStaticADX::CStaticADX(CADX *data,double step)
  {
   DataArray   =  data;
   d_Step      =  step;
   ArrayFree(PDI);
   ArrayFree(NDI);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStaticADX::~CStaticADX()
  {
   int total=ArrayRange(PDI,0);
   for(int i=0;i<total;i++)
      for(int d=0;d<3;d++)
         if(CheckPointer(PDI[i,d])!=POINTER_INVALID)
            delete PDI[i,d];
   ArrayFree(PDI);
   //---
   total=ArrayRange(NDI,0);
   for(int i=0;i<total;i++)
      for(int d=0;d<3;d++)
         if(CheckPointer(NDI[i,d])!=POINTER_INVALID)
            delete NDI[i,d];
   ArrayFree(NDI);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStaticADX::Ad(long ticket,double profit,ENUM_POSITION_TYPE type)
  {
   if(CheckPointer(DataArray)==POINTER_INVALID)
      return false;

   double adx_value,adx_dinamic,pdi_value,pdi_dinamic,ndi_value,ndi_dinamic;
   if(!DataArray.GetValues(ticket,adx_value,adx_dinamic,pdi_value,pdi_dinamic,ndi_value,ndi_dinamic))
      return false;
   adx_value = NormalizeDouble(adx_value/d_Step,0)*d_Step;
   pdi_value = NormalizeDouble(pdi_value/d_Step,0)*d_Step;
   ndi_value = NormalizeDouble(ndi_value/d_Step,0)*d_Step;
   return AdValues(adx_value,adx_dinamic,pdi_value,pdi_dinamic,ndi_value,ndi_dinamic,profit,type);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStaticADX::AdValues(double adx_value,double adx_dinamic,double pdi_value,double pdi_dinamic,double ndi_value,double ndi_dinamic,double profit,ENUM_POSITION_TYPE type)
  {
   int index=GetPDIIndex(pdi_value);
   if(index<0)
      return false;
   
   int pdi_d=(pdi_dinamic<1 ? 0 :(pdi_dinamic>1 ? 2 : 1));
   int ndi_p=(pdi_value>ndi_value ? 0 :(pdi_value<ndi_value ? 2 : 1));
   int ndi_d=(ndi_dinamic<1 ? 0 :(ndi_dinamic>1 ? 2 : 1));
   int adx_p=(pdi_value>adx_value ? 0 :(pdi_value<adx_value ? 2 : 1));
   int adx_d=(adx_dinamic<1 ? 0 :(adx_dinamic>1 ? 2 : 1));
   switch(type)
     {
      case POSITION_TYPE_BUY:
        PDI[index,pdi_d].LongProfit[ndi_p,ndi_d,adx_p,adx_d]+=profit;
        break;
      case POSITION_TYPE_SELL:
        PDI[index,pdi_d].ShortProfit[ndi_p,ndi_d,adx_p,adx_d]+=profit;
        break;
     }
   //---
   index=GetNDIIndex(ndi_value);
   if(index<0)
      return false;
   
   int pdi_p=(ndi_value>pdi_value ? 0 :(ndi_value<pdi_value ? 2 : 1));
       adx_p=(ndi_value>adx_value ? 0 :(ndi_value<adx_value ? 2 : 1));
   switch(type)
     {
      case POSITION_TYPE_BUY:
        NDI[index,ndi_d].LongProfit[pdi_p,pdi_d,adx_p,adx_d]+=profit;
        break;
      case POSITION_TYPE_SELL:
        NDI[index,ndi_d].ShortProfit[pdi_p,pdi_d,adx_p,adx_d]+=profit;
        break;
     }
   //---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CStaticADX::GetPDIIndex(double value)
  {
   int result=-1;
   int total=ArrayRange(PDI,0);
   for(int i=0;i<total;i++)
     {
      if(PDI[i,0].Value==value)
        {
         result=i;
         break;
        }
     }
   if(result<0)
     {
      if(ArrayResize(PDI,total+1)<0)
         return result;
      result               =  total;
      for(int i=0;i<3;i++)
        {
         PDI[total,i]      =  new C_ProfitData();
         PDI[total,i].Value=  value;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CStaticADX::GetNDIIndex(double value)
  {
   int result=-1;
   int total=ArrayRange(NDI,0);
   for(int i=0;i<total;i++)
     {
      if(NDI[i,0].Value==value)
        {
         result=i;
         break;
        }
     }
   if(result<0)
     {
      if(ArrayResize(NDI,total+1)<0)
         return result;
      result               =  total;
      for(int i=0;i<3;i++)
        {
         NDI[total,i]      =  new C_ProfitData();
         NDI[total,i].Value=  value;
        }
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStaticADX::Sort(void)
  {
   int total=ArrayRange(PDI,0);
   bool found=false;
   do
     {
      found =  false;
      for(int i=0;i<total-1;i++)
        {
         if(PDI[i,0].Value>PDI[i+1,0].Value)
           {
            for(int d=0;d<3;d++)
              {
               C_ProfitData *temp   =  PDI[i,d];
               PDI[i,d]             =  PDI[i+1,d];
               PDI[i+1,d]           =  temp;
              }
            found          =  true;
           }
        }
     }
   while(found);
   //---
   total=ArrayRange(NDI,0);
   do
     {
      found =  false;
      for(int i=0;i<total-1;i++)
        {
         if(NDI[i,0].Value>NDI[i+1,0].Value)
           {
            for(int d=0;d<3;d++)
              {
               C_ProfitData *temp   =  NDI[i,d];
               NDI[i,d]             =  NDI[i+1,d];
               NDI[i+1,d]           =  temp;
              }
            found             =  true;
           }
        }
     }
   while(found);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CStaticADX::HTML_header(void)
  {
   int handle=DataArray.GetIndyHandle();
   int digits=0;
   double lg=MathLog10(d_Step);
   if(lg<0)
     {
      if(MathAbs(lg)>4)
         digits=5;
      else
        {
         if(MathAbs(lg)>3)
            digits=4;
         else
           {
            if(MathAbs(lg)>2)
               digits=3;
            else
              {
               if(MathAbs(lg)>1)
                  digits=2;
               else
                  digits=1;
              }
           }
        }
     }
   if(handle<0)
      return NULL;
   
   string ident=IntegerToString(handle);
   Sort();
   int pdi_total=ArrayRange(PDI,0);
   int ndi_total=ArrayRange(NDI,0);
   //---
   string result="var tit"+ident+"=new Highcharts.Chart({chart:{renderTo:'title"+ident+"',borderWidth:0,shadow:false,backgroundColor:{linearGradient:[0,0,500,500],\n";
   result+="stops:[[0,'rgb(251,252,255)'],[1,'rgb(223,227,252)']]}}, title:{style:{color:'#405A75',font:'normal 25px \"Trebuchet MS\",Verdana,Tahoma,Arial,Helvetica,sans-serif'},";
   result+="align:'center',text:'"+DataArray.GetName()+"'}});";
   result+="var value"+ident+"=new Highcharts.Chart({";
   result+="chart:{renderTo:\'pdi_values"+ident+"\',zoomType: 'x'},";
   result+="title:{text:\'Profit to +DI values.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:["+DoubleToString(PDI[0,0].Value,digits);
   for(int i=1;i<pdi_total;i++)
      result+=","+DoubleToString(PDI[i,0].Value,digits);
   result+="]},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'spline',color:\'#00AA00\',name:\'Long\',data:[";
   for(int i=0;i<pdi_total;i++)
     {
      double sum=0;
      if(i!=0)
         result+=",";
      for(int d=0;d<3;d++)
         for(int up_p=0;up_p<3;up_p++)
            for(int up_d=0;up_d<3;up_d++)
               for(int adx_p=0;adx_p<3;adx_p++)
                  for(int adx_d=0;adx_d<3;adx_d++)
                    {
                     sum+=PDI[i,d].LongProfit[up_p,up_d,adx_p,adx_d];
                    }
      result+=DoubleToString(sum,2);
     }
   result+="]},";
   result+="{type:'spline',color:\'#DD0202\',name:\'Short\',data:[";
   for(int i=0;i<pdi_total;i++)
     {
      double sum=0;
      if(i!=0)
         result+=",";
      for(int d=0;d<3;d++)
         for(int up_p=0;up_p<3;up_p++)
            for(int up_d=0;up_d<3;up_d++)
               for(int adx_p=0;adx_p<3;adx_p++)
                  for(int adx_d=0;adx_d<3;adx_d++)
                    {
                     sum+=PDI[i,d].ShortProfit[up_p,up_d,adx_p,adx_d];
                    }
      result+=DoubleToString(sum,2);
     }
   result+="]}]});\n";
   //---
   result+="var adx_to_pdi"+ident+"=new Highcharts.Chart({";
   result+="chart:{renderTo:\'position_adx_to_pdi"+ident+"\'},";
   result+="title:{text:\'Profit by position ADX to +DI.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:['Lower','Equal','Upper']},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'column',color:\'#00AA00\',name:\'Long\',data:[";
   double sum=0;
   for(int i=0;i<pdi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int d=0;d<3;d++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=PDI[i,d].LongProfit[up_p,up_d,0,adx_d];
   
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<pdi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int d=0;d<3;d++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=PDI[i,d].LongProfit[up_p,up_d,1,adx_d];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<pdi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int d=0;d<3;d++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=PDI[i,d].LongProfit[up_p,up_d,2,adx_d];
   result+=DoubleToString(sum,2)+"]},";
   result+="{type:'column',color:\'#DD0202\',name:\'Short\',data:[";
   sum=0;
   for(int i=0;i<pdi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int d=0;d<3;d++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=PDI[i,d].ShortProfit[up_p,up_d,0,adx_d];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<pdi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int d=0;d<3;d++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=PDI[i,d].ShortProfit[up_p,up_d,1,adx_d];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<pdi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int d=0;d<3;d++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=PDI[i,d].ShortProfit[up_p,up_d,2,adx_d];
   result+=DoubleToString(sum,2);
   result+="]}]});\n";
   //---
   result+="var direct"+ident+"=new Highcharts.Chart({";
   result+="chart:{renderTo:\'pdi_directs"+ident+"\'},";
   result+="title:{text:\'Profit by +DI line direction.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:['Down','Equal','Up']},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'column',color:\'#00AA00\',name:\'Long\',data:[";
   sum=0;
   for(int i=0;i<pdi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int adx_p=0;adx_p<3;adx_p++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=PDI[i,0].LongProfit[up_p,up_d,adx_p,adx_d];
   
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<pdi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int adx_p=0;adx_p<3;adx_p++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=PDI[i,1].LongProfit[up_p,up_d,adx_p,adx_d];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<pdi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int adx_p=0;adx_p<3;adx_p++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=PDI[i,2].LongProfit[up_p,up_d,adx_p,adx_d];
   result+=DoubleToString(sum,2)+"]},";
   result+="{type:'column',color:\'#DD0202\',name:\'Short\',data:[";
   sum=0;
   for(int i=0;i<pdi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int adx_p=0;adx_p<3;adx_p++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=PDI[i,0].ShortProfit[up_p,up_d,adx_p,adx_d];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<pdi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int adx_p=0;adx_p<3;adx_p++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=PDI[i,1].ShortProfit[up_p,up_d,adx_p,adx_d];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<pdi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int adx_p=0;adx_p<3;adx_p++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=PDI[i,2].ShortProfit[up_p,up_d,adx_p,adx_d];
   result+=DoubleToString(sum,2);
   result+="]}]});\n";
   //---
   result+="var ndi_value"+ident+"=new Highcharts.Chart({";
   result+="chart:{renderTo:\'ndi_values"+ident+"\',zoomType: 'x'},";
   result+="title:{text:\'Profit to -DI values.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:["+DoubleToString(NDI[0,0].Value,digits);
   for(int i=1;i<ndi_total;i++)
      result+=","+DoubleToString(NDI[i,0].Value,digits);
   result+="]},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'spline',color:\'#00AA00\',name:\'Long\',data:[";
   for(int i=0;i<ndi_total;i++)
     {
      sum=0;
      if(i!=0)
         result+=",";
      for(int d=0;d<3;d++)
         for(int up_p=0;up_p<3;up_p++)
            for(int up_d=0;up_d<3;up_d++)
               for(int adx_p=0;adx_p<3;adx_p++)
                  for(int adx_d=0;adx_d<3;adx_d++)
                    {
                     sum+=NDI[i,d].LongProfit[up_p,up_d,adx_p,adx_d];
                    }
      result+=DoubleToString(sum,2);
     }
   result+="]},";
   result+="{type:'spline',color:\'#DD0202\',name:\'Short\',data:[";
   for(int i=0;i<ndi_total;i++)
     {
      sum=0;
      if(i!=0)
         result+=",";
      for(int d=0;d<3;d++)
         for(int up_p=0;up_p<3;up_p++)
            for(int up_d=0;up_d<3;up_d++)
               for(int adx_p=0;adx_p<3;adx_p++)
                  for(int adx_d=0;adx_d<3;adx_d++)
                    {
                     sum+=NDI[i,d].ShortProfit[up_p,up_d,adx_p,adx_d];
                    }
      result+=DoubleToString(sum,2);
     }
   result+="]}]});\n";
   //---
   result+="var adx_to_ndi"+ident+"=new Highcharts.Chart({";
   result+="chart:{renderTo:\'position_adx_to_ndi"+ident+"\'},";
   result+="title:{text:\'Profit by position ADX to -DI.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:['Lower','Equal','Upper']},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'column',color:\'#00AA00\',name:\'Long\',data:[";
   sum=0;
   for(int i=0;i<ndi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int d=0;d<3;d++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=NDI[i,d].LongProfit[up_p,up_d,0,adx_d];
   
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<ndi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int d=0;d<3;d++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=NDI[i,d].LongProfit[up_p,up_d,1,adx_d];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<ndi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int d=0;d<3;d++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=NDI[i,d].LongProfit[up_p,up_d,2,adx_d];
   result+=DoubleToString(sum,2)+"]},";
   result+="{type:'column',color:\'#DD0202\',name:\'Short\',data:[";
   sum=0;
   for(int i=0;i<ndi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int d=0;d<3;d++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=NDI[i,d].ShortProfit[up_p,up_d,0,adx_d];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<ndi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int d=0;d<3;d++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=NDI[i,d].ShortProfit[up_p,up_d,1,adx_d];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<ndi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int d=0;d<3;d++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=NDI[i,d].ShortProfit[up_p,up_d,2,adx_d];
   result+=DoubleToString(sum,2);
   result+="]}]});\n";
   //---
   result+="var ndi_direct"+ident+"=new Highcharts.Chart({";
   result+="chart:{renderTo:\'ndi_directs"+ident+"\'},";
   result+="title:{text:\'Profit by -DI line direction.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:['Down','Equal','Up']},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'column',color:\'#00AA00\',name:\'Long\',data:[";
   sum=0;
   for(int i=0;i<ndi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int adx_p=0;adx_p<3;adx_p++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=NDI[i,0].LongProfit[up_p,up_d,adx_p,adx_d];
   
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<ndi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int adx_p=0;adx_p<3;adx_p++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=NDI[i,1].LongProfit[up_p,up_d,adx_p,adx_d];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<ndi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int adx_p=0;adx_p<3;adx_p++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=NDI[i,2].LongProfit[up_p,up_d,adx_p,adx_d];
   result+=DoubleToString(sum,2)+"]},";
   result+="{type:'column',color:\'#DD0202\',name:\'Short\',data:[";
   sum=0;
   for(int i=0;i<ndi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int adx_p=0;adx_p<3;adx_p++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=NDI[i,0].ShortProfit[up_p,up_d,adx_p,adx_d];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<ndi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int adx_p=0;adx_p<3;adx_p++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=NDI[i,1].ShortProfit[up_p,up_d,adx_p,adx_d];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<ndi_total;i++)
      for(int up_p=0;up_p<3;up_p++)
         for(int up_d=0;up_d<3;up_d++)
            for(int adx_p=0;adx_p<3;adx_p++)
               for(int adx_d=0;adx_d<3;adx_d++)
                  sum+=NDI[i,2].ShortProfit[up_p,up_d,adx_p,adx_d];
   result+=DoubleToString(sum,2);
   result+="]}]});\n";
   //---
   
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CStaticADX::HTML_body(void)
  {
   int handle=DataArray.GetIndyHandle();
   if(handle<0)
      return NULL;
   
   string ident=IntegerToString(handle);
   string result="<table border=0 cellspacing=0><tr><td><div id=\"title"+ident+"\" style=\"width:1200px; height:40px; margin:0 auto\"></div></td></tr></table>";
   result+="<table border=0 cellspacing=0><tr><td><div id=\"pdi_values"+ident+"\" style=\"width:700px; height:300px; margin:0 auto\"></div></td>";
   result+="<td><div id=\"pdi_directs"+ident+"\" style=\"width:250px; height:300px; margin:0 auto\"></div></td>";
   result+="<td><div id=\"position_adx_to_pdi"+ident+"\" style=\"width:250px; height:300px; margin:0 auto\"></div></td>";
   result+="</tr></table>";
   result+="<table border=0 cellspacing=0><tr><td><div id=\"ndi_values"+ident+"\" style=\"width:700px; height:300px; margin:0 auto\"></div></td>";
   result+="<td><div id=\"ndi_directs"+ident+"\" style=\"width:250px; height:300px; margin:0 auto\"></div></td>";
   result+="<td><div id=\"position_adx_to_ndi"+ident+"\" style=\"width:250px; height:300px; margin:0 auto\"></div></td>";
   result+="</tr></table>";
   
   return result;
  }
//+------------------------------------------------------------------+
