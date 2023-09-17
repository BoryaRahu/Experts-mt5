//--- Связь с основным файлом эксперта
#include "..\MultiSymbolPendingOrders.mq5"
//--- Подключаем свои библиотеки
#include "Enums.mqh"
#include "InitializeArrays.mqh"
#include "TradeSignals.mqh"
#include "TradeFunctions.mqh"
#include "ToString.mqh"
#include "Auxiliary.mqh"
//+------------------------------------------------------------------+
//| Возвращает текстовое описание причины деинициализации            |
//+------------------------------------------------------------------+
string GetDeinitReasonText(int reason_code)
  {
   string text="";
//---
   switch(reason_code)
     {
      case REASON_PROGRAM :     // 0
         text="Эксперт прекратил свою работу, вызвав функцию ExpertRemove().";      break;
      case REASON_REMOVE :      // 1
         text="Программа '"+EXPERT_NAME+"' была удалена с графика.";                break;
      case REASON_RECOMPILE :   // 2
         text="Программа '"+EXPERT_NAME+"' была перекомпилирована.";                break;
      case REASON_CHARTCHANGE : // 3
         text="Символ или период графика был изменен.";                             break;
      case REASON_CHARTCLOSE :  // 4
         text="График закрыт.";                                                     break;
      case REASON_PARAMETERS :  // 5
         text="Входные параметры были изменены пользователем.";                     break;
      case REASON_ACCOUNT :     // 6
         text="Активирован другой счет.";                                           break;
      case REASON_TEMPLATE :    // 7
         text="Применен другой шаблон графика.";                                    break;
      case REASON_INITFAILED :  // 8
         text="Признак того, что обработчик OnInit() вернул ненулевое значение.";   break;
      case REASON_CLOSE :       // 9
         text="Терминал был закрыт.";                                               break;
      default : text="Причина не определена.";
     }
//---
   return text;
  }
//+------------------------------------------------------------------+
//| Возвращает описание ошибки                                       |
//+------------------------------------------------------------------+
string ErrorDescription(int error_code)
  {
   string error_string="";
//---
   switch(error_code)
     {
      //--- Коды возврата торгового сервера

      case 10004: error_string="Реквота";                                                         break;
      case 10006: error_string="Запрос отвергнут";                                                break;
      case 10007: error_string="Запрос отменён трейдером";                                        break;
      case 10008: error_string="Ордер размещён";                                                  break;
      case 10009: error_string="Заявка выполнена";                                                break;
      case 10010: error_string="Заявка выполнена частично";                                       break;
      case 10011: error_string="Ошибка обработки запроса";                                        break;
      case 10012: error_string="Запрос отменён по истечению времени";                             break;
      case 10013: error_string="Неправильный запрос";                                             break;
      case 10014: error_string="Неправильный объём в запросе";                                    break;
      case 10015: error_string="Неправильная цена в запросе";                                     break;
      case 10016: error_string="Неправильные стопы в запросе";                                    break;
      case 10017: error_string="Торговля запрещена";                                              break;
      case 10018: error_string="Рынок закрыт";                                                    break;
      case 10019: error_string="Нет достаточных денежных средств";                                break;
      case 10020: error_string="Цены изменились";                                                 break;
      case 10021: error_string="Отсутствуют котировки для обработки запроса";                     break;
      case 10022: error_string="Неверная дата истечения ордера в запросе";                        break;
      case 10023: error_string="Состояние ордера изменилось";                                     break;
      case 10024: error_string="Слишком частые запросы";                                          break;
      case 10025: error_string="В запросе нет изменений";                                         break;
      case 10026: error_string="Автотрейдинг запрещён трейдером";                                 break;
      case 10027: error_string="Автотрейдинг запрещён клиентским терминалом";                     break;
      case 10028: error_string="Запрос заблокирован для обработки";                               break;
      case 10029: error_string="Ордер или позиция заморожены";                                    break;
      case 10030: error_string="Указан неподдерживаемый тип исполнения ордера по остатку";        break;
      case 10031: error_string="Нет соединения с торговым сервером";                              break;
      case 10032: error_string="Операция разрешена только для реальных счетов";                   break;
      case 10033: error_string="Достигнут лимит на количество отложенных ордеров";                break;
      case 10034: error_string="Достигнут лимит на объём ордеров и позиций для данного символа";  break;

      //--- Ошибки времени выполнения

      case 0:  // Операция выполнена успешно
      case 4001: error_string="Неожиданная внутренняя ошибка";                                                                                                   break;
      case 4002: error_string="Ошибочный параметр при внутреннем вызове функции клиентского терминала";                                                          break;
      case 4003: error_string="Ошибочный параметр при вызове системной функции";                                                                                 break;
      case 4004: error_string="Недостаточно памяти для выполнения системной функции";                                                                            break;
      case 4005: error_string="Структура содержит объекты строк и/или динамических массивов и/или структуры с такими объектами и/или классы";                    break;
      case 4006: error_string="Массив неподходящего типа, неподходящего размера или испорченный объект динамического массива";                                   break;
      case 4007: error_string="Недостаточно памяти для перераспределения массива либо попытка изменения размера статического массива";                           break;
      case 4008: error_string="Недостаточно памяти для перераспределения строки";                                                                                break;
      case 4009: error_string="Неинициализированная строка";                                                                                                     break;
      case 4010: error_string="Неправильное значение даты и/или времени";                                                                                        break;
      case 4011: error_string="Запрашиваемый размер массива превышает 2 гигабайта";                                                                              break;
      case 4012: error_string="Ошибочный указатель";                                                                                                             break;
      case 4013: error_string="Ошибочный тип указателя";                                                                                                         break;
      case 4014: error_string="Системная функция не разрешена для вызова";                                                                                       break;
      //-- Графики
      case 4101: error_string="Ошибочный идентификатор графика";                                                                                                 break;
      case 4102: error_string="График не отвечает";                                                                                                              break;
      case 4103: error_string="График не найден";                                                                                                                break;
      case 4104: error_string="У графика нет эксперта, который мог бы обработать событие";                                                                       break;
      case 4105: error_string="Ошибка открытия графика";                                                                                                         break;
      case 4106: error_string="Ошибка при изменении для графика символа и периода";                                                                              break;
      case 4107: error_string="Ошибочный параметр для таймера";                                                                                                  break;
      case 4108: error_string="Ошибка при создании таймера";                                                                                                     break;
      case 4109: error_string="Ошибочный идентификатор свойства графика";                                                                                        break;
      case 4110: error_string="Ошибка при создании скриншота";                                                                                                   break;
      case 4111: error_string="Ошибка навигации по графику";                                                                                                     break;
      case 4112: error_string="Ошибка при применении шаблона";                                                                                                   break;
      case 4113: error_string="Подокно, содержащее указанный индикатор, не найдено";                                                                             break;
      case 4114: error_string="Ошибка при добавлении индикатора на график";                                                                                      break;
      case 4115: error_string="Ошибка при удалении индикатора с графика";                                                                                        break;
      case 4116: error_string="Индикатор не найден на указанном графике";                                                                                        break;
      //-- Графические объекты
      case 4201: error_string="Ошибка при работе с графическим объектом";                                                                                        break;
      case 4202: error_string="Графический объект не найден";                                                                                                    break;
      case 4203: error_string="Ошибочный идентификатор свойства графического объекта";                                                                           break;
      case 4204: error_string="Невозможно получить дату, соответствующую значению";                                                                              break;
      case 4205: error_string="Невозможно получить значение, соответствующее дате";                                                                              break;
      //-- MarketInfo
      case 4301: error_string="Неизвестный символ";                                                                                                              break;
      case 4302: error_string="Символ не выбран в MarketWatch";                                                                                                  break;
      case 4303: error_string="Ошибочный идентификатор свойства символа";                                                                                        break;
      case 4304: error_string="Время последнего тика неизвестно (тиков не было)";                                                                                break;
      //-- Доступ к истории
      case 4401: error_string="Запрашиваемая история не найдена!";                                                                                               break;
      case 4402: error_string="Ошибочный идентификатор свойства истории";                                                                                        break;
      //-- Global_Variables
      case 4501: error_string="Глобальная переменная клиентского терминала не найдена";                                                                          break;
      case 4502: error_string="Глобальная переменная клиентского терминала с таким именем уже существует";                                                       break;
      case 4510: error_string="Не удалось отправить письмо";                                                                                                     break;
      case 4511: error_string="Не удалось воспроизвести звук";                                                                                                   break;
      case 4512: error_string="Ошибочный идентификатор свойства программы";                                                                                      break;
      case 4513: error_string="Ошибочный идентификатор свойства терминала";                                                                                      break;
      case 4514: error_string="Не удалось отправить файл по ftp";                                                                                                break;
      //-- Буфера пользовательских индикаторов
      case 4601: error_string="Недостаточно памяти для распределения индикаторных буферов";                                                                      break;
      case 4602: error_string="Ошибочный индекс своего индикаторного буфера";                                                                                    break;
      //-- Свойства пользовательских индикаторов
      case 4603: error_string="Ошибочный идентификатор свойства пользовательского индикатора";                                                                   break;
      //-- Account
      case 4701: error_string="Ошибочный идентификатор свойства счета";                                                                                          break;
      case 4751: error_string="Ошибочный идентификатор свойства торговли";                                                                                       break;
      case 4752: error_string="Торговля для эксперта запрещена";                                                                                                 break;
      case 4753: error_string="Позиция не найдена";                                                                                                              break;
      case 4754: error_string="Ордер не найден";                                                                                                                 break;
      case 4755: error_string="Сделка не найдена";                                                                                                               break;
      case 4756: error_string="Не удалось отправить торговый запрос";                                                                                            break;
      //-- Индикаторы
      case 4801: error_string="Неизвестный символ";                                                                                                              break;
      case 4802: error_string="Индикатор не может быть создан";                                                                                                  break;
      case 4803: error_string="Недостаточно памяти для добавления индикатора";                                                                                   break;
      case 4804: error_string="Индикатор не может быть применен к другому индикатору";                                                                           break;
      case 4805: error_string="Ошибка при добавлении индикатора";                                                                                                break;
      case 4806: error_string="Запрошенные данные не найдены";                                                                                                   break;
      case 4807: error_string="Ошибочный хэндл индикатора";                                                                                                      break;
      case 4808: error_string="Неправильное количество параметров при создании индикатора";                                                                      break;
      case 4809: error_string="Отсутствуют параметры при создании индикатора";                                                                                   break;
      case 4810: error_string="Первым параметром в массиве должно быть имя пользовательского индикатора";                                                        break;
      case 4811: error_string="Неправильный тип параметра в массиве при создании индикатора";                                                                    break;
      case 4812: error_string="Ошибочный индекс запрашиваемого индикаторного буфера";                                                                            break;
      //-- Стакан цен
      case 4901: error_string="Стакан цен не может быть добавлен";                                                                                               break;
      case 4902: error_string="Стакан цен не может быть удален";                                                                                                 break;
      case 4903: error_string="Данные стакана цен не могут быть получены";                                                                                       break;
      case 4904: error_string="Ошибка при подписке на получение новых данных стакана цен";                                                                       break;
      //-- Файловые операции
      case 5001: error_string="Не может быть открыто одновременно более 64 файлов";                                                                              break;
      case 5002: error_string="Недопустимое имя файла";                                                                                                          break;
      case 5003: error_string="Слишком длинное имя файла";                                                                                                       break;
      case 5004: error_string="Ошибка открытия файла";                                                                                                           break;
      case 5005: error_string="Недостаточно памяти для кеша чтения";                                                                                             break;
      case 5006: error_string="Ошибка удаления файла";                                                                                                           break;
      case 5007: error_string="Файл с таким хэндлом уже был закрыт, либо не открывался вообще";                                                                  break;
      case 5008: error_string="Ошибочный хэндл файла";                                                                                                           break;
      case 5009: error_string="Файл должен быть открыт для записи";                                                                                              break;
      case 5010: error_string="Файл должен быть открыт для чтения";                                                                                              break;
      case 5011: error_string="Файл должен быть открыт как бинарный";                                                                                            break;
      case 5012: error_string="Файл должен быть открыт как текстовый";                                                                                           break;
      case 5013: error_string="Файл должен быть открыт как текстовый или CSV";                                                                                   break;
      case 5014: error_string="Файл должен быть открыт как CSV";                                                                                                 break;
      case 5015: error_string="Ошибка чтения файла";                                                                                                             break;
      case 5016: error_string="Должен быть указан размер строки, так как файл открыт как бинарный";                                                              break;
      case 5017: error_string="Для строковых массивов должен быть текстовый файл, для остальных – бинарный";                                                     break;
      case 5018: error_string="Это не файл, а директория";                                                                                                       break;
      case 5019: error_string="Файл не существует";                                                                                                              break;
      case 5020: error_string="Файл не может быть переписан";                                                                                                    break;
      case 5021: error_string="Ошибочное имя директории";                                                                                                        break;
      case 5022: error_string="Директория не существует";                                                                                                        break;
      case 5023: error_string="Это файл, а не директория";                                                                                                       break;
      case 5024: error_string="Директория не может быть удалена";                                                                                                break;
      case 5025: error_string="Не удалось очистить директорию (возможно, один или несколько файлов заблокированы и операция удаления не удалась)";               break;
      //-- Преобразование строк
      case 5030: error_string="В строке нет даты";                                                                                                               break;
      case 5031: error_string="В строке ошибочная дата";                                                                                                         break;
      case 5032: error_string="В строке ошибочное время";                                                                                                        break;
      case 5033: error_string="Ошибка преобразования строки в дату";                                                                                             break;
      case 5034: error_string="Недостаточно памяти для строки";                                                                                                  break;
      case 5035: error_string="Длина строки меньше, чем ожидалось";                                                                                              break;
      case 5036: error_string="Слишком большое число, больше, чем ULONG_MAX";                                                                                    break;
      case 5037: error_string="Ошибочная форматная строка";                                                                                                      break;
      case 5038: error_string="Форматных спецификаторов больше, чем параметров";                                                                                 break;
      case 5039: error_string="Параметров больше, чем форматных спецификаторов";                                                                                 break;
      case 5040: error_string="Испорченный параметр типа string";                                                                                                break;
      case 5041: error_string="Позиция за пределами строки";                                                                                                     break;
      case 5042: error_string="К концу строки добавлен 0, бесполезная операция";                                                                                 break;
      case 5043: error_string="Неизвестный тип данных при конвертации в строку";                                                                                 break;
      case 5044: error_string="Испорченный объект строки";                                                                                                       break;
      //-- Работа с массивами
      case 5050: error_string="Копирование несовместимых массивов. Строковый массив может быть скопирован только в строковый, а числовой массив – в числовой";   break;
      case 5051: error_string="Приемный массив объявлен как AS_SERIES, и он недостаточного размера";                                                             break;
      case 5052: error_string="Слишком маленький массив, стартовая позиция за пределами массива";                                                                break;
      case 5053: error_string="Массив нулевой длины";                                                                                                            break;
      case 5054: error_string="Должен быть числовой массив";                                                                                                     break;
      case 5055: error_string="Должен быть одномерный массив";                                                                                                   break;
      case 5056: error_string="Таймсерия не может быть использована";                                                                                            break;
      case 5057: error_string="Должен быть массив типа double";                                                                                                  break;
      case 5058: error_string="Должен быть массив типа float";                                                                                                   break;
      case 5059: error_string="Должен быть массив типа long";                                                                                                    break;
      case 5060: error_string="Должен быть массив типа int";                                                                                                     break;
      case 5061: error_string="Должен быть массив типа short";                                                                                                   break;
      case 5062: error_string="Должен быть массив типа char";                                                                                                    break;
      //-- Пользовательские ошибки

      default: error_string="Ошибка не определена";
     }
//---
   return(error_string);
  }