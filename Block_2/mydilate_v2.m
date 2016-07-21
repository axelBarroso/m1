function B = mydilate_v2(A, SE)

SE = rot90(SE, 2);

num_neighbors = sum(SE(:));

B = ordfilt2(A, num_neighbors, SE, 'symmetric');
