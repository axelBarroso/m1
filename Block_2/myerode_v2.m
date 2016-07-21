function B = myerode_v2(A, SE)

B = ordfilt2(A, 1, SE, 'symmetric');