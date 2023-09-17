//+------------------------------------------------------------------+
//|                                                   StaticMACD.mqh |
//|                                              Copyright 2017, DNG |
//|                                 http://www.mql5.com/ru/users/dng |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, DNG"
#property link      "http://www.mql5.com/ru/users/dng"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "MACD.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CStaticMACD  :  CObject
  {
private:
   CMACD            *DataArray;
   
   double            d_Step;                 //Step in values Array
   double            Value[];                //Array of values
   double            SignalValue[];                //Array of values
   double            Long_Profit[][3][3];          //Array of long trades profit, direct -> DOWN-0, EQUAL-1, UP-2
   double            Short_Profit[][3][3];         //Array of short trades profit, direct -> DOWN-0, EQUAL-1, UP-2
   double            Signal_Long_Profit[][3];          //Array of long trades profit, direct -> DOWN-0, EQUAL-1, UP-2
   double            Signal_Short_Profit[][3];         //Array of short trades profit, direct -> DOWN-0, EQUAL-1, UP-2
   
   bool              AdValues(double main_value, double main_dinamic, double signal_value, double signal_dinamic, double profit, ENUM_POSITION_TYPE type);
   int               GetIndex(double value);
   int               GetSignalIndex(double value);
   bool              Sort(void);
   
public:
                     CStaticMACD(CMACD *data, double step);
                    ~CStaticMACD();
   bool              Ad(long ticket, double profit, ENUM_POSITION_TYPE type);
   string            HTML_header(void);
   string            HTML_body(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStaticMACD::CStaticMACD(CMACD *data,double step)
  {
   DataArray   =  data;
   d_Step      =  step;
   ArrayFree(Value);
   ArrayFree(Long_Profit);
   ArrayFree(Short_Profit);
   //ArrayInitialize(Direct_Long_Profit,0);
   //ArrayInitialize(Direct_Short_Profit,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStaticMACD::~CStaticMACD()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStaticMACD::Ad(long ticket,double profit,ENUM_POSITION_TYPE type)
  {
   if(CheckPointer(DataArray)==POINTER_INVALID)
      return false;

   double main_value,main_dinamic,signal_value,signal_dinamic;
   if(!DataArray.GetValues(ticket,main_value,main_dinamic,signal_value,signal_dinamic))
      return false;
   main_value = NormalizeDouble(main_value/d_Step,0)*d_Step;
   signal_value = NormalizeDouble(signal_value/d_Step,0)*d_Step;
   return AdValues(main_value,main_dinamic,signal_value,signal_dinamic,profit,type);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStaticMACD::AdValues(double main_value,double main_dinamic,double signal_value,double signal_dinamic,double profit,ENUM_POSITION_TYPE type)
  {
   int index=GetIndex(main_value);
   if(index<0)
      return false;
   
   int signal_i=(main_value<signal_value ? 0 :(main_value>signal_value ? 2 : 1));
   switch(type)
     {
      case POSITION_TYPE_BUY:
        if(main_dinamic<1)
           Long_Profit[index,0,signal_i]+=profit;
        else
           if(main_dinamic==1)
              Long_Profit[index,1,signal_i]+=profit;
           else
              Long_Profit[index,2,signal_i]+=profit;
        break;
      case POSITION_TYPE_SELL:
        if(main_dinamic<1)
           Short_Profit[index,0,signal_i]+=profit;
        else
           if(main_dinamic==1)
              Short_Profit[index,1,signal_i]+=profit;
           else
              Short_Profit[index,2,signal_i]+=profit;
        break;
     }
   
   index=GetSignalIndex(signal_value);
   if(index<0)
      return false;
   
   switch(type)
     {
      case POSITION_TYPE_BUY:
        if(signal_dinamic<1)
           Signal_Long_Profit[index,0]+=profit;
        else
           if(signal_dinamic==1)
              Signal_Long_Profit[index,1]+=profit;
           else
              Signal_Long_Profit[index,2]+=profit;
        break;
      case POSITION_TYPE_SELL:
        if(signal_dinamic<1)
           Signal_Short_Profit[index,0]+=profit;
        else
           if(signal_dinamic==1)
              Signal_Short_Profit[index,1]+=profit;
           else
              Signal_Short_Profit[index,2]+=profit;
        break;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CStaticMACD::GetIndex(double value)
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
         for(int c=0;c<3;c++)
            Long_Profit[total,i,c]   =  Short_Profit[total,i,c]  =  0;
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CStaticMACD::GetSignalIndex(double value)
  {
   int result=-1;
   int total=ArraySize(SignalValue);
   for(int i=0;i<total;i++)
     {
      if(SignalValue[i]==value)
        {
         result=i;
         break;
        }
     }
   if(result<0)
     {
      if(ArrayResize(SignalValue,total+1)<0)
         return result;
      if(ArrayResize(Signal_Long_Profit,total+1)<0 || ArrayResize(Signal_Short_Profit,total+1)<0)
        {
         ArrayResize(SignalValue,total);
         return result;
        }
      result               =  total;
      SignalValue[total]   =  value;
      for(int i=0;i<3;i++)
         Signal_Long_Profit[total,i]   =  Signal_Short_Profit[total,i]  =  0;
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStaticMACD::Sort(void)
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
               for(int c=0;c<3;c++)
                 {
                  temp                 =  Long_Profit[i,j,c];
                  Long_Profit[i,j,c]     =  Long_Profit[i+1,j,c];
                  Long_Profit[i+1,j,c]   =  temp;
                  temp                 =  Short_Profit[i,j,c];
                  Short_Profit[i,j,c]    =  Short_Profit[i+1,j,c];
                  Short_Profit[i+1,j,c]  =  temp;
                 }
            found             =  true;
           }
        }
     }
   while(found);
   //---
   total=ArraySize(SignalValue);
   do
     {
      found =  false;
      for(int i=0;i<total-1;i++)
        {
         if(SignalValue[i]>SignalValue[i+1])
           {
            double temp       =  SignalValue[i];
            SignalValue[i]    =  SignalValue[i+1];
            SignalValue[i+1]  =  temp;
            for(int j=0;j<3;j++)
              {
               temp                        =  Signal_Long_Profit[i,j];
               Signal_Long_Profit[i,j]     =  Signal_Long_Profit[i+1,j];
               Signal_Long_Profit[i+1,j]   =  temp;
               temp                        =  Signal_Short_Profit[i,j];
               Signal_Short_Profit[i,j]    =  Signal_Short_Profit[i+1,j];
               Signal_Short_Profit[i+1,j]  =  temp;
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
string CStaticMACD::HTML_header(void)
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
   result+="title:{text:\'Profit to main values.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:["+DoubleToString(Value[0],digits);
   for(int i=1;i<total;i++)
      result+=","+DoubleToString(Value[i],digits);
   result+="]},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'spline',color:\'#00AA00\',name:\'Long\',data:[";
   for(int i=0;i<total;i++)
     {
      if(i!=0)
         result+=",";
      double sum=0;
      for(int c=0;c<3;c++)
         sum+=Long_Profit[i,0,c]+Long_Profit[i,1,c]+Long_Profit[i,2,c];
      result+=DoubleToString(sum,2);
     }
   result+="]},";
   result+="{type:'spline',color:\'#DD0202\',name:\'Short\',data:[";
   for(int i=0;i<total;i++)
     {
      if(i!=0)
         result+=",";
      double sum=0;
      for(int c=0;c<3;c++)
         sum+=Short_Profit[i,0,c]+Short_Profit[i,1,c]+Short_Profit[i,2,c];
      result+=DoubleToString(sum,2);
     }
   result+="]}]});\n";
   //---
   result+="var direct"+ident+"=new Highcharts.Chart({";
   result+="chart:{renderTo:\'directs"+ident+"\'},";
   result+="title:{text:\'Profit by main histogram direction.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:['Down','Equal','Up']},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'column',color:\'#00AA00\',name:\'Long\',data:[";
   double sum=0;
   for(int i=0;i<total;i++)
      for(int c=0;c<3;c++)
         sum+=Long_Profit[i,0,c];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<total;i++)
      for(int c=0;c<3;c++)
         sum+=Long_Profit[i,1,c];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<total;i++)
      for(int c=0;c<3;c++)
         sum+=Long_Profit[i,2,c];
   result+=DoubleToString(sum,2)+"]},";
   result+="{type:'column',color:\'#DD0202\',name:\'Short\',data:[";
   sum=0;
   for(int i=0;i<total;i++)
      for(int c=0;c<3;c++)
         sum+=Short_Profit[i,0,c];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<total;i++)
      for(int c=0;c<3;c++)
         sum+=Short_Profit[i,1,c];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<total;i++)
      for(int c=0;c<3;c++)
         sum+=Short_Profit[i,2,c];
   result+=DoubleToString(sum,2);
   result+="]}]});\n";
   //---
   result+="var sig_value"+ident+"=new Highcharts.Chart({";
   result+="chart:{renderTo:\'sig_values"+ident+"\',zoomType: 'x'},";
   result+="title:{text:\'Profit to signal values.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:["+DoubleToString(SignalValue[0],digits);
   int total_sig=ArraySize(SignalValue);
   for(int i=1;i<total_sig;i++)
      result+=","+DoubleToString(SignalValue[i],digits);
   result+="]},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'spline',color:\'#00AA00\',name:\'Long\',data:[";
   for(int i=0;i<total_sig;i++)
     {
      if(i!=0)
         result+=",";
      sum=Signal_Long_Profit[i,0]+Signal_Long_Profit[i,1]+Signal_Long_Profit[i,2];
      result+=DoubleToString(sum,2);
     }
   result+="]},";
   result+="{type:'spline',color:\'#DD0202\',name:\'Short\',data:[";
   for(int i=0;i<total_sig;i++)
     {
      if(i!=0)
         result+=",";
      sum=Signal_Short_Profit[i,0]+Signal_Short_Profit[i,1]+Signal_Short_Profit[i,2];
      result+=DoubleToString(sum,2);
     }
   result+="]}]});\n";
   //---
   result+="var sig_direct"+ident+"=new Highcharts.Chart({";
   result+="chart:{renderTo:\'sig_directs"+ident+"\'},";
   result+="title:{text:\'Profit by signal line direction.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:['Down','Equal','Up']},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'column',color:\'#00AA00\',name:\'Long\',data:[";
   sum=0;
   for(int i=0;i<total_sig;i++)
      sum+=Signal_Long_Profit[i,0];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<total_sig;i++)
      sum+=Signal_Long_Profit[i,1];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<total_sig;i++)
      sum+=Signal_Long_Profit[i,2];
   result+=DoubleToString(sum,2)+"]},";
   result+="{type:'column',color:\'#DD0202\',name:\'Short\',data:[";
   sum=0;
   for(int i=0;i<total_sig;i++)
      sum+=Signal_Short_Profit[i,0];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<total_sig;i++)
      sum+=Signal_Short_Profit[i,1];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<total_sig;i++)
      sum+=Signal_Short_Profit[i,2];
   result+=DoubleToString(sum,2);
   result+="]}]});\n";
   //---
   result+="var sign"+ident+"=new Highcharts.Chart({";
   result+="chart:{renderTo:\'signals"+ident+"\'},";
   result+="title:{text:\'Profit by signal deviation.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:['Lower','Equal','Upper']},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'column',color:\'#00AA00\',name:\'Long\',data:[";
   sum=0;
   for(int i=0;i<total;i++)
      for(int d=0;d<3;d++)
         sum+=Long_Profit[i,d,0];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<total;i++)
      for(int d=0;d<3;d++)
         sum+=Long_Profit[i,d,1];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<total;i++)
      for(int d=0;d<3;d++)
         sum+=Long_Profit[i,d,2];
   result+=DoubleToString(sum,2)+"]},";
   result+="{type:'column',color:\'#DD0202\',name:\'Short\',data:[";
   sum=0;
   for(int i=0;i<total;i++)
      for(int d=0;d<3;d++)
         sum+=Short_Profit[i,d,0];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<total;i++)
      for(int d=0;d<3;d++)
         sum+=Short_Profit[i,d,1];
   result+=DoubleToString(sum,2)+",";
   sum=0;
   for(int i=0;i<total;i++)
      for(int d=0;d<3;d++)
         sum+=Short_Profit[i,d,2];
   result+=DoubleToString(sum,2);
   result+="]}]});\n";
   //---
   for(int c=0;c<3;c++)
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
      string dev=NULL;
      switch(c)
        {
         case 0:
           dev="lower";
           break;
         case 1:
           dev="equal";
           break;
         case 2:
           dev="upper";
           break;
        }
      result+="var value_c"+(string)c+add+ident+"=new Highcharts.Chart({";
      result+="chart:{renderTo:\'values_col_"+(string)c+add+ident+"\',zoomType: 'x'},";
      result+="title:{text:\'Profit to main values by "+add+" histogram direct. Signal line "+dev+"\'},";
      result+="yAxis:{title:{text:\'Profit\'}},";
      result+="xAxis:{categories:["+DoubleToString(Value[0],digits);
      for(int i=1;i<total;i++)
         result+=","+DoubleToString(Value[i],digits);
      result+="]},";
      result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
      result+="series:[{type:'spline',color:\'#00AA00\',name:\'Long\',data:[";
      for(int i=0;i<total;i++)
        {
         if(i!=0)
            result+=",";
         sum=Long_Profit[i,d,c];
         result+=DoubleToString(sum,2);
        }
      result+="]},";
      result+="{type:'spline',color:\'#DD0202\',name:\'Short\',data:[";
      for(int i=0;i<total;i++)
        {
         if(i!=0)
            result+=",";
         sum=Short_Profit[i,d,c];
         result+=DoubleToString(sum,2);
        }
      result+="]}]});\n";
     }
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
      result+="title:{text:\'Profit to main values by "+add+" hidtogram direct.\'},";
      result+="yAxis:{title:{text:\'Profit\'}},";
      result+="xAxis:{categories:["+DoubleToString(Value[0],digits);
      for(int i=1;i<total;i++)
         result+=","+DoubleToString(Value[i],digits);
      result+="]},";
      result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
      result+="series:[{type:'spline',color:\'#00AA00\',name:\'Long\',data:[";
      for(int i=0;i<total;i++)
        {
         if(i!=0)
            result+=",";
         sum=0;
         for(int c=0;c<3;c++)
            sum+=Long_Profit[i,d,c];
         result+=DoubleToString(sum,2);
        }
      result+="]},";
      result+="{type:'spline',color:\'#DD0202\',name:\'Short\',data:[";
      for(int i=0;i<total;i++)
        {
         if(i!=0)
            result+=",";
         sum=0;
         for(int c=0;c<3;c++)
            sum+=Short_Profit[i,d,c];
         result+=DoubleToString(sum,2);
        }
      result+="]}]});\n";
   
     }
   
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CStaticMACD::HTML_body(void)
  {
   int handle=DataArray.GetIndyHandle();
   if(handle<0)
      return NULL;
   
   string ident=IntegerToString(handle);
   string result="<table border=0 cellspacing=0><tr><td><div id=\"title"+ident+"\" style=\"width:1200px; height:40px; margin:0 auto\"></div></td></tr></table>";
   result+="<table border=0 cellspacing=0><tr><td><div id=\"values"+ident+"\" style=\"width:700px; height:300px; margin:0 auto\"></div></td>";
   result+="<td><div id=\"directs"+ident+"\" style=\"width:250px; height:300px; margin:0 auto\"></div></td>";
   result+="<td><div id=\"signals"+ident+"\" style=\"width:250px; height:300px; margin:0 auto\"></div></td>";
   result+="</tr></table>";
   result+="<table border=0 cellspacing=0><tr><td><div id=\"sig_values"+ident+"\" style=\"width:800px; height:300px; margin:0 auto\"></div></td>";
   result+="<td><div id=\"sig_directs"+ident+"\" style=\"width:400px; height:300px; margin:0 auto\"></div></td>";
   result+="</tr></table>";
   result+="<table border=0 cellspacing=0><tr><td><div id=\"values_down"+ident+"\" style=\"width:400px; height:300px; margin:0 auto\"></div></td>";
   result+="<td><div id=\"values_equal"+ident+"\" style=\"width:400px; height:300px; margin:0 auto\"></div></td>";
   result+="<td><div id=\"values_up"+ident+"\" style=\"width:400px; height:300px; margin:0 auto\"></div></td>";
   result+="</tr></table>";
   result+="<table border=0 cellspacing=0>";
   for(int i=0;i<3;i++)
     {
      result+="<tr><td><div id=\"values_col_"+(string)i+"down"+ident+"\" style=\"width:400px; height:300px; margin:0 auto\"></div></td>";
      result+="<td><div id=\"values_col_"+(string)i+"equal"+ident+"\" style=\"width:400px; height:300px; margin:0 auto\"></div></td>";
      result+="<td><div id=\"values_col_"+(string)i+"up"+ident+"\" style=\"width:400px; height:300px; margin:0 auto\"></div></td>";
      result+="</tr>";
     }
   result+="</table>";
   
   return result;
  }
//+------------------------------------------------------------------+
