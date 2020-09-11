function [p_val_matrix, ssdcouples, cutoff, lim] = BHcorrection_bidirectional(sortedSystems, bootstrapTable, alpha)
    pvals = [];
    nSys = length(sortedSystems);
    p_val_matrix = array2table(zeros(nSys), 'VariableNames', sortedSystems(:), 'RowNames', sortedSystems(:));
    N = (nSys*(nSys-1))/2;
    %for each pair of variables
    k = 1;
    meansS = mean(bootstrapTable{:, sortedSystems});
    stdsS = std(bootstrapTable{:, sortedSystems});
    [M, ~] = size(bootstrapTable{:, :});
    for i=1:nSys-1
        for j=i+1:nSys
            if meansS(i)<meansS(j)
                left_most  = i;
                right_most = j;
            else
                left_most  = j;
                right_most = i;
            end
            left_side  = normcdf(meansS(left_most), meansS(right_most), stdsS(right_most));
            right_side = 1-normcdf(meansS(right_most), meansS(left_most), stdsS(left_most));
            computed_pvals = left_side + right_side;
            pvals = [pvals, computed_pvals];
            p_val_matrix{sortedSystems{i}, sortedSystems{j}} = computed_pvals;
            p_val_matrix{sortedSystems{j}, sortedSystems{i}} = computed_pvals.';
        end
    end
    pvals_sorted = sort(pvals);
    k = [1:N]/N*alpha;
    lim = find(pvals_sorted>k);
    lim = lim(1) - 1;
    cutoff = cast(M*(alpha/2)*lim/(2*N), 'int32');
    ssdcouples = lim;
end
