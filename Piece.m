classdef Piece
    enumeration
        nothing % 0
        pawn    % 1
        knight  % 2
        bishop  % 3
        rook    % 4
        queen   % 5
        king    % 6
    end
    
    methods
        function value = index(enum)
            value = find(enum == enumeration(class(enum))) - 1;
        end
    end
end