classdef Token < handle
    properties (Constant)
        BOUNDS = [8, 8]
    end
    
    properties
        type Piece = Piece.nothing
        position cell {Token.withinBoardBounds} = {1 1}
        moveCount (1, 1) uint8 = 0
    end
    
    methods
        function obj = Token(property, value)
            arguments (Repeating)
                property {mustBeSingleString}
                value
            end
            for i = 1:length(property)
                obj.(property{i}) = value{i};
            end
        end
        
        function Update(obj, newPosition)
            if ~iscell(newPosition)
                assert(isnumeric(newPosition) && numel(newPosition) ==...
                    2, 'Invalid variable type.');
                newPosition = cell(newPosition(1), newPosition(2));
            end
            
            obj.position = newPosition;
            obj.moveCount = obj.moveCount + 1;
        end
    end
    
    methods (Static)
        function withinBoardBounds(value)
            for i = 1:length(value)
                assert(value{i} <= 8 && value{i} > 0,...
                    'Must be between 1 and 8.');
            end 
        end
        
        function outArr = generateEmptyArray(r, c)
            for i = 1:r
                for j = 1:c
                    outArr(i,j) = Token();
                end
            end
        end
    end
end