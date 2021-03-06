//+------------------------------------------------------------------+
//|                                                roboCrossOver.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "DeltaTrader"
#property link      "www.deltatrader.com.br"
#property version   "1.00"
//---
#include <Trade/Trade.mqh> 
input int lote = 0.1;
input int periodoCurta = 12;
input int periodoLonga = 26;
//---
int curtaHandle = INVALID_HANDLE;
int longaHandle = INVALID_HANDLE;
//--- 
double mediaCurta[];
double mediaLonga[];
//--- 
CTrade trade;

int OnInit()
  {
//---
   ArraySetAsSeries(mediaCurta,true);
   ArraySetAsSeries(mediaLonga,true);
//--- 
   curtaHandle = iMA(_Symbol,_Period,periodoCurta,0,MODE_SMA,PRICE_CLOSE);
   longaHandle = iMA(_Symbol,_Period,periodoLonga,0,MODE_SMA,PRICE_CLOSE);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(isNewBar())
     {
      //+------------------------------------------------------------------+
      //| obter dados                                                      |
      //+------------------------------------------------------------------+
      int copied1 = CopyBuffer(curtaHandle,0,0,3,mediaCurta);
      int copied2 = CopyBuffer(longaHandle,0,0,3,mediaLonga);
      //---
      bool sinalCompra = false;
      bool sinalVenda = false;
      //--- se os dados tiverem sido copiados corretamente
      if(copied1==3 && copied2==3)
        {
         //--- sinal de compra
         if( mediaCurta[1]>mediaLonga[1] && mediaCurta[2]<mediaLonga[2] )
           {
            sinalCompra = true;
           }
         //--- sinal de venda
         if( mediaCurta[1]<mediaLonga[1] && mediaCurta[2]>mediaLonga[2] )
           {
            sinalVenda = true;
           }
        }
      
      //--- verificação de posição

      bool comprado = false;
      bool vendido = false;
      if(PositionSelect(_Symbol))
        {
         //--- comprado
         if( PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY )
           {
            comprado = true;
           }
         //--- vendido
         if( PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL )
           {
            vendido = true;
           }
        }
      //--- zerado
      if( !comprado && !vendido )
        {
         //--- compra
         if( sinalCompra )
           {
            trade.Buy(lote,_Symbol,0,0,0,"Compra a mercado");
           }
         //--- vende
         if( sinalVenda )
           {
            trade.Sell(lote,_Symbol,0,0,0,"Venda a mercado");
           }
        }
      else
        {
         //--- comprado
         if( comprado )
           {
            if( sinalVenda )
              {
               trade.Sell(lote*2,_Symbol,0,0,0,"Virada de mão (compra->venda)");
              }
           }
         //--- vendido
         else if( vendido )
           {
            if( sinalCompra )
              {
               trade.Buy(lote*2,_Symbol,0,0,0,"Virada de mão (venda->compra)");
              }
           }
        }
     }
  }

//---

bool isNewBar()
  {
//--- memorize the time of opening of the last bar in the static variable
   static datetime last_time=0;
//--- current time
   datetime lastbar_time=(datetime)SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);

//--- if it is the first call of the function
   if(last_time==0)
     {
      //--- set the time and exit
      last_time=lastbar_time;
      return(false);
     }

//--- if the time differs
   if(last_time!=lastbar_time)
     {
      //--- memorize the time and return true
      last_time=lastbar_time;
      return(true);
     }
//--- if we passed to this line, then the bar is not new; return false
   return(false);
  }