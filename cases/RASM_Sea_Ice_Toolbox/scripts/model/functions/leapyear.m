function ly=leapyear(year)

for i=1:length(year)
   
    b=mod(year(i),4);
    year
    ly1(i)=logical(b);
    ly=~ly1(i)
    %if b==0
     %   ly1(i)=1;
    %else 
     %   ly1(i)=0;
    %end
end
    %ly=ly1(length(ly1))
