function [w, m]=calculateCurrent(times, curr)
    w=0;
    m=0;
    for i=1:(length(times)-1)
        dt=(times(i+1)-times(i))/1000;
        w=w+curr(i)*dt;
        if curr(i)>m
            m=curr(i);
        end
    end
    w=w/3600;
end