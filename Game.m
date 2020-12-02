classdef Game < handle
    properties (Constant)
        UI_SIZE = [500, 500]
        COLOR_ENCODING = {'white', 'black'}
        NEW_MESSAGE = '%s%s%d'
        HELD_ASCII_P = char(9812:9823)
        HELD_ASCII_C = char(97:104)
    end
    
    properties (Access=private)
        env = EnvironmentManager('bin>system>env.txt')
        valid
        uiHandle
        moveHandle
        uiPieces matlab.ui.control.Image
        uiBackground
    end
    
    properties
        board (8,8) Token = Token().generateEmptyArray(8,8)
        colors
        move = []
        player (1, 1) uint8 = 1
        backLock logical = false;
        freeMode logical = false;
        flipBoard logical = false;
        
        moveHistory cell = {}
        takeHistory cell = {}
        moveIndex uint16 = 1
    end
    
    methods
        function obj = Game(property, value)
            arguments (Repeating)
                property {mustBeSingleString}
                value
            end
            for i = 1:length(property)
                obj.(property{i}) = value{i};
            end
            
            obj.valid = Validator('parent', obj);
            obj.moveHandle = MoveGui('parent', obj);
            
            obj.colors = zeros(8, 8);
            obj.colors([1, 2], :) = obj.flipBoard + 1;
            obj.colors([7, 8], :) = mod(obj.colors(1, 1), 2) + 1;
            
            tempArr = zeros(8, 8);
            tempArr([2, 7], :) = 1;
            tempArr([1, 8], [2, 7]) = 2;
            tempArr([1, 8], [3, 6]) = 3;
            tempArr([1, 8], [1, 8]) = 4;
            tempArr([1, 8], 4) = 5;
            tempArr([1, 8], 5) = 6;
            
            possibleTypes = enumeration('Piece');
            
            for i = 1:8
                for j = 1:8
                    obj.board(i,j).position = {i, j};
                    obj.board(i,j).type = possibleTypes(tempArr(i,j) + 1);
                end
            end
            
            obj.GenerateBoard();
        end
        
        function PrepMove(obj, location, varargin)
            if obj.backLock
                return;
            end
            
            obj.move{end + 1} = location;
            if length(obj.move) == 2
                if obj.valid.ValidateMove()
                    ambiguousMoves = {};
                    for i = 1:8
                        for j = 1:8
                            if obj.board(i, j).type ==...
                                    obj.board(obj.move{1}{:}).type &&...
                                    obj.colors(i, j) ==...
                                    obj.colors(obj.move{1}{:}) &&...
                                    ~all([i j] == [obj.move{1}{:}]) &&...
                                    obj.valid.ValidateMove({i, j})
                                ambiguousMoves{end + 1} = [i j];
                            end
                        end
                    end
                    
                    ambiguousDimensions = false(1, 2);
                    for i = 1:length(ambiguousMoves)
                        ambiguousDimensions = ambiguousMoves{i} ==...
                            [obj.move{1}{:}];
                    end
                    
                    newMoveMessage = obj.HELD_ASCII_P(6*(obj.player - 1)...
                        + (7 - obj.board(obj.move{1}{:}).type.index));
                    
                    if ambiguousDimensions(2)
                        newMoveMessage = [obj.HELD_ASCII_C(...
                            obj.move{1}{2}), newMoveMessage];
                    end
                    if ambiguousDimensions(1)
                        newMoveMessage = [num2str(obj.move{1}{1}),...
                            newMoveMessage];
                    end
                    
                    newMoveMessage = [newMoveMessage,...
                        obj.HELD_ASCII_C(obj.move{2}{2}), num2str(...
                        obj.move{2}{1})];
                    
                    obj.moveHandle.NewMove(newMoveMessage);
                    
                    obj.moveHistory{end + 1} = [obj.move{1},...
                        obj.move{2}];
                    obj.takeHistory{end + 1} = [obj.board(...
                        obj.move{2}{:}).type.index, obj.board(...
                        obj.move{2}{:}).moveCount, obj.colors(...
                        obj.move{2}{:})];
                    obj.moveIndex = length(obj.moveHistory);
                    
                    obj.player = mod(obj.player, 2) + 1;
                    obj.board(obj.move{2}{:}) = obj.board(obj.move{1}{:});
                    obj.board(obj.move{2}{:}).Update(obj.move{2});
                    obj.board(obj.move{1}{:}) = Token('position',...
                        obj.move{1});
                    obj.colors(obj.move{2}{:}) = obj.colors(obj.move{1}{:});
                    obj.colors(obj.move{1}{:}) = 0;
                    
                    obj.UpdateBoard();
                    fprintf('Move: %s\n', obj.COLOR_ENCODING{obj.player});
                end
                obj.move = [];
            end
        end
        
        function BackMove(obj, varargin)
            if ~obj.moveIndex
                return;
            end
            
            obj.player = mod(obj.player, 2) + 1;
            temp_Piece = enumeration('Piece');
            
            tempMove{1} = obj.moveHistory{obj.moveIndex}(3:4);
            tempMove{2} = obj.moveHistory{obj.moveIndex}(1:2);
            
            obj.board(tempMove{1}{:}).Update(tempMove{2});
            obj.board(tempMove{1}{:}).moveCount =...
                obj.board(tempMove{1}{:}).moveCount - 2;
            obj.board(tempMove{2}{:}) = obj.board(tempMove{1}{:});
            obj.colors(tempMove{2}{:}) = obj.colors(tempMove{1}{:});
            obj.colors(tempMove{1}{:}) = obj.takeHistory{obj.moveIndex}(3);
            
            delete(obj.uiPieces(tempMove{2}{:}));
            obj.uiPieces(tempMove{2}{:}) = obj.uiPieces(tempMove{1}{:});
            obj.uiPieces(tempMove{2}{:}).Position(1:2) = ...
                fliplr(cell2mat(obj.board(tempMove{2}{:}).position) - 1)...
                .* (obj.UI_SIZE ./ 8);
            
            tempImgFile = '%s.png';
            if obj.takeHistory{obj.moveIndex}(1)
                tempImgFile = sprintf(tempImgFile, sprintf(...
                    '%s_%s', obj.COLOR_ENCODING{obj.colors(...
                    tempMove{1}{:})}, obj.board(tempMove{1}{:}).type));
            else
                tempImgFile = sprintf(tempImgFile, 'empty');
            end
            
            obj.uiPieces(tempMove{1}{:}) = uiimage(obj.uiHandle,...
                'ImageSource', obj.env.ToPath('art', tempImgFile,...
                '-s'), 'Position', [0, 0, obj.UI_SIZE / 8],...
                'ImageClickedFcn', @(varargin) obj.PrepMove(...
                obj.board(obj.move{2}{:}).position, varargin{:}));
            obj.board(tempMove{1}{:}) = Token('type',...
                temp_Piece(obj.takeHistory{obj.moveIndex}(1) + 1),...
                'position', tempMove{1}, 'moveCount',...
                obj.takeHistory{obj.moveIndex}(2));
            obj.uiPieces(tempMove{1}{:}).Position(1:2) = ...
                fliplr(cell2mat(obj.board(tempMove{1}{:}).position) - 1)...
                .* (obj.UI_SIZE ./ 8);
            
            obj.moveIndex = obj.moveIndex - 1;
        end
        
        function PieceUp(obj, varargin)
            if obj.moveIndex == length(obj.moveHistory)
                return;
            end
            
            obj.moveIndex = obj.moveIndex + 1;
            
            obj.move{1} = obj.moveHistory{obj.moveIndex}(1:2);
            obj.move{2} = obj.moveHistory{obj.moveIndex}(3:4);
            
            obj.board(obj.move{2}{:}) = obj.board(obj.move{1}{:});
            obj.board(obj.move{2}{:}).Update(obj.move{2});
            obj.board(obj.move{1}{:}) = Token('position',...
                obj.move{1});
            obj.colors(obj.move{2}{:}) = obj.colors(obj.move{1}{:});
            obj.colors(obj.move{1}{:}) = 0;
            
            if obj.moveIndex == length(obj.moveHistory)
                obj.player = mod(obj.moveIndex, 2) + 1;
            end
            
            obj.UpdateBoard();
        end
        
        function Current(obj, varargin)
            for i = obj.moveIndex:length(obj.moveHistory)
                obj.PieceUp();
            end
        end
    end
    
    methods (Access=private)
        function GenerateBoard(obj)
            obj.uiHandle = uifigure('Menu', 'none', 'Toolbar', 'none',...
                'Position', [500 50 obj.UI_SIZE]);
            obj.uiBackground = uiimage(obj.uiHandle, 'Position',...
                [0, 0, obj.UI_SIZE], 'ImageSource',...
                obj.env.ToPath('art', 'chess_board.png', '-s'));
            
            obj.uiPieces = uiimage(obj.uiHandle);
            for i = 2:8
                obj.uiPieces(1, i) = obj.uiPieces(1, 1);
            end
            delete(obj.uiPieces(1, 8));
            for i = 1:3
                obj.uiPieces = [obj.uiPieces; obj.uiPieces];
            end
            
            for i = 1:8
                for j = 1:8
                    
                    obj.uiPieces(i,j) = uiimage(obj.uiHandle,...
                        'Position', [(fliplr([i, j]) - 1) .* (obj.UI_SIZE...
                        ./ 8), obj.UI_SIZE ./ 8], 'ImageClickedFcn',...
                        @(varargin) obj.PrepMove(...
                        obj.board(i,j).position, varargin{:}));
                    
                    if ~obj.colors(i, j)
                        obj.uiPieces(i,j).ImageSource =...
                            obj.env.ToPath('art', 'empty.png', '-s');
                    else
                        obj.uiPieces(i,j).ImageSource =...
                            obj.env.ToPath('art', sprintf('%s_%s.png',...
                            obj.COLOR_ENCODING{obj.colors(i, j)},...
                            obj.board(i, j).type), '-s');
                    end
                end
            end
        end
        
        function UpdateBoard(obj)
            delete(obj.uiPieces(obj.move{2}{:}));
            obj.uiPieces(obj.move{2}{:}) = obj.uiPieces(obj.move{1}{:});
            
            obj.uiPieces(obj.move{1}{:}) = uiimage(obj.uiHandle,...
                'ImageSource', obj.env.ToPath('art', 'empty.png',...
                '-s'), 'Position', [0, 0, obj.UI_SIZE / 8],...
                'ImageClickedFcn', @(varargin) obj.PrepMove(...
                obj.board(obj.move{2}{:}).position, varargin{:}));
            
            
            for i = 1:8
                for j = 1:8
                    obj.uiPieces(i, j).Position(1:2) =...
                        fliplr(cell2mat(obj.board(i, j).position) - 1)...
                        .* (obj.UI_SIZE ./ 8);
                    obj.uiPieces(i, j).ImageClickedFcn =...
                        @(varargin) obj.PrepMove(...
                        obj.board(i, j).position, varargin{:});
                end
            end
        end
    end
    
    methods (Static)
        
    end
end