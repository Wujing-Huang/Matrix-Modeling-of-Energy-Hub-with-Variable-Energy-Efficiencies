function [ Enum ] = EIndex( Elist )
% Return energy number according to its name.
% Input argument is cell matrix.
Enum=zeros(size(Elist));
for i=1:size(Elist')
    Ename=Elist{i};
    switch(Ename)
        case('power')
            Enum(i)=1;
        case('cooling')
            Enum(i)=2;
        case('heat')
            Enum(i)=3;
        case('gas')
            Enum(i)=4;
    end
end
end

