function r2 = R2(x,y)
% returns the R^2 of the vectors
% x is actual, y is the predictions
% x can be a vector and y can be a matrix (rows are variables, columns are
% samples).
% if x and y are both matrix, R2 returns the R^2 for each column separately

    r2 = 1 - sum((x - y).^2) ./ sum((x - mean(x)).^2);
end