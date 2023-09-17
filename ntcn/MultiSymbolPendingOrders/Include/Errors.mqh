//--- ����� � �������� ������ ��������
#include "..\MultiSymbolPendingOrders.mq5"
//--- ���������� ���� ����������
#include "Enums.mqh"
#include "InitializeArrays.mqh"
#include "TradeSignals.mqh"
#include "TradeFunctions.mqh"
#include "ToString.mqh"
#include "Auxiliary.mqh"
//+------------------------------------------------------------------+
//| ���������� ��������� �������� ������� ���������������            |
//+------------------------------------------------------------------+
string GetDeinitReasonText(int reason_code)
  {
   string text="";
//---
   switch(reason_code)
     {
      case REASON_PROGRAM :     // 0
         text="������� ��������� ���� ������, ������ ������� ExpertRemove().";      break;
      case REASON_REMOVE :      // 1
         text="��������� '"+EXPERT_NAME+"' ���� ������� � �������.";                break;
      case REASON_RECOMPILE :   // 2
         text="��������� '"+EXPERT_NAME+"' ���� �����������������.";                break;
      case REASON_CHARTCHANGE : // 3
         text="������ ��� ������ ������� ��� �������.";                             break;
      case REASON_CHARTCLOSE :  // 4
         text="������ ������.";                                                     break;
      case REASON_PARAMETERS :  // 5
         text="������� ��������� ���� �������� �������������.";                     break;
      case REASON_ACCOUNT :     // 6
         text="����������� ������ ����.";                                           break;
      case REASON_TEMPLATE :    // 7
         text="�������� ������ ������ �������.";                                    break;
      case REASON_INITFAILED :  // 8
         text="������� ����, ��� ���������� OnInit() ������ ��������� ��������.";   break;
      case REASON_CLOSE :       // 9
         text="�������� ��� ������.";                                               break;
      default : text="������� �� ����������.";
     }
//---
   return text;
  }
//+------------------------------------------------------------------+
//| ���������� �������� ������                                       |
//+------------------------------------------------------------------+
string ErrorDescription(int error_code)
  {
   string error_string="";
//---
   switch(error_code)
     {
      //--- ���� �������� ��������� �������

      case 10004: error_string="�������";                                                         break;
      case 10006: error_string="������ ���������";                                                break;
      case 10007: error_string="������ ������ ���������";                                        break;
      case 10008: error_string="����� ��������";                                                  break;
      case 10009: error_string="������ ���������";                                                break;
      case 10010: error_string="������ ��������� ��������";                                       break;
      case 10011: error_string="������ ��������� �������";                                        break;
      case 10012: error_string="������ ������ �� ��������� �������";                             break;
      case 10013: error_string="������������ ������";                                             break;
      case 10014: error_string="������������ ����� � �������";                                    break;
      case 10015: error_string="������������ ���� � �������";                                     break;
      case 10016: error_string="������������ ����� � �������";                                    break;
      case 10017: error_string="�������� ���������";                                              break;
      case 10018: error_string="����� ������";                                                    break;
      case 10019: error_string="��� ����������� �������� �������";                                break;
      case 10020: error_string="���� ����������";                                                 break;
      case 10021: error_string="����������� ��������� ��� ��������� �������";                     break;
      case 10022: error_string="�������� ���� ��������� ������ � �������";                        break;
      case 10023: error_string="��������� ������ ����������";                                     break;
      case 10024: error_string="������� ������ �������";                                          break;
      case 10025: error_string="� ������� ��� ���������";                                         break;
      case 10026: error_string="������������ �������� ���������";                                 break;
      case 10027: error_string="������������ �������� ���������� ����������";                     break;
      case 10028: error_string="������ ������������ ��� ���������";                               break;
      case 10029: error_string="����� ��� ������� ����������";                                    break;
      case 10030: error_string="������ ���������������� ��� ���������� ������ �� �������";        break;
      case 10031: error_string="��� ���������� � �������� ��������";                              break;
      case 10032: error_string="�������� ��������� ������ ��� �������� ������";                   break;
      case 10033: error_string="��������� ����� �� ���������� ���������� �������";                break;
      case 10034: error_string="��������� ����� �� ����� ������� � ������� ��� ������� �������";  break;

      //--- ������ ������� ����������

      case 0:  // �������� ��������� �������
      case 4001: error_string="����������� ���������� ������";                                                                                                   break;
      case 4002: error_string="��������� �������� ��� ���������� ������ ������� ����������� ���������";                                                          break;
      case 4003: error_string="��������� �������� ��� ������ ��������� �������";                                                                                 break;
      case 4004: error_string="������������ ������ ��� ���������� ��������� �������";                                                                            break;
      case 4005: error_string="��������� �������� ������� ����� �/��� ������������ �������� �/��� ��������� � ������ ��������� �/��� ������";                    break;
      case 4006: error_string="������ ������������� ����, ������������� ������� ��� ����������� ������ ������������� �������";                                   break;
      case 4007: error_string="������������ ������ ��� ����������������� ������� ���� ������� ��������� ������� ������������ �������";                           break;
      case 4008: error_string="������������ ������ ��� ����������������� ������";                                                                                break;
      case 4009: error_string="�������������������� ������";                                                                                                     break;
      case 4010: error_string="������������ �������� ���� �/��� �������";                                                                                        break;
      case 4011: error_string="������������� ������ ������� ��������� 2 ���������";                                                                              break;
      case 4012: error_string="��������� ���������";                                                                                                             break;
      case 4013: error_string="��������� ��� ���������";                                                                                                         break;
      case 4014: error_string="��������� ������� �� ��������� ��� ������";                                                                                       break;
      //-- �������
      case 4101: error_string="��������� ������������� �������";                                                                                                 break;
      case 4102: error_string="������ �� ��������";                                                                                                              break;
      case 4103: error_string="������ �� ������";                                                                                                                break;
      case 4104: error_string="� ������� ��� ��������, ������� ��� �� ���������� �������";                                                                       break;
      case 4105: error_string="������ �������� �������";                                                                                                         break;
      case 4106: error_string="������ ��� ��������� ��� ������� ������� � �������";                                                                              break;
      case 4107: error_string="��������� �������� ��� �������";                                                                                                  break;
      case 4108: error_string="������ ��� �������� �������";                                                                                                     break;
      case 4109: error_string="��������� ������������� �������� �������";                                                                                        break;
      case 4110: error_string="������ ��� �������� ���������";                                                                                                   break;
      case 4111: error_string="������ ��������� �� �������";                                                                                                     break;
      case 4112: error_string="������ ��� ���������� �������";                                                                                                   break;
      case 4113: error_string="�������, ���������� ��������� ���������, �� �������";                                                                             break;
      case 4114: error_string="������ ��� ���������� ���������� �� ������";                                                                                      break;
      case 4115: error_string="������ ��� �������� ���������� � �������";                                                                                        break;
      case 4116: error_string="��������� �� ������ �� ��������� �������";                                                                                        break;
      //-- ����������� �������
      case 4201: error_string="������ ��� ������ � ����������� ��������";                                                                                        break;
      case 4202: error_string="����������� ������ �� ������";                                                                                                    break;
      case 4203: error_string="��������� ������������� �������� ������������ �������";                                                                           break;
      case 4204: error_string="���������� �������� ����, ��������������� ��������";                                                                              break;
      case 4205: error_string="���������� �������� ��������, ��������������� ����";                                                                              break;
      //-- MarketInfo
      case 4301: error_string="����������� ������";                                                                                                              break;
      case 4302: error_string="������ �� ������ � MarketWatch";                                                                                                  break;
      case 4303: error_string="��������� ������������� �������� �������";                                                                                        break;
      case 4304: error_string="����� ���������� ���� ���������� (����� �� ����)";                                                                                break;
      //-- ������ � �������
      case 4401: error_string="������������� ������� �� �������!";                                                                                               break;
      case 4402: error_string="��������� ������������� �������� �������";                                                                                        break;
      //-- Global_Variables
      case 4501: error_string="���������� ���������� ����������� ��������� �� �������";                                                                          break;
      case 4502: error_string="���������� ���������� ����������� ��������� � ����� ������ ��� ����������";                                                       break;
      case 4510: error_string="�� ������� ��������� ������";                                                                                                     break;
      case 4511: error_string="�� ������� ������������� ����";                                                                                                   break;
      case 4512: error_string="��������� ������������� �������� ���������";                                                                                      break;
      case 4513: error_string="��������� ������������� �������� ���������";                                                                                      break;
      case 4514: error_string="�� ������� ��������� ���� �� ftp";                                                                                                break;
      //-- ������ ���������������� �����������
      case 4601: error_string="������������ ������ ��� ������������� ������������ �������";                                                                      break;
      case 4602: error_string="��������� ������ ������ ������������� ������";                                                                                    break;
      //-- �������� ���������������� �����������
      case 4603: error_string="��������� ������������� �������� ����������������� ����������";                                                                   break;
      //-- Account
      case 4701: error_string="��������� ������������� �������� �����";                                                                                          break;
      case 4751: error_string="��������� ������������� �������� ��������";                                                                                       break;
      case 4752: error_string="�������� ��� �������� ���������";                                                                                                 break;
      case 4753: error_string="������� �� �������";                                                                                                              break;
      case 4754: error_string="����� �� ������";                                                                                                                 break;
      case 4755: error_string="������ �� �������";                                                                                                               break;
      case 4756: error_string="�� ������� ��������� �������� ������";                                                                                            break;
      //-- ����������
      case 4801: error_string="����������� ������";                                                                                                              break;
      case 4802: error_string="��������� �� ����� ���� ������";                                                                                                  break;
      case 4803: error_string="������������ ������ ��� ���������� ����������";                                                                                   break;
      case 4804: error_string="��������� �� ����� ���� �������� � ������� ����������";                                                                           break;
      case 4805: error_string="������ ��� ���������� ����������";                                                                                                break;
      case 4806: error_string="����������� ������ �� �������";                                                                                                   break;
      case 4807: error_string="��������� ����� ����������";                                                                                                      break;
      case 4808: error_string="������������ ���������� ���������� ��� �������� ����������";                                                                      break;
      case 4809: error_string="����������� ��������� ��� �������� ����������";                                                                                   break;
      case 4810: error_string="������ ���������� � ������� ������ ���� ��� ����������������� ����������";                                                        break;
      case 4811: error_string="������������ ��� ��������� � ������� ��� �������� ����������";                                                                    break;
      case 4812: error_string="��������� ������ �������������� ������������� ������";                                                                            break;
      //-- ������ ���
      case 4901: error_string="������ ��� �� ����� ���� ��������";                                                                                               break;
      case 4902: error_string="������ ��� �� ����� ���� ������";                                                                                                 break;
      case 4903: error_string="������ ������� ��� �� ����� ���� ��������";                                                                                       break;
      case 4904: error_string="������ ��� �������� �� ��������� ����� ������ ������� ���";                                                                       break;
      //-- �������� ��������
      case 5001: error_string="�� ����� ���� ������� ������������ ����� 64 ������";                                                                              break;
      case 5002: error_string="������������ ��� �����";                                                                                                          break;
      case 5003: error_string="������� ������� ��� �����";                                                                                                       break;
      case 5004: error_string="������ �������� �����";                                                                                                           break;
      case 5005: error_string="������������ ������ ��� ���� ������";                                                                                             break;
      case 5006: error_string="������ �������� �����";                                                                                                           break;
      case 5007: error_string="���� � ����� ������� ��� ��� ������, ���� �� ���������� ������";                                                                  break;
      case 5008: error_string="��������� ����� �����";                                                                                                           break;
      case 5009: error_string="���� ������ ���� ������ ��� ������";                                                                                              break;
      case 5010: error_string="���� ������ ���� ������ ��� ������";                                                                                              break;
      case 5011: error_string="���� ������ ���� ������ ��� ��������";                                                                                            break;
      case 5012: error_string="���� ������ ���� ������ ��� ���������";                                                                                           break;
      case 5013: error_string="���� ������ ���� ������ ��� ��������� ��� CSV";                                                                                   break;
      case 5014: error_string="���� ������ ���� ������ ��� CSV";                                                                                                 break;
      case 5015: error_string="������ ������ �����";                                                                                                             break;
      case 5016: error_string="������ ���� ������ ������ ������, ��� ��� ���� ������ ��� ��������";                                                              break;
      case 5017: error_string="��� ��������� �������� ������ ���� ��������� ����, ��� ��������� � ��������";                                                     break;
      case 5018: error_string="��� �� ����, � ����������";                                                                                                       break;
      case 5019: error_string="���� �� ����������";                                                                                                              break;
      case 5020: error_string="���� �� ����� ���� ���������";                                                                                                    break;
      case 5021: error_string="��������� ��� ����������";                                                                                                        break;
      case 5022: error_string="���������� �� ����������";                                                                                                        break;
      case 5023: error_string="��� ����, � �� ����������";                                                                                                       break;
      case 5024: error_string="���������� �� ����� ���� �������";                                                                                                break;
      case 5025: error_string="�� ������� �������� ���������� (��������, ���� ��� ��������� ������ ������������� � �������� �������� �� �������)";               break;
      //-- �������������� �����
      case 5030: error_string="� ������ ��� ����";                                                                                                               break;
      case 5031: error_string="� ������ ��������� ����";                                                                                                         break;
      case 5032: error_string="� ������ ��������� �����";                                                                                                        break;
      case 5033: error_string="������ �������������� ������ � ����";                                                                                             break;
      case 5034: error_string="������������ ������ ��� ������";                                                                                                  break;
      case 5035: error_string="����� ������ ������, ��� ���������";                                                                                              break;
      case 5036: error_string="������� ������� �����, ������, ��� ULONG_MAX";                                                                                    break;
      case 5037: error_string="��������� ��������� ������";                                                                                                      break;
      case 5038: error_string="��������� �������������� ������, ��� ����������";                                                                                 break;
      case 5039: error_string="���������� ������, ��� ��������� ��������������";                                                                                 break;
      case 5040: error_string="����������� �������� ���� string";                                                                                                break;
      case 5041: error_string="������� �� ��������� ������";                                                                                                     break;
      case 5042: error_string="� ����� ������ �������� 0, ����������� ��������";                                                                                 break;
      case 5043: error_string="����������� ��� ������ ��� ����������� � ������";                                                                                 break;
      case 5044: error_string="����������� ������ ������";                                                                                                       break;
      //-- ������ � ���������
      case 5050: error_string="����������� ������������� ��������. ��������� ������ ����� ���� ���������� ������ � ���������, � �������� ������ � � ��������";   break;
      case 5051: error_string="�������� ������ �������� ��� AS_SERIES, � �� �������������� �������";                                                             break;
      case 5052: error_string="������� ��������� ������, ��������� ������� �� ��������� �������";                                                                break;
      case 5053: error_string="������ ������� �����";                                                                                                            break;
      case 5054: error_string="������ ���� �������� ������";                                                                                                     break;
      case 5055: error_string="������ ���� ���������� ������";                                                                                                   break;
      case 5056: error_string="��������� �� ����� ���� ������������";                                                                                            break;
      case 5057: error_string="������ ���� ������ ���� double";                                                                                                  break;
      case 5058: error_string="������ ���� ������ ���� float";                                                                                                   break;
      case 5059: error_string="������ ���� ������ ���� long";                                                                                                    break;
      case 5060: error_string="������ ���� ������ ���� int";                                                                                                     break;
      case 5061: error_string="������ ���� ������ ���� short";                                                                                                   break;
      case 5062: error_string="������ ���� ������ ���� char";                                                                                                    break;
      //-- ���������������� ������

      default: error_string="������ �� ����������";
     }
//---
   return(error_string);
  }