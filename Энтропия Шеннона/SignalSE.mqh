//+------------------------------------------------------------------+
//|                                                     SignalSE.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
//
#define  __INPUTS 4
int      __SIGNALS[__INPUTS]={5,8,13,21};
#define  __RULES 23
//
#include <Math\Fuzzy\MamdaniFuzzySystem.mqh>
#include <Math\Stat\Uniform.mqh>
#include <Math\Alglib\dataanalysis.mqh>                                                      //Use Decsion Forest lib
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals of'Shannon Entropy'                                |
//| Type=SignalAdvanced                                              |
//| Name=Shannon Entropy                                             |
//| ShortName=SE                                                     |
//| Class=CSignalSE                                                  |
//| Page=signal_se                                                   |
//| Parameter=Reset,bool,false,Reset Training                        |
//| Parameter=Trees,int,50,Trees number                              |
//| Parameter=Regularization,double,0.15,Regularization Threshold    |
//| Parameter=Trainings,int,21,Trainings number                      |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalSE.                                                 |
//| Purpose: Class of generator of trade signals based on            |
//|          the 'Shannon Entropy' signals.                          |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+
class CSignalSE : public CExpertSignal
   {
      public:
         
         //Decision Forest objects.
         CDecisionForest               DF;                                                   //Decision Forest
         CMatrixDouble                 DF_SIGNAL;                                            //Decision Forest Matrix for inputs and output
         CDFReport                     DF_REPORT;                                            //Decision Forest Report for results
         int                           DF_INFO;                                              //Decision Forest feedback

         double                        m_out_calculations[2], m_in_calculations[__INPUTS];   //Decision Forest calculation arrays

         //--- adjusted parameters
         bool                          m_reset;
         int                           m_trees;
         double                        m_regularization;
         int                           m_trainings;
         //--- methods of setting adjustable parameters
         void                          Reset(bool value){ m_reset=value; }
         void                          Trees(int value){ m_trees=value; }
         void                          Regularization(double value){ m_regularization=value; }
         void                          Trainings(int value){ m_trainings=value; }
         
         //Decision Forest FUZZY system objects
         CMamdaniFuzzySystem           *m_fuzzy;
         
         CFuzzyVariable                *m_in_variables[__INPUTS];
         CFuzzyVariable                *m_out_variable;

         CDictionary_Obj_Double        *m_in_text[__INPUTS];
         CDictionary_Obj_Double        *m_out_text;

         CMamdaniFuzzyRule             *m_rule[__RULES];
         CList                         *m_in_list;

         double                        m_signals[][__INPUTS];
         
         CNormalMembershipFunction     *m_update;
         
         datetime                      m_last_time;
         double                        m_last_signal;
         double                        m_last_condition;

                                       CSignalSE(void);
                                       ~CSignalSE(void);
         //--- method of verification of settings
         virtual bool                  ValidationSettings(void);
         //--- method of creating the indicator and timeseries
         virtual bool                  InitIndicators(CIndicators *indicators);
         //--- methods of checking if the market models are formed
         virtual int                   LongCondition(void);
         virtual int                   ShortCondition(void);

         bool                          m_random;
         bool                          m_read_forest;
         int                           m_samples;

         //--- method of initialization of the oscillator
         bool                          InitSE(CIndicators *indicators);
         
         double                        Data(int Index){ return(Close(StartIndex()+Index)-Close(StartIndex()+Index+1)); }
         
         void                          ReadForest();
         void                          WriteForest();
         
         void                          SignalUpdate(double Signal);
         void                          ResultUpdate(double Result);
         
         double                        Signal(void);
         double                        Result(void);
         
         bool                          IsNewBar(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalSE::CSignalSE(void)             :  m_random(true), 
                                          m_reset(false), 
                                          m_read_forest(false),
                                          m_samples(0),
                                          m_regularization(0.15),
                                          m_trainings(21),
                                          m_last_time(0)
   {
      //--- initialization of protected data
      m_used_series=USE_SERIES_HIGH+USE_SERIES_LOW+USE_SERIES_CLOSE;
      
      m_fuzzy=new CMamdaniFuzzySystem();
      
      //m_fuzzy.
      
      for(int i=0;i<__INPUTS;i++)
      {
         m_in_variables[i]=new CFuzzyVariable("input_"+IntegerToString(1+i),0.0,1.0);
      }
      m_out_variable=new CFuzzyVariable("output",0.0,1.0);
      
      for(int i=0;i<__INPUTS;i++)
      {
         m_in_text[i]=new CDictionary_Obj_Double();
      }
      m_out_text=new CDictionary_Obj_Double;
      
      m_update=new CNormalMembershipFunction(0.5,m_regularization);
      
      m_in_list=new CList();
      
      for(int i=0;i<__INPUTS;i++)
      {
         m_in_variables[i].Terms().Add(new CFuzzyTerm("long", new CZ_ShapedMembershipFunction(0.0,0.5-m_regularization)));
         m_in_variables[i].Terms().Add(new CFuzzyTerm("neutral", new CNormalMembershipFunction(0.5, m_regularization)));
         m_in_variables[i].Terms().Add(new CFuzzyTerm("short", new CS_ShapedMembershipFunction(0.5+m_regularization,1.0)));
         m_fuzzy.Input().Add(m_in_variables[i]);
      }
      
      m_out_variable.Terms().Add(new CFuzzyTerm("long", new CZ_ShapedMembershipFunction(0.0,0.5-m_regularization)));
      m_out_variable.Terms().Add(new CFuzzyTerm("neutral", m_update));
      m_out_variable.Terms().Add(new CFuzzyTerm("short", new CS_ShapedMembershipFunction(0.5+m_regularization,1.0)));
      m_fuzzy.Output().Add(m_out_variable);
      
      //
      
      for(int i=0;i<__INPUTS;i++)
      {
         m_rule[i] = new CMamdaniFuzzyRule();
      }
      
      //
      
      m_rule[0] = m_fuzzy.ParseRule("if (input_1 is long) and (input_2 is long) and (input_3 is long) and (input_4 is long) then (output is long)");
      m_rule[1] = m_fuzzy.ParseRule("if (input_1 is short) and (input_2 is short) and (input_3 is short) and (input_4 is short) then (output is short)");
      m_rule[2] = m_fuzzy.ParseRule("if (input_1 is neutral) and (input_2 is neutral) and (input_3 is neutral) and (input_4 is neutral) then (output is neutral)");
      
      m_rule[3] = m_fuzzy.ParseRule("if (input_1 is long) and (input_2 is short) and (input_3 is long) and (input_4 is short) then (output is neutral)");
      m_rule[4] = m_fuzzy.ParseRule("if (input_1 is short) and (input_2 is long) and (input_3 is short) and (input_4 is long) then (output is neutral)");
      m_rule[5] = m_fuzzy.ParseRule("if (input_1 is long) and (input_2 is long) and (input_3 is short) and (input_4 is short) then (output is neutral)");
      m_rule[6] = m_fuzzy.ParseRule("if (input_1 is long) and (input_2 is long) and (input_3 is short) and (input_4 is short) then (output is neutral)");
      m_rule[7] = m_fuzzy.ParseRule("if (input_1 is short) and (input_2 is short) and (input_3 is long) and (input_4 is long) then (output is neutral)");
      m_rule[8] = m_fuzzy.ParseRule("if (input_1 is short) and (input_2 is short) and (input_3 is long) and (input_4 is long) then (output is neutral)");
      
      m_rule[9] = m_fuzzy.ParseRule("if (input_1 is long) and (input_2 is long) and (input_3 is neutral) and (input_4 is neutral) then (output is long)");
      m_rule[10] = m_fuzzy.ParseRule("if (input_1 is short) and (input_2 is short) and (input_3 is neutral) and (input_4 is neutral) then (output is short)");
      m_rule[11] = m_fuzzy.ParseRule("if (input_1 is long) and (input_2 is neutral) and (input_3 is neutral) and (input_4 is long) then (output is long)");
      m_rule[12] = m_fuzzy.ParseRule("if (input_1 is short) and (input_2 is neutral) and (input_3 is neutral) and (input_4 is short) then (output is short)");
      m_rule[13] = m_fuzzy.ParseRule("if (input_1 is neutral) and (input_2 is neutral) and (input_3 is long) and (input_4 is long) then (output is long)");
      m_rule[14] = m_fuzzy.ParseRule("if (input_1 is neutral) and (input_2 is neutral) and (input_3 is short) and (input_4 is short) then (output is short)");
      m_rule[15] = m_fuzzy.ParseRule("if (input_1 is neutral) and (input_2 is long) and (input_3 is long) and (input_4 is long) then (output is long)");
      m_rule[16] = m_fuzzy.ParseRule("if (input_1 is neutral) and (input_2 is short) and (input_3 is short) and (input_4 is short) then (output is short)");
      m_rule[17] = m_fuzzy.ParseRule("if (input_1 is long) and (input_2 is neutral) and (input_3 is long) and (input_4 is long) then (output is long)");
      m_rule[18] = m_fuzzy.ParseRule("if (input_1 is short) and (input_2 is neutral) and (input_3 is short) and (input_4 is short) then (output is short)");
      m_rule[19] = m_fuzzy.ParseRule("if (input_1 is long) and (input_2 is long) and (input_3 is neutral) and (input_4 is long) then (output is long)");
      m_rule[20] = m_fuzzy.ParseRule("if (input_1 is short) and (input_2 is short) and (input_3 is neutral) and (input_4 is short) then (output is short)");
      m_rule[21] = m_fuzzy.ParseRule("if (input_1 is long) and (input_2 is long) and (input_3 is long) and (input_4 is neutral) then (output is long)");
      m_rule[22] = m_fuzzy.ParseRule("if (input_1 is short) and (input_2 is short) and (input_3 is short) and (input_4 is neutral) then (output is short)");
      
      for(int r=0;r<__RULES;r++)
      {
         m_fuzzy.Rules().Add(m_rule[r]);
      }
      
      //
      
      ArrayResize(m_signals,1);
   }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalSE::~CSignalSE(void)
  {
      m_in_list.FreeMode(true);
      delete m_in_list;
      delete m_fuzzy;
   
      for(int i=0;i<__INPUTS;i++)
      {
         delete m_in_text[i];
      }
      
      //
      
      ChartRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalSE::ReadForest()
   {
      if(m_reset)
      {
         FileDelete("DF_BUFFER_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_COMMON);
         FileDelete("DF_CLASSES_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_COMMON);
         FileDelete("DF_VARIABLES_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_COMMON);
         FileDelete("DF_TREES_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_COMMON);
         
         int _df_reset=FileOpen("DF_TREES_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON);
         FileWrite(_df_reset,0);
         FileClose(_df_reset);
         
         ExpertRemove();
         return;
      }

      int _df_init = FileOpen("DF_TREES_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON);
      int _trees = (int)FileReadNumber(_df_init);
      FileClose(_df_init);
      
      if(_trees>0)
      {
         m_random=false;
         
         int _df_read=FileOpen("DF_BUFFER_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON);
         DF.m_bufsize=(int)FileReadNumber(_df_read);
         FileClose(_df_read);
         
         _df_read=FileOpen("DF_CLASSES_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON);
         DF.m_nclasses=(int)FileReadNumber(_df_read);
         FileClose(_df_read);
         
         _df_read=FileOpen("DF_TREES_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON);
         DF.m_ntrees=(int)FileReadNumber(_df_read);
         FileClose(_df_read);
         
         _df_read=FileOpen("DF_VARIABLES_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON);
         DF.m_nvars=(int)FileReadNumber(_df_read);
         FileClose(_df_read);
         
         _df_read=FileOpen("DF_TREES_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_READ|FILE_WRITE|FILE_BIN|FILE_ANSI|FILE_COMMON);
         FileReadArray(_df_read,DF.m_trees);
         FileClose(_df_read);
      }
      else
      {
         printf(__FUNCSIG__+" INITIATING FOREST... ");
      }
      
      m_read_forest=true;
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
void CSignalSE::WriteForest()
   {
      if(m_reset) return;
      
      if(MQLInfoInteger(MQL_OPTIMIZATION))
      {
         if(m_samples>0)
         {
            CDForest::DFBuildRandomDecisionForest(DF_SIGNAL,m_samples,__INPUTS,2,m_trees,0.5+m_regularization,DF_INFO,DF,DF_REPORT);
         }
         
         FileDelete("DF_BUFFER_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_COMMON);
         FileDelete("DF_CLASSES_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_COMMON);
         FileDelete("DF_VARIABLES_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_COMMON);
         FileDelete("DF_TREES_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_COMMON);
         
         int _df_write=FileOpen("DF_BUFFER_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON);
         FileWrite(_df_write,DF.m_bufsize);
         FileClose(_df_write);
         
         _df_write=FileOpen("DF_CLASSES_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON);
         FileWrite(_df_write,DF.m_nclasses);
         FileClose(_df_write);
         
         _df_write=FileOpen("DF_TREES_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON);
         FileWrite(_df_write,DF.m_ntrees);
         FileClose(_df_write);
         
         _df_write=FileOpen("DF_VARIABLES_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON);
         FileWrite(_df_write,DF.m_nvars);
         FileClose(_df_write);
         
         _df_write=FileOpen("DF_TREES_"+m_symbol.Name()+"_"+EnumToString(m_period)+".txt",FILE_READ|FILE_WRITE|FILE_BIN|FILE_ANSI|FILE_COMMON);
         FileWriteArray(_df_write,DF.m_trees);
         FileClose(_df_write);
      }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
void CSignalSE::SignalUpdate(double Signal)
   {
      if(MQLInfoInteger(MQL_OPTIMIZATION))
      {
         m_samples++;
         DF_SIGNAL.Resize(m_samples,__INPUTS+2);
         
         for(int i=0;i<__INPUTS;i++)
         {
            DF_SIGNAL[m_samples-1].Set(i,m_signals[0][i]);
         }
         //
         DF_SIGNAL[m_samples-1].Set(__INPUTS,Signal);
         DF_SIGNAL[m_samples-1].Set(__INPUTS+1,1-Signal);    
      }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
void CSignalSE::ResultUpdate(double Result)
   {
      if(MQLInfoInteger(MQL_OPTIMIZATION))
      {
         int _err;
         if(Result<0.0) 
         {
            double _odds = MathRandomUniform(0,1,_err);
            DF_SIGNAL[m_samples-1].Set(__INPUTS,_odds);
            DF_SIGNAL[m_samples-1].Set(__INPUTS+1,1-_odds);
         }
      }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
double CSignalSE::Signal(void)
   {
      for(int i=0;i<__INPUTS;i++)
      {
         double _range=m_symbol.Point();
         for(int s=0;s<__SIGNALS[i];s++)
         {
            _range=fmax(_range,fabs(Data(s)));
         }
         //
         double 
         _long_entropy=0.0,_short_entropy=0.0,
         _max_entropy=fabs(log10(__SIGNALS[i])/log10(2.0));
         for(int s=0;s<__SIGNALS[i];s++)
         {
            double _data=Data(s);
            //
            if(_data>0.0)
            {
               _long_entropy-=((1.0/__SIGNALS[i])*((__SIGNALS[i]-s)/__SIGNALS[i])*(fabs(_data)/_range)*(log10(1.0/__SIGNALS[i])/log10(2.0)));
            }
            else if(_data<0.0)
            {
               _short_entropy-=((1.0/__SIGNALS[i])*((__SIGNALS[i]-s)/__SIGNALS[i])*(fabs(_data)/_range)*(log10(1.0/__SIGNALS[i])/log10(2.0)));
            }
         }
         //
         m_signals[0][i]=0.5*(1.0+((_short_entropy/_max_entropy)-(_long_entropy/_max_entropy)));
      }
      
      if(!m_random)
      {
         for(int i=0;i<__INPUTS;i++)
         {
            m_in_calculations[i]=m_signals[0][i];
         }
         
         CDForest::DFProcess(DF,m_in_calculations,m_out_calculations);
         m_update.B(m_out_calculations[1]);
      }
      else
      {
         int _err;
         m_update.B(MathRandomUniform(0,1,_err));
      }
      
      //
      
      for(int i=0;i<__INPUTS;i++)
      {
         m_in_text[i]=new CDictionary_Obj_Double();
         m_in_text[i].SetAll(m_in_variables[i],m_signals[0][i]);
      }
      
      m_in_list.Clear();
      //printf(__FUNCSIG__+" list 'total' : "+IntegerToString(m_in_list.Total()));
      
      for(int i=0;i<__INPUTS;i++)
      {
         //printf(__FUNCSIG__+" adding value: "+DoubleToString(m_in_text[i].Value())+", to list at: "+IntegerToString(i));
         m_in_list.Add(m_in_text[i]);
         //printf(__FUNCSIG__+" added. ");
      }
      
      //CList *_signal_list=m_fuzzy.Calculate(m_in_list).GetNodeAtIndex(0);
      //m_out_text=_signal_list.GetNodeAtIndex(0);
      
      
      //delete _signal_list;
      
      m_out_text=m_fuzzy.Calculate(m_in_list).GetNodeAtIndex(0);
      
      double _signal=m_out_text.Value();
      
      return(_signal);
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
double CSignalSE::Result(void)
  {
      double _result=0.0;
      
      if(HistorySelect(0,m_symbol.Time()))
      {
         int _deals=HistoryDealsTotal();
         
         for(int d=_deals-1;d>=0;d--)
         {
            ulong _deal_ticket=HistoryDealGetTicket(d);
            if(HistoryDealSelect(_deal_ticket))
            {
               if(HistoryDealGetInteger(_deal_ticket,DEAL_ENTRY)==DEAL_ENTRY_OUT)
               {
                  _result=HistoryDealGetDouble(_deal_ticket,DEAL_PROFIT);
                  break;
               }
            }
         }
      }
   
      return(_result);
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSignalSE::IsNewBar(void)
   {
      datetime _bar_time=datetime(SeriesInfoInteger(m_symbol.Name(),m_period,SERIES_LASTBAR_DATE));
      
      //
      if(m_last_time==0)
      {
         m_last_time=_bar_time;
         return(false);
      }
      
      //
      if(m_last_time!=_bar_time)
      {
         m_last_time=_bar_time;
         return(true);
      }
      
      return(false);
   }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CSignalSE::ValidationSettings(void)
   {
      //--- validation settings of additional filters
      if(!CExpertSignal::ValidationSettings())
         return(false);
      //--- initial data checks
      
      //--- ok
      return(true);
   }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool CSignalSE::InitIndicators(CIndicators *indicators)
   {
      //--- check pointer
      if(indicators==NULL)
         return(false);
      //--- initialization of indicators and timeseries of additional filters
      if(!CExpertSignal::InitIndicators(indicators))
         return(false);
      //--- create and initialize SE oscillator
      if(!InitSE(indicators))
         return(false);
      //--- ok
      return(true);
   }
//+------------------------------------------------------------------+
//| Initialize SE oscillators.                                      |
//+------------------------------------------------------------------+
bool CSignalSE::InitSE(CIndicators *indicators)
   {
      //--- check pointer
      if(indicators==NULL) return(false);
      //--- add object to collection
      
      //--- initialize object
      
      //--- ok
      return(true);
   }
//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalSE::LongCondition(void)
   {
      int _result=0;
      
      if(IsNewBar())
      {
         m_last_signal=Signal();
      }
      
      if(m_last_signal>0.5)
      {
         double _signal=m_last_signal;
         _signal*=100.0;
         _signal-=50.0;
         _signal*=2.0;
         
         _result=int(fmin(100.0,_signal));
         
         m_last_condition=_result;
      }
      
      //---
      
      //--- return the result
      return(_result);
   }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalSE::ShortCondition(void)
   {
      int _result=0;
      
      if(IsNewBar())
      {
         m_last_signal=Signal();
      }
      
      if(m_last_signal<0.5)
      {
         double _signal=m_last_signal;
         _signal*=100.0;
         _signal*=2.0;
         
         _result=int(fmin(100.0,_signal));
         
         m_last_condition=_result;
      }
      
      //---
      
      //--- return the result
      return(_result);
   }
//+------------------------------------------------------------------+
