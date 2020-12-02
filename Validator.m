classdef Validator < handle
    properties (Constant)
        
    end
    
    properties (Access=private)
        env = EnvironmentManager('bin>system>env.txt')
        parent
    end
    
    properties
        
    end
    
    methods
        function obj = Validator(property, value)
            arguments (Repeating)
                property {mustBeSingleString}
                value
            end
            for i = 1:length(property)
                obj.(property{i}) = value{i};
            end
            
            assert(~isempty(obj.parent),...
                ['Error: parent property must be set in Validator ',...
                'instances.']);
        end
        
        function boolOut = ValidateMove(obj, varargin)
            arguments
                obj
            end
            arguments (Repeating)
                varargin
            end
            
            if nargin == 2
                chosenPiece = varargin{1};
            else
                chosenPiece = obj.parent.move{1};
            end
            chosenMove = obj.parent.move{2};
            heldPiece = chosenPiece;
            heldMove = chosenMove;
            storedTokens = {obj.parent.board(chosenPiece{:}),...
                obj.parent.board(chosenMove{:})};
            storedColors = {obj.parent.colors(chosenPiece{:}),...
                obj.parent.colors(chosenMove{:})};
            
            boolOut = true;
            try
                assert(obj.parent.colors(chosenPiece{:}) ==...
                    obj.parent.player, 'Wrong Color');
                assert(obj.parent.colors(chosenMove{:}) ~=...
                    obj.parent.player, 'That is your piece');
                if obj.parent.freeMode
                    return;
                end
                
                eval(fileread(obj.env.ToPath('scripts',...
                    sprintf('behavior_%s.m', obj.parent.board(...
                    chosenPiece{:}).type), '-s')));
                
                obj.parent.colors(chosenMove{:}) =...
                    obj.parent.colors(chosenPiece{:});
                obj.parent.colors(chosenPiece{:}) = 0;
                obj.parent.board(chosenMove{:}) =...
                    obj.parent.board(chosenPiece{:});
                obj.parent.board(chosenPiece{:}) = Token();
                
                escapeBool = false;
                for counterI = 1:8
                    for counterJ = 1:8
                        if obj.parent.board(counterI, counterJ).type ==...
                                Piece.king && obj.parent.colors(...
                                counterI, counterJ) == obj.parent.player
                            chosenMove = {counterI counterJ};
                            escapeBool = true;
                            break;
                        end
                    end
                    if escapeBool
                        break;
                    end
                end
                
                escapeBool = false;
                for counterI = 1:8
                    for counterJ = 1:8
                        if obj.parent.colors(counterI, counterJ) && obj.parent.colors(...
                                counterI, counterJ) ~= obj.parent.player
                            chosenPiece = {counterI counterJ};
                            try
                                eval(fileread(obj.env.ToPath('scripts',...
                                    sprintf('behavior_%s.m',...
                                    obj.parent.board(...
                                    chosenPiece{:}).type), '-s')));
                                fprintf('r:%d c:%d\n', counterI, counterJ);
                                escapeBool = true;
                                break;
                            catch
                                
                            end
                        end
                    end
                    if escapeBool
                        break;
                    end
                end
                
                obj.parent.board(heldPiece{:}) = storedTokens{1};
                obj.parent.board(heldMove{:}) = storedTokens{2};
                obj.parent.colors(heldPiece{:}) = storedColors{1};
                obj.parent.colors(heldMove{:}) = storedColors{2};
                
                assert(~escapeBool, 'King under threat.');
            catch ME
                boolOut = false;
                %fprintf('Invalid move. %s\n', ME.message);
            end
        end
    end
    
    methods (Access=private)
        
    end
    
    methods (Static)
        
    end
end