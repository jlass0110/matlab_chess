genMessage = 'Invalid knight movement.';

tempArr = [abs(chosenMove{2} - chosenPiece{2}), abs(...
    chosenMove{1} - chosenPiece{1})];

assert(any(tempArr == 2) && any(tempArr == 1), genMessage);