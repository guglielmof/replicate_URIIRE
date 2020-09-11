function [p_val_matrix, ssdcouples, cutoff, lim] = BHcorrection(sortedSystems, bootstrapTable, alpha)
    pvals = [];
    nSys = length(sortedSystems);
    p_val_matrix = array2table(zeros(nSys), 'VariableNames', sortedSystems(:), 'RowNames', sortedSystems(:));
    N = (nSys*(nSys-1))/2;
    %for each pair of variables
    k = 1;
    for i=1:nSys-1
        meanS1 = mean(bootstrapTable{:, sortedSystems{i}});
        stdS1 = std(bootstrapTable{:, sortedSystems{i}});
        meansS2 = mean(bootstrapTable{:, sortedSystems(i+1:nSys)});
        computed_pvals = 1-normcdf(meansS2, meanS1, stdS1);
        pvals = [pvals, computed_pvals];
        p_val_matrix{sortedSystems{i}, sortedSystems(i+1:nSys)} = computed_pvals;
        p_val_matrix{sortedSystems(i+1:nSys), sortedSystems{i}} = computed_pvals.';
    end
    pvals_sorted = sort(pvals);
    k = [1:N]/N*alpha;
    lim = find(pvals_sorted>k);
    lim = lim(1) - 1;
    
    cutoff = alpha*lim/(2*N);
    ssdcouples = lim;
end
