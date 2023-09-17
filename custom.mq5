// Кроссплатформенный скрипт создает отчет истории торгов с фильтрами по символу, мэджику, времени и других параметров.

// MQL4&5-code
#property strict
#property script_show_inputs

input string inFileName = "Report.htm"; // FileName
input bool inSymbolFilter = true;       // true - Current Symbol, false - All Symbols
input long inMagicFilter = -1;          // MagicFilter (negative - All Magics)
input bool inPending = false;           // Pending (true - include)
input bool inBalance = false;           // Balance (true - include)
input datetime inStartTime = 0;         // OrderCloseTime >= this time
input datetime inEndTime = INT_MAX;     // OrderCloseTime <= this time

input bool inOpenBrowser = true; // Open Browser with Report - DLL!

#import "shell32.dll"
  int ShellExecuteW( int hwnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, int nShowCmd );
#import

#ifdef __MQL5__
  #include <MT4Orders.mqh> // https://www.mql5.com/ru/code/16006

  #define BASEPATH (TerminalInfoString(TERMINAL_PATH) + "\\MQL5\\Files\\")
#else // __MQL5__
  #define BASEPATH (TerminalInfoString(TERMINAL_PATH) + "\\MQL4\\Files\\")
#endif // __MQL5__

#include <Report.mqh> // https://www.mql5.com/ru/code/18801

void OnStart()
{
  REPORT_FILTER Filter;

  Filter.Symb = inSymbolFilter ? _Symbol : NULL;
  Filter.Magic = inMagicFilter < 0 ? -1 : inMagicFilter;
  Filter.Pending = inPending;
  Filter.Balance = inBalance;
  Filter.StartTime = inStartTime;
  Filter.EndTime = inEndTime;

  if (REPORT::ToFile(inFileName, Filter) && inOpenBrowser && MQLInfoInteger(MQL_DLLS_ALLOWED))
    ShellExecuteW(0, "Open", BASEPATH + inFileName, NULL, NULL, 3); // https://www.mql5.com/ru/forum/23223#comment_1741093
}