//+------------------------------------------------------------------+
//|                                                       Select.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/ru/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/ru/users/artmedia70"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Включаемые файлы                                                 |
//+------------------------------------------------------------------+
#include <Arrays\ArrayObj.mqh>
#include "..\Objects\Orders\Order.mqh"
//+------------------------------------------------------------------+
//| Список-хранилище                                                 |
//+------------------------------------------------------------------+
CArrayObj   ListStorage; // Объект-хранилище для хранения сортированных списков коллекций
//+------------------------------------------------------------------+
//| Класс для выборки объектов, удовлетворяющих критерию             |
//+------------------------------------------------------------------+
class CSelect
  {
private:
   //--- Метод сравнения двух величин
   template<typename T>
   static bool       CompareValues(T value1,T value2,ENUM_COMPARER_TYPE mode);
public:
   //--- Возвращает список ордеров, у которых одно из (1) целочисленных, (2) вещественных и (3) строковых свойств удовлетворяет заданному критерию
   static CArrayObj *ByOrderProperty(CArrayObj *list_source,ENUM_ORDER_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode);
   static CArrayObj *ByOrderProperty(CArrayObj *list_source,ENUM_ORDER_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode);
   static CArrayObj *ByOrderProperty(CArrayObj *list_source,ENUM_ORDER_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode);
   //--- Возвращает индекс ордера в списке с максимальным значением (1) целочисленного, (2) вещественного и (3) строкового свойства
   static int        FindOrderMax(CArrayObj *list_source,ENUM_ORDER_PROP_INTEGER property);
   static int        FindOrderMax(CArrayObj *list_source,ENUM_ORDER_PROP_DOUBLE property);
   static int        FindOrderMax(CArrayObj *list_source,ENUM_ORDER_PROP_STRING property);
   //--- Возвращает индекс ордера в списке с минимальным значением (1) целочисленного, (2) вещественного и (3) строкового свойства
   static int        FindOrderMin(CArrayObj *list_source,ENUM_ORDER_PROP_INTEGER property);
   static int        FindOrderMin(CArrayObj *list_source,ENUM_ORDER_PROP_DOUBLE property);
   static int        FindOrderMin(CArrayObj *list_source,ENUM_ORDER_PROP_STRING property);
  };
//+------------------------------------------------------------------+
//| Метод сравнения двух величин                                     |
//+------------------------------------------------------------------+
template<typename T>
bool CSelect::CompareValues(T value1,T value2,ENUM_COMPARER_TYPE mode)
  {
   return
     (
      mode==EQUAL && value1==value2          ?  true  :
      mode==NO_EQUAL && value1!=value2       ?  true  :
      mode==MORE && value1>value2            ?  true  :
      mode==LESS && value1<value2            ?  true  :
      mode==EQUAL_OR_MORE && value1>=value2  ?  true  :
      mode==EQUAL_OR_LESS && value1<=value2  ?  true  :  false
     );
  }
//+------------------------------------------------------------------+
//| Работа со списками ордеров                                       |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Возвращает список ордеров, у которых одно из целочисленных       |
//| свойств удовлетворяет заданному критерию                         |
//+------------------------------------------------------------------+
CArrayObj *CSelect::ByOrderProperty(CArrayObj *list_source,ENUM_ORDER_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode)
  {
   if(list_source==NULL) return NULL;
   CArrayObj *list=new CArrayObj();
   if(list==NULL) return NULL;
   list.FreeMode(false);
   ListStorage.Add(list);
   int total=list_source.Total();
   for(int i=0; i<total; i++)
     {
      COrder *order=list_source.At(i);
      if(!order.SupportProperty(property)) continue;
      long order_prop=order.GetProperty(property);
      if(CompareValues(order_prop,value,mode)) list.Add(order);
     }
   return list;
  }
//+------------------------------------------------------------------+
//| Возвращает список ордеров, у которых одно из вещественных        |
//| свойств удовлетворяет заданному критерию                         |
//+------------------------------------------------------------------+
CArrayObj *CSelect::ByOrderProperty(CArrayObj *list_source,ENUM_ORDER_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode)
  {
   if(list_source==NULL) return NULL;
   CArrayObj *list=new CArrayObj();
   if(list==NULL) return NULL;
   list.FreeMode(false);
   ListStorage.Add(list);
   for(int i=0; i<list_source.Total(); i++)
     {
      COrder *order=list_source.At(i);
      if(!order.SupportProperty(property)) continue;
      double order_prop=order.GetProperty(property);
      if(CompareValues(order_prop,value,mode)) list.Add(order);
     }
   return list;
  }
//+------------------------------------------------------------------+
//| Возвращает список ордеров, у которых одно из строковых           |
//| свойств удовлетворяет заданному критерию                         |
//+------------------------------------------------------------------+
CArrayObj *CSelect::ByOrderProperty(CArrayObj *list_source,ENUM_ORDER_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode)
  {
   if(list_source==NULL) return NULL;
   CArrayObj *list=new CArrayObj();
   if(list==NULL) return NULL;
   list.FreeMode(false);
   ListStorage.Add(list);
   for(int i=0; i<list_source.Total(); i++)
     {
      COrder *order=list_source.At(i);
      if(!order.SupportProperty(property)) continue;
      string order_prop=order.GetProperty(property);
      if(CompareValues(order_prop,value,mode)) list.Add(order);
     }
   return list;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс ордера в списке                                |
//| с максимальным значением целочисленного свойства                 |
//+------------------------------------------------------------------+
int CSelect::FindOrderMax(CArrayObj *list_source,ENUM_ORDER_PROP_INTEGER property)
  {
   if(list_source==NULL) return WRONG_VALUE;
   int index=0;
   COrder *max_order=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      COrder *order=list_source.At(i);
      long order1_prop=order.GetProperty(property);
      max_order=list_source.At(index);
      long order2_prop=max_order.GetProperty(property);
      if(CompareValues(order1_prop,order2_prop,MORE)) index=i;
     }
   return index;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс ордера в списке                                |
//| с максимальным значением вещественного свойства                  |
//+------------------------------------------------------------------+
int CSelect::FindOrderMax(CArrayObj *list_source,ENUM_ORDER_PROP_DOUBLE property)
  {
   if(list_source==NULL) return WRONG_VALUE;
   int index=0;
   COrder *max_order=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      COrder *order=list_source.At(i);
      double order1_prop=order.GetProperty(property);
      max_order=list_source.At(index);
      double order2_prop=max_order.GetProperty(property);
      if(CompareValues(order1_prop,order2_prop,MORE)) index=i;
     }
   return index;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс ордера в списке                                |
//| с максимальным значением строкового свойства                     |
//+------------------------------------------------------------------+
int CSelect::FindOrderMax(CArrayObj *list_source,ENUM_ORDER_PROP_STRING property)
  {
   if(list_source==NULL) return WRONG_VALUE;
   int index=0;
   COrder *max_order=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      COrder *order=list_source.At(i);
      string order1_prop=order.GetProperty(property);
      max_order=list_source.At(index);
      string order2_prop=max_order.GetProperty(property);
      if(CompareValues(order1_prop,order2_prop,MORE)) index=i;
     }
   return index;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс ордера в списке                                |
//| с минимальным значением целочисленного свойства                  |
//+------------------------------------------------------------------+
int CSelect::FindOrderMin(CArrayObj* list_source,ENUM_ORDER_PROP_INTEGER property)
  {
   int index=0;
   COrder* min_order=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++){
      COrder* order=list_source.At(i);
      long order1_prop=order.GetProperty(property);
      min_order=list_source.At(index);
      long order2_prop=min_order.GetProperty(property);
      if(CompareValues(order1_prop,order2_prop,LESS)) index=i;
      }
   return index;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс ордера в списке                                |
//| с минимальным значением вещественного свойства                   |
//+------------------------------------------------------------------+
int CSelect::FindOrderMin(CArrayObj* list_source,ENUM_ORDER_PROP_DOUBLE property)
  {
   int index=0;
   COrder* min_order=NULL;
   int total=list_source.Total();
   if(total== 0) return WRONG_VALUE;
   for(int i=1; i<total; i++){
      COrder* order=list_source.At(i);
      double order1_prop=order.GetProperty(property);
      min_order=list_source.At(index);
      double order2_prop=min_order.GetProperty(property);
      if(CompareValues(order1_prop,order2_prop,LESS)) index=i;
      }
   return index;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс ордера в списке                                |
//| с минимальным значением строкового свойства                      |
//+------------------------------------------------------------------+
int CSelect::FindOrderMin(CArrayObj* list_source,ENUM_ORDER_PROP_STRING property)
  {
   int index=0;
   COrder* min_order=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++){
      COrder* order=list_source.At(i);
      string order1_prop=order.GetProperty(property);
      min_order=list_source.At(index);
      string order2_prop=min_order.GetProperty(property);
      if(CompareValues(order1_prop,order2_prop,LESS)) index=i;
      }
   return index;
  }
//+------------------------------------------------------------------+
