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
#include "..\Objects\Events\Event.mqh"
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
//+------------------------------------------------------------------+
//| Методы работы с ордерами                                         |
//+------------------------------------------------------------------+
   //--- Возвращает список ордеров, у которых одно из (1) целочисленных, (2) вещественных и (3) строковых свойств удовлетворяет заданному критерию
   static CArrayObj *ByOrderProperty(CArrayObj *list_source,ENUM_ORDER_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode);
   static CArrayObj *ByOrderProperty(CArrayObj *list_source,ENUM_ORDER_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode);
   static CArrayObj *ByOrderProperty(CArrayObj *list_source,ENUM_ORDER_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode);
   //--- Возвращает индекс ордера в списке с максимальным значением (1) целочисленного, (2) вещественного и (3) строкового свойства ордера
   static int        FindOrderMax(CArrayObj *list_source,ENUM_ORDER_PROP_INTEGER property);
   static int        FindOrderMax(CArrayObj *list_source,ENUM_ORDER_PROP_DOUBLE property);
   static int        FindOrderMax(CArrayObj *list_source,ENUM_ORDER_PROP_STRING property);
   //--- Возвращает индекс ордера в списке с минимальным значением (1) целочисленного, (2) вещественного и (3) строкового свойства ордера
   static int        FindOrderMin(CArrayObj *list_source,ENUM_ORDER_PROP_INTEGER property);
   static int        FindOrderMin(CArrayObj *list_source,ENUM_ORDER_PROP_DOUBLE property);
   static int        FindOrderMin(CArrayObj *list_source,ENUM_ORDER_PROP_STRING property);
//+------------------------------------------------------------------+
//| Методы работы с событиями                                        |
//+------------------------------------------------------------------+
   //--- Возвращает список событий, у которых одно из (1) целочисленных, (2) вещественных и (3) строковых свойств удовлетворяет заданному критерию
   static CArrayObj *ByEventProperty(CArrayObj *list_source,ENUM_EVENT_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode);
   static CArrayObj *ByEventProperty(CArrayObj *list_source,ENUM_EVENT_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode);
   static CArrayObj *ByEventProperty(CArrayObj *list_source,ENUM_EVENT_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode);
   //--- Возвращает индекс события в списке с максимальным значением (1) целочисленного, (2) вещественного и (3) строкового свойства события
   static int        FindEventMax(CArrayObj *list_source,ENUM_EVENT_PROP_INTEGER property);
   static int        FindEventMax(CArrayObj *list_source,ENUM_EVENT_PROP_DOUBLE property);
   static int        FindEventMax(CArrayObj *list_source,ENUM_EVENT_PROP_STRING property);
   //--- Возвращает индекс события в списке с минимальным значением (1) целочисленного, (2) вещественного и (3) строкового свойства события
   static int        FindEventMin(CArrayObj *list_source,ENUM_EVENT_PROP_INTEGER property);
   static int        FindEventMin(CArrayObj *list_source,ENUM_EVENT_PROP_DOUBLE property);
   static int        FindEventMin(CArrayObj *list_source,ENUM_EVENT_PROP_STRING property);
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
//| Методы работы со списками ордеров                                |
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
      COrder *obj=list_source.At(i);
      if(!obj.SupportProperty(property)) continue;
      long obj_prop=obj.GetProperty(property);
      if(CompareValues(obj_prop,value,mode)) list.Add(obj);
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
      COrder *obj=list_source.At(i);
      if(!obj.SupportProperty(property)) continue;
      double obj_prop=obj.GetProperty(property);
      if(CompareValues(obj_prop,value,mode)) list.Add(obj);
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
      COrder *obj=list_source.At(i);
      if(!obj.SupportProperty(property)) continue;
      string obj_prop=obj.GetProperty(property);
      if(CompareValues(obj_prop,value,mode)) list.Add(obj);
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
   COrder *max_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      COrder *obj=list_source.At(i);
      long obj1_prop=obj.GetProperty(property);
      max_obj=list_source.At(index);
      long obj2_prop=max_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
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
   COrder *max_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      COrder *obj=list_source.At(i);
      double obj1_prop=obj.GetProperty(property);
      max_obj=list_source.At(index);
      double obj2_prop=max_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
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
   COrder *max_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      COrder *obj=list_source.At(i);
      string obj1_prop=obj.GetProperty(property);
      max_obj=list_source.At(index);
      string obj2_prop=max_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
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
   COrder* min_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++){
      COrder* obj=list_source.At(i);
      long obj1_prop=obj.GetProperty(property);
      min_obj=list_source.At(index);
      long obj2_prop=min_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
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
   COrder* min_obj=NULL;
   int total=list_source.Total();
   if(total== 0) return WRONG_VALUE;
   for(int i=1; i<total; i++){
      COrder* obj=list_source.At(i);
      double obj1_prop=obj.GetProperty(property);
      min_obj=list_source.At(index);
      double obj2_prop=min_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
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
   COrder* min_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++){
      COrder* obj=list_source.At(i);
      string obj1_prop=obj.GetProperty(property);
      min_obj=list_source.At(index);
      string obj2_prop=min_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
      }
   return index;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Методы работы со списками событий                                |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Возвращает список событий, у которых одно из целочисленных       |
//| свойств удовлетворяет заданному критерию                         |
//+------------------------------------------------------------------+
CArrayObj *CSelect::ByEventProperty(CArrayObj *list_source,ENUM_EVENT_PROP_INTEGER property,long value,ENUM_COMPARER_TYPE mode)
  {
   if(list_source==NULL) return NULL;
   CArrayObj *list=new CArrayObj();
   if(list==NULL) return NULL;
   list.FreeMode(false);
   ListStorage.Add(list);
   int total=list_source.Total();
   for(int i=0; i<total; i++)
     {
      CEvent *obj=list_source.At(i);
      if(!obj.SupportProperty(property)) continue;
      long obj_prop=obj.GetProperty(property);
      if(CompareValues(obj_prop,value,mode)) list.Add(obj);
     }
   return list;
  }
//+------------------------------------------------------------------+
//| Возвращает список событий, у которых одно из вещественных        |
//| свойств удовлетворяет заданному критерию                         |
//+------------------------------------------------------------------+
CArrayObj *CSelect::ByEventProperty(CArrayObj *list_source,ENUM_EVENT_PROP_DOUBLE property,double value,ENUM_COMPARER_TYPE mode)
  {
   if(list_source==NULL) return NULL;
   CArrayObj *list=new CArrayObj();
   if(list==NULL) return NULL;
   list.FreeMode(false);
   ListStorage.Add(list);
   for(int i=0; i<list_source.Total(); i++)
     {
      CEvent *obj=list_source.At(i);
      if(!obj.SupportProperty(property)) continue;
      double obj_prop=obj.GetProperty(property);
      if(CompareValues(obj_prop,value,mode)) list.Add(obj);
     }
   return list;
  }
//+------------------------------------------------------------------+
//| Возвращает список событий, у которых одно из строковых           |
//| свойств удовлетворяет заданному критерию                         |
//+------------------------------------------------------------------+
CArrayObj *CSelect::ByEventProperty(CArrayObj *list_source,ENUM_EVENT_PROP_STRING property,string value,ENUM_COMPARER_TYPE mode)
  {
   if(list_source==NULL) return NULL;
   CArrayObj *list=new CArrayObj();
   if(list==NULL) return NULL;
   list.FreeMode(false);
   ListStorage.Add(list);
   for(int i=0; i<list_source.Total(); i++)
     {
      CEvent *obj=list_source.At(i);
      if(!obj.SupportProperty(property)) continue;
      string obj_prop=obj.GetProperty(property);
      if(CompareValues(obj_prop,value,mode)) list.Add(obj);
     }
   return list;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс события в списке                               |
//| с максимальным значением целочисленного свойства                 |
//+------------------------------------------------------------------+
int CSelect::FindEventMax(CArrayObj *list_source,ENUM_EVENT_PROP_INTEGER property)
  {
   if(list_source==NULL) return WRONG_VALUE;
   int index=0;
   CEvent *max_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CEvent *obj=list_source.At(i);
      long obj1_prop=obj.GetProperty(property);
      max_obj=list_source.At(index);
      long obj2_prop=max_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
     }
   return index;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс события в списке                               |
//| с максимальным значением вещественного свойства                  |
//+------------------------------------------------------------------+
int CSelect::FindEventMax(CArrayObj *list_source,ENUM_EVENT_PROP_DOUBLE property)
  {
   if(list_source==NULL) return WRONG_VALUE;
   int index=0;
   CEvent *max_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CEvent *obj=list_source.At(i);
      double obj1_prop=obj.GetProperty(property);
      max_obj=list_source.At(index);
      double obj2_prop=max_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
     }
   return index;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс события в списке                               |
//| с максимальным значением строкового свойства                     |
//+------------------------------------------------------------------+
int CSelect::FindEventMax(CArrayObj *list_source,ENUM_EVENT_PROP_STRING property)
  {
   if(list_source==NULL) return WRONG_VALUE;
   int index=0;
   CEvent *max_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++)
     {
      CEvent *obj=list_source.At(i);
      string obj1_prop=obj.GetProperty(property);
      max_obj=list_source.At(index);
      string obj2_prop=max_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,MORE)) index=i;
     }
   return index;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс события в списке                               |
//| с минимальным значением целочисленного свойства                  |
//+------------------------------------------------------------------+
int CSelect::FindEventMin(CArrayObj* list_source,ENUM_EVENT_PROP_INTEGER property)
  {
   int index=0;
   CEvent* min_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++){
      CEvent* obj=list_source.At(i);
      long obj1_prop=obj.GetProperty(property);
      min_obj=list_source.At(index);
      long obj2_prop=min_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
      }
   return index;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс события в списке                               |
//| с минимальным значением вещественного свойства                   |
//+------------------------------------------------------------------+
int CSelect::FindEventMin(CArrayObj* list_source,ENUM_EVENT_PROP_DOUBLE property)
  {
   int index=0;
   CEvent* min_obj=NULL;
   int total=list_source.Total();
   if(total== 0) return WRONG_VALUE;
   for(int i=1; i<total; i++){
      CEvent* obj=list_source.At(i);
      double obj1_prop=obj.GetProperty(property);
      min_obj=list_source.At(index);
      double obj2_prop=min_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
      }
   return index;
  }
//+------------------------------------------------------------------+
//| Возвращает индекс события в списке                               |
//| с минимальным значением строкового свойства                      |
//+------------------------------------------------------------------+
int CSelect::FindEventMin(CArrayObj* list_source,ENUM_EVENT_PROP_STRING property)
  {
   int index=0;
   CEvent* min_obj=NULL;
   int total=list_source.Total();
   if(total==0) return WRONG_VALUE;
   for(int i=1; i<total; i++){
      CEvent* obj=list_source.At(i);
      string obj1_prop=obj.GetProperty(property);
      min_obj=list_source.At(index);
      string obj2_prop=min_obj.GetProperty(property);
      if(CompareValues(obj1_prop,obj2_prop,LESS)) index=i;
      }
   return index;
  }
//+------------------------------------------------------------------+
