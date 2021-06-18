% first paramater is your ip adress. In command window execute ipconfig
% and learn your ip address
% second parameter is port
% do not touch other parameters
t = tcpip('192.168.56.1', 12345, 'NetworkRole', 'server');
fopen(t);
data = 0;

start = zeros(2);
target = zeros(2);

mapsize = 200;

obstacles = -1 * ones((mapsize+1)^2,2);
%size of obstacle array
obs_index = 1;
path = -1;
%start listening
while true
    %wait until there is data to be read
    while t.BytesAvailable <= 0 
        pause(0.1);
    end
    if t.BytesAvailable > 0
        %read data
        data = fread(t, t.BytesAvailable);
        % turn into char array since matlab turns chars to their numeric
        % values
        data = char(data);
        
        %turn data to string
        str = "";
        for i = 1:length(data)
            str = str + data(i);
        end
        %if AI reached its destination. WE ARE DONE!
        if(strcmp("done",str))
            disp("Mission Done");
            fclose(t);
            clear;
            break;
        end 
        %split the data by delimeter whitespace
        data = split(str);
        %start command is given at start of the connection
        if strcmp("start",data(1))
            disp("starting path calculations");
            start = str2double(data(2:3));
            %dismiss 4. elemets since its the z coordinate
            target = str2double(data(5:6));
            %calculate path
            path = Astar(mapsize,start,target,obstacles,obs_index-1);
            if path == -1
                disp("no path found");
            else
                disp("path found sending");
            end
        end
        %If AI is stuck somewhere, it sends one obstacle
        if strcmp("stuck",data(1))
            new_obstacles = str2double(data(2:end));
            %obstacle coordinates
            fx = new_obstacles(1);
            fy = new_obstacles(2);
            
            %AI will start at where it stucked
            start = new_obstacles(4:5);
            %target did not change
            target = new_obstacles(7:8);
            
            start(1) = floor(start(1));
            start(2) = floor(start(2));
            target(1) = floor(target(1));
            target(2) = floor(target(2));
            fx = floor(fx);
            fy = floor(fy);
            
            % add them to the obstacle array
            
            %if target location is marked as an obstacle mark start
            %location as obstacle
            if fx ~= target(1) || fy ~= target(2)
                obstacles(obs_index,1) = fx;
                obstacles(obs_index,2) = fy;
            else
                obstacles(obs_index,1) = start(1);
                obstacles(obs_index,2) = start(2);
            end
            disp("new obstacle " +obstacles(obs_index,1)+ " " + obstacles(obs_index,2));
            obs_index = obs_index + 1;
                  
            
            %calculate again
            path = Astar(mapsize,start,target,obstacles,obs_index-1);

        end
    end
        %if path found it has to be turned into string. Remember that first
        %element of the path array is keeps the size of the path
        if length(path) ~= 1 && (strcmp(data(1),"start") || strcmp("stuck",data(1)))
            str = "";
                disp("sending path");
                for i = 1:length(path)
                    str = str + path(i,1) + " " + path(i,2) + " ";
                end
            fprintf(t,str);
            disp("sent "+str);          
        else
            fprintf(t,"nopath");
            disp("no path found. Disconnecting...");
            fclose(t);
            clear;
        end
         pause(1);  
end
fclose(t);
