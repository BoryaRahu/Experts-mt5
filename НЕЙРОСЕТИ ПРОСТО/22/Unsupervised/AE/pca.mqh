//+------------------------------------------------------------------+
//|                                                          pca.mqh |
//|                                   Copyright 2022, Dmitriy Gizlyk |
//|                                https://www.mql5.com/ru/users/dng |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Dmitriy Gizlyk"
#property link      "https://www.mql5.com/ru/users/dng"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "kmeans.mqh"
//+------------------------------------------------------------------+
//| Defines                                                          |
//+------------------------------------------------------------------+
#define defUnsupervisedPCA    0x7902
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPCA : public CObject
  {
private:
   bool              b_Studied;
   matrix            m_Ureduce;
   vector            v_Means;
   vector            v_STDs;
   //---
   CBufferDouble     *FromMatrix(matrix &data);
   CBufferDouble     *FromVector(vector &data);
   matrix            FromBuffer(CBufferDouble *data, ulong vector_size);
   vector            FromBuffer(CBufferDouble *data);
public:
                     CPCA();
                    ~CPCA();
   //---
   bool              Study(CBufferDouble *data, int vector_size);
   bool              Study(matrix &data);
   CBufferDouble     *Reduce(CBufferDouble *data);
   CBufferDouble     *Reduce(matrix &data);
   matrix            ReduceM(CBufferDouble *data);
   matrix            ReduceM(matrix &data);
   //---
   bool              Studied(void)  {  return b_Studied; }
   ulong             VectorSize(void)  {  return m_Ureduce.Cols();}
   ulong             Inputs(void)   {  return m_Ureduce.Rows();   }
   //---
   virtual bool      Save(const int file_handle);
   virtual bool      Load(const int file_handle);
   //---
   virtual int       Type(void)  { return defUnsupervisedPCA; }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPCA::CPCA()   :  b_Studied(false)
  {
   m_Ureduce.Init(0, 0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPCA::~CPCA()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
matrix CPCA::FromBuffer(CBufferDouble *data, ulong vector_size)
  {
   matrix result;
   if(CheckPointer(data) == POINTER_INVALID)
     {
      result.Init(0, 0);
      return result;
     }
//---
   if((data.Total() % vector_size) != 0)
     {
      result.Init(0, 0);
      return result;
     }
//---
   ulong rows = data.Total() / vector_size;
   if(!result.Init(rows, vector_size))
     {
      result.Init(0, 0);
      return result;
     }
   for(ulong r = 0; r < rows; r++)
     {
      ulong shift = r * vector_size;
      for(ulong c = 0; c < vector_size; c++)
         result[r, c] = data[(int)(shift + c)];
     }
//---
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
vector CPCA::FromBuffer(CBufferDouble *data)
  {
   vector result;
   result.Init(0);
   if(CheckPointer(data) == POINTER_INVALID)
      return result;
//---
   ulong rows = data.Total();
   if(!result.Init(rows))
      return result;
   for(ulong r = 0; r < rows; r++)
      result[r] = data[(int)r];
//---
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBufferDouble *CPCA::FromMatrix(matrix &data)
  {
   CBufferDouble *result = new CBufferDouble();
   if(CheckPointer(result) == POINTER_INVALID)
      return result;
//---
   ulong rows = data.Rows();
   ulong cols = data.Cols();
   if(!result.Reserve((int)(rows * cols)))
     {
      delete result;
      return result;
     }
//---
   for(ulong r = 0; r < rows; r++)
      for(ulong c = 0; c < cols; c++)
         if(!result.Add(data[r, c]))
           {
            delete result;
            return result;
           }
//---
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBufferDouble *CPCA::FromVector(vector &data)
  {
   CBufferDouble *result = new CBufferDouble();
   if(CheckPointer(result) == POINTER_INVALID)
      return result;
//---
   ulong rows = data.Size();
   if(!result.Reserve((int)rows))
     {
      delete result;
      return result;
     }
//---
   for(ulong r = 0; r < rows; r++)
      if(!result.Add(data[r]))
        {
         delete result;
         return result;
        }
//---
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBufferDouble *CPCA::Reduce(CBufferDouble *data)
  {
   matrix result = ReduceM(data);
//---
   return FromMatrix(result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBufferDouble *CPCA::Reduce(matrix &data)
  {
   matrix result = ReduceM(data);
//---
   return FromMatrix(result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
matrix CPCA::ReduceM(CBufferDouble *data)
  {
   matrix result;
   result.Init(0, 0);
   if(!b_Studied || (data.Total() % m_Ureduce.Rows()) != 0)
      return result;
   result = FromBuffer(data, m_Ureduce.Rows());
//---
   return ReduceM(result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
matrix CPCA::ReduceM(matrix &data)
  {
   matrix result;
   if(!b_Studied || data.Cols() != m_Ureduce.Rows())
     {
      result.Init(0, 0);
      return result;
     }
//---
   ulong total = data.Rows();
   if(!result.Init(total, data.Cols()))
     {
      result.Init(0, 0);
      return result;
     }
   for(ulong r = 0; r < total; r++)
     {
      vector temp = data.Row(r) - v_Means;
      temp /= v_STDs;
      result = result.Row(temp, r);
     }
//---
   return result.MatMul(m_Ureduce);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPCA::Study(matrix &data)
  {
   matrix X;
   ulong total = data.Rows();
   if(!X.Init(total, data.Cols()))
      return false;
   v_Means = data.Mean(0);
   v_STDs = data.Std(0) + 1e-8;
   for(ulong i = 0; i < total; i++)
     {
      vector temp = data.Row(i) - v_Means;
      temp /= v_STDs;
      X = X.Row(temp, i);
     }
//---
   X = X.Transpose().MatMul(X / total);
   matrix U, V;
   vector S;
   if(!X.SVD(U, V, S))
      return false;
//---
   double sum_total = S.Sum();
   if(sum_total <= 0)
      return false;
   S = S.CumSum() / sum_total;
   int k = 0;
   while(S[k] < 0.99)
      k++;
   if(!U.Resize(U.Rows(), k + 1))
      return false;
//---
   m_Ureduce = U;
   b_Studied = true;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPCA::Study(CBufferDouble *data, int vector_size)
  {
   matrix d = FromBuffer(data, vector_size);
   return Study(d);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPCA::Save(const int file_handle)
  {
   if(file_handle == INVALID_HANDLE)
      return false;
//---
   if(FileWriteInteger(file_handle, (int)b_Studied) < INT_VALUE)
      return false;
   if(!b_Studied)
      return true;
//---
   CBufferDouble *temp = FromMatrix(m_Ureduce);
   if(CheckPointer(temp) == POINTER_INVALID)
      return false;
   if(FileWriteLong(file_handle, (long)m_Ureduce.Cols()) <= 0)
     {
      delete temp;
      return false;
     }
   if(!temp.Save(file_handle))
     {
      delete temp;
      return false;
     }
   delete temp;
//---
   temp = FromVector(v_Means);
   if(CheckPointer(temp) == POINTER_INVALID)
      return false;
   if(!temp.Save(file_handle))
     {
      delete temp;
      return false;
     }
   delete temp;
//---
   temp = FromVector(v_STDs);
   if(CheckPointer(temp) == POINTER_INVALID)
      return false;
   if(!temp.Save(file_handle))
     {
      delete temp;
      return false;
     }
   delete temp;
//---
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPCA::Load(const int file_handle)
  {
   if(file_handle == INVALID_HANDLE)
      return false;
//---
   b_Studied = (bool)FileReadInteger(file_handle);
   if(!b_Studied)
      return true;
//---
   CBufferDouble *temp = new CBufferDouble();
   if(CheckPointer(temp) == POINTER_INVALID)
      return false;
   long cols = FileReadLong(file_handle);
   if(!temp.Load(file_handle))
     {
      delete temp;
      return false;
     }
   m_Ureduce = FromBuffer(temp, cols);
//---
   if(!temp.Load(file_handle))
     {
      delete temp;
      return false;
     }
   v_Means = FromBuffer(temp);
//---
   if(!temp.Load(file_handle))
     {
      delete temp;
      return false;
     }
   v_STDs = FromBuffer(temp);
//---
   delete temp;
//---
   return true;
  }
//+------------------------------------------------------------------+
