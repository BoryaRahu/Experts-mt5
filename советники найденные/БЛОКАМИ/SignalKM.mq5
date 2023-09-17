//+------------------------------------------------------------------+
//|                                                     SignalKM.mqh |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals of MQL5-Wizard article 'Kohonen-Map'               |
//| Type=SignalAdvanced                                              |
//| Name=Kohonen-Map                                                 |
//| ShortName=KM                                                     |
//| Class=CSignalKM                                                  |
//| Page=signal_km                                                   |
//| Parameter=TrainingRead,bool,true,Read Training File              |
//| Parameter=TrainingWrite,bool,true,Write Training File            |
//| Parameter=TrainingOnly,bool,false,Training Only                  |
//| Parameter=TrainingRate,double,0.5,Training Rate                  |
//| Parameter=TrainingIterations,int,10000,Training Iterations       |
//| Parameter=QE,double,0.5,proxy for Quantization Error             |
//| Parameter=TE,double,5000.0,proxy for Topological Error           |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalKM.                                                 |
//| Purpose: Class of generator of trade signals based on            |
//|          MQL5-Wizard article 'Kohonen-Map'.                      |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+
#property copyright       "Copyright 2022, MetaQuotes Ltd."
#property link            "https://www.mql5.com"
#property version         "1.00"
//
#include                 <Expert\ExpertSignal.mqh>

#include                 <Generic\ArrayList.mqh>
#include                 <Generic\HashMap.mqh>

#define                  SCALE 5

#define                  IN_WIDTH 2*SCALE
#define                  OUT_LENGTH 1

#define                  IN_RADIUS 100.0
#define                  OUT_BUFFER 10000

//
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Cdimension         : public CArrayList<double>
  {
public:

                     Cdimension() {};
                    ~Cdimension() {};

   virtual double      Get(const int Index)
     {
      double _value=0.0;
      TryGetValue(Index,_value);
      return(_value);
     };

   virtual void        Set(const int Index,double Value)
     {
      Insert(Index,Value);
     };
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Cfeed             : public Cdimension
  {
public:

                     Cfeed() { Clear(); Capacity(IN_WIDTH);  };
                    ~Cfeed() {                               };
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Cfunctor          : public Cdimension
  {
public:

                     Cfunctor() { Clear(); Capacity(OUT_LENGTH); };
                    ~Cfunctor() {                                };
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Cneuron           : public CHashMap<Cfeed*,Cfunctor*>
  {
public:

   double              weight;

   Cfeed               *fd;
   Cfunctor            *fr;

   CKeyValuePair
   <
   Cfeed*,
   Cfunctor*
   >                   *ff;

                     Cneuron()
     {
      weight=0.0;
      fd = new Cfeed();
      fr = new Cfunctor();
      ff = new CKeyValuePair<Cfeed*,Cfunctor*>(fd,fr);
      Add(ff);
     };

                    ~Cneuron()
     {
      ZeroMemory(weight);
      delete fd;
      delete fr;
      delete ff;
     };
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Clayer            : public CArrayList<Cneuron*>
  {
public:

   Cneuron             *n;

                     Clayer() { n = new Cneuron();     };
                    ~Clayer() { delete n;              };
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Cinput_layer      : public Clayer
  {
public:

   static const int     size;

                     Cinput_layer()
     {
      Clear();
      Capacity(Cinput_layer::size);
      for(int s=0; s<size; s++)
        {
         n = new Cneuron();
         Add(n);
        }
     }
                    ~Cinput_layer() {};
  };
const int Cinput_layer::size=1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Coutput_layer      : public Clayer
  {
public:

   int                  index;
   int                  size;

                     Coutput_layer()
     {
      index=0;
      size=OUT_BUFFER;
      Clear();
      Capacity(size);
      for(int s=0; s<size; s++)
        {
         n = new Cneuron();
         Add(n);
        }
     };

                    ~Coutput_layer()
     {
      ZeroMemory(index);
      ZeroMemory(size);
     };
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Cnetwork           : public CHashMap<Cinput_layer*,Coutput_layer*>
  {
public:

   Cinput_layer        *i;
   Coutput_layer       *o;

   CKeyValuePair
   <
   Cinput_layer*,
   Coutput_layer*
   >                   *io;

   Cneuron             *i_neuron;
   Cneuron             *o_neuron;

   Cneuron             *best_neuron;

                     Cnetwork()
     {
      i = new Cinput_layer();
      o = new Coutput_layer();
      io = new CKeyValuePair<Cinput_layer*,Coutput_layer*>(i,o);
      Add(io);

      i_neuron = new Cneuron();
      o_neuron = new Cneuron();

      best_neuron = new Cneuron();
     };

                    ~Cnetwork()
     {
      delete i;
      delete o;
      delete io;
      delete i_neuron;
      delete o_neuron;
      delete best_neuron;
     };

   virtual int        GetInputSize()
     {
      TryGetValue(i,o);
      return(i.size);
     };

   virtual int        GetOutputIndex()
     {
      TryGetValue(i,o);
      return(o.index);
     };

   virtual void       SetOutputIndex(const int Index)
     {
      TryGetValue(i,o);
      o.index=Index;
      TrySetValue(i,o);
     };

   virtual int        GetOutputSize()
     {
      TryGetValue(i,o);
      return(o.size);
     };

   virtual void       SetOutputSize(const int Size)
     {
      TryGetValue(i,o);
      o.size=Size;
      o.Capacity(Size);
      TrySetValue(i,o);
     };

   virtual void       GetInNeuron(const int NeuronIndex)
     {
      TryGetValue(i,o);
      i.TryGetValue(NeuronIndex,i_neuron);
     };

   virtual void       GetOutNeuron(const int NeuronIndex)
     {
      TryGetValue(i,o);
      o.TryGetValue(NeuronIndex,o_neuron);
     };

   virtual void       SetInNeuron(const int NeuronIndex)
     {
      i.TrySetValue(NeuronIndex,i_neuron);
     };

   virtual void       SetOutNeuron(const int NeuronIndex)
     {
      o.TrySetValue(NeuronIndex,o_neuron);
     };
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Cmap
  {
public:

   Cnetwork               *network;

   static const double     radius;
   static double           time;

   double                  QE; //proxy for Quantization Error
   double                  TE; //proxy for Topological Error

   datetime                refreshed;

   bool                    initialised;

                     Cmap()
     {
      network = new Cnetwork();

      initialised=false;

      time=0.0;

      QE=0.50;
      TE=5000.0;

      refreshed=D'1970.01.05';
     };

                    ~Cmap()
     {
      ZeroMemory(initialised);

      ZeroMemory(time);

      ZeroMemory(QE);
      ZeroMemory(TE);

      ZeroMemory(refreshed);
     };
  };
const double Cmap::radius=IN_RADIUS;
double Cmap::time=10000/fmax(1.0,log(IN_RADIUS));

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSignalKM : public CExpertSignal
  {
protected:

   CiATR                m_ATR;

   //--- adjusted parameters
   bool                 m_training_read;
   bool                 m_training_write;
   double               m_training_rate;
   bool                 m_training_only;
   int                  m_training_iterations;
   double               m_qe;
   double               m_te;

   string               m_training_name;

public:
                     CSignalKM();
                    ~CSignalKM();

   //--- methods of setting adjustable parameters
   void                 TrainingRead(bool value)            { m_training_read=value;      }
   void                 TrainingWrite(bool value)           { m_training_write=value;     }
   void                 TrainingRate(double value)          { m_training_rate=value;      }
   void                 TrainingOnly(bool value)            { m_training_only=value;      }
   void                 TrainingIterations(int value)       { m_training_iterations=value;}
   void                 QE(double value)              { m_qe=value;          }
   void                 TE(double value)            { m_te=value;         }

   void                 TrainingName(string value)          { m_training_name=value;      }

   //--- method of verification of settings
   virtual bool         ValidationSettings(void);
   //--- method of creating the indicator and timeseries
   virtual bool         InitIndicators(CIndicators *indicators);
   bool                 InitKM(CIndicators *indicators);
   //--- methods for detection of levels of entering the market
   virtual bool         OpenLongParams(double &price,double &sl,double &tp,datetime &expiration);
   virtual bool         OpenShortParams(double &price,double &sl,double &tp,datetime &expiration);
   //--- methods of checking if the market models are formed
   virtual double       Direction(void);
   //
   virtual int          LongCondition(void);
   virtual int          ShortCondition(void);

protected:

   //

   void                 SetWeights(Cneuron &Trainer,Cneuron &Mapped,double RemappedRadius,double TrainingRate);

   double               GetTrainingRadius(Cmap &Map,int Iteration);
   double               GetRemappedRadius(double Radius, double CurrentRadius);

   double               EuclideanFunctor(Cneuron &NeuronA, Cneuron &NeuronB);
   double               EuclideanFeed(Cneuron &NeuronA, Cneuron &NeuronB);

   //

   //--- data variables

   Cneuron              m_feed_neuron;
   double               m_condition;

   //

   void                 NetworkTrain(Cmap &Map,Cneuron &TrainNeuron);
   void                 NetworkMapping(Cmap &Map,Cneuron *MapNeuron);

   void                 MapFeed(Cneuron &FeedNeuron,int Index,bool OnFeed=true);
   void                 MapRefresh(Cmap &Map);

   double               MapCondition(Cmap &Map);
   void                 MapInit(Cmap &Map);

   Cmap                 MAP;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSignalKM::CSignalKM() :      m_training_read(false),
   m_training_rate(0.5),
   m_training_only(false),
   m_training_iterations(10000),
   m_qe(0.5),
   m_te(5000.0)
  {
//--- initialization of protected data
   m_used_series=USE_SERIES_OPEN+USE_SERIES_HIGH+USE_SERIES_LOW+USE_SERIES_CLOSE+USE_SERIES_TIME;
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CSignalKM::ValidationSettings(void)
  {
//--- validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);
//--- initial data checks

   if(m_training_rate<=0.0||m_training_rate>1.0)
     {
      printf(__FUNCTION__+": open training rate should not be less than 0.0 or equal to 0.0 or more than 1.0 ");
      return(false);
     }
//

   MapInit(MAP);

   if(m_training_read)
     {
      TrainingName(m_symbol.Name()+"_"+EnumToString(m_period));

      ResetLastError();
      string _name=m_training_name+"_IN-RADIUS_"+IntegerToString(IN_RADIUS)+"_OUT-BUFFER_"+IntegerToString(OUT_BUFFER)+"_IN-WIDTH_"+IntegerToString(IN_WIDTH)+"_OUT-LENGTH_"+IntegerToString(OUT_LENGTH)+".bin";
      int _handle=FileOpen(_name,FILE_SHARE_READ|FILE_BIN|FILE_COMMON);

      if(_handle!=INVALID_HANDLE)
        {
         MAP.network.SetOutputIndex(FileReadInteger(_handle));

         for(int s=0; s<=MAP.network.GetOutputIndex(); s++)
           {
            MAP.network.GetOutNeuron(s);
            for(int w=0; w<IN_WIDTH; w++)
              {
               MAP.network.o_neuron.fd.Set(w,FileReadDouble(_handle));
              }

            for(int l=0; l<OUT_LENGTH; l++)
              {
               MAP.network.o_neuron.fr.Set(l,FileReadDouble(_handle));
              }
           }

         FileClose(_handle);
        }
      else
        {
         printf(__FUNCTION__+": failed to load network: "+_name+", with err: "+IntegerToString(GetLastError()));
         return(false);
        }
     }

//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool CSignalKM::InitIndicators(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- create and initialize RSI oscillator
   if(!InitKM(indicators))
      return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize RSI oscillators.                                      |
//+------------------------------------------------------------------+
bool CSignalKM::InitKM(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- add object to collection

//--- initialize ATR indicator
   if(!m_ATR.Create(m_symbol.Name(),m_period,IN_WIDTH))
     {
      printf(__FUNCTION__+": error initializing ATR indicator");
      return(false);
     }

//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Detecting the levels for buying                                  |
//+------------------------------------------------------------------+
bool CSignalKM::OpenLongParams(double &price,double &sl,double &tp,datetime &expiration)
  {
   CExpertSignal *general=(m_general!=-1) ? m_filters.At(m_general) : NULL;
//---
   if(general==NULL)
     {
      m_ATR.Refresh(-1);
      //--- if a base price is not specified explicitly, take the current market price
      double base_price=(m_base_price==0.0) ? m_symbol.Ask() : m_base_price;

      //--- price overload that sets entry price to be based on ATR
      price      =base_price;
      double _range=m_ATR.Main(StartIndex())+((m_symbol.StopsLevel()+m_symbol.FreezeLevel())*m_symbol.Point());
      //
      if(m_price_level<0.0)
        {
         price=m_symbol.NormalizePrice(m_symbol.Ask()+(fabs(m_price_level)*_range)+(m_symbol.Ask()-m_symbol.Bid()));
        }
      else
         if(m_price_level>0.0)
           {
            price=m_symbol.NormalizePrice(m_symbol.Bid()-(fabs(m_price_level)*_range)-(m_symbol.Ask()-m_symbol.Bid()));
           }

      //--- sl overload that sets exit price to be based on ATR
      sl         =(m_stop_level==0.0) ? 0.0 : m_symbol.NormalizePrice(fmin(m_symbol.Bid(),price)-(m_stop_level*_range)-(m_symbol.Ask()-m_symbol.Bid()));

      //--- tp overload that sets exit price to be based on ATR
      tp         =(m_take_level==0.0) ? 0.0 : m_symbol.NormalizePrice(fmax(m_symbol.Ask(),price)+(m_take_level*_range)+(m_symbol.Ask()-m_symbol.Bid()));

      expiration+=m_expiration*PeriodSeconds(m_period);
      return(true);
     }
//---
   return(general.OpenLongParams(price,sl,tp,expiration));
  }
//+------------------------------------------------------------------+
//| Detecting the levels for selling                                 |
//+------------------------------------------------------------------+
bool CSignalKM::OpenShortParams(double &price,double &sl,double &tp,datetime &expiration)
  {
   CExpertSignal *general=(m_general!=-1) ? m_filters.At(m_general) : NULL;
//---
   if(general==NULL)
     {
      m_ATR.Refresh(-1);
      //--- if a base price is not specified explicitly, take the current market price
      double base_price=(m_base_price==0.0) ? m_symbol.Bid() : m_base_price;

      //--- price overload that sets entry price to be based on ATR
      price      =base_price;
      double _range=m_ATR.Main(StartIndex())+((m_symbol.StopsLevel()+m_symbol.FreezeLevel())*m_symbol.Point());
      //
      if(m_price_level>0.0)
        {
         price=m_symbol.NormalizePrice(m_symbol.Ask()+(fabs(m_price_level)*_range)+(m_symbol.Ask()-m_symbol.Bid()));
        }
      else
         if(m_price_level<0.0)
           {
            price=m_symbol.NormalizePrice(m_symbol.Bid()-(fabs(m_price_level)*_range)-(m_symbol.Ask()-m_symbol.Bid()));
           }

      //--- sl overload that sets exit price to be based on ATR
      sl         =(m_stop_level==0.0) ? 0.0 : m_symbol.NormalizePrice(fmax(m_symbol.Ask(),price)+(m_stop_level*_range)+(m_symbol.Ask()-m_symbol.Bid()));

      //--- tp overload that sets exit price to be based on ATR
      tp         =(m_take_level==0.0) ? 0.0 : m_symbol.NormalizePrice(fmin(m_symbol.Bid(),price)-(m_take_level*_range)-(m_symbol.Ask()-m_symbol.Bid()));

      expiration+=m_expiration*PeriodSeconds(m_period);
      return(true);
     }
//---
   return(general.OpenShortParams(price,sl,tp,expiration));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSignalKM::Direction(void)
  {
   MapRefresh(MAP);

   m_condition=MapCondition(MAP);

   double result=m_weight*(LongCondition()-ShortCondition());

   return(result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CSignalKM::LongCondition(void)
  {
   if(MAP.initialised)
     {
      if(m_training_only || MAP.QE>=m_qe || MAP.TE>=m_te)
        {
         return(0);
        }

      if(m_condition>0)
        {
         return(int(round(m_condition)));
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CSignalKM::ShortCondition(void)
  {
   if(MAP.initialised)
     {
      if(m_training_only || MAP.QE>=m_qe || MAP.TE>=m_te)
        {
         return(0);
        }

      if(m_condition<0)
        {
         return((int)fabs(round(m_condition)));
        }
     }

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSignalKM::EuclideanFunctor(Cneuron &NeuronA, Cneuron &NeuronB)
  {
   uint _a_capacity=NeuronA.fr.Capacity();
   uint _b_capacity=NeuronB.fr.Capacity();
   if(_a_capacity<OUT_LENGTH || _b_capacity<OUT_LENGTH)
     {
      printf(__FUNCTION__+" Mis-matched vector sizes. A is: "+IntegerToString(_a_capacity)+", while B is: "+IntegerToString(_b_capacity)+", on an output length of: "+IntegerToString(OUT_LENGTH));
      NeuronA.fr.Capacity(OUT_LENGTH);
      NeuronB.fr.Capacity(OUT_LENGTH);
     }

   double _err=0.0;
   for(int l=0; l<OUT_LENGTH; l++)
     {
      _err+=pow((NeuronA.fr.Get(l) - NeuronB.fr.Get(l)), 2.0);
     }

   _err=sqrt(_err);

   return(_err);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSignalKM::EuclideanFeed(Cneuron &NeuronA, Cneuron &NeuronB)
  {
   uint _a_capacity=NeuronA.fd.Capacity();
   uint _b_capacity=NeuronB.fd.Capacity();
   if(_a_capacity<IN_WIDTH || _b_capacity<IN_WIDTH)
     {
      printf(__FUNCTION__+" Mis-matched vector sizes. A is: "+IntegerToString(_a_capacity)+", while B is: "+IntegerToString(_b_capacity)+", on an input width of: "+IntegerToString(IN_WIDTH));
      NeuronA.fd.Capacity(IN_WIDTH);
      NeuronB.fd.Capacity(IN_WIDTH);
     }

   double _err=0.0;
   for(uint w=0; w<IN_WIDTH; w++)
     {
      _err+=pow(NeuronA.fd.Get(w)-NeuronB.fd.Get(w),2.0);
     }

   _err=sqrt(_err);

   return(_err);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSignalKM::GetTrainingRadius(Cmap &Map,int Iteration)
  {
   return(Map.radius*exp(-Iteration/(m_training_iterations*Map.time)));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSignalKM::GetRemappedRadius(double Radius, double CurrentRadius)
  {
   return(exp(-(pow(Radius,2.0)/pow(CurrentRadius,2.0))));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalKM::SetWeights(Cneuron &Trainer,Cneuron &Mapped,double RemappedRadius,double TrainingRate)
  {
   uint _mapped_capacity=Mapped.fr.Capacity();
   uint _trainer_capacity=Trainer.fr.Capacity();
   if(_trainer_capacity<OUT_LENGTH || _mapped_capacity<OUT_LENGTH)
     {
      printf(__FUNCTION__+" Mis-matched vector capacities. Trainer is: "+IntegerToString(_trainer_capacity)+", while Mapped is: "+IntegerToString(_mapped_capacity)+", on an output length of: "+IntegerToString(OUT_LENGTH));
      Trainer.fr.Capacity(OUT_LENGTH);
      Mapped.fr.Capacity(OUT_LENGTH);
     }

   for(int l=0; l<OUT_LENGTH; l++)
     {
      double _mapped=Mapped.fr.Get(l);
      double _trainer=Trainer.fr.Get(l);

      Mapped.weight+=(RemappedRadius * TrainingRate * (_trainer - _mapped));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalKM::NetworkMapping(Cmap &Map,Cneuron *MapNeuron)
  {
   Map.QE=0.0;

   Map.network.best_neuron = new Cneuron();

   int _random_neuron=rand()%Map.network.GetOutputIndex();

   Map.network.GetInNeuron(0);
   Map.network.GetOutNeuron(_random_neuron);

   double _feed_error = EuclideanFeed(Map.network.i_neuron,Map.network.o_neuron);

   for(int i=0; i<Map.network.GetOutputIndex(); i++)
     {
      Map.network.GetOutNeuron(i);

      double _error = EuclideanFeed(Map.network.i_neuron,Map.network.o_neuron);

      if(_error < _feed_error)
        {
         for(int w=0; w<IN_WIDTH; w++)
           {
            Map.network.best_neuron.fd.Set(w,Map.network.o_neuron.fd.Get(w));
           }

         for(int l=0; l<OUT_LENGTH; l++)
           {
            Map.network.best_neuron.fr.Set(l,Map.network.o_neuron.fr.Get(l));
           }

         _feed_error = _error;
        }
     }

   Map.QE=_feed_error/IN_RADIUS;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalKM::NetworkTrain(Cmap &Map,Cneuron &TrainNeuron)
  {
   Map.TE=0.0;

   int _iteration=0;
   double _training_rate=m_training_rate;

   int _err=0;
   double _functor_error=0.0;

   while(_iteration<m_training_iterations)
     {
      double _current_radius=GetTrainingRadius(Map,_iteration);

      for(int i=0; i<=Map.network.GetOutputIndex(); i++)
        {
         Map.network.GetOutNeuron(i);
         double _error = EuclideanFunctor(TrainNeuron,Map.network.o_neuron);

         if(_error<_current_radius)
           {
            _functor_error+=(_error);
            _err++;

            double _remapped_radius = GetRemappedRadius(_error, _current_radius);

            SetWeights(TrainNeuron,Map.network.o_neuron,_remapped_radius,_training_rate);

            Map.network.SetOutNeuron(i);
           }
        }

      _iteration++;
      _training_rate=_training_rate*exp(-(double)_iteration/m_training_iterations);
     }

   int
   _size=Map.network.GetOutputSize(),
   _index=Map.network.GetOutputIndex();
   Map.network.SetOutputIndex(_index+1);
   if(_index+1>=_size)
     {
      Map.network.SetOutputSize(_size+OUT_BUFFER);
     }

   Map.network.GetOutNeuron(_index+1);
   for(int w=0; w<IN_WIDTH; w++)
     {
      Map.network.o_neuron.fd.Set(w,TrainNeuron.fd.Get(w));
     }

   for(int l=0; l<OUT_LENGTH; l++)
     {
      Map.network.o_neuron.fr.Set(l,TrainNeuron.fr.Get(l));
     }

   Map.network.SetOutNeuron(_index+1);

   if(_err>0)
     {
      _functor_error/=_err;
      Map.TE=_functor_error*IN_RADIUS;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalKM::MapFeed(Cneuron &FeedNeuron,int Index,bool OnFeed=true)
  {
   m_open.Refresh(-1);
   m_high.Refresh(-1);
   m_low.Refresh(-1);
   m_close.Refresh(-1);

   if(OnFeed)
     {
      for(int w=0; w<IN_WIDTH; w++)
        {
         double _dimension=fabs(IN_RADIUS)*((Low(StartIndex()+w+Index)-Low(StartIndex()+w+Index+1))-(High(StartIndex()+w+Index)-High(StartIndex()+w+Index+1)))/fmax(m_symbol.Point(),fmax(High(StartIndex()+w+Index),High(StartIndex()+w+Index+1))-fmin(Low(StartIndex()+w+Index),Low(StartIndex()+w+Index+1)));

         FeedNeuron.fd.Set(w,_dimension);
        }

     }
   else
      if(!OnFeed)
        {
         for(int l=0; l<OUT_LENGTH; l++)
           {
            double _dimension=fabs(IN_RADIUS)*(1.0+((Close(StartIndex()+Index)-Open(StartIndex()+Index+1))/fmax(m_symbol.Point(),fmax(High(StartIndex()+Index),High(StartIndex()+Index+1))-fmin(Low(StartIndex()+Index),Low(StartIndex()+Index+1)))));

            FeedNeuron.fr.Set(l,_dimension);
           }
        }
  }
//+------------------------------------------------------------------+
//| Map Refresh                                                      |
//+------------------------------------------------------------------+
void CSignalKM::MapRefresh(Cmap &Map)
  {
   if(!Map.initialised)
     {
      printf(__FUNCSIG__+" initialised with: "+IntegerToString(Map.network.GetInputSize())+", bars. ");

      for(int s=Map.network.GetInputSize()-1; s>=0; s--)
        {
         //printf(__FUNCSIG__+" on init: "+IntegerToString(Map.network.GetInputSize()-s)+", of: "+IntegerToString(Map.network.GetInputSize()));
         //
         MapFeed(m_feed_neuron,s,true);
         MapFeed(m_feed_neuron,s+1,false);
         Map.network.i_neuron = new Cneuron();
         Map.network.GetInNeuron(0);
         for(int w=0; w<IN_WIDTH; w++)
           {
            Map.network.i_neuron.fd.Set(w,m_feed_neuron.fd.Get(w));
           }

         for(int l=0; l<OUT_LENGTH; l++)
           {
            Map.network.i_neuron.fr.Set(l,m_feed_neuron.fr.Get(l));
           }
         Map.network.SetInNeuron(0);

         if(!m_training_read)
           {
            Map.network.GetInNeuron(0);
            NetworkTrain(Map,Map.network.i_neuron);
           }
        }

      printf(__FUNCSIG__+" calculated for: "+IntegerToString(Map.network.GetInputSize())+", indicators.");

      Map.refreshed=Time(StartIndex());

      Map.initialised=true;
     }
   else
     {
      if(Map.refreshed<Time(StartIndex()))
        {
         MapFeed(m_feed_neuron,0,true);
         MapFeed(m_feed_neuron,1,false);
         Map.network.i_neuron = new Cneuron();
         Map.network.GetInNeuron(0);
         for(int w=0; w<IN_WIDTH; w++)
           {
            Map.network.i_neuron.fd.Set(w,m_feed_neuron.fd.Get(w));
           }

         for(int l=0; l<OUT_LENGTH; l++)
           {
            Map.network.i_neuron.fr.Set(l,m_feed_neuron.fr.Get(l));
           }
         Map.network.SetInNeuron(0);

         Map.refreshed=Time(StartIndex());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CSignalKM::MapCondition(Cmap &Map)
  {
   Map.network.best_neuron.Clear();
   Map.network.best_neuron = new Cneuron();

   NetworkMapping(Map,Map.network.best_neuron);
   NetworkTrain(Map,Map.network.i_neuron);

   return((Map.network.best_neuron.fr.Get(0))-IN_RADIUS);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalKM::MapInit(Cmap &Map)
  {
//---KM initialisation
   Map.time=(m_training_iterations/fmax(1.0,log(Map.radius)));
//
   Map.initialised=false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSignalKM::~CSignalKM()
  {
   if(m_training_write && !MQLInfoInteger(MQL_OPTIMIZATION))
     {
      TrainingName(m_symbol.Name()+"_"+EnumToString(m_period));

      ResetLastError();
      string _name=m_training_name+"_IN-RADIUS_"+IntegerToString(IN_RADIUS)+"_OUT-BUFFER_"+IntegerToString(OUT_BUFFER)+"_IN-WIDTH_"+IntegerToString(IN_WIDTH)+"_OUT-LENGTH_"+IntegerToString(OUT_LENGTH)+".bin";
      int _handle=FileOpen(_name,FILE_WRITE|FILE_BIN|FILE_COMMON);

      if(_handle!=INVALID_HANDLE)
        {
         FileWriteInteger(_handle,MAP.network.GetOutputIndex());

         for(int s=0; s<=MAP.network.GetOutputIndex(); s++)
           {
            MAP.network.GetOutNeuron(s);
            for(int w=0; w<IN_WIDTH; w++)
              {
               FileWriteDouble(_handle,MAP.network.o_neuron.fd.Get(w));
              }

            for(int l=0; l<OUT_LENGTH; l++)
              {
               FileWriteDouble(_handle,MAP.network.o_neuron.fd.Get(l));
              }
           }

         //
         FileClose(_handle);
        }
      else
        {
         printf(__FUNCSIG__+" failed to create write handle err: "+IntegerToString(GetLastError()));
        }
     }
  }
//+------------------------------------------------------------------+
