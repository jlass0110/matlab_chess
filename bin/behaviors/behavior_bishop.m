genMessage = 'Invalid bishop movement.';

assert(abs((chosenMove{1} - chosenPiece{1}) / (chosenMove{2} -...
    chosenPiece{2})) == 1, genMessage);

rSign = sign(chosenMove{1} - chosenPiece{1});
cSign = sign(chosenMove{2} - chosenPiece{2});

rArray = chosenPiece{1} + rSign : rSign : chosenMove{1} - rSign;
cArray = chosenPiece{2} + cSign : cSign : chosenMove{2} - cSign;

for i = 1:length(rArray)
    assert(~obj.parent.colors(rArray(i), cArray(i)), genMessage);
end