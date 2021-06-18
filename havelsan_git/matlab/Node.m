classdef Node
    %NODE Summary of this class goes here
%     Node class presents the coordinates of the found path
%     x and y: coordinates of the node
%     distance: is the cost of the node
%     g: distance of parent to source + distance between current node and parent node
%     h: distance between current node and target node (eucledian)
%     isProcessed: if node is already processed in the priority queue dismiss it
%     edge_to: points to the parent node. It is used to print path array
%     node_count: counts how many nodes required to get to the current node. It is
%         used to find size of the path array.
%     isObstacle: if current node is obstacle dismiss it from calculations.
    %   Detailed explanation goes here
    
    properties
        x
        y
        distance
        g
        h
        isProcessed
        edge_to
        node_count
    end
    
    methods
        function obj = Node(node_x , node_y ,dist)
            %NODE Construct an instance of this class
            %   Detailed explanation goes here
                obj.x = node_x;
                obj.y = node_y;
                obj.distance = dist; 
                obj.isProcessed = 0;
                obj.edge_to = zeros(1,2);
                obj.node_count = 0;
                obj.g = 0;
                obj.h = 0;
        end  
    end
end

