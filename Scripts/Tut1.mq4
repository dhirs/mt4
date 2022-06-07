void OnStart()
  {
   Alert("Hello World!");
   double yesterdayHigh = iLowest(NULL, PERIOD_D1, 1);
   ObjectCreate("HLine", OBJ_HLINE , 0,Time[0], yesterdayHigh);
           ObjectSet("HLine", OBJPROP_STYLE, STYLE_SOLID);
           ObjectSet("HLine", OBJPROP_COLOR, Red);
           ObjectSet("HLine", OBJPROP_WIDTH, 0);
  }

