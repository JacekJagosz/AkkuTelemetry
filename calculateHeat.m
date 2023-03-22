function w=calculateHeat(times, curr, R)
    w=0;
    for i=1:(length(times)-1)
        dt=(times(i+1)-times(i))/1000;
        temp=curr(i)*curr(i)*R;
        w=w+temp*dt;
    end
    %w=w/3600;
end