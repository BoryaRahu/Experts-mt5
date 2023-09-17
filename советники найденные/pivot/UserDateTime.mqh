//+------------------------------------------------------------------+
//|                                                 UserDateTime.mqh |
//|                                           Copyright 2015, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, denkir"
#property link      "https://login.mql5.com/ru/users/denkir"
#property strict
//---
#include <Tools\DateTime.mqh>
#include <Strings\String.mqh>
//+------------------------------------------------------------------+
//| Structure CUserDateTime.                                         |
//| Purpose: Working with dates and time.                            |
//|         Extends the CDateTime structure.                         |
//+------------------------------------------------------------------+
struct SUserDateTime : public CDateTime
  {
   datetime          DateOfDay(void);
   datetime          FillDateByString(const string _date,const string _hour,const string _minute);
   string            FormatTo24(const string _am_pm_time_str);
  };
//+------------------------------------------------------------------+
//| The day format date                                              |
//+------------------------------------------------------------------+
datetime SUserDateTime::DateOfDay(void)
  {
   datetime curr_date=this.DateTime();
   string curr_date_str=TimeToString(curr_date,TIME_DATE);
//---
   return StringToTime(curr_date_str);
  }
//+------------------------------------------------------------------+
//| Составить дату из дня, часов и минут                             |
//+------------------------------------------------------------------+
datetime SUserDateTime::FillDateByString(const string _date,const string _hour,
                                         const string _minute)
  {
   string curr_time_str=_date+" "+_hour+":"+_minute;
   return StringToTime(curr_time_str);
  }
//+------------------------------------------------------------------+
//| Перевести строку hh:mm в формат 24 часов                         |
//+------------------------------------------------------------------+
string SUserDateTime::FormatTo24(const string _am_pm_time_str)
  {
   string format24_str=NULL;
   int str_len=StringLen(_am_pm_time_str);
   CString str_to_trim;
   str_to_trim.Assign(_am_pm_time_str);
//---
   if(str_len>0)
     {
      //--- AM
      int right_trim=str_to_trim.TrimRight("am");
      if(right_trim>1)
        {
         //--- hour 
         int del_idx=str_to_trim.Find(0,":");
         if(del_idx>-1)
           {
            string hour_str=str_to_trim.Left(del_idx);
            int hour_val=(int)StringToInteger(hour_str);
            if(hour_val==12)
               hour_val=0;
            //---
            string right_str=str_to_trim.Mid(del_idx,3);
            format24_str=IntegerToString(hour_val)+right_str;
           }
        }
      //--- PM
      else if(str_to_trim.TrimRight("p")==1)
        {
         //--- hour 
         int del_idx=str_to_trim.Find(0,":");
         if(del_idx>-1)
           {
            string hour_str=str_to_trim.Left(del_idx);
            int hour_val=(int)StringToInteger(hour_str);
            if(hour_val>12)
               hour_val+=12;
            //---
            string right_str=str_to_trim.Mid(del_idx,3);
            format24_str=IntegerToString(hour_val)+right_str;
           }
        }
     }
//---
   return format24_str;
  }

//--- [EOF]
