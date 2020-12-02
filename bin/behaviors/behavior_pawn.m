genMessage = 'Invalid pawn movement.';
if obj.parent.colors(chosenMove{:}) == 0
    assert(chosenPiece{2} == chosenMove{2}, genMessage);
    if ~obj.parent.board(chosenPiece{:}).moveCount
        assert(abs(chosenPiece{1} - chosenMove{1}) <= 2, genMessage);
    else
        assert(abs(chosenPiece{1} - chosenMove{1}) == 1, genMessage);
    end
else
    assert(all([abs(chosenPiece{2} - chosenMove{2}),...
        abs(chosenPiece{1} - chosenMove{1})] == 1), genMessage);
end

if xor(logical(obj.parent.player - 1), obj.parent.flipBoard)
    % white
    assert(chosenMove{1} < chosenPiece{1}, genMessage);
else
    % black
    assert(chosenMove{1} > chosenPiece{1}, genMessage);
end