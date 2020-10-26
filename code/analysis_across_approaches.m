function avg_cons = analysis_across_approaches(trackID, splitID, balanced, sstype, ...
                                  quartile,direction, startMeasure, endMeasure, ...
                                  startSample, endSample)


    mods = {'md2', 'md3', 'md6'};
    %mods = {'md2', 'md3'};
    common_parameters;
    
    for mod = 1:length(mods)
        TAG = mods{mod};

        for m=startMeasure:endMeasure

            mid = EXPERIMENT.measure.list{m};


            globalDecisions = zeros(3, endSample-startSample+1);
            comparisons = zeros(3, endSample-startSample+1);
            for smpl=startSample:endSample
                fprintf("    - processing %d sample \n", smpl);
                %fprintf('    - sample %d\n', s);

                bLabel = balanced;
                params = {TAG, bLabel, ...
                          sstype, quartile, mid,...
                          EXPERIMENT.pattern.identifier.split(splitID, smpl), ...
                          trackID};
                %upload data
                %fprintf('      * load data\n');


                %standard ANOVA
                fprintf("        * loading traditional ANOVA data \n");
                anovaID = EXPERIMENT.pattern.identifier.anova.analysis(params{:});

                anovaStsID = EXPERIMENT.pattern.identifier.anova.sts(params{:});


                serload2(EXPERIMENT.pattern.file.analysis.shard(trackID, splitID, anovaID), ...
                  'WorkspaceVarNames', {'sts'}, ...
                  'FileVarNames', {anovaStsID});


                alpha = EXPERIMENT.analysis.alpha.threshold;
                n_systems = sts.nlevels(2);
                N  = n_systems*(n_systems-1)/2;
                [oldmc,m,h,oldgnames] = EXPERIMENT.analysis.multcompare.system(sts);

                [newmc,m,h,gnames]  = mymultcompare(sts, 'CType','bonferroni','Alpha', alpha, 'dimension', [2], 'Display', 'off');

                uncorrected_pvalues = newmc(:,6);

                pvals_sorted = sort(uncorrected_pvalues).';
                k = ([1:N]/N*alpha);
                lim = find(pvals_sorted>k);
                lim = lim(1) - 1;

                pvalues = uncorrected_pvalues*N/lim;
                newmc(:, 6)= newmc(:, 6).*N/lim;


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



                %bootstrap ANOVA
                
                params = {TAG, ... %model considered
                          balanced, ... %balanced
                          sstype, ... %sstype 
                          quartile, ... %quartile: consider all systems 
                          mid, ... % measure id 
                          EXPERIMENT.pattern.identifier.split(splitID, smpl),...
                          trackID,... %track ID 
                          char(10000)}; %number of samples 
                
                fprintf("        * loading bootstrap ANOVA data and computing SSD pairs\n");
          
                bootsrapEffectsID = EXPERIMENT.pattern.identifier.bootsrapEffects.analysis(params{:});

                serload2(EXPERIMENT.pattern.file.analysis.shard(trackID, splitID, bootsrapEffectsID), ...
                              'WorkspaceVarNames', {'bootstrapTable'}, ...
                              'FileVarNames', {bootsrapEffectsID});

                sMean = mean(bootstrapTable{:,:}, 1);
                [sMean, sIdx] = sort(sMean);

                sortedSystems = bootstrapTable.Properties.VariableNames(sIdx);

                if strcmp(direction, 'bi')
                    [pValBootstrapANOVAFDR, ~, ~, ~] = BHcorrection_bidirectional(...
                        sortedSystems,...
                        bootstrapTable, EXPERIMENT.analysis.alpha.threshold); 
                else
                    [pValBootstrapANOVAFDR, ~, ~, ~] = BHcorrection_directional(...
                        sortedSystems,...
                        bootstrapTable, EXPERIMENT.analysis.alpha.threshold); 
                end

                mask = triu(true(size(pValBootstrapANOVAFDR{:,:})), 1);
                pvBAFDR = pValBootstrapANOVAFDR{sgnames,sgnames}(mask);
                pvAFDR = pValANOVAFDR{sgnames,sgnames}(mask);
                pvAFWER = pValANOVAFWER{sgnames,sgnames}(mask);
                
                find(pvAFDR<=alpha & pvBAFDR>alpha);
                find(pvAFWER<=alpha & pvAFDR>alpha);
                

                decisionsBAFDR = pvBAFDR<alpha;
                decisionsAFDR  = pvAFDR<alpha;
                decisionsAFWER = pvAFWER<alpha;

                globalDecisions(:, smpl-startSample+1) = [sum(decisionsBAFDR), sum(decisionsAFDR), sum(decisionsAFWER)].';

                comparisons(1, 2, smpl-startSample+1) = sum(decisionsBAFDR~=decisionsAFDR);
                comparisons(1, 3, smpl-startSample+1) = sum(decisionsBAFDR~=decisionsAFWER);
                comparisons(2, 3, smpl-startSample+1) = sum(decisionsAFDR~=decisionsAFWER);

            end
            fprintf("    - computing aggregated results for measure %s model %s\n", mid, TAG);
            %disp(globalDecisions);
            mcomparisons = mean(comparisons, 3);
            cicomparisons = confidenceIntervalDelta(comparisons, alpha, 3);
            mdecisions = mean(globalDecisions, 2);
            cidecisions = confidenceIntervalDelta(globalDecisions, alpha, 2);

            approaches = ["B-ANOVA", "ANOVA FDR", "ANOVA HSD"];

            fprintf("\\begin{table}[h]\n");
            fprintf("\\caption{%s - %s}\n", TAG, splitID);
            fprintf("\\resizebox{0.95\\columnwidth}{!}{\\begin{tabular}{|c|c|c|c|}\n");
            fprintf("\\hline\n");
            fprintf("approach & B-ANOVA & ANOVA FDR & ANOVA HSD \\\\\n");
            fprintf("\\hline\n");
            for i=1:3
                fprintf("%16s &", approaches(i));
                for j = 1:3
                    if j<i
                        fprintf("%16s", "-");
                    elseif j==i
                        fprintf("%.2f $\\pm$ %.3f", mdecisions(i), cidecisions(i))
                    else    
                        fprintf("%.2f $\\pm$ %.3f",mcomparisons(i, j), cicomparisons(i,j))
                    end

                    if j == 3
                        fprintf(" \\\\\n");
                    else
                        fprintf(" & ");
                    end
                end
            end

            fprintf("\\hline\\end{tabular}}\n");
            fprintf("\\end{table}\n");
        end
    end


end
