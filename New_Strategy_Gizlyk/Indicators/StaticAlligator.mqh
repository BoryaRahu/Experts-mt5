//+------------------------------------------------------------------+
//|                                                    StaticAlligator.mqh |
//|                                              Copyright 2017, DNG |
//|                                 http://www.mql5.com/ru/users/dng |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, DNG"
#property link      "http://www.mql5.com/ru/users/dng"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "Alligator.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CStaticAlligator  :  CObject
  {
private:
   CAlligator             *DataArray;
   
   double            Long_Profit[3]/*Signal*/[3]/*JAW direct*/[3]/*TEETH direct*/[3]/*LIPS direct*/;  //Array of long deals profit
   double            Short_Profit[3]/*Signal*/[3]/*JAW direct*/[3]/*TEETH direct*/[3]/*LIPS direct*/; //Array of short feals profit
   
   bool              AdValues(double jaw_value, double jaw_dinamic, double teeth_value, double teeth_dinamic, double lips_value, double lips_dinamic, double profit, ENUM_POSITION_TYPE type);
   
public:
                     CStaticAlligator(CAlligator *data);
                    ~CStaticAlligator();
   bool              Ad(long ticket, double profit, ENUM_POSITION_TYPE type);
   string            HTML_header(void);
   string            HTML_body(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStaticAlligator::CStaticAlligator(CAlligator *data)
  {
   DataArray   =  data;
   ArrayInitialize(Long_Profit,0);
   ArrayInitialize(Short_Profit,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CStaticAlligator::~CStaticAlligator()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStaticAlligator::Ad(long ticket,double profit,ENUM_POSITION_TYPE type)
  {
   if(CheckPointer(DataArray)==POINTER_INVALID)
      return false;

   double jaw_value,jaw_dinamic,teeth_value,teeth_dinamic,lips_value,lips_dinamic;
   if(!DataArray.GetValues(ticket,jaw_value,jaw_dinamic,teeth_value,teeth_dinamic,lips_value,lips_dinamic))
      return false;
   return AdValues(jaw_value,jaw_dinamic,teeth_value,teeth_dinamic,lips_value,lips_dinamic,profit,type);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CStaticAlligator::AdValues(double jaw_value,double jaw_dinamic,double teeth_value,double teeth_dinamic,double lips_value,double lips_dinamic,double profit,ENUM_POSITION_TYPE type)
  {
   
   int signal=((jaw_value>=teeth_value && teeth_value>lips_value) ? 0/*sell*/ :((jaw_value<=teeth_value && teeth_value<lips_value) ? 2/*buy*/ : 1/*flat*/));
   int jaw_direct=(jaw_dinamic<1 ? 0 :(jaw_dinamic>1 ? 2 : 1));
   int teeth_direct=(teeth_dinamic<1 ? 0 :(teeth_dinamic>1 ? 2 : 1));
   int lips_direct=(lips_dinamic<1 ? 0 :(lips_dinamic>1 ? 2 : 1));
   switch(type)
     {
      case POSITION_TYPE_BUY:
        Long_Profit[signal,jaw_direct,teeth_direct,lips_direct]+=profit;
        break;
      case POSITION_TYPE_SELL:
        Short_Profit[signal,jaw_direct,teeth_direct,lips_direct]+=profit;
        break;
     }
   //---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CStaticAlligator::HTML_header(void)
  {
   int handle=DataArray.GetIndyHandle();
   if(handle<0)
      return NULL;
   
   string ident=IntegerToString(handle);
   //---
   string result="var tit"+ident+"=new Highcharts.Chart({chart:{renderTo:'title"+ident+"',borderWidth:0,shadow:false,backgroundColor:{linearGradient:[0,0,500,500],\n";
   result+="stops:[[0,'rgb(251,252,255)'],[1,'rgb(223,227,252)']]}}, title:{style:{color:'#405A75',font:'normal 25px \"Trebuchet MS\",Verdana,Tahoma,Arial,Helvetica,sans-serif'},";
   result+="align:'center',text:'"+DataArray.GetName()+"'}});";
   result+="var signal"+ident+"=new Highcharts.Chart({";
   result+="chart:{renderTo:\'signals"+ident+"\'},";
   result+="title:{text:\'Profit to indicator\\'s signal.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:['Buy','Flat','Sell']},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'column',color:\'#00AA00\',name:\'Long\',data:[";
   for(int i=0;i<3;i++)
     {
      double sum=0;
      if(i!=0)
         result+=",";
      for(int jaw=0;jaw<3;jaw++)
         for(int teeth=0;teeth<3;teeth++)
            for(int lips=0;lips<3;lips++)
               sum+=Long_Profit[i,jaw,teeth,lips];
      result+=DoubleToString(sum,2);
     }
   result+="]},";
   result+="{type:'column',color:\'#DD0202\',name:\'Short\',data:[";
   for(int i=0;i<3;i++)
     {
      double sum=0;
      if(i!=0)
         result+=",";
      for(int jaw=0;jaw<3;jaw++)
         for(int teeth=0;teeth<3;teeth++)
            for(int lips=0;lips<3;lips++)
               sum+=Short_Profit[i,jaw,teeth,lips];
      result+=DoubleToString(sum,2);
     }
   result+="]}]});\n";
   //---
   result+="var jawdirect"+ident+"=new Highcharts.Chart({";
   result+="chart:{renderTo:\'jaw_directs"+ident+"\'},";
   result+="title:{text:\'Profit by JAW line direction.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:['Down','Equal','Up']},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'column',color:\'#00AA00\',name:\'Long\',data:[";
   for(int i=0;i<3;i++)
     {
      double sum=0;
      if(i!=0)
         result+=",";
      for(int signal=0;signal<3;signal++)
         for(int teeth=0;teeth<3;teeth++)
            for(int lips=0;lips<3;lips++)
               sum+=Long_Profit[signal,i,teeth,lips];
      result+=DoubleToString(sum,2);
     }
   result+="]},";
   result+="{type:'column',color:\'#DD0202\',name:\'Short\',data:[";
   for(int i=0;i<3;i++)
     {
      double sum=0;
      if(i!=0)
         result+=",";
      for(int signal=0;signal<3;signal++)
         for(int teeth=0;teeth<3;teeth++)
            for(int lips=0;lips<3;lips++)
               sum+=Short_Profit[signal,i,teeth,lips];
      result+=DoubleToString(sum,2);
     }
   result+="]}]});\n";
   //---
   result+="var teethdirect"+ident+"=new Highcharts.Chart({";
   result+="chart:{renderTo:\'teeth_directs"+ident+"\'},";
   result+="title:{text:\'Profit by TEETH line direction.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:['Down','Equal','Up']},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'column',color:\'#00AA00\',name:\'Long\',data:[";
   for(int i=0;i<3;i++)
     {
      double sum=0;
      if(i!=0)
         result+=",";
      for(int signal=0;signal<3;signal++)
         for(int jaw=0;jaw<3;jaw++)
            for(int lips=0;lips<3;lips++)
               sum+=Long_Profit[signal,jaw,i,lips];
      result+=DoubleToString(sum,2);
     }
   result+="]},";
   result+="{type:'column',color:\'#DD0202\',name:\'Short\',data:[";
   for(int i=0;i<3;i++)
     {
      double sum=0;
      if(i!=0)
         result+=",";
      for(int signal=0;signal<3;signal++)
         for(int jaw=0;jaw<3;jaw++)
            for(int lips=0;lips<3;lips++)
               sum+=Short_Profit[signal,jaw,i,lips];
      result+=DoubleToString(sum,2);
     }
   result+="]}]});\n";
   //---
   result+="var lipsdirect"+ident+"=new Highcharts.Chart({";
   result+="chart:{renderTo:\'lips_directs"+ident+"\'},";
   result+="title:{text:\'Profit by LIPS line direction.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:['Down','Equal','Up']},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'column',color:\'#00AA00\',name:\'Long\',data:[";
   for(int i=0;i<3;i++)
     {
      double sum=0;
      if(i!=0)
         result+=",";
      for(int signal=0;signal<3;signal++)
         for(int jaw=0;jaw<3;jaw++)
            for(int teeth=0;teeth<3;teeth++)
               sum+=Long_Profit[signal,jaw,teeth,i];
      result+=DoubleToString(sum,2);
     }
   result+="]},";
   result+="{type:'column',color:\'#DD0202\',name:\'Short\',data:[";
   for(int i=0;i<3;i++)
     {
      double sum=0;
      if(i!=0)
         result+=",";
      for(int signal=0;signal<3;signal++)
         for(int jaw=0;jaw<3;jaw++)
            for(int teeth=0;teeth<3;teeth++)
               sum+=Short_Profit[signal,jaw,teeth,i];
      result+=DoubleToString(sum,2);
     }
   result+="]}]});\n";
   //---
   result+="var comb_s"+ident+"=new Highcharts.Chart({";
   result+="chart:{renderTo:\'combi_sell"+ident+"\'},";
   result+="title:{text:\'Profit by combination of lines direction.\'},subtitle:{text:\'Signal SELL.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:['Lips Down Teeth Down Jaw Down','Lips Flat Teeth Down Jaw Down','Lips Up Teeth Down Jaw Down',";
   result+="'Lips Down Teeth Flat Jaw Down','Lips Flat Teeth Flat Jaw Down','Lips Up Teeth Flat Jaw Down',";
   result+="'Lips Down Teeth Up Jaw Down','Lips Flat Teeth Up Jaw Down','Lips Up Teeth Up Jaw Down',";
   result+="'Lips Down Teeth Down Jaw Flat','Lips Flat Teeth Down Jaw Flat','Lips Up Teeth Down Jaw Flat',";
   result+="'Lips Down Teeth Flat Jaw Flat','Lips Flat Teeth Flat Jaw Flat','Lips Up Teeth Flat Jaw Flat',";
   result+="'Lips Down Teeth Up Jaw Flat','Lips Flat Teeth Up Jaw Flat','Lips Up Teeth Up Jaw Flat',";
   result+="'Lips Down Teeth Down Jaw Up','Lips Flat Teeth Down Jaw Up','Lips Up Teeth Down Jaw Up',";
   result+="'Lips Down Teeth Flat Jaw Up','Lips Flat Teeth Flat Jaw Up','Lips Up Teeth Flat Jaw Up',";
   result+="'Lips Down Teeth Up Jaw Up','Lips Flat Teeth Up Jaw Up','Lips Up Teeth Up Jaw Up',";
   result+="]},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'column',color:\'#00AA00\',name:\'Long\',data:[";
   for(int jaw=0;jaw<3;jaw++)
      for(int teeth=0;teeth<3;teeth++)
         for(int lips=0;lips<3;lips++)
           {
            if(jaw!=0 || teeth!=0 || lips!=0)
               result+=",";
            result+=DoubleToString(Long_Profit[0,jaw,teeth,lips],2);
           }
   result+="]},";
   result+="{type:'column',color:\'#DD0202\',name:\'Short\',data:[";
   for(int jaw=0;jaw<3;jaw++)
      for(int teeth=0;teeth<3;teeth++)
         for(int lips=0;lips<3;lips++)
           {
            if(jaw!=0 || teeth!=0 || lips!=0)
               result+=",";
            result+=DoubleToString(Short_Profit[0,jaw,teeth,lips],2);
           }
   result+="]}]});\n";
   //---
   result+="var comb_f"+ident+"=new Highcharts.Chart({";
   result+="chart:{renderTo:\'combi_flat"+ident+"\'},";
   result+="title:{text:\'Profit by combination of lines direction.\'},subtitle:{text:\'Signal FLAT.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:['Lips Down Teeth Down Jaw Down','Lips Flat Teeth Down Jaw Down','Lips Up Teeth Down Jaw Down',";
   result+="'Lips Down Teeth Flat Jaw Down','Lips Flat Teeth Flat Jaw Down','Lips Up Teeth Flat Jaw Down',";
   result+="'Lips Down Teeth Up Jaw Down','Lips Flat Teeth Up Jaw Down','Lips Up Teeth Up Jaw Down',";
   result+="'Lips Down Teeth Down Jaw Flat','Lips Flat Teeth Down Jaw Flat','Lips Up Teeth Down Jaw Flat',";
   result+="'Lips Down Teeth Flat Jaw Flat','Lips Flat Teeth Flat Jaw Flat','Lips Up Teeth Flat Jaw Flat',";
   result+="'Lips Down Teeth Up Jaw Flat','Lips Flat Teeth Up Jaw Flat','Lips Up Teeth Up Jaw Flat',";
   result+="'Lips Down Teeth Down Jaw Up','Lips Flat Teeth Down Jaw Up','Lips Up Teeth Down Jaw Up',";
   result+="'Lips Down Teeth Flat Jaw Up','Lips Flat Teeth Flat Jaw Up','Lips Up Teeth Flat Jaw Up',";
   result+="'Lips Down Teeth Up Jaw Up','Lips Flat Teeth Up Jaw Up','Lips Up Teeth Up Jaw Up',";
   result+="]},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'column',color:\'#00AA00\',name:\'Long\',data:[";
   for(int jaw=0;jaw<3;jaw++)
      for(int teeth=0;teeth<3;teeth++)
         for(int lips=0;lips<3;lips++)
           {
            if(jaw!=0 || teeth!=0 || lips!=0)
               result+=",";
            result+=DoubleToString(Long_Profit[1,jaw,teeth,lips],2);
           }
   result+="]},";
   result+="{type:'column',color:\'#DD0202\',name:\'Short\',data:[";
   for(int jaw=0;jaw<3;jaw++)
      for(int teeth=0;teeth<3;teeth++)
         for(int lips=0;lips<3;lips++)
           {
            if(jaw!=0 || teeth!=0 || lips!=0)
               result+=",";
            result+=DoubleToString(Short_Profit[1,jaw,teeth,lips],2);
           }
   result+="]}]});\n";
   //---
   result+="var comb_b"+ident+"=new Highcharts.Chart({";
   result+="chart:{renderTo:\'combi_buy"+ident+"\'},";
   result+="title:{text:\'Profit by combination of lines direction.\'},subtitle:{text:\'Signal BUY.\'},";
   result+="yAxis:{title:{text:\'Profit\'}},";
   result+="xAxis:{categories:['Lips Down Teeth Down Jaw Down','Lips Flat Teeth Down Jaw Down','Lips Up Teeth Down Jaw Down',";
   result+="'Lips Down Teeth Flat Jaw Down','Lips Flat Teeth Flat Jaw Down','Lips Up Teeth Flat Jaw Down',";
   result+="'Lips Down Teeth Up Jaw Down','Lips Flat Teeth Up Jaw Down','Lips Up Teeth Up Jaw Down',";
   result+="'Lips Down Teeth Down Jaw Flat','Lips Flat Teeth Down Jaw Flat','Lips Up Teeth Down Jaw Flat',";
   result+="'Lips Down Teeth Flat Jaw Flat','Lips Flat Teeth Flat Jaw Flat','Lips Up Teeth Flat Jaw Flat',";
   result+="'Lips Down Teeth Up Jaw Flat','Lips Flat Teeth Up Jaw Flat','Lips Up Teeth Up Jaw Flat',";
   result+="'Lips Down Teeth Down Jaw Up','Lips Flat Teeth Down Jaw Up','Lips Up Teeth Down Jaw Up',";
   result+="'Lips Down Teeth Flat Jaw Up','Lips Flat Teeth Flat Jaw Up','Lips Up Teeth Flat Jaw Up',";
   result+="'Lips Down Teeth Up Jaw Up','Lips Flat Teeth Up Jaw Up','Lips Up Teeth Up Jaw Up',";
   result+="]},";
   result+="tooltip:{enabled:true,formatter:function(){return ('Profit: '+this.y+', at: '+this.x)}},";
   result+="series:[{type:'column',color:\'#00AA00\',name:\'Long\',data:[";
   for(int jaw=0;jaw<3;jaw++)
      for(int teeth=0;teeth<3;teeth++)
         for(int lips=0;lips<3;lips++)
           {
            if(jaw!=0 || teeth!=0 || lips!=0)
               result+=",";
            result+=DoubleToString(Long_Profit[2,jaw,teeth,lips],2);
           }
   result+="]},";
   result+="{type:'column',color:\'#DD0202\',name:\'Short\',data:[";
   for(int jaw=0;jaw<3;jaw++)
      for(int teeth=0;teeth<3;teeth++)
         for(int lips=0;lips<3;lips++)
           {
            if(jaw!=0 || teeth!=0 || lips!=0)
               result+=",";
            result+=DoubleToString(Short_Profit[2,jaw,teeth,lips],2);
           }
   result+="]}]});\n";
   //---
   
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CStaticAlligator::HTML_body(void)
  {
   int handle=DataArray.GetIndyHandle();
   if(handle<0)
      return NULL;
   
   string ident=IntegerToString(handle);
   string result="<table border=0 cellspacing=0><tr><td><div id=\"title"+ident+"\" style=\"width:1200px; height:40px; margin:0 auto\"></div></td></tr></table>";
   result+="<table border=0 cellspacing=0><tr><td><div id=\"signals"+ident+"\" style=\"width:300px; height:300px; margin:0 auto\"></div></td>";
   result+="<td><div id=\"jaw_directs"+ident+"\" style=\"width:300px; height:300px; margin:0 auto\"></div></td>";
   result+="<td><div id=\"teeth_directs"+ident+"\" style=\"width:300px; height:300px; margin:0 auto\"></div></td>";
   result+="<td><div id=\"lips_directs"+ident+"\" style=\"width:300px; height:300px; margin:0 auto\"></div></td>";
   result+="</tr></table>";
   result+="<table border=0 cellspacing=0><tr>";
   result+="<td><div id=\"combi_sell"+ident+"\" style=\"width:1200px; height:300px; margin:0 auto\"></div></td>";
   result+="</tr>";
   result+="<td><div id=\"combi_flat"+ident+"\" style=\"width:1200px; height:300px; margin:0 auto\"></div></td>";
   result+="</tr>";
   result+="<td><div id=\"combi_buy"+ident+"\" style=\"width:1200px; height:300px; margin:0 auto\"></div></td>";
   result+="</tr></table>";
   
   return result;
  }
//+------------------------------------------------------------------+
