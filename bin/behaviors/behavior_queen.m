genMessage = 'Invalid queen movement.';

try
    assert(abs((chosenMove{1} - chosenPiece{1}) / (chosenMove{2} -...
        chosenPiece{2})) == 1, genMessage);

    rSign = sign(chosenMove{1} - chosenPiece{1});
    cSign = sign(chosenMove{2} - chosenPiece{2});

    rArray = chosenPiece{1} + rSign : rSign : chosenMove{1} - rSign;
    cArray = chosenPiece{2} + cSign : cSign : chosenMove{2} - cSign;

    for i = 1:length(rArray)
        assert(~obj.parent.colors(rArray(i), cArray(i)), genMessage);
    end
catch
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
end