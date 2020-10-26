function [] = analysis_across_shards(trackID, splitID, balanced, sstype, ...
                                  quartile,direction, startMeasure, endMeasure, ...
                                  startSample, endSample)


    mods = {'md2', 'md3', 'md6'};
    %mods = {'md2', 'md3'};
    
    common_parameters;
    printable = cell(3, 3);
    alpha = EXPERIMENT.analysis.alpha.threshold;
    for mod = 1:length(mods)
        TAG = mods{mod};

        for m=startMeasure:endMeasure

            measures = {};
            tANOVAFDR = {};
            tANOVAFWER = {};
            bANOVA = {};
            
            mid = EXPERIMENT.measure.list{m};

            for smpl=startSample:endSample

                %fprintf('    - sample %d\n', s);

                bLabel = balanced;
                params = {TAG, bLabel, ...
                          sstype, quartile, mid,...
                          EXPERIMENT.pattern.identifier.split(splitID, smpl), ...
                          trackID};



                %standard ANOVA
                anovaID = EXPERIMENT.pattern.identifier.anova.analysis(params{:});

                anovaStsID = EXPERIMENT.pattern.identifier.anova.sts(params{:});


                serload2(EXPERIMENT.pattern.file.analysis.shard(trackID, splitID, anovaID), ...
                  'WorkspaceVarNames', {'sts'}, ...
                  'FileVarNames', {anovaStsID});


                
                n_systems = sts.nlevels(2);
                N  = n_systems*(n_systems-1)/2;
                [oldmc,~,~,oldgnames] = EXPERIMENT.analysis.multcompare.system(sts);

                [newmc,m,~,gnames]  = mymultcompare(sts, 'CType','bonferroni','Alpha', alpha, 'dimension', [2], 'Display', 'off');

                uncorrected_pvalues = newmc(:,6);

                %%% correct the pvalues using BH %%%
                pvals_sorted = sort(uncorrected_pvalues).';
                k = ([1:N]/N*alpha);
                lim = find(pvals_sorted>k);
                if ~isempty(lim) 
                    lim = lim(1) - 1;
                else
                    lim = N;
                end

                pvalues = uncorrected_pvalues*N/lim;
                newmc(:, 6)= newmc(:, 6).*N/lim;
                %%% --------------------------- %%%

                sgnames = {};
                oldsgnames = {};
                for i=1:length(gnames)
                    sgnames{end+1} = char(gnames{i,:}(8:end));
                    oldsgnames{end+1} = char(oldgnames{i,:}(8:end));
                end

                pValANOVAFDR = array2table(ones(length(gnames)), 'VariableNames', sgnames, 'RowNames', sgnames);
                pValANOVAFWER = array2table(ones(length(oldsgnames)), 'VariableNames', oldsgnames, 'RowNames', oldsgnames);

                for r=1:length(oldmc)
                    pValANOVAFDR{sgnames{newmc(r, 1)}, sgnames{newmc(r, 2)}} = newmc(r, 6);
                    pValANOVAFDR{sgnames{newmc(r, 2)}, sgnames{newmc(r, 1)}} = newmc(r, 6);

                    pValANOVAFWER{sgnames{oldmc(r, 1)}, sgnames{oldmc(r, 2)}} = oldmc(r, 6);
                    pValANOVAFWER{sgnames{oldmc(r, 2)}, sgnames{oldmc(r, 1)}} = oldmc(r, 6);
                end



                %%% UPLOAD bootstrap ANOVA DATA %%%
                params = {TAG, ... %model considered
                          balanced, ... %balanced
                          sstype, ... %sstype 
                          quartile, ... %quartile: consider all systems 
                          mid, ... % measure id 
                          EXPERIMENT.pattern.identifier.split(splitID, smpl),...
                          trackID,... %track ID 
                          char(10000)}; %number of samples 
                          
                bootsrapEffectsID = EXPERIMENT.pattern.identifier.bootsrapEffects.analysis(params{:});

                serload2(EXPERIMENT.pattern.file.analysis.shard(trackID, splitID, bootsrapEffectsID), ...
                              'WorkspaceVarNames', {'bootstrapTable'}, ...
                              'FileVarNames', {bootsrapEffectsID});

                sMean = mean(bootstrapTable{:,:}, 1);
                [~, sIdx] = sort(sMean);

                sortedSystems = bootstrapTable.Properties.VariableNames(sIdx);


                [pValBootstrapANOVAFDR, ~, ~, k] = BHcorrection_bidirectional(...
                    sortedSystems,...
                    bootstrapTable, EXPERIMENT.analysis.alpha.threshold); 
                

                
                pValBootstrapANOVAFDR{:,:} = pValBootstrapANOVAFDR{:,:}*N/k;
                %%% ------------------------- %%%
                
                
                
                measures{end+1} = array2table(m(:,1), 'RowNames', sgnames);
                tANOVAFDR{end+1} = pValANOVAFDR;
                tANOVAFWER{end+1} = pValANOVAFWER;
                bANOVA{end+1} = pValBootstrapANOVAFDR;
                

            end
           
            
            %for each couple of shardings, check:
            %SSA: for both shardings, A>B (AA in the paper)
            %SSD: for a sharding A>B, but for the other B>A (AD in the
            %paper)
            %NS: for a sharding A>B, for the other A=B 
            %SN: for a sharding B=A, for the other A>B
            %PD in the paper: sum between NS and SN
            %NN: for both shardings A=B (PA in the paper)
            tests = {bANOVA, tANOVAFDR, tANOVAFWER};
            t_names = ["bANOVA", "tANOVAFDR", "tANOVAFWER"];
            n_comparisons = length(measures)*(length(measures)-1)/2;
            for t=1:length(tests)
                ave_pos_agr = [];
                ave_neg_agr = [];
                ave_ssa = 0;
                ave_ssd = 0;
                
                test = tests{t};
                ssa_ssd_table = cell(endSample-startSample);
                sn_ns_table = cell(endSample-startSample);
                for i=1:length(measures)
                    ssa_ssd_table(i,i) = {"-"};
                    sn_ns_table(i,i) = {"-"};
                    for j=i+1:length(measures)
                        [SSA, SSD, NS, SN, NN] = compute_agreements_stats(measures{i}, ...
                                                    measures{j}, test{i}, test{j}, alpha);
                        ssa_ssd_table(i,j) = {sprintf("%d", SSA)};
                        ssa_ssd_table(j,i) = {sprintf("%d", SSD)};
                        sn_ns_table(j,i) = {sprintf("%d", SN)};
                        sn_ns_table(i,j) = {sprintf("%d", NS)};
                        
                        %sn_ns_table(j,i) = {sprintf("%.3f", 2*NN/(2*NN+NS+SN))};
                        %sn_ns_table(i,j) = {sprintf("%.3f", 2*SSA/(2*SSA+NS+SN))};
                        ave_ssa = ave_ssa + SSA/n_comparisons;
                        ave_pos_agr = [ave_pos_agr, (2*SSA/(2*SSA+NS+SN))];
                        ave_neg_agr = [ave_neg_agr, (2*NN/(2*NN+NS+SN))];
                        
                    end
                end
                
                printable(t, 1) = {sprintf("%.2f", ave_ssa)};
                printable(t, 2) = {sprintf("%.3f $pm$ %.3f", mean(ave_pos_agr), tinv(1-alpha/2, length(ave_pos_agr)-1)*std(ave_pos_agr)/sqrt(length(ave_pos_agr)))};
                printable(t, 3) = {sprintf("%.3f $pm$ %.3f", mean(ave_neg_agr), tinv(1-alpha/2, length(ave_neg_agr)-1)*std(ave_neg_agr)/sqrt(length(ave_neg_agr)))};
 
               
                %colNames = ["shardings", "s1", "s2", "s3", "s4", "s5"];
                %rowNames = colNames(2:end);

                %print_latex_table(ssa_ssd_table, rowNames, colNames);
               % print_latex_table(sn_ns_table, rowNames, colNames);
            end
            colNames = ["approach", "mean AA", "Average PAA", "Average PPA"];
            rowNames = t_names;
           
            print_latex_table(printable, rowNames, colNames);
        end
    end


end


function [SSA, SSD, NS, SN, NN] = compute_agreements_stats(s_mean1, s_mean2, t1, t2, alpha)

    SSA = 0;
    SSD = 0;
    NS = 0;
    SN = 0;
    NN = 0;
    s_names = s_mean1.Properties.RowNames;

    
    for is1 = 1:length(s_names)
        s1 = s_names{is1};
        for is2= is1+1:length(s_names)
            s2 = s_names{is2};
            if t1{s1, s2}<alpha
                if t2{s1,s2}<alpha
                    if (s_mean1{s1,1}>s_mean1{s2,1} && s_mean2{s1,1}>s_mean2{s2,1}) || ...
                       (s_mean1{s1,1}<s_mean1{s2,1} && s_mean2{s1,1}<s_mean2{s2,1}) 
                        SSA = SSA + 1;
                    else
                        SSD = SSD + 1;
                    end
                else
                    SN = SN+1;
                end
            elseif t2{s1,s2}<alpha
                NS = NS+1;
            else
                NN = NN+1;
             
            end
        end
    end

end

function print_latex_table(tab, RowNames, ColNames)
    format = join(repmat("c", 1, length(ColNames)), "|");
    header = join(ColNames, " & ");
    fprintf("\\begin{table}[h]\n");
    fprintf("\\caption{}\n");
    fprintf("\\resizebox{0.95\\columnwidth}{!}{\\begin{tabular}{|%s|}\n",format);
    fprintf("\\hline\n");
    fprintf("%s \\\\\n", header);
    fprintf("\\hline\n");
    for r=1:length(RowNames)
        
        row = sprintf("%s & %s", RowNames(r), join(string(tab(r, :)), " & "));
       	fprintf("%s \\\\\n", row);
    end

    fprintf("\\hline\\end{tabular}}\n");
    fprintf("\\end{table}\n");
end
