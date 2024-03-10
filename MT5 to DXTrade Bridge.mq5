//+------------------------------------------------------------------+
//|                                        MT5 to DXTrade Bridge.mq5 |
//|                                   Copyright 2024, 6alaileTrades. |
//|                                https://twitter.com/6alaileTrades |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, 6alaileTrades."
#property link      "https://twitter.com/6alaileTrades"
#property version   "1.00"


#define BASE_URL "https://demo.dx.trade/dxsca-web/"
#define USERNAME ""
#define PASSWORD ""

int OnInit()
  {
   login();
   return(INIT_SUCCEEDED);
  }
  

int login(){
   string url = BASE_URL+"login";
   char post[], result[];
   string headers = "Content-Type: application/json\r\nAccept: application/json\r\n";
   string resultHeader;
   
   string json = "{\"username\": \""+USERNAME+"\", \"domain\": \"default\", \"password\": \""+PASSWORD+"\"}";
   StringToCharArray(json,post,0,StringLen(json));
   
   ResetLastError();
   int res = WebRequest("POST",url,headers,5000,post,result,resultHeader);
   if(res == -1){
      Print(__FUNCTION__," > web request failed... code: ",GetLastError());
   }else if(res != 200){
      Print(__FUNCTION__," > server request failed... code: ",res);
   }else{
      string msg = CharArrayToString(result);
      Print(__FUNCTION__," > Login success! ");
      
      token = getJsonStringValue(msg,"sessionToken");
      timeout = TimeCurrent() + PeriodSeconds(PERIOD_M1)*30;
      Print(__FUNCTION__," > token: ",token,", timeout: ",timeout);
   }
   
   return res;
}

int ping(){
   string url = BASE_URL+"ping";
   char post[], result[];
   string headers = "Content-Type: application/json\r\nAccept: application/json\r\nAuthorization: DXAPI "+token+"\r\n";
   string resultHeader;
   
   ResetLastError();
   int res = WebRequest("POST",url,headers,5000,post,result,resultHeader);
   if(res == -1){
      Print(__FUNCTION__," > web request failed... code: ",GetLastError());
   }else if(res != 200){
      Print(__FUNCTION__," > server request failed... code: ",res);
   }else{
      string msg = CharArrayToString(result);
      Print(__FUNCTION__," > server ping success... ",msg);
      
      timeout = TimeCurrent() + PeriodSeconds(PERIOD_M1)*30;
      Print(__FUNCTION__," > token: ",token,", timeout: ",timeout);
   }
   
   return res;
}

string getJsonStringValue(string json, string key){
   int indexStart = StringFind(json,key)+StringLen(key)+3;
   int indexEnd = StringFind(json,"\"",indexStart);
   return StringSubstr(json,indexStart,indexEnd-indexStart);
}

