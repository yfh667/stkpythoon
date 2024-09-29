%% Call ALL Function
function F = A
    F.add = @add;
    F.multiply = @multiply;
    F.mis = @mis;
end

%% Function body
function c = add(a,b)
c=a+b;
end

function c = multiply(a,b)
c=a*b;
end

function c = mis(a,b)
c=a-b;
end
