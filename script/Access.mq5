//+------------------------------------------------------------------+
//|                                       NSATS (North Sulawesi ATS) |
//|                                         Copyright 2020, heviooot |
//|                                https://github.com/heviooot/NSATS |
//+------------------------------------------------------------------+
class Access {
 private:
   int               status; //indicate possible trade execution condition
   int               numOfOrders; //number of currently opened order
   void              setStatus(int status); //function to set status with 1 or 0
   int               countNumOfOrders(); //function to count opened order
   int               checkBalance(); //function that check account balance
 public:
   int               getStatus(); //function to get status value 1 or 0
                     Access(); //constructor that check balance and order count then setting status value
};
//+------------------------------------------------------------------+

//+--------------------------------------------------------------------------+
//| constructor that check balance and order count then setting status value |
//+--------------------------------------------------------------------------+
Access::Access(void) {
   if(checkBalance() == 1) {
      //give access when balance is above 250
      if(countNumOfOrders() == 1) {
         //give access when no opened order
         setStatus(1);
      } else {
         setStatus(0);
      }
   } else {
      //terminate system when balance is below 250
      ExpertRemove();
   }
}
//+------------------------------------------------------------------+
//| function that check account balance                              |
//+------------------------------------------------------------------+
int Access::checkBalance(void) {
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(balance > 250) {
      //give access when balance is above 250
      return 1;
   } else {
      return -1;
   }
}
//+------------------------------------------------------------------+
//| function to count opened order                                   |
//+------------------------------------------------------------------+
int Access::countNumOfOrders(void) {
   numOfOrders = PositionsTotal();
   if(numOfOrders == 0) {
      //give access when no opened order
      return 1;
   } else {
      return -1;
   }
}
//+------------------------------------------------------------------+
//| function to get status value 1 or 0                              |
//+------------------------------------------------------------------+
int Access::getStatus(void) {
   if(status == 1 || status == 0) {
      return status;
   } else {
      Print("Invalid Status");
      return -1;
   }
}
//+------------------------------------------------------------------+
//| function to set status with 1 or 0                               |
//+------------------------------------------------------------------+
void Access::setStatus(int status) {
   if(status == 1 || status == 0) {
      this.status = status;
   } else {
      Print("Invalid Status Input");
   }
}
//+------------------------------------------------------------------+