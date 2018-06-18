gridm=zeros(8,8);
gridm=init_grid(gridm);
update_grid(gridm);
in=update_in(gridm);
a=cluster(gridm,in);
b=link(gridm);
d=route_area(b,5,7);
[f,c]=route_shortest(b,5,7);
e=between_center(b,2)

function newgridm=update_grid(gridm)
newgridm=gridm;
end

function newgridm=init_grid(gridm)
newgridm=gridm;
newgridm(1,2)=1;newgridm(2,1)=1;
newgridm(1,6)=1;newgridm(6,1)=1;
newgridm(1,7)=1;newgridm(7,1)=1;
newgridm(2,3)=1;newgridm(3,2)=1;
newgridm(2,4)=1;newgridm(4,2)=1;
newgridm(2,5)=1;newgridm(5,2)=1;
newgridm(3,8)=1;newgridm(8,3)=1;
newgridm(3,6)=1;newgridm(6,3)=1;
newgridm(6,7)=1;newgridm(7,6)=1;
end

function in= update_in(gridm)
sizem=size(gridm);
length=sizem(1);
in=zeros(1,length); out=0;
for i=1:length
    for j=1:length
        if gridm(i,j)==1
            in(1,i)=in(1,i)+1;
        end
    end
end
end

function [factor_cluster,in] =cluster(gridm,in)
sizem=size(gridm);
length=sizem(1);
factor_cluster=zeros(1,length);
for i=1:length
    if in(1,i)<=1
        factor_cluster(1,i)=0;
    else
        a=in(1,i)*(in(1,i)-1);
        b=0;
        for x=1:length
            for y=1:length
                if gridm(x,y)==1 && gridm(x,i)==1 && gridm(y,i)==1
                    b=b+1;
                end
            end
        end
        factor_cluster(1,i)=b/a;
    end
end
end

function linkm=link(gridm)
sizem=size(gridm);
length=sizem(1);
linkm=zeros(length);
for i=1:length
    index=1;
    for j=1:length
        if gridm(i,j)~=0
            linkm(i,index)=j;
            index=index+1;
        end
    end
end        
end

function [route_length,routelist]=route_shortest(linkm,i,j)
routelist=zeros(10,4);
route=route_area(linkm,i,j);
route_length=1;
allnum=1;
while(route(route_length,1)~=0)
    route_length=route_length+1;
end
route_length=route_length-1;
routenum=zeros(1,route_length);
for i=1:route_length
    num=1;
    while(route(i,num)~=0)
        num=num+1;
    end
    allnum=allnum*(num-1);
    routenum(1,i)=num-1;
end
routenum(1,route_length+1)=1;
routeall=zeros(allnum,route_length);
for i=1:allnum
    for j=1:route_length
        n=floor(mod(i,prod(routenum(1,j:route_length)))/prod(routenum(1,j+1:route_length+1)))+1;
        routeall(i,j)=route(j,n);
    end
end
index=1;    
for i=1:allnum
    flag2=1;
    for j=1:route_length-1 
        x=routeall(i,j+1);
        flag=0;
        for y=linkm(routeall(i,j),:)
            if y==x
                flag=1;
                break;
            else
               continue;
            end
        end
        if flag==0
            flag2=0;
        end  
    end 
    if flag2~=0
        routelist(index,1:route_length)=routeall(i,1:route_length);
        index=index+1;
    end
end
end
       
function route=route_area(linkm,i,j)
sizem=size(linkm);
length=sizem(1);
used=ones(1,length);
used(1,i)=0;
route=zeros(length);
route(1,1)=i;
flag=0;
for x=1:length-1
    index=1;
    for m=1:(length-1)
        if flag~=0
            break;
        end
        if route(x,m)==0 
            continue;
        else
            for y=linkm(route(x,m),:)
                if y==j
                    used(1,y)=0;
                    route(x+1,index)=y;
                    flag=1;
                    break;
                end
                if y==0
                    break;
                end
                if used(1,y)~=0
                    used(1,y)=0;
                    route(x+1,index)=y;
                    index=index+1;                    
                end
            end
        end
    end
    if flag~=0
        if index>1
            route(x+1,1)=route(x+1,index);
            for n=2:index
                route(x+1,n)=0;
            end
        end   
        break;
    end
end
end        

function bc=between_center(linkm,n)
sizem=size(linkm);
length=sizem(1);
bc=0;
for i=1:length
    if i==n
        continue;
    else
        for j=1:i
            if j==i || j==n
                continue;
            else
                [route_length,routelist]=route_shortest(linkm,i,j);
                num=1;
                while(routelist(num,1)~=0)
                    num=num+1;
                end
                route_length=route_length-1;
                numhave=0;
                for x=1:num
                    for y=1:route_length
                        if routelist(x,y)==n
                            numhave=numhave+1;
                            break;
                        end
                    end
                end
                bc=bc+numhave/num;
            end
        end
    end
end
                                   
end

