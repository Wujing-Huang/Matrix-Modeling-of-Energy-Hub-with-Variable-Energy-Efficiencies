function NTI = formNTI( fname )
% Form NTI from TXT file.
% Save NTI as a MAT file.
if nargin==0 
fname = 'NT_Info.txt';
end
fid = fopen(fname, 'r');
i=1;
while ~feof(fid)
    tline=fgetl(fid);
    if tline(1)~='%'
       if  tline(1)=='#'    %beginning
           temp = regexp(tline, '\s+', 'split');
           NTI(i).num=str2double(temp{1}(2));
           NTI(i).name=temp{2};
           tline = fgetl(fid);
           while ~isempty(tline)
%              disp(tline)
                 if tline(1)~='%'
                     temp = regexp(tline, '\s+', 'split');
                     switch(temp{1})
                         case('Input:')
                            NTI(i).input=EIndex(temp(1,2:end));
                         case('Output:')
                            NTI(i).output=EIndex(temp(1,2:end));
                         case('Adjustability:')
                             if temp{1,2}=='Y'
                                 NTI(i).adj=1;
                             elseif temp{1,2}=='N'
                                 NTI(i).adj=0;
                             end
                         case('Storage:')
                             if temp{1,2}=='Y'
                                 NTI(i).storage=1;
                             elseif temp{1,2}=='N'
                                 NTI(i).storage=0;
                             end
                     end
                 end
             tline = fgetl(fid);
           end
       end
       i=i+1;   %end
    end
end
save('NTI.mat','NTI');
return;
end

