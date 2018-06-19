
gridm=zeros(8,8);
gridm=init_grid(gridm);

parent=test(gridm,1,8);



function newgridm=init_grid(gridm)
newgridm=gridm;
sizem=size(gridm);
length=sizem(1);
for i=1:length
    for j=1:length
        newgridm(i,j)=inf;
    end
end
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

function parent=test(gridm,start,endnode)
sizem=size(gridm);
length=sizem(1);
distance=zeros(1,length);
used=ones(1,length);
parent=1:length;
num=1;
for i=1:length
    distance(i)=inf;
end
distance(start)=0;
used(start)=0;
for i=2:length
    temp=zeros(1,length);
    for k=1:length
        temp(k)=inf;
    end
    for k=1:length
        num=1;
        for j=1:length
            if  used(k)~=0
                if distance(k) == distance(j)+gridm(j,k) && distance(k)~=inf...
                        && parent(num,k)~=j
                    num=num+1;
                    parent(num,k)=j;
                end
                if distance(k)> distance(j)+gridm(j,k)
                    distance(k)= distance(j)+gridm(j,k);
                    parent(1,k)=j;
                    num=1;
                    for z=2:length
                        parent(z,k)=0;
                    end
                    temp(k)=distance(k);     
                end
                
            end
        end
    end
    [~,index]=min(temp);
    used(index)=0;
end
%---------------------------------------
newparent=parent;
sizen=size(parent);
width=sizen(1);
routenum=1;
pathlist=zeros(1,1);
while newparent(1,endnode)~=0
    pathlist(routenum,1)=endnode;
    te=endnode;
    x=1;
    while te~=start
        te=newparent(1,te);
        x=x+1;
        pathlist(routenum,x)=te;
    end
    testlist=pathlist(routenum,:);
    for y=testlist
        if newparent(2,y)~=0
            for z=2:width
                newparent(z-1,y)=newparent(z,y);
            end
            break
        end
    end
    if y==start
        break;
    end       
    routenum=routenum+1;
end
pathlist
end
