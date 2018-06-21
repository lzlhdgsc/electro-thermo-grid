%initialize the microgrid
gridm=zeros(8,8);
gridm=init_grid(gridm);
G=graph(gridm);
%plot(G); 
%-----------
%initialize the properity of mocrogrid
sizem=size(gridm);
length=sizem(1);
%0:generator,1:load,2:storage,3:transformer,4:others
%new load can directly be added to an old load node
properity=[0,3,3,0,0,1,2,1];
P_list=[15,-0.1,-0.15,2.5,4,-20,0.1,-1.5];
%Q_list=[15,-0.1,-0.15,4.5,8,-20,0.1,-1.5];
%Rup_list=[1.5,0,0,-2.5,-4,-6,6,0];%WAVE transient
%Rdown_list=[1.5,0,0,-2,-4,-6,6,0];
R_list=[1.5,0,0,-2.5,-4,-2,7,0];
C_list=zeros(1,length);C_list(7)=100;
%Rram_list=[1,];%ramp rate
%Rram_sum=0;
%---------------------------
%initialize the probablity of change
s=RandStream.getGlobalStream;
p_addload=0.3;
p_error=0.01;
P_sum=0;
Pout_sum=21.5;
%Q_sum=0;
R_sum=0;
Rout_sum=8.5;

n=200;
used=ones(1,length);
%新增节点,原有节点有功/无功/波动冗余量 不变
addload_time=0;
for i=1:n 
    if rand(s)<p_addload
        addload_time=addload_time+1;
        addload=rand(s)*(-2);
        temp_compare=zeros(1,length);
        for j=1:length
            if properity(j)==1 && addload>P_list(j) && used(j)~=0
                temp_compare(j)=1;
            end
        end
        if sum(temp_compare)~=0
            temp_index=0;temp_in=inf;in=update_in(gridm);
            %temp_G=addnode(temp_G,1); temp_G=addedge(temp_G,j,);
            for j=1:length
                if temp_compare(j)~=0 && temp_in>abs(in(j)*P_list(j))
                    temp_index=j;
                    temp_in=abs(in(j)*P_list(j));
                end
            end
            P_list(temp_index)= P_list(temp_index)+addload;
            R_list(temp_index)= R_list(temp_index)+addload*0.1;
            P_sum=P_sum+addload;
            R_sum=R_sum+addload*0.1;
            used(temp_index)=0;     
        else 
            for j=1:length
                if properity(j)==3 && used(j)>-2
                    temp_compare(j)=1;
                end
            end
            if sum(temp_compare)~=0
                temp_G=G;temp_efficiency=0;temp_index=0;
                for j=1:length
                    if properity(j)==3 && (temp_compare(j)~=0)
                        temp_G=addedge(temp_G,j,length+1,1);
                        if efficiency(back_up(temp_G))>temp_efficiency
                            temp_index=j;
                            temp_efficiency=efficiency(back_up(temp_G));
                        end
                        temp_G=rmedge(temp_G,j,length+1);
                        temp_G=rmnode(temp_G,length+1);
                    end  
                end
                temp_G=addedge(temp_G,temp_index,length+1,1);
                G=temp_G;
                used(temp_index)=used(temp_index)-1;
                used=[used,1];
                gridm=back_up(G);
                length=length+1;
                P_list=[P_list,addload];
                R_list=[R_list,addload*0.1];
                P_sum=P_sum+addload;
                R_sum=R_sum+addload*0.1;
                properity=[properity,1];
            else
                temp_G=G;temp_efficiency=0;temp_index=0;
                for j=1:length
                   if properity(j)==0 || properity(j)==2
                        temp_G=addedge(temp_G,j,length+1,1);
                        temp_G=addedge(temp_G,length+1,length+2,1);
                        if efficiency(back_up(temp_G))>temp_efficiency   
                            temp_index=j;
                            temp_efficiency=efficiency(back_up(temp_G));  
                        end
                        temp_G=rmedge(temp_G,j,length+1);
                        temp_G=rmedge(temp_G,length+1,length+2);
                   end  
                end
                temp_G=addedge(temp_G,temp_index,length+1,1);
                temp_G=addedge(temp_G,length+1,length+2,1);
                used(temp_index)=used(temp_index)-1;
                used=[used,1,1];
                G=temp_G;
                gridm=back_up(G);
                length=length+2;
                P_list=[P_list,-0.1,addload];
                R_list=[R_list,0,addload*0.1];
                P_sum=P_sum+addload-0.1;
                R_sum=R_sum+addload*0.1*rand(s);
                properity=[properity,3,1];
            end
        end
    end
    if abs(P_sum/Pout_sum)>0.6
        addgenerator=-P_sum;
        P_sum=0;
        temp_G=G;temp_efficiency=0;temp_index=0;
        for j=1:length
            if properity(j)==1
                temp_G=addedge(temp_G,j,length+1,1);
                temp_G=addedge(temp_G,length+1,length+2,1);
                if efficiency(back_up(temp_G))>temp_efficiency
                    temp_index=j;
                    temp_efficiency=efficiency(back_up(temp_G));
                end
                temp_G=rmedge(temp_G,j,length+1);
                temp_G=rmedge(temp_G,length+1,length+2);
            end 
        end
        temp_G=addedge(temp_G,temp_index,length+1,1);
        temp_G=addedge(temp_G,length+1,length+2,1);
        
        used(temp_index)=1;
        used=[used,1,1];
        G=temp_G;
        gridm=back_up(G);
        length=length+2;
        P_list=[P_list,-0.1,addgenerator];
        R_list=[R_list,0,addgenerator*0.1];
        R_sum=R_sum+addload*0.1*rand(s);
        properity=[properity,3,0];
    end  
end

p=plot(G,'NodeLabel',properity);
p.NodeColor='r';


function mat=back_up(G)
mat=full(adjacency(G));
end

function newproperity=update_properity(properity,index,value)
newproperity=properity;
if index==0
    newproperity=[value,properity];
else
    if index==list_length(properity)
        newproperity=[properity,value];
    else
        newproperity=[properity(1,1:index),value,properity(1,index+1:list_length(properity))];
    end
end
end

function length=list_length(mat)
[~,length]=size(mat);
end

function newgridm=update_grid(gridm,x,y)
sizem=size(gridm);
length=sizem(1);
newgridm=zeros(length+1,length+1);
newgridm(1:length,1:length)=gridm;
newgridm(length+1,x)=1;
newgridm(length+1,y)=1;
newgridm(x,length+1)=1;
newgridm(y,length+1)=1;
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

function [factor_cluster,in] =cluster(gridm)
sizem=size(gridm);
length=sizem(1);
factor_cluster=zeros(1,length);
in=update_in(gridm);
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

function eff=efficiency(linkm)
sizem=size(linkm);
length=sizem(1);
eff=0;
for i=1:length
    for j=1:i
        if j==i 
            continue;
        else
            [route_length,routelist]=route_shortest(linkm,i,j);
        end
        eff=eff+1/route_length;
    end  
end
eff=eff/(length-1)/length;        
end

%update_grid(gridm);
%{
in=update_in(gridm);
a=cluster(gridm);
b=link(gridm);
d=route_area(b,5,7);
[f,c]=route_shortest(b,5,7);
e=between_center(b,3);
g=efficiency(b);

Ce=0.5;
Cl=1;
Cs=0.8;
Me=1;
Ml=2;
Ms=0.8;
Pe=0.1;
Pl=0.5;
Ps=0.2;

bclist=zeros(1,8);
for i=1:8
    bclist(1,i)=between_center(b,i);
end
result=bclist;
%}
