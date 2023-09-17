//+------------------------------------------------------------------+
//|                                                 OrderControl.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                             https://mql5.com/ru/users/artmedia70 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com/ru/users/artmedia70"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Включаемые файлы                                                 |
//+------------------------------------------------------------------+
#include "..\Defines.mqh"
#include "..\Objects\Orders\Order.mqh"
#include <Object.mqh>
//+------------------------------------------------------------------+
//| Класс контроля ордеров и позиций                                 |
//+------------------------------------------------------------------+
class COrderControl : public CObject
  {
private:
   ENUM_CHANGE_TYPE  m_changed_type;                                    // Тип изменения ордера
   MqlTick           m_tick;                                            // Структура тика
   string            m_symbol;                                          // Символ
   ulong             m_position_id;                                     // Идентификатор позиции
   ulong             m_ticket;                                          // Тикет ордера
   long              m_magic;                                           // Магический номер
   ulong             m_type_order;                                      // Тип ордера
   ulong             m_type_order_prev;                                 // Предыдущий тип ордера
   double            m_price;                                           // Цена ордера
   double            m_price_prev;                                      // Предыдущая цена ордера
   double            m_stop;                                            // Цена StopLoss
   double            m_stop_prev;                                       // Предыдущая цена StopLoss
   double            m_take;                                            // Цена TakeProfit
   double            m_take_prev;                                       // Предыдущая цена TakeProfit
   double            m_volume;                                          // Объём ордера
   datetime          m_time;                                            // Время установки ордера
   datetime          m_time_prev;                                       // Предыдущее время установки ордера
   int               m_change_code;                                     // Код изменения ордера
//--- возвращает факт наличия флага изменения свойства
   bool              IsPresentChangeFlag(const int change_flag)   const { return (this.m_change_code & change_flag)==change_flag;   }
//--- Рассчитывает тип изменения параметров ордера
   void              CalculateChangedType(void);
public:
//--- Устанавливает (1,2) текущий и прошлый тип (2,3) текущую и прошлую цену, (4,5) текущий и прошлый StopLoss,
//--- (6,7) текущий и прошлый TakeProfit, (8,9) текущее и прошлое время установки, (10) объём
   void              SetTypeOrder(const ulong type)                     { this.m_type_order=type;        }
   void              SetTypeOrderPrev(const ulong type)                 { this.m_type_order_prev=type;   }
   void              SetPrice(const double price)                       { this.m_price=price;            }
   void              SetPricePrev(const double price)                   { this.m_price_prev=price;       }
   void              SetStopLoss(const double stop_loss)                { this.m_stop=stop_loss;         }
   void              SetStopLossPrev(const double stop_loss)            { this.m_stop_prev=stop_loss;    }
   void              SetTakeProfit(const double take_profit)            { this.m_take=take_profit;       }
   void              SetTakeProfitPrev(const double take_profit)        { this.m_take_prev=take_profit;  }
   void              SetTime(const datetime time)                       { this.m_time=time;              }
   void              SetTimePrev(const datetime time)                   { this.m_time_prev=time;         }
   void              SetVolume(const double volume)                     { this.m_volume=volume;          }
//--- Устанавливает (1) тип изменения, (2) новое текущее состояние
   void              SetChangedType(const ENUM_CHANGE_TYPE type)        { this.m_changed_type=type;      }
   void              SetNewState(COrder* order);
//--- Проверяет и устанавливает флаги изменения параметров ордера и возвращает тип изменения
   ENUM_CHANGE_TYPE  ChangeControl(COrder* compared_order);

//--- Возвращает (1,2,3,4) идентификатор позиции, тикет, магик и символ, (5,6) текущий и прошлый тип (7,8) текущую и прошлую цену,
//--- (9,10) текущий и прошлый StopLoss, (11,12) текущий и прошлый TakeProfit, (13,14) текущее и прошлое время установки, (15) объём
   ulong             PositionID(void)                             const { return this.m_position_id;     }
   ulong             Ticket(void)                                 const { return this.m_ticket;          }
   long              Magic(void)                                  const { return this.m_magic;           }
   string            Symbol(void)                                 const { return this.m_symbol;          }
   ulong             TypeOrder(void)                              const { return this.m_type_order;      }
   ulong             TypeOrderPrev(void)                          const { return this.m_type_order_prev; }
   double            Price(void)                                  const { return this.m_price;           }
   double            PricePrev(void)                              const { return this.m_price_prev;      }
   double            StopLoss(void)                               const { return this.m_stop;            }
   double            StopLossPrev(void)                           const { return this.m_stop_prev;       }
   double            TakeProfit(void)                             const { return this.m_take;            }
   double            TakeProfitPrev(void)                         const { return this.m_take_prev;       }
   ulong             Time(void)                                   const { return this.m_time;            }
   ulong             TimePrev(void)                               const { return this.m_time_prev;       }
   double            Volume(void)                                 const { return this.m_volume;          }
//--- Возвращает тип изменения
   ENUM_CHANGE_TYPE  GetChangeType(void)                          const { return this.m_changed_type;    }

//--- Конструктор
                     COrderControl(const ulong position_id,const ulong ticket,const long magic,const string symbol) :
                                                                        m_change_code(CHANGE_TYPE_FLAG_NO_CHANGE),
                                                                        m_changed_type(CHANGE_TYPE_NO_CHANGE),
                                                                        m_position_id(position_id),m_symbol(symbol),m_ticket(ticket),m_magic(magic) {;}
  };
//+------------------------------------------------------------------+
//| Проверяет и устанавливает флаги изменения параметров ордера      |
//+------------------------------------------------------------------+
ENUM_CHANGE_TYPE COrderControl::ChangeControl(COrder *compared_order)
  {
   this.m_change_code=CHANGE_TYPE_FLAG_NO_CHANGE;
   if(compared_order==NULL || compared_order.Ticket()!=this.m_ticket)
      return CHANGE_TYPE_NO_CHANGE;
   if(compared_order.Status()==ORDER_STATUS_MARKET_ORDER || compared_order.Status()==ORDER_STATUS_MARKET_PENDING)
      this.m_change_code+=CHANGE_TYPE_FLAG_ORDER;
   if(compared_order.TypeOrder()!=this.m_type_order)
      this.m_change_code+=CHANGE_TYPE_FLAG_TYPE;
   if(compared_order.PriceOpen()!=this.m_price)
      this.m_change_code+=CHANGE_TYPE_FLAG_PRICE;
   if(compared_order.StopLoss()!=this.m_stop)
      this.m_change_code+=CHANGE_TYPE_FLAG_STOP;
   if(compared_order.TakeProfit()!=this.m_take)
      this.m_change_code+=CHANGE_TYPE_FLAG_TAKE;
   this.CalculateChangedType();
   return this.GetChangeType();
  }
//+------------------------------------------------------------------+
//| Рассчитывает тип изменения параметров ордера                     |
//+------------------------------------------------------------------+
void COrderControl::CalculateChangedType(void)
  {
   this.m_changed_type=
     (
      //--- Если стоит флаг ордера
      this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_ORDER) ? 
        (
         //--- Если сработал StopLimit-ордер
         this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_TYPE)    ?  CHANGE_TYPE_ORDER_TYPE :
         //--- Если модифицирована цена установки ордера
         this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_PRICE)   ? 
           (
            //--- Если вместе с ценой установки модифицированы StopLoss и TakeProfit
            this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_TAKE) && this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_STOP) ? CHANGE_TYPE_ORDER_PRICE_STOP_LOSS_TAKE_PROFIT :
            //--- Если вместе с ценой установки модифицирован TakeProfit
            this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_TAKE) ? CHANGE_TYPE_ORDER_PRICE_TAKE_PROFIT : 
            //--- Если вместе с ценой установки модифицирован StopLoss
            this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_STOP) ? CHANGE_TYPE_ORDER_PRICE_STOP_LOSS   :
            //--- Модифицирована только цена установки ордера
            CHANGE_TYPE_ORDER_PRICE
           ) : 
         //--- Цена установки не модифицирована
         //--- Если модифицированы StopLoss и TakeProfit
         this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_TAKE) && this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_STOP) ? CHANGE_TYPE_ORDER_STOP_LOSS_TAKE_PROFIT :
         //--- Если модифицирован TakeProfit
         this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_TAKE) ? CHANGE_TYPE_ORDER_TAKE_PROFIT : 
         //--- Если модифицирован StopLoss
         this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_STOP) ? CHANGE_TYPE_ORDER_STOP_LOSS   :
         //--- Нет изменений
         CHANGE_TYPE_NO_CHANGE
        ) : 
      //--- Позиция
      //--- Если у позиции модифицированы StopLoss и TakeProfit
      this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_TAKE) && this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_STOP) ? CHANGE_TYPE_POSITION_STOP_LOSS_TAKE_PROFIT :
      //--- Если у позиции модифицирован TakeProfit
      this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_TAKE) ? CHANGE_TYPE_POSITION_TAKE_PROFIT : 
      //--- Если у позиции модифицирован StopLoss
      this.IsPresentChangeFlag(CHANGE_TYPE_FLAG_STOP) ? CHANGE_TYPE_POSITION_STOP_LOSS   :
      //--- Нет изменений
      CHANGE_TYPE_NO_CHANGE
     );
  }
//+------------------------------------------------------------------+
//| Устанавливает новое текущее состояние                            |
//+------------------------------------------------------------------+
void COrderControl::SetNewState(COrder* order)
  {
   if(order==NULL || !::SymbolInfoTick(this.Symbol(),this.m_tick))
      return;
   //--- Новый тип
   this.SetTypeOrderPrev(this.TypeOrder());
   this.SetTypeOrder(order.TypeOrder());
   //--- Новая цена
   this.SetPricePrev(this.Price());
   this.SetPrice(order.PriceOpen());
   //--- Новый StopLoss
   this.SetStopLossPrev(this.StopLoss());
   this.SetStopLoss(order.StopLoss());
   //--- Новый TakeProfit
   this.SetTakeProfitPrev(this.TakeProfit());
   this.SetTakeProfit(order.TakeProfit());
   //--- Новое время
   this.SetTimePrev(this.Time());
   this.SetTime(this.m_tick.time_msc);
  }
//+------------------------------------------------------------------+
