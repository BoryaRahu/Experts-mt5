//+------------------------------------------------------------------+
//|                                                          FQF.mqh |
//|                                                   Copyright DNG® |
//|                                https://www.mql5.com/ru/users/dng |
//+------------------------------------------------------------------+
#property copyright "Copyright DNG®"
#property link      "https://www.mql5.com/ru/users/dng"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include "..\NeuroNet_DNG\NeuroNet.mqh"
//---
#define defFQF             0x7792   ///<Neuron Net \details Identified class #CFQF
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CFQF : protected CNet
  {
private:
   uint              iCountBackProp;
protected:
   uint              iUpdateTarget;
   //---
   CNet              cTargetNet;
public:
   /** Constructor */
                     CFQF(void);
                     CFQF(CArrayObj *Description)  { Create(Description); }
   bool              Create(CArrayObj *Description);
   /** Destructor */~CFQF(void);
   bool              feedForward(CArrayFloat *inputVals, int window = 1, bool tem = true) ///< Feed Forward method.@param[in] prevLayer Pointer to previos layer. @param[in] window Window of input data. @param[in] tem Use Time Embedding.
     { return        CNet::feedForward(inputVals, window, tem); }
   bool              backProp(CBufferFloat *targetVals, float discount = 0.9f, CArrayFloat *nextState = NULL, int window = 1, bool tem = true);               ///< Back propagation method. @param[in] targetVals Target values
   void              getResults(CBufferFloat *&resultVals);                ///< Method to get results of feed forward process.@param[out] resultVals Array of result values
   int               getAction(void);                ///< Method to get results of feed forward process.@param[out] resultVals Array of result values
   int               getSample(void);
   float             getRecentAverageError() { return recentAverageError; } ///< Method to check quality of study. @return Average error
   bool              Save(string file_name, datetime time, bool common = true)
     { return        CNet::Save(file_name, getRecentAverageError(), (float)iUpdateTarget, 0, time, common); }
   ///< Save method. @param[in] file_name File name to save @param[in] error Average error @param[in] undefine Undefined percent @param[in] Foecast percent @param[in] time Last study time @param[in] common Common flag
   virtual bool      Save(const int file_handle);
   virtual bool      Load(string file_name, datetime &time, bool common = true);
   ///< Load method. @param[in] file_name File name to save @param[out] error Average error @param[out] undefine Undefined percent @param[out] Foecast percent @param[out] time Last study time @param[in] common Common flag
   virtual bool      Load(const int file_handle);
   //---
   virtual int       Type(void)   const   {  return defFQF;   }///< Identificator of class.@return Type of class
   virtual bool      TrainMode(bool flag) { return CNet::TrainMode(flag); } ///< Set Training Mode Flag
   virtual bool      GetLayerOutput(uint layer, CBufferFloat *&result) ///< Retutn Output data of layer. @param[in] layer Number of layer @param[out] return Buffer with data
     { return        CNet::GetLayerOutput(layer, result); }
   //---
   virtual void      SetUpdateTarget(uint batch)   { iUpdateTarget = batch; }
   virtual bool      UpdateTarget(string file_name);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFQF::CFQF(void)  :  iUpdateTarget(1000)
  {
   cTargetNet.Create(NULL);
   Create(NULL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CFQF::~CFQF()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CFQF::Create(CArrayObj *Description)
  {
   if(!CNet::Create(Description))
      return false;
   cTargetNet.Create(NULL);
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CFQF::backProp(CBufferFloat *targetVals, float discount = 0.9f, CArrayFloat *nextState = NULL, int window = 1, bool tem = true)
  {
//---
   if(!targetVals)
      return false;
//---
   if(!!nextState)
     {
      vectorf target;
      if(!targetVals.GetData(target) || target.Size() <= 0)
         return false;
      if(!cTargetNet.feedForward(nextState, window, tem))
         return false;
      cTargetNet.getResults(targetVals);
      if(!targetVals)
         return false;
      target = target + discount * targetVals.Maximum();
      if(!targetVals.AssignArray(target))
         return false;
     }
//---
   if(iCountBackProp >= iUpdateTarget)
     {
#ifdef FileName
      if(UpdateTarget(FileName + ".nnw"))
#else
      if(UpdateTarget("FQF.upd"))
#endif
         iCountBackProp = 0;
     }
   else
      iCountBackProp++;
//---
   return CNet::backProp(targetVals);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CFQF::getResults(CBufferFloat *&resultVals)
  {
   CNet::getResults(resultVals);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CFQF::getAction(void)
  {
   CBufferFloat *temp;
   CNet::getResults(temp);
   if(!temp)
      return -1;
//---
   return temp.Maximum(0, temp.Total());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CFQF::getSample(void)
  {
   CBufferFloat* resultVals;
   CNet::getResults(resultVals);
   if(!resultVals)
      return -1;
   vectorf temp;
   if(!resultVals.GetData(temp))
     {
      delete resultVals;
      return -1;
     }
   delete resultVals;
//---
   if(!temp.Activation(temp, AF_SOFTMAX))
      return -1;
   temp = temp.CumSum();
   int err_code;
   float random = (float)Math::MathRandomNormal(0.5, 0.5, err_code);
   if(random >= 1)
      return (int)temp.Size() - 1;
   for(int i = 0; i < (int)temp.Size(); i++)
      if(random <= temp[i] && temp[i] > 0)
         return i;
//---
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CFQF::UpdateTarget(string file_name)
  {
   if(!Save(file_name, 0, false))
      return false;
   float error, undefine, forecast;
   datetime time;
   if(!cTargetNet.Load(file_name, error, undefine, forecast, time, false))
      return false;
   iCountBackProp = 0;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CFQF::Save(const int file_handle)
  {
   if(!CNet::Save(file_handle))
      return false;
   if(FileWriteInteger(file_handle, (int)iUpdateTarget) < INT_VALUE)
      return false;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CFQF::Load(const int file_handle)
  {
   if(!CNet::Load(file_handle))
      return false;
   if(FileIsEnding(file_handle))
      return true;
   iUpdateTarget = (uint)FileReadInteger(file_handle);
   if(!UpdateTarget("FQF.upd"))
      return false;
   iCountBackProp = 0;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CFQF::Load(string file_name, datetime &time, bool common = true)
  {
   float undefine, forecast;
   if(!CNet::Load(file_name, recentAverageError, undefine, forecast, time, common))
      return false;
   iUpdateTarget = (uint)undefine;
//---
   return true;
  }
//+------------------------------------------------------------------+
