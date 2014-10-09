flag = 1;
for i = 4: (365/5*9-3)
   if (IceL_all_demo(3, i) == 0 && IceL_all_demo(3, i+3) == 0 && IceL_all_demo(3, i-1) ~= 0) 
       IceL_i(1, flag) = i;
   end
   if (IceL_all_demo(3, i) == 0 && IceL_all_demo(3, i-3) == 0 && IceL_all_demo(3, i+1) ~= 0) 
       IceL_i(2, flag) = i;
       flag = flag + 1;
   end
end

IceP_all_demo = IceP_all_Year;

for i = 1: 10
   startl = IceL_i(1, i);
   endl = IceL_i(2, i);
   IceP_all_demo(3, startl: endl) = NaN;
end