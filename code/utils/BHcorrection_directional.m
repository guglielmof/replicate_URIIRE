function [p_val_matrix, ssdcouples, cutoff, lim] = BHcorrection_directional(sortedSystems, bootstrapTable, alpha)
    pvals = [];
    nSys = length(sortedSystems);
    p_val_matrix = array2table(zeros(nSys), 'VariableNames', sortedSystems(:), 'RowNames', sortedSystems(:));
    N = (nSys*(nSys-1))/2;
    [M, ~] = size(bootstrapTable{:, :});
    %for each pair of variables
    k = 1;
    for i=1:nSys-1

        meansS2 = mean(bootstrapTable{:, sortedSystems(i+1:nSys)});
        pd  = fitdist(bootstrapTable{:, sortedSystems{i}},'kernel','Kernel','normal');
        computed_pvals = (1-cdf(pd, meansS2));
        pvals = [pvals, computed_pvals];
        p_val_matrix{sortedSystems{i}, sortedSystems(i+1:nSys)} = computed_pvals;
        p_val_matrix{sortedSystems(i+1:nSys), sortedSystems{i}} = computed_pvals.';
    end
    pvals_sorted = sort(pvals);
    k = (1:N).*alpha/N;
    lim = find(pvals_sorted>k);
    lim = lim(1) - 1;
    
    cutoff = cast(M*alpha*lim/(2*N), 'int32');
    
    
    
    %{ 
    %CHECK CDF FOR REMOVED ELEMENTS
    excluded_size = double(cutoff)/(M*100);
    startIdx = cast(M*excluded_size+1, 'int32');
    endIdx   = cast(M*(1-excluded_size)-1,'int32');
    
    left_side = zeros(nSys, 1);
    right_side = zeros(nSys, 1);

    for i=1:nSys
        %computed_pvals = 1-normcdf(meansS2, meanS1, stdS1);
        pd  = fitdist(bootstrapTable{:, sortedSystems{i}},'kernel','Kernel','normal');
        %computed_pvals = 2*(1-cdf(pd, meansS2));
        sortedSamples = sort(bootstrapTable{:, sortedSystems{i}});
        left_side(i) = cdf(pd, sortedSamples(startIdx));
        right_side(i) = cdf(pd, sortedSamples(endIdx));
    end
    disp(mean(left_side))
    disp(mean(right_side));
    %}
    
    
    ssdcouples = lim;
end
