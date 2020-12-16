function [w, m]=calculateEnergy(times, curr, v)
    w=0;
    m=0;
    for i=1:(length(times)-1)
        dt=(times(i+1)-times(i))/1000;
        temp=curr(i)*v(i);
        w=w+temp*dt;
        if temp>m
            m=temp;
        end
    end
    w=w/3600;
end