function w=calculateEnergy(times, curr, v)
    w=0;
    for i=1:(length(times)-1)
        dt=(times(i+1)-times(i))/1000;
        w=w+curr(i)*v(i)*dt;
    end
    w=w/3600;
end