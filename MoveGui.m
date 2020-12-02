classdef MoveGui < handle
    properties (Constant)
        MOVE_FORMAT = '%d)\t%s\t';
    end
    
    properties (Access=private)
        stateSwitch logical = true
        moveCount = 0
        parent
    end
    
    properties
        guiHandle
        scrollFrame
        moveLog
        backButton
        forwardButton
        currentButton
    end
    
    methods
        function obj = MoveGui(property, value)
            arguments (Repeating)
                property {mustBeSingleString}
                value
            end
            
            for i = 1:length(property)
                obj.(property{i}) = value{i};
            end
            
            obj.guiHandle = uifigure('Menu', 'none', 'Toolbar', 'none',...
                'Position', [300 50 200 500], 'Scrollable', 'off');
            obj.scrollFrame = uipanel(obj.guiHandle, 'Scrollable', 'on',...
                'Position', [10 10 180 440]);
            obj.moveLog = uitextarea(obj.scrollFrame,...
                'Position', [10 10 150 420]);
            obj.backButton = uibutton(obj.guiHandle, 'Text', '<',...
                'Position', [100 450 50 50], 'ButtonPushedFcn',...
                @(varargin) obj.parent.BackMove(varargin{:}));
            obj.forwardButton = uibutton(obj.guiHandle, 'Text', '>',...
                'Position', [150 450 50 50], 'ButtonPushedFcn',...
                @(varargin) obj.parent.PieceUp(varargin{:}));
            obj.currentButton = uibutton(obj.guiHandle, 'Text', 'C',...
                'Position', [10 450 50 50], 'ButtonPushedFcn',...
                @(varargin) obj.parent.Current(varargin{:}));
        end
        
        function NewMove(obj, newMove)
            if obj.stateSwitch
                obj.moveCount = obj.moveCount + 1;
                obj.moveLog.Value{obj.moveCount} = sprintf(...
                    obj.MOVE_FORMAT, obj.moveCount, newMove);
                
                if (length(obj.moveLog.Value) - 3) * 15 >=...
                        obj.moveLog.Position(4)
                    obj.moveLog.Position(4) = obj.moveLog.Position(4) + 15;
                    scroll(obj.scrollFrame, 1, 1);
                end
            else
                obj.moveLog.Value{obj.moveCount} = [...
                    obj.moveLog.Value{obj.moveCount}, newMove];
            end
            
            obj.stateSwitch = ~obj.stateSwitch;
        end
    end
    
    methods (Access=private)
    end
end