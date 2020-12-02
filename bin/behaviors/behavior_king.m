genMessage = 'Invalid king movement.';

tempArr = [abs(chosenMove{2} - chosenPiece{2}),...
    abs(chosenMove{1} - chosenPiece{1})];

assert(all(tempArr <= 1), genMessage);