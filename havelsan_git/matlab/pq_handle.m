classdef pq_handle < handle
    %UNTİTLED Summary of this class goes here
%     Priority queue class. It is used to pick node with smallest cost so that shortest
%     path can be achieved.
%     array: representation of the min heap
%     top: top of the array
%     bottom: always equals to 1
    %   Detailed explanation goes here
    
    properties(SetAccess = public)
        array
        top
        bottom
    end
    
    methods
        function obj = pq_handle(mapsize)
            %UNTİTLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.array = cell(1,(mapsize+1)^2);
            obj.bottom = 1;
            obj.top = 0;
        end
        function out = contains(obj,x,y)
            %search for the node if its in the queue or not.
            %if found, index position is returned else returned 0
            out = 0;
            for i = 1:obj.top
                if(isobject(obj.array{i}) && obj.array{i}.x == x && obj.array{i}.y == y)
                    out = i;
                    break;
                end
            end
        end
        function out = printContent(obj)
            %displays the content of the tree
            for i=1:obj.top
                if(isobject(obj.array{i}))
                    disp("x " + obj.array{i}.x + " y " + obj.array{i}.y + "  dist " + obj.array{i}.distance);
                else
                    break;
                end
            end
            out = 1;
        end
        function insert(obj,node)
            %insert new instance to the end of the node and new instance
            %tries to swim.
            obj.top = obj.top + 1; 
            obj.array{obj.top} = node;
            obj.swim(obj.top);
        end
        function swim(obj,n)
            %this method takes the given instance and makes it swim through
            %root of the tree
            while n >= 2 && obj.array{n}.distance < obj.array{floor(n/2)}.distance
                temp = Node(obj.array{n}.x,obj.array{n}.y,obj.array{n}.distance);
                obj.array{n} = obj.array{floor(n/2)};
                obj.array{floor(n/2)} = temp;
                n = floor(n/2);
            end
        end
        function sink(obj,top)
            %reverse of swim. Given instance goes under the tree
            n = 1;
            while int8(2*n) <= top
                child = int8(n*2);
                if child + 1 <= top && obj.array{child}.distance > obj.array{child+1}.distance
                    child = child + 1;
                end
                if obj.array{n}.distance > obj.array{child}.distance
                temp = Node(obj.array{n}.x,obj.array{n}.y,obj.array{n}.distance);
                obj.array{n} = obj.array{child};
                obj.array{child} = temp;
                end
                n = int8(child);
            end
        end
        function popped = pop(obj)
            %returns the node with smallest cost
            %to do that first element and last element of the arrat swaps
            %positions and root instance leaved to the sink method.
            if(~obj.isEmpty())
                temp = Node(obj.array{obj.top}.x,obj.array{obj.top}.y,obj.array{obj.top}.distance);
                obj.array{obj.top} = obj.array{1};
                obj.array{1} = temp;
                obj.top = obj.top - 1;
                popped = obj.array{obj.top+1};
                obj.sink(obj.top);
            else
               popped = -1;
            end
        end
        function out = isEmpty(obj)
            %checks whether the queue is empty or not
            if(obj.top < obj.bottom)
                out = true;
            else
                out = false;
            end
        end
        function decreaseKey(obj,x,y,newdistance)
            %when some node's cost is decreased
            %it tries to swim up.
            %first it finds the index of the node then, it is leaved to
            %swim method.
            index = obj.contains(x,y);
            if index ~= 0
                obj.array{index}.distance = newdistance;
                obj.swim(index);
            end
        end
    end
end

