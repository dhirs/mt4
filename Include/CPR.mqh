#include  <CustomFunctions01.mqh>

#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
double pdh, pdl,pdc, fp, fBC, fTC, fr1, fr2, fr3, fs1, fs2, fs3;
double top_pivot, bottom_pivot;

void set_chart_pivots(string ea_name)

{



      //Previous day high
      pdh = iHigh(NULL, PERIOD_D1,1);  
      drawHLine(0,"PDH", 0,pdh,true,"PDHLabel","PDH",clrBlue,STYLE_DOT,ea_name);
   
      //Previous day low
      pdl = iLow(NULL, PERIOD_D1,1); 
      drawHLine(0,"PDL", 0,pdl,true,"PDLLabel","PDL", clrGreen,STYLE_DOT,ea_name);
      
      //Previous day close
      pdc = iClose(NULL, PERIOD_D1,1);
      
      fp =(pdh + pdl + pdc)/3;
      drawHLine(0,"CentralPivot", 0,fp,false,NULL,NULL,clrBlue,STYLE_DOT,ea_name);
      
      fBC = (pdh + pdl)/2;
      drawHLine(0,"PivotBottom", 0,fBC,false,NULL,NULL,clrRed,STYLE_DOT,ea_name);
      
      fTC = (fp - fBC) + fp;
      drawHLine(0,"PivotTop", 0,fTC,false,NULL,NULL,clrRed,STYLE_DOT,ea_name);
      
      //Resistance levels
      fr1 = (2 * fp) - pdl;
      fr1 = NormalizeDouble(fr1, Digits);      
      drawHLine(0,"R1", 0,fr1,true,"R-1","R-1",clrRed,STYLE_DASH,ea_name);
      
      fr2 = fp + (pdh - pdl);
      fr2 = NormalizeDouble(fr2, Digits);
      drawHLine(0,"R2", 0,fr2,true,"R-2","R-2",clrRed,STYLE_DASH,ea_name);
      
      fr3 = fr1 + (pdh - pdl);
      fr3 = NormalizeDouble(fr3, Digits);
      drawHLine(0,"R3", 0,fr3,true,"R-3","R-3",clrRed,STYLE_DASH,ea_name);
      
      //Support levels
      fs1 = (2 * fp) - pdh;
      fs1 = NormalizeDouble(fs1, Digits); 
      drawHLine(0,"S1", 0,fs1,true,"S-1","S-1",clrGreen,STYLE_DASH,ea_name);   
      
      fs2 = fp - (pdh - pdl); 
      fs2 = NormalizeDouble(fs2, Digits); 
      drawHLine(0,"S2", 0,fs2,true,"S-2","S-2",clrGreen,STYLE_DASH,ea_name);  
      
      fs3 = fs1 - (pdh - pdl); 
      fs3 = NormalizeDouble(fs3, Digits); 
      drawHLine(0,"S3", 0,fs3,true,"S-3","S-3",clrGreen,STYLE_DASH,ea_name); 
      
      top_pivot = MathMax(fTC,fBC);
      bottom_pivot = MathMin(fTC, fBC); 
  
      

}
