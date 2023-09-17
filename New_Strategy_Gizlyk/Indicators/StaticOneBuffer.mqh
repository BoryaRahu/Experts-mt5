//+------------------------------------------------------------------+
//|                                              StaticOneBuffer.mqh |
//|                                              Copyright 2017, DNG |
//|                                 http://www.mql5.com/ru/users/dng |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, DNG"
#property link      "http://www.mql5.com/ru/users/dng"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "OneBufferArray.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CStaticOneBuffer  :  CObject
  {
private:
   COneBufferArray  *DataArray;
   
   double            d_Step;                    //Step in values Array
   double            Value[];                   //Array of values
   double            Long_Profit[][3];          //Array of long trades profit, direct -> DOWN-0, EQUAL-1, UP-2
   double            Short_Profit[][3];         //Array of short trades profit, direct -> DOWN-0, EQUAL-1, UP-2
   
   bool              AdValues(double value, double dinamic, double profit, ENUM_POSITION_TYPE type);
   int               GetIndex(double value);
   bool              Sort(void);
   
public:
                     CStaticOneBuffer(COneBufferArray *data, double step);
                    ~CStaticOneBuffer();
   bool              Ad(long ticket, double profit, ENUM_POSITION_TYPE type);
   string            HTML_header(void);
   string            HTML_body(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStaticOneBuffer::CStaticOneBuffer(COneBufferArray *data,double step)
  {
   DataArray   =  data;
   d_Step      =  step;
   ArrayFree(Value);
   ArrayFree(Long_Profit);
   ArrayFree(Short_Profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStaticOneBuffer::~CStaticOneBuffer()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStaticOneBuffer::Ad(long ticket,double profit,ENUM_POSITION_TYPE type)
  {
   if(CheckPointer(DataArray)==POINTER_INVALID)
      return false;

   double value, dinamic;
   if(!DataArray.GetValues(ticket,value,dinamic))
      return false;
   value = NormalizeDouble(value/d_Step,0)*d_Step;
   return AdValues(value,dinamic,profit,type);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStaticOneBuffer::AdValues(double value,double dinamic,double profit,ENUM_POSITION_TYPE type)
  {
   int index=GetIndex(value);
   if(index<0)
      return false;
   
   switch(type)
     {
      case POSITION_TYPE_BUY:
        if(dinamic<1)
           Long_Profit[index,0]+=profit;
        else
           if(dinamic==1)
              Long_Profit[index,1]+=profit;
           else
              Long_Profit[index,2]+=profit;
        break;
      case POSITION_TYPE_SELL:
        if(dinamic<1)
           Short_Profit[index,0]+=profit;
        else
           if(dinamic==1)
              Short_Profit[index,1]+=profit;
           else
              Short_Profit[index,2]+=profit;
        break;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CStaticOneBuffer::GetIndex(double value)
  {
   int result=-1;
   int total=ArraySize(Value);
   for(int i=0;i<total;i++)
     {
      if(Value[i]==value)
        {
         result=i;
         break;
        }
     }
   if(result<0)
     {
      if(ArrayResize(Value,total+1)<0)
         return result;
      if(ArrayResize(Long_Profit,total+1)<0 || ArrayResize(Short_Profit,total+1)<0)
        {
         ArrayResize(Value,total);
         return result;
        }
      result               =  total;
      Value[total]         =  value;
      for(int i=0;i<3;i++)
         Long_Profit[total,i]   =  Short_Profit[total,i]  =  0;
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStaticOneBuffer::Sort(void)
  {
   int total=ArraySize(Value);
   bool found=false;
   do
     {
      found =  false;
      for(int i=0;i<total-1;i++)
        {
         if(Value[i]>Value[i+1])
           {
            double temp       =  Value[i];
            Value[i]          =  Value[i+1];
            Value[i+1]        =  temp;
            for(int j=0;j<3;j++)
              {
               temp                 =  Long_Profit[i,j];
               Long_Profit[i,j]     =  Long_Profit[i+1,j];
               Long_Profit[i+1,j]   =  temp;
               temp                 =  Short_Profit[i,j];
               Short_Profit[i,j]    =  Short_Profit[i+1,j];
               Short_Profit[i+1,j]  =  temp;
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
string CStaticOneBuffer::HTML_header(void)
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
   int total=ArraySize(Value);
   //---
   string result="var tit"+ident+"=new Highcharts.Chart({chart:{renderTo:'title"+ident+"',borderWidth:0,shadow:false,backgroundColor:{linearGradient:[0,0,500,500],\n";
   result+="stops:[[0,'rgb(251,252,255)'],[1,'rgb(223,227,252)']]}}, title:{style:{color:'#405A75',font:'normal 25px \"Trebuchet MS\",Verdana,Tahoma,Arial,Helvetica,sans-serif'},";
   result+="align:'center',text:'"+DataArray.GetName()+"'}});";
   result+="var value"+ident+"=new Highcharts.Chart({";
   result+="chart:{renderTo:\'values"+ident+"\',zoomType: 'x'},";
   result+="title:{text:\'Profit to values.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:["+DoubleToString(Value[0],digits);
   for(int i=1;i<total;i++)
      result+=","+DoubleToString(Value[i],digits);
   result+="]},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'spline',color:\'#00AA00\',name:\'Long\',data:["+DoubleToString(Long_Profit[0,0]+Long_Profit[0,1]+Long_Profit[0,2],2);
   for(int i=1;i<total;i++)
      result+=","+DoubleToString(Long_Profit[i,0]+Long_Profit[i,1]+Long_Profit[i,2],2);
   result+="]},";
   result+="{type:'spline',color:\'#DD0202\',name:\'Short\',data:["+DoubleToString(Short_Profit[0,0]+Short_Profit[0,1]+Short_Profit[0,2],2);
   for(int i=1;i<total;i++)
      result+=","+DoubleToString(Short_Profit[i,0]+Short_Profit[i,1]+Short_Profit[i,2],2);
   result+="]}]});\n";
   //---
   result+="var direct"+ident+"=new Highcharts.Chart({";
   result+="chart:{renderTo:\'directs"+ident+"\'},";
   result+="title:{text:\'Profit by line direction.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:['Down','Equal','Up']},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'column',color:\'#00AA00\',name:\'Long\',data:[";
   double sum=0;
   for(int i=0;i<total;i++)
      sum+=Long_Profit[i,0];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<total;i++)
      sum+=Long_Profit[i,1];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<total;i++)
      sum+=Long_Profit[i,2];
   result+=DoubleToString(sum,2)+"]},";
   result+="{type:'column',color:\'#DD0202\',name:\'Short\',data:[";
   sum=0;
   for(int i=0;i<total;i++)
      sum+=Short_Profit[i,0];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<total;i++)
      sum+=Short_Profit[i,1];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<total;i++)
      sum+=Short_Profit[i,2];
   result+=DoubleToString(sum,2);
   result+="]}]});\n";
   //---
   for(int d=0;d<3;d++)
     {
      string add=NULL;
      switch(d)
        {
         case 0:
           add="down";
           break;
         case 1:
           add="equal";
           break;
         case 2:
           add="up";
           break;
        }
      result+="var value_"+add+ident+"=new Highcharts.Chart({";
      result+="chart:{renderTo:\'values_"+add+ident+"\',zoomType: 'x'},";
      result+="title:{text:\'Profit to values by "+add+" line direct.\'},";
      result+="yAxis:{title:{text:\'Profit\'}},";
      result+="xAxis:{categories:["+DoubleToString(Value[0],digits);
      for(int i=1;i<total;i++)
         result+=","+DoubleToString(Value[i],digits);
      result+="]},";
      result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
      result+="series:[{type:'spline',color:\'#00AA00\',name:\'Long\',data:["+DoubleToString(Long_Profit[0,d],2);
      for(int i=1;i<total;i++)
         result+=","+DoubleToString(Long_Profit[i,d],2);
      result+="]},";
      result+="{type:'spline',color:\'#DD0202\',name:\'Short\',data:["+DoubleToString(Short_Profit[0,d],2);
      for(int i=1;i<total;i++)
         result+=","+DoubleToString(Short_Profit[i,d],2);
      result+="]}]});\n";
   
     }
   
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CStaticOneBuffer::HTML_body(void)
  {
   int handle=DataArray.GetIndyHandle();
   if(handle<0)
      return NULL;
   
   string ident=IntegerToString(handle);
   string result="<table border=0 cellspacing=0><tr><td><div id=\"title"+ident+"\" style=\"width:1200px; height:40px; margin:0 auto\"></div></td></tr></table>";
   result+="<table border=0 cellspacing=0><tr><td><div id=\"values"+ident+"\" style=\"width:800px; height:300px; margin:0 auto\"></div></td>";
   result+="<td><div id=\"directs"+ident+"\" style=\"width:400px; height:300px; margin:0 auto\"></div></td>";
   result+="</tr></table>";
   result+="<table border=0 cellspacing=0><tr><td><div id=\"values_down"+ident+"\" style=\"width:400px; height:300px; margin:0 auto\"></div></td>";
   result+="<td><div id=\"values_equal"+ident+"\" style=\"width:400px; height:300px; margin:0 auto\"></div></td>";
   result+="<td><div id=\"values_up"+ident+"\" style=\"width:400px; height:300px; margin:0 auto\"></div></td>";
   result+="</tr></table>";
   
   return result;
  }
//+------------------------------------------------------------------+
