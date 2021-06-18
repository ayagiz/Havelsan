function [path] = Astar(mapsize,start,target,obstacles,obsize)
%ASTAR Summary of this function goes here
%tries to find shortest path
%mapsize: size of the map(prediction) Some errors might happen
% start: start position
% target: the position it tries to reach
% obstacles: obstacle array. Function will check obstacles
% obsize: size of the obstacle array
% Detailed explanation goes here
mapsize = floor(mapsize);
%since AI can go in 8 directions, we first create adjecent array
adj = zeros(8,2);
%right
adj(1,1) = 1;
adj(1,2) = 0;
%up-right
adj(2,1) = 1;
adj(2,2) = 1;
%up
adj(3,1) = 0;
adj(3,2) = 1;
%up-left
adj(4,1) = -1;
adj(4,2) = 1;
%left
adj(5,1) = -1;
adj(5,2) = 0;
%down-left
adj(6,1) = -1;
adj(6,2) = -1;
%down
adj(7,1) = 0;
adj(7,2) = -1;
%right-down
adj(8,1) = 1;
adj(8,2) = -1;

%all coordinate informations can be turned into index elements.
%even negative coordinates
%cal_index takes the obstacle array and changes coordinate information
%inside into corresponding node indexes so that we can use them in Node
%cell array. See below

for i = 1:obsize
        [obstacles(i,1),obstacles(i,2)] = cal_index(mapsize,floor(obstacles(i,1)),floor(obstacles(i,2)));
end

% pq = PriorityQueue(mapsize);

%create priority queue
pq = pq_handle(mapsize);

start(1) = floor(start(1));
start(2) = floor(start(2));

target(1) = floor(target(1));
target(2) = floor(target(2));

%index of start point
[sx,sy] = cal_index(mapsize,start(1),start(2));

% index of target coordinate in Nodes cell array
% keep it we will use later
[tarx,tary] = cal_index(mapsize,target(1),target(2));


%before starting pathing check whether target point is surrounded by
%obstacles or not
isTargetReachable = 1;
%if obstacle count becomes 8, it means target point is surrounded by
%obstacles
obstacle_count = 0;
if obsize >= 8
    for i=1:length(adj)
        target_adjx = target(1) + adj(i,1);
        target_adjy = target(2) + adj(i,2);
        [target_adjx_index,target_adjy_index] = cal_index(mapsize,target_adjx,target_adjy);
        for o=1:obsize
            if target_adjx_index == obstacles(o,1) && target_adjy_index == obstacles(o,2)
                obstacle_count = obstacle_count + 1;
                break;
            end
        end
    end
end
if obsize >= 8
disp("target surrounded by " + obstacle_count + " obstacles");
end
if obstacle_count == 8
    isTargetReachable = 0;
    disp("target point surrounded by obstacles.So, there is no path");
end
%create nodes cell array
%for exp if mapsize is 200:
%it creates a 2D square with diagonal coordinates
%200,200|-200,200|-200,-200|200,-200
%and this square and its inside are our map.
%So, be careful when choosing mapsize. First decide max coordinates can be
%reach. For example you find max coordinate as -743,456. Then, choose
%mapsize as 750 or 800.
% There are (mapsize*2+1)^2 number of possible
% coordinates.
Nodes = cell(mapsize*2+1,mapsize*2+1);

%we start to assign coordinates from the bottom
%for example: if mapsize is 200 then, we start from coordinate -200,-200 to
%200,200

startx = -mapsize;
starty = -mapsize;
%assign coordinates to nodes
for row = 1:length(Nodes(:,1))
    cury = starty;
    for col = 1:length(Nodes)
        Nodes{row,col} = Node(startx,cury,999999);
        cury = cury + 1;
    end
    startx = startx +1;
end

% suppose mapsize is 200 again. We know first element of the Node array
% points to -200,-200 coordinate. This function below does that
% cal_index(mapsize,x,y):
% x = node.x + mapsize + 1;
% y = node.y + mapsize + 1;
% x = -200 + 200 + 1 = 1
% y = -200 + 200 + 1 = 1
%returns [1,1] which is the index to access that position

%insert source node to the priority queue
%as you can see cal_index function is called to
%convert start position the index elements so that it can be used in Nodes
%cell array.



%check whether start point marked as an obstacle or not. Start point marked
%as obstacle when target point detected as obstacle but marking target
%point as obstacle is wrong. Without making AI go around the target point, we can
%not say target point is not reachable. Looking at the end of the obstacles
%array is enough.
isStartObstacle = 0;
if obsize > 0
    if sx == obstacles(obsize,1) && sy == obstacles(obsize,2)
        isStartObstacle = 1;
    end
end
% if start point is an obstacle, try to find new start point. If new start point
% can not found marke condition as dead point. If its
% marked as dead point, it means there is no path.
deadPoint = 1;
if isStartObstacle == 1
    %traverse thorugh its adjecents
    for i=1:length(adj)
        new_startx = start(1) + adj(i,1);
        new_starty = start(2) + adj(i,2);
        if new_startx < -mapsize || new_startx > mapsize
            continue;
        end
        if new_starty < -mapsize || new_starty > mapsize
            continue;
        end
        [new_startx_index,new_starty_index] = cal_index(mapsize,new_startx,new_starty);
        %carefull to not choose new start point as target point since thats
        %the all point!
        found = 1;
        if tarx == new_startx_index && tary == new_starty_index
            continue;
        end
        for o=1:obsize
            %if new start point is found change sx and sy values
            
            if new_startx_index == obstacles(o,1) && new_starty_index == obstacles(o,2)
                
                found = 0;
                break;
            end
            if o == obsize
                sx = new_startx_index;
                sy = new_starty_index;
            end
        end
        if found == 1
            deadPoint = 0;
            disp("new start point is found.");
            break;
        end
    end
end

if deadPoint == 1 && isStartObstacle
    disp("start point surrounded by obstacles, so cant find any new start point");
end

Nodes{sx,sy}.distance = 0;
% [pq.top, pq.array] = pq.insert(Nodes{sx,sy});
% insert start positions corresponding node to the queue
pq.insert(Nodes{sx,sy});


% keep the time since if there is no path and mapsize is very big
%(notice that mapsize=200 is very big. Means 200^2 nodes to traverse) then, it will take forever to find
%path. So, I decided that if it takes more than 30 seconds to find path,
%then, it will give up
start_time = cputime;
if isTargetReachable == 1 && (deadPoint ~= 1 || isStartObstacle ~= 1)
while(~pq.isEmpty())
    %pop the min distance node and process it
%     [current,pq.top,pq.array] = pq.pop();
      current = pq.pop();

      %if time elapsed is more than 60 seconds break the loop
      time_elapsed = cputime - start_time;
      if(time_elapsed > 60)
          disp("its been 60 seconds, probably there is no path");
          break;
      end
    %take popped nodes coordinates and turn them to index values
    %and with using that index marked the node as processed
    [curx,cury] = cal_index(mapsize,current.x,current.y);
    Nodes{curx,cury}.isProcessed = 1;


    %path found no need for further calculations
    if curx == tarx && cury == tary
        disp("path found");
        break;
    end
    
    %if path not found continue
    
    % traverse adj's
    for i=1:length(adj)
        %coordinates of the adj
        corx = current.x + adj(i,1);
        cory = current.y + adj(i,2);
        
        %check the boundaries of the map
        if corx < -mapsize || corx > mapsize
            continue;
        end
        if cory < -mapsize || cory > mapsize
            continue;
        end
        % calculate index of the adjecent in Nodes cell array
        [adjx,adjy] = cal_index(mapsize,corx,cory);
        %if current adj is an obstacle dont process it
        %we know that obstacles array's coordinate values turned into
        %indexes so we compare index values to decide if current adjecent
        %node is obstacle or not
        isObstacle = 0;
        if obsize > 0
            for obs=1:obsize
                if adjx == obstacles(obs,1) && adjy == obstacles(obs,2)
                    isObstacle = 1;
                    break;
                end
            end
        end
        %if current adjecent node is obstacle dismiss it
        if isObstacle == 1
            continue;
        end
        
        % if adjecent is not processed do the following
         if(Nodes{adjx,adjy}.isProcessed == 0)
            %calculate cost of adj 
            %g = parent nodes distance to source node + distance between
            %adjecent and parent node
            g = current.g + sqrt((current.x - corx)^2 + (current.y - cory)^2);
            %this is the difference between dijkstra and A* algorithm
            %h = distance between current node and target node
            h = sqrt( (target(1)-corx)^2 + (target(2)-cory)^2);
            %cost is simply summation of them
            %edit: removing g from the calculations resulted in better
            %results
            %old distance calculation was distance = g + h
            distance = g + h;
            index = pq.contains(corx,cory);
           %if priority queue contains the node and new found
           %cost is lesser than previous cost, update the queue
           if index ~= 0 && Nodes{adjx,adjy}.distance > distance

                Nodes{adjx,adjy}.distance = distance;
                Nodes{adjx,adjy}.g = g;
                
                % keeping the h value is actually unnecessary
                Nodes{adjx,adjy}.h = h;
               %with edge to property of Node class we, keep the path
               Nodes{adjx,adjy}.edge_to = [curx cury];
               %we keep the number of node counts the reach our adjecent
               %node so that we can know size of the path array
               Nodes{adjx,adjy}.node_count = Nodes{curx,cury}.node_count + 1;
               
%                pq.array = pq.decreaseKey(corx,cory,distance);
                 %updated node finds its correct place in queue
                 pq.decreaseKey(corx,cory,distance);
           % if pq does not contain it and new found cost is lesser than
           % previous cost, add it to the pq
           elseif index == 0 && Nodes{adjx,adjy}.distance > distance
               
                Nodes{adjx,adjy}.distance = distance;
                Nodes{adjx,adjy}.g = g;
                Nodes{adjx,adjy}.h = h;


%                [pq.top,pq.array] = pq.insert(Nodes{adjx,adjy});
                 pq.insert(Nodes{adjx,adjy});
                 
               Nodes{adjx,adjy}.node_count = Nodes{curx,cury}.node_count + 1;
               Nodes{adjx,adjy}.edge_to = [curx cury];
           end    
         end
    end
end
end
disp("took " + (cputime-start_time) + " seconds to find path");


%get the path from target node
%if no path is found -1 will be returned
path = -1;
save_node = Nodes{tarx,tary}.node_count+1;
%if no nodes leads to the target node, then, node_count of the target node
%will be 0
if Nodes{tarx,tary}.node_count == 0
    disp("no path found ");
else    
    %node_count of target node + 1 is our path size but we also keep array
    %size in path array so array size is node_count+2
    path = zeros(Nodes{tarx,tary}.node_count+2,2);
    start_index = Nodes{tarx,tary}.node_count+2;
    while start_index >= 2
        path(start_index,1:2) = [Nodes{tarx,tary}.x Nodes{tarx,tary}.y];
        tempx = Nodes{tarx,tary}.edge_to(1);
        tempy = Nodes{tarx,tary}.edge_to(2);
        tarx = tempx;
        tary = tempy;
        start_index = start_index -1 ;
    end
    %first element of the path array is the size of of the path
    path(1,1) = save_node;
    path(1,2) = save_node;
end
end
function [row,col] = cal_index(mapsize,x,y)
    %calculates index of the node according to its world coordinates
    row = mapsize + x + 1;
    col = mapsize + y + 1;
end

