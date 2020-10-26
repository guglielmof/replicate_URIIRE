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
            
            pd  = fitdist(bootstrapTable{:, sortedSystems{right_most}},'kernel','Kernel','normal');
            left_side = cdf(pd, meansS(left_most));
            
            pd  = fitdist(bootstrapTable{:, sortedSystems{left_most}},'kernel','Kernel','normal');
            right_side = 1-cdf(pd, meansS(right_most));
            
            computed_pvals = left_side + right_side;
            pvals = [pvals, computed_pvals];
            p_val_matrix{sortedSystems{i}, sortedSystems{j}} = computed_pvals;
            p_val_matrix{sortedSystems{j}, sortedSystems{i}} = computed_pvals.';
        end
    end
    pvals_sorted = sort(pvals);
    k = (1:N).*alpha/N;
    lim = find(pvals_sorted>k);
    lim = lim(1) - 1;
    cutoff = cast(M*(alpha)*lim/(2*N), 'int32');
    ssdcouples = lim;
end
