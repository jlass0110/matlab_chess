genMessage = 'Invalid rook movement.';

assert(chosenMove{1} == chosenPiece{1} || chosenMove{2} ==...
    chosenPiece{2}, genMessage);

direction = (chosenMove{1} == chosenPiece{1}) + 1;
heldIndex = chosenMove{mod(direction, 2) + 1};

stepSign = sign(chosenMove{direction} - chosenPiece{direction});

for i = chosenPiece{direction} + stepSign : stepSign :...
        chosenMove{direction} - stepSign
    currentIndex = ones(1,2) * heldIndex;
    currentIndex(direction) = i;
    assert(~obj.parent.colors(currentIndex(1), currentIndex(2)),...
        genMessage);
end