//+------------------------------------------------------------------+
//|                                                         基础模板.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
input ENUM_TIMEFRAMES EA运行时间周期=0;
input double 计算单量余额百分比=5;
input int    计算区间K线数=100;
input double 开仓区间比例=0.2;
input double 盈亏比平半仓=2;
input bool   显示区间=true;
input int    Magic=2564447;


  
string wjname="WJ";
string qstime="QSTIME";
int    stoplevel=0;
double minlot,maxlot;
int OnInit()
  {
//--- create timer
  Comment("");
  minlot=MarketInfo(Symbol(), MODE_MINLOT);
  maxlot=MarketInfo(Symbol(), MODE_MAXLOT);
  stoplevel=int(MarketInfo(Symbol(), MODE_STOPLEVEL));
  Print("平台限制：允许的最小交易手数",MarketInfo(Symbol(), MODE_MINLOT));
  Print("平台限制：允许的最小止损止盈和当前价格距离微点数",MarketInfo(Symbol(), MODE_STOPLEVEL));
  EventSetMillisecondTimer(200);
  if(checkgv(qstime)==false) setgv(qstime,TimeCurrent());
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   if(reason==0 || reason==1 || reason==1 || reason==4 || reason==6 || reason==8 || IsTesting())
    {
    
    delgvall();
    }
  delobject(wjname);
  Comment("");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   main();
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   main();
  }
//+------------------------------------------------------------------+
void main()
  {
  pingcang();
  kaicang();
  }

void kaicang()
  {
  tongji();
  if(A.vol==0) qujian();
  
  if(显示区间)
    {
    CreatLine(wjname+"UP",qjup,clrDarkOrange);
    CreatLine(wjname+"DN",qjdn,clrDarkOrange);
    CreatLine(wjname+"S",qjs,clrDodgerBlue);
    CreatLine(wjname+"X",qjx,clrDodgerBlue);
    }
  
  
  if(A.vol>0) return;
  if(A.time!=timek(0) && closek(0)<=qjx && baohan() && closek(0)>highk(1))
    {
    int slp=int((Ask-lowest(2,1))/Point);
    if(send(0,lots(slp,AccountBalance()*计算单量余额百分比*0.01))) A.time=timek(0);
    }
  
  if(A.time!=timek(0) && closek(0)>=qjs && baohan() && closek(0)<lowk(1))
    {
    int slp=int((highest(2,1)-Bid)/Point);
    if(send(1,lots(slp,AccountBalance()*计算单量余额百分比*0.01))) A.time=timek(0);
    }
  
  }

void pingcang()
  {
  sl_tp();
  jiancang();
  }

void CreatLine(string A_name_0,double A_price_12,color A_color_20)//  画横线
  {
  if(A_price_12==0) ObjectDelete(A_name_0);
  if(A_price_12!=0 && ObjectFind(0,A_name_0)==-1)
    {
    ObjectCreate(A_name_0,OBJ_HLINE,0,0,A_price_12);
    ObjectSet(A_name_0,OBJPROP_COLOR,A_color_20);
    ObjectSet(A_name_0,OBJPROP_STYLE,STYLE_DASHDOT);
    ObjectSetInteger(0,A_name_0,OBJPROP_SELECTABLE,0); //0不可选取,1可被选取
    ObjectSetInteger(0,A_name_0,OBJPROP_SELECTED,0);
    }
  ObjectSet(A_name_0,OBJPROP_PRICE1,A_price_12);
  }
  
bool baohan()
  {
  if(highk(2)>highk(1) && lowk(2)<lowk(1)) return true;
  return false;
  }

double qjup=0,qjdn=0;
double qjx=0,qjs=0;
void qujian()
  {
  qjup=highest(计算区间K线数,1);
  qjdn=lowest(计算区间K线数,1);
  qjx=qjdn+(qjup-qjdn)*开仓区间比例;
  qjs=qjup-(qjup-qjdn)*开仓区间比例;
  }
  
bool zbok(double zhi)
  {
  if(zhi>0 && zhi<1000000) return true;
  return false;
  }
double closek(int shift=1)
  {
  return iClose(NULL,EA运行时间周期,shift);
  }
double openk(int shift=1)
  {
  return iOpen(NULL,EA运行时间周期,shift);
  }
double highk(int shift=1)
  {
  return iHigh(NULL,EA运行时间周期,shift);
  }
double lowk(int shift=1)
  {
  return iLow(NULL,EA运行时间周期,shift);
  }
datetime timek(int shift=1)
  {
  return iTime(NULL,EA运行时间周期,shift);
  }

double highest(int count,int startnum)
  {
  return iHigh(NULL,EA运行时间周期,iHighest(NULL,EA运行时间周期,MODE_HIGH,count,startnum));
  }

double lowest(int count,int startnum)
  {
  return iLow(NULL,EA运行时间周期,iLowest(NULL,EA运行时间周期,MODE_LOW,count,startnum));
  }
  
struct shuju
 {
  int               vol;
  int               vol_g;
  int               vol_s;
  bool              kc;
  double            lots;
  datetime          time;
  double            yl;
  bool              ping;
  
  int               lasttype;
  int               lastticket;
  double            lastlots;
  double            lastprice;
  
  int               histvol;
  double            histalllots;
  double            histyl;
  int               histlastticket;
  double            histlastyk;
  double            histlastlots;
  double            histlastprice;
  
  double            highestprice;
  double            highestlots;
  double            lowestprice;
  double            lowestlots;
  
                    shuju() 
                      {
                      vol=0;kc=false;time=0;yl=0;lots=0;ping=0;
                      lastticket=0;lastlots=0;lastprice=0;
                      histvol=0;histalllots=0;histyl=0;histlastticket=0;histlastlots=0;histlastprice=0;
                      highestprice=0;highestlots=0;
                      lowestprice=0;lowestlots=0;
                      }
                   ~shuju() {}
 };
shuju A;
shuju B;
shuju S;

void tongji()
  {
   A.vol=0;A.yl=0;A.lots=0;
   A.vol_g=0;A.vol_s=0;
   A.lastprice=0;
   
   B.vol=0;B.yl=0;B.lots=0;
   B.lastlots=0;
   B.highestprice=0;
   B.lowestprice=0;
   B.vol_g=0;B.vol_s=0;
   
   S.vol=0;S.yl=0;S.lots=0;
   S.lastlots=0;
   S.highestprice=0;
   S.lowestprice=0;
   S.vol_g=0;S.vol_s=0;
   
  if(OrdersTotal()>0)  
    {
    for(int k=OrdersTotal()-1;k>=0;k--)  
      {
      if(OrderSelect(k,SELECT_BY_POS,MODE_TRADES)==true)  
        {
        if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)  
          {
          double openp=OrderOpenPrice();
          if(OrderType()<2)
            {
            A.vol++;
            A.lots+=OrderLots();
            A.yl+=OrderProfit()+OrderSwap()+OrderCommission();
            }
          else A.vol_g++;
          if(OrderType()==OP_BUY)  
            {
            B.vol++;
            B.lots+=OrderLots();
            B.yl+=OrderProfit()+OrderSwap()+OrderCommission();
            if(B.lastlots==0) B.lastlots=OrderLots();
            if(B.highestprice<openp) B.highestprice=openp;
            if(B.lowestprice>openp || B.lowestprice==0) B.lowestprice=openp;
            }
          if(OrderType()==OP_SELL) 
            {
            S.vol++; 
            S.lots+=OrderLots();
            S.yl+=OrderProfit()+OrderSwap()+OrderCommission();
            if(S.lastlots==0) S.lastlots=OrderLots();
            if(S.highestprice<openp) S.highestprice=openp;
            if(S.lowestprice>openp || S.lowestprice==0) S.lowestprice=openp;
            }
          if(OrderType()==2 || OrderType()==4) B.vol_g++;
          if(OrderType()==3 || OrderType()==5) S.vol_g++;
          } 
        } 
      } 
    }
  
  //static int ltic=0;
  //int n=0;
  //if(OrdersHistoryTotal()>0)  
  //  for(int k=OrdersHistoryTotal()-1;k>=0;k--)  
  //    if(OrderSelect(k,SELECT_BY_POS,MODE_HISTORY)==true)  
  //      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic && OrderType()<2)  
  //        {
  //        if(OrderCloseTime()<=getgv(qstime)) break;
  //        if(n==0 && ltic==OrderTicket()) break;
  //        if(n==0 && ltic!=OrderTicket()) {ltic=OrderTicket();A.histalllots=0;  A.histdayyl=0;  A.histyl=0;}
  //        n++;
  //        double yk=(OrderProfit()+OrderSwap()+OrderCommission());
  //        if(OrderCloseTime()>=iTime(NULL,1440,0)) A.histdayyl+=yk;
  //        A.histyl+=yk;
  //        A.histalllots+=OrderLots();
  //        }
  }



void sl_tp()//移动止损+保本止损
  {
  if(OrdersTotal()>0)
    {
    for(int i=OrdersTotal()-1;i>=0;i--)
      {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
        {
        if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
          {
          int tic=OrderTicket();
          if(OrderType()==OP_BUY)
            {
            double buysl=0,buytp=0,buysl2=0,buysl3=0;
            if(OrderTakeProfit()==0 && qjs>0) buytp=qjs;
            if(OrderStopLoss()==0) buysl=lowest(2,1);
            if(buysl<buysl2) buysl=buysl2;
            if(buysl<buysl3) buysl=buysl3;
            buysl=NormalizeDouble(buysl,Digits);
            buytp=NormalizeDouble(buytp,Digits);
            if(OrderStopLoss()<buysl)
              {
              if(OrderModify(OrderTicket(),OrderOpenPrice(),buysl,OrderTakeProfit(),0,clrBlue)==false)//多单设置初始止损
                {Print("初始止损：订单号为：",OrderTicket(),"的多单止损失败",iGetErrorInf0());}
              }
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
            if(buytp>0 && OrderTakeProfit()!=buytp)
              {
              if(OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),buytp,0,clrBlue)==false)//多单设置初始止损
                {Print("初始止损：订单号为：",OrderTicket(),"的多单止盈失败",iGetErrorInf0());}
              }
            if(buysl>0 && Bid<=buysl) closetic(tic);
            if(buytp>0 && Bid>=buytp) closetic(tic);
            continue;
            }
          if(OrderType()==OP_SELL)
            {
            double sellsl=0,selltp=0,sellsl2=0,sellsl3=0;
            if(OrderTakeProfit()==0 && qjx>0) selltp=qjx;
            if(OrderStopLoss()==0) sellsl=highest(2,1);
            if(sellsl2>0 && (sellsl>sellsl2||sellsl==0)) sellsl=sellsl2;
            if(sellsl3>0 && (sellsl>sellsl3||sellsl==0)) sellsl=sellsl3;
            sellsl=NormalizeDouble(sellsl,Digits);
            selltp=NormalizeDouble(selltp,Digits);
            if(sellsl>0 && (OrderStopLoss()>sellsl || OrderStopLoss()==0))
              {
              if(OrderModify(OrderTicket(),OrderOpenPrice(),sellsl,OrderTakeProfit(),0,clrBlue)==false)//空单设置初始止损
                {Print("初始止损：订单号为：",OrderTicket(),"的空单止损失败",iGetErrorInf0());}
              }
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
            if(selltp>0 && OrderTakeProfit()!=selltp)
              {
              if(OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),selltp,0,clrBlue)==false)//空单设置初始止损
                {Print("初始止损：订单号为：",OrderTicket(),"的空单止盈失败",iGetErrorInf0());}
              }
            if(selltp>0 && Ask<=selltp) closetic(tic);
            if(sellsl>0 && Ask>=sellsl) closetic(tic);
            }
          }
        }
      }
    }
  }
  

void jiancang()
  {
  if(OrdersTotal()>0)
    {
    for(int i=OrdersTotal()-1;i>=0;i--)
      {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
        {
        if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
        if(StringFind(OrderComment(),"from")<0)
          {
          int tic=OrderTicket();
          if(OrderType()==OP_BUY)
            {
            if(OrderStopLoss()>0 && (Bid-OrderOpenPrice())/(OrderOpenPrice()-OrderStopLoss())>=盈亏比平半仓) 
              closeticbili(OrderTicket(),0.5);
            continue;
            }
          if(OrderType()==OP_SELL)
            {
            if(OrderStopLoss()>0 && (OrderOpenPrice()-Ask)/(OrderStopLoss()-OrderOpenPrice())>=盈亏比平半仓) 
              closeticbili(OrderTicket(),0.5);
            }
          }
        }
      }
    }
  }

bool closeticbili(int tic,double bili)
  {
  if(OrderSelect(tic,SELECT_BY_TICKET ,MODE_TRADES)==true)
    {
    double lots=OrderLots();
     minlot=MarketInfo(OrderSymbol(), MODE_MINLOT);
    lots=MathRound(lots*bili/minlot)*minlot;
    if(OrderType()==OP_BUY )
      {
      if(OrderClose(OrderTicket(),lots,MarketInfo(OrderSymbol(),MODE_BID),500,clrRed)) return(true);
      else{Print("订单号为：",OrderTicket(),"的多单平仓失败",iGetErrorInf0());return(false);}
      }
    if(OrderType()==OP_SELL )
      {
      if(OrderClose(OrderTicket(),lots,MarketInfo(OrderSymbol(),MODE_ASK),500,clrGreen)) return(true);
      else{Print("订单号为：",OrderTicket(),"的多单平仓失败",iGetErrorInf0());return(false);}
      }
    }
  return(false);
  } 
  
double lots(int slpip,double ksje)//通过止损点数和亏损金额算手数
  {
  if(slpip<=0) return(0);
  double lots_0=0;
  double dianzhi=MarketInfo(Symbol(),MODE_TICKVALUE );
  if(slpip>0) lots_0=ksje/(slpip*dianzhi);
  else lots_0=0;
  
  double minlot_0=MarketInfo(Symbol(), MODE_MINLOT);
  double maxlot_0=MarketInfo(Symbol(), MODE_MAXLOT);
  lots_0= MathRound(lots_0/minlot_0)*minlot_0;
  if(lots_0<minlot_0) {lots_0=minlot_0;}
  if(lots_0>maxlot_0) {lots_0=maxlot_0;}
  return(lots_0);
  }


bool send(int fx_0,double danliang,double price=0,string com="")
  {
  int ticket=0;
  string symbol=Symbol();
  minlot=MarketInfo(symbol, MODE_MINLOT);
  maxlot=MarketInfo(symbol, MODE_MAXLOT);
  danliang=int(danliang/minlot)*minlot;
  if(danliang<minlot) return false;
  if(danliang>maxlot) danliang=maxlot;
  price=NormalizeDouble(price,(int)MarketInfo(symbol,MODE_DIGITS));
  if(fx_0==0)
    {
    ticket=OrderSend(symbol,0,danliang,MarketInfo(symbol,MODE_ASK),500,0,0,com,Magic,0,clrBlue);
    if(ticket>0){Print("多单开单成功"); }
    else {Print("多单开单失败。失败原因：",iGetErrorInf0());Sleep(500);}
    }
  if(fx_0==1)
    {
    ticket=OrderSend(symbol,1,danliang,MarketInfo(symbol,MODE_BID),500,0,0,com,Magic,0,clrBlue);
    if(ticket>0){Print("空单开单成功");}
    else {Print("空单开单失败。失败原因：",iGetErrorInf0());Sleep(500);}
    }
  if(fx_0==2)
    {
    ticket=OrderSend(symbol,2,danliang,price,500,0,0,com,Magic,0,clrBlue);
    if(ticket>0){Print("多单挂单开单成功"); }
    else {Print("多单挂单开单失败。失败原因：",iGetErrorInf0());Sleep(500);}
    }
  if(fx_0==3)
    {
    ticket=OrderSend(symbol,3,danliang,price,500,0,0,com,Magic,0,clrBlue);
    if(ticket>0){Print("空单挂单开单成功");}
    else {Print("空单挂单开单失败。失败原因：",iGetErrorInf0());Sleep(500);}
    }
  if(fx_0==4)
    {
    ticket=OrderSend(symbol,4,danliang,price,500,0,0,com,Magic,0,clrBlue);
    if(ticket>0){Print("多单挂单开单成功"); }
    else {Print("多单挂单开单失败。失败原因：",iGetErrorInf0());Sleep(500);}
    }
  if(fx_0==5)
    {
    ticket=OrderSend(symbol,5,danliang,price,500,0,0,com,Magic,0,clrBlue);
    if(ticket>0){Print("空单挂单开单成功");}
    else {Print("空单挂单开单失败。失败原因：",iGetErrorInf0());Sleep(500);}
    }
  if(ticket>0) return(true);
  return(false);
  }

bool close(int fx=-1)
  {
  if(OrdersTotal()>0)
    {
    for(int k=OrdersTotal()-1;k>=0;k--)
      {
      if(OrderSelect(k,SELECT_BY_POS,MODE_TRADES)==true)
        {
        if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
          {
          if(OrderType()==OP_BUY && fx<=0)
            {
            if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),500,clrRed));
            else{Print("订单号为：",OrderTicket(),"的多单平仓失败",iGetErrorInf0());}
            }
          if(OrderType()==OP_SELL && (fx==1||fx<0))
            {
            if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),500,clrGreen));
            else{Print("订单号为：",OrderTicket(),"的多单平仓失败",iGetErrorInf0());}
            }
          }
        }
      }
    }
  
  int vol=0;
  if(OrdersTotal()>0)
    for(int k=OrdersTotal()-1;k>=0;k--)
      if(OrderSelect(k,SELECT_BY_POS,MODE_TRADES)==true)
        if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
          {
          if(OrderType()==OP_BUY && fx<=0) vol++;
          if(OrderType()==OP_SELL && (fx==1||fx<0)) vol++;
          }
  if(vol==0) return true;
  return false;
  }

bool delgua(int fx=-1)
  {
  bool ok=true;
  if(OrdersTotal()>0)
    {
    for(int k=OrdersTotal()-1;k>=0;k--)
      {
      if(OrderSelect(k,SELECT_BY_POS,MODE_TRADES)==true)
        {
        if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic && OrderType()>1)
          {
          if((OrderType()==2 || OrderType()==4) && fx<=0)
            {
            if(OrderDelete(OrderTicket())==false) ok=false;
            continue;
            }
          if((OrderType()==3 || OrderType()==5) && (fx==1||fx<0))
            {
            if(OrderDelete(OrderTicket())==false) ok=false;
            continue;
            }
          }
        }
      }
    }
  return ok;
  }
  
bool closetic(int ticket_0)
  {
  if(OrderSelect(ticket_0,SELECT_BY_TICKET))
    {
    if(OrderClose(OrderTicket(),OrderLots(),OrderType()==OP_BUY? MarketInfo(OrderSymbol(),MODE_BID) : MarketInfo(OrderSymbol(),MODE_ASK),500,clrRed)) return(true);
    else{Print("订单号为：",OrderTicket(),"的定单平仓失败",iGetErrorInf0());return(false);}
    }
  return(true);
  }
void delobject(string name_)
  {
   int    obj_total=ObjectsTotal();
   for(int i=obj_total-1;i>=0;i--)
     {
      if(StringFind(ObjectName(i),name_,0)>=0)
         ObjectDelete(ObjectName(i));
     }
  }
  
void delgv(string pre)
  {
  string name0=Symbol()+"_"+string(Magic)+"_";
  if(IsTesting()) name0+="test_";
  pre=name0+pre;
  for(int i=GlobalVariablesTotal()-1;i>=0;--i)
    {
    string cap=GlobalVariableName(i);
    if(cap==pre)
    GlobalVariableDel(cap);
    }
  }

bool checkgv(string pre)
  {
  string name0=Symbol()+"_"+string(Magic)+"_";
  if(IsTesting()) name0+="test_";
  pre=name0+pre;
  return(GlobalVariableCheck(pre));
  }

bool setgv(string pre,double ad_8) //写入全局变量赋值
  {
  string name0=Symbol()+"_"+string(Magic)+"_";
  if(IsTesting()) name0+="test_";
  pre=name0+pre;
   GlobalVariableSet(pre,ad_8);
   if(GlobalVariableGet(pre)!=ad_8) return(false);
   return (true);
  }

bool setgv(string pre,int ad_8) //写入全局变量赋值
  {
  string name0=Symbol()+"_"+string(Magic)+"_";
  if(IsTesting()) name0+="test_";
  pre=name0+pre;
   GlobalVariableSet(pre,ad_8);
   if(GlobalVariableGet(pre)!=ad_8) return(false);
   return (true);
  }

bool setgv(string pre,bool ad_8) //写入全局变量赋值
  {
  string name0=Symbol()+"_"+string(Magic)+"_";
  if(IsTesting()) name0+="test_";
  pre=name0+pre;
   GlobalVariableSet(pre,ad_8);
   if(GlobalVariableGet(pre)!=ad_8) return(false);
   return (true);
  }
bool setgv(string pre,datetime ad_8) //写入全局变量赋值
  {
  string name0=Symbol()+"_"+string(Magic)+"_";
  if(IsTesting()) name0+="test_";
  pre=name0+pre;
   GlobalVariableSet(pre,ad_8);
   if(GlobalVariableGet(pre)!=ad_8) return(false);
   return (true);
  }

bool addgv(string pre,double ad_8) //写入全局变量赋值
  {
  string name0=Symbol()+"_"+string(Magic)+"_";
  if(IsTesting()) name0+="test_";
  pre=name0+pre;
  double getzhi=GlobalVariableGet(pre);
   GlobalVariableSet(pre,getzhi+ad_8);
   if(GlobalVariableGet(pre)!=getzhi+ad_8) return(false);
   return (true);
  }


double getgv(string pre) //获取全局变量赋值
  {
  string name0=Symbol()+"_"+string(Magic)+"_";
  if(IsTesting()) name0+="test_";
  pre=name0+pre;
  double a=0;
  if(GlobalVariableCheck(pre))
    {
    a=GlobalVariableGet(pre);
    }
  return(a);
  }

bool delgvall()
  {
  string name0=Symbol()+"_"+string(Magic)+"_";
  if(IsTesting()) name0+="test_";
  if(GlobalVariablesDeleteAll(name0)>0) return true;
  return false;
  }

string iGetErrorInf0()
  {
   int myLastErrorMub=GetLastError();
   string myLastErrorStr;
   switch(myLastErrorMub)
     {
      case 0:myLastErrorStr="错误代码:#"+(string)0+",没有错误返回";break;
      case 1:myLastErrorStr="错误代码:#"+(string)1+",没有错误返回但结果不明";break;
      case 2:myLastErrorStr="错误代码:#"+(string)2+",一般错误";break;
      case 3:myLastErrorStr="错误代码:#"+(string)3+",无效交易参量";break;
      case 4:myLastErrorStr="错误代码:#"+(string)4+",交易服务器繁忙";break;
      case 5:myLastErrorStr="错误代码:#"+(string)5+",客户终端旧版本";break;
      case 6:myLastErrorStr="错误代码:#"+(string)6+",没有连接服务器";break;
      case 7:myLastErrorStr="错误代码:#"+(string)7+",没有权限";break;
      case 8:myLastErrorStr="错误代码:#"+(string)8+",请求过于频繁";break;
      case 9:myLastErrorStr="错误代码:#"+(string)9+",交易运行故障";break;
      case 64:myLastErrorStr="错误代码:#"+(string)64+",账户禁止";break;
      case 65:myLastErrorStr="错误代码:#"+(string)65+",无效账户";break;
      case 128:myLastErrorStr="错误代码:#"+(string)128+",交易超时";break;
      case 129:myLastErrorStr="错误代码:#"+(string)129+",无效价格";break;
      case 130:myLastErrorStr="错误代码:#"+(string)130+",无效停止";break;
      case 131:myLastErrorStr="错误代码:#"+(string)131+",无效交易量";break;
      case 132:myLastErrorStr="错误代码:#"+(string)132+",市场关闭";break;
      case 133:myLastErrorStr="错误代码:#"+(string)133+",交易被禁止";break;
      case 134:myLastErrorStr="错误代码:#"+(string)134+",资金不足";break;
      case 135:myLastErrorStr="错误代码:#"+(string)135+",价格改变";break;
      case 136:myLastErrorStr="错误代码:#"+(string)136+",开价";break;
      case 137:myLastErrorStr="错误代码:#"+(string)137+",经纪繁忙";break;
      case 138:myLastErrorStr="错误代码:#"+(string)138+",重新开价";break;
      case 139:myLastErrorStr="错误代码:#"+(string)139+",定单被锁定";break;
      case 140:myLastErrorStr="错误代码:#"+(string)140+",只允许看涨仓位";break;
      case 141:myLastErrorStr="错误代码:#"+(string)141+",过多请求";break;
      case 145:myLastErrorStr="错误代码:#"+(string)145+",因为过于接近市场，修改否定";break;
      case 146:myLastErrorStr="错误代码:#"+(string)146+",交易文本已满";break;
      case 147:myLastErrorStr="错误代码:#"+(string)147+",时间周期被经纪否定";break;
      case 148:myLastErrorStr="错误代码:#"+(string)148+",开单和挂单总数已被经纪限定";break;
      case 149:myLastErrorStr="错误代码:#"+(string)149+",当对冲备拒绝时,打开相对于现有的一个单置";break;
      case 150:myLastErrorStr="错误代码:#"+(string)150+",把为反FIFO规定的单子平掉";break;
      case 4000:myLastErrorStr="错误代码:#"+(string)4000+",没有错误";break;
      case 4001:myLastErrorStr="错误代码:#"+(string)4001+",错误函数指示";break;
      case 4002:myLastErrorStr="错误代码:#"+(string)4002+",数组索引超出范围";break;
      case 4003:myLastErrorStr="错误代码:#"+(string)4003+",对于调用堆栈储存器函数没有足够内存";break;
      case 4004:myLastErrorStr="错误代码:#"+(string)4004+",循环堆栈储存器溢出";break;
      case 4005:myLastErrorStr="错误代码:#"+(string)4005+",对于堆栈储存器参量没有内存";break;
      case 4006:myLastErrorStr="错误代码:#"+(string)4006+",对于字行参量没有足够内存";break;
      case 4007:myLastErrorStr="错误代码:#"+(string)4007+",对于字行没有足够内存";break;
      case 4008:myLastErrorStr="错误代码:#"+(string)4008+",没有初始字行";break;
      case 4009:myLastErrorStr="错误代码:#"+(string)4009+",在数组中没有初始字串符";break;
      case 4010:myLastErrorStr="错误代码:#"+(string)4010+",对于数组没有内存";break;
      case 4011:myLastErrorStr="错误代码:#"+(string)4011+",字行过长";break;
      case 4012:myLastErrorStr="错误代码:#"+(string)4012+",余数划分为零";break;
      case 4013:myLastErrorStr="错误代码:#"+(string)4013+",零划分";break;
      case 4014:myLastErrorStr="错误代码:#"+(string)4014+",不明命令";break;
      case 4015:myLastErrorStr="错误代码:#"+(string)4015+",错误转换(没有常规错误)";break;
      case 4016:myLastErrorStr="错误代码:#"+(string)4016+",没有初始化数组";break;
      case 4017:myLastErrorStr="错误代码:#"+(string)4017+",禁止调用DLL ";break;
      case 4018:myLastErrorStr="错误代码:#"+(string)4018+",数据库不能下载";break;
      case 4019:myLastErrorStr="错误代码:#"+(string)4019+",不能调用函数";break;
      case 4020:myLastErrorStr="错误代码:#"+(string)4020+",禁止调用智能交易函数";break;
      case 4021:myLastErrorStr="错误代码:#"+(string)4021+",对于来自函数的字行没有足够内存";break;
      case 4022:myLastErrorStr="错误代码:#"+(string)4022+",系统繁忙 (没有常规错误)";break;
      case 4050:myLastErrorStr="错误代码:#"+(string)4050+",无效计数参量函数";break;
      case 4051:myLastErrorStr="错误代码:#"+(string)4051+",无效参量值函数";break;
      case 4052:myLastErrorStr="错误代码:#"+(string)4052+",字行函数内部错误";break;
      case 4053:myLastErrorStr="错误代码:#"+(string)4053+",一些数组错误";break;
      case 4054:myLastErrorStr="错误代码:#"+(string)4054+",应用不正确数组";break;
      case 4055:myLastErrorStr="错误代码:#"+(string)4055+",自定义指标错误";break;
      case 4056:myLastErrorStr="错误代码:#"+(string)4056+",不协调数组";break;
      case 4057:myLastErrorStr="错误代码:#"+(string)4057+",整体变量过程错误";break;
      case 4058:myLastErrorStr="错误代码:#"+(string)4058+",整体变量未找到";break;
      case 4059:myLastErrorStr="错误代码:#"+(string)4059+",测试模式函数禁止";break;
      case 4060:myLastErrorStr="错误代码:#"+(string)4060+",没有确认函数";break;
      case 4061:myLastErrorStr="错误代码:#"+(string)4061+",发送邮件错误";break;
      case 4062:myLastErrorStr="错误代码:#"+(string)4062+",字行预计参量";break;
      case 4063:myLastErrorStr="错误代码:#"+(string)4063+",整数预计参量";break;
      case 4064:myLastErrorStr="错误代码:#"+(string)4064+",双预计参量";break;
      case 4065:myLastErrorStr="错误代码:#"+(string)4065+",数组作为预计参量";break;
      case 4066:myLastErrorStr="错误代码:#"+(string)4066+",刷新状态请求历史数据";break;
      case 4067:myLastErrorStr="错误代码:#"+(string)4067+",交易函数错误";break;
      case 4099:myLastErrorStr="错误代码:#"+(string)4099+",文件结束";break;
      case 4100:myLastErrorStr="错误代码:#"+(string)4100+",一些文件错误";break;
      case 4101:myLastErrorStr="错误代码:#"+(string)4101+",错误文件名称";break;
      case 4102:myLastErrorStr="错误代码:#"+(string)4102+",打开文件过多";break;
      case 4103:myLastErrorStr="错误代码:#"+(string)4103+",不能打开文件";break;
      case 4104:myLastErrorStr="错误代码:#"+(string)4104+",不协调文件";break;
      case 4105:myLastErrorStr="错误代码:#"+(string)4105+",没有选择定单";break;
      case 4106:myLastErrorStr="错误代码:#"+(string)4106+",不明货币对";break;
      case 4107:myLastErrorStr="错误代码:#"+(string)4107+",无效价格";break;
      case 4108:myLastErrorStr="错误代码:#"+(string)4108+",无效定单编码";break;
      case 4109:myLastErrorStr="错误代码:#"+(string)4109+",不允许交易";break;
      case 4110:myLastErrorStr="错误代码:#"+(string)4110+",不允许多单";break;
      case 4111:myLastErrorStr="错误代码:#"+(string)4111+",不允许空单";break;
      case 4200:myLastErrorStr="错误代码:#"+(string)4200+",定单已经存在";break;
      case 4201:myLastErrorStr="错误代码:#"+(string)4201+",不明定单属性";break;
      case 4202:myLastErrorStr="错误代码:#"+(string)4202+",定单不存在";break;
      case 4203:myLastErrorStr="错误代码:#"+(string)4203+",不明定单类型";break;
      case 4204:myLastErrorStr="错误代码:#"+(string)4204+",没有定单名称";break;
      case 4205:myLastErrorStr="错误代码:#"+(string)4205+",定单坐标错误";break;
      case 4206:myLastErrorStr="错误代码:#"+(string)4206+",没有指定子窗口";break;
      case 4207:myLastErrorStr="错误代码:#"+(string)4207+",定单一些函数错误";break;
      case 4250:myLastErrorStr="错误代码:#"+(string)4250+",错误设定发送通知到队列中";break;
      case 4251:myLastErrorStr="错误代码:#"+(string)4251+",无效参量- 空字符串传递到SendNotification()函数";break;
      case 4252:myLastErrorStr="错误代码:#"+(string)4252+",无效设置发送通知(未指定ID或未启用通知)";break;
      case 4253:myLastErrorStr="错误代码:#"+(string)4253+",通知发送过于频繁";break;
      default :myLastErrorStr="错误代码: "+string(myLastErrorMub);break;
     }
   return(myLastErrorStr);
  }