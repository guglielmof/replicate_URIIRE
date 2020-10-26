function [] = analysis_across_balancings(trackID, splitID, sstype, ...
                                  quartile, direction, startMeasure, endMeasure, ...
                                  startSample, endSample)

    common_parameters;
    
    models = {'md2', 'md3', 'md6'};
    %models = {'md3'};

    balancings = {'zero', 'lq', 'mean', 'one'};
    alpha = EXPERIMENT.analysis.alpha.threshold;
    
    nSamples = endSample-startSample+1;
    
    
    params = {models{1}, ... %model considered
          balancings{1}, ... %balanced
          sstype, ... %sstype 
          quartile, ... %quartile: consider all systems 
          EXPERIMENT.measure.list{startMeasure}, ... % measure id 
          EXPERIMENT.pattern.identifier.split(splitID, startSample),...
          trackID,... %track ID 
          char(10000)}; %number of samples 

    bootsrapEffectsID = EXPERIMENT.pattern.identifier.bootsrapEffects.analysis(params{:});

    serload2(EXPERIMENT.pattern.file.analysis.shard(trackID, splitID, bootsrapEffectsID), ...
                  'WorkspaceVarNames', {'bootstrapTable'}, ...
                  'FileVarNames', {bootsrapEffectsID});
              
    s_order_ref = bootstrapTable.Properties.VariableNames;


    for m=startMeasure:endMeasure

        mid = EXPERIMENT.measure.list{m};

        for md=1:length(models)
            TAG = models{md};

            fprintf("model %s\n", TAG)
            pdANOVA  = cell(nSamples, 1);
            pdbANOVA = cell(nSamples, 1);

            full_h1_ANOVA = cell(nSamples, 1);
            full_h1_bANOVA = cell(nSamples, 1);

            for smpl=startSample:endSample
                
                                
                fprintf("    * processing sample %d\n", smpl);
                
                
                pdANOVA{smpl-startSample+1}  =  zeros(length(balancings));
                pdbANOVA{smpl-startSample+1} =  zeros(length(balancings));
                


                fprintf('    - sample %d\n', smpl);
                h1_ANOVA  = cell(length(balancings), 1);
                h1_bANOVA = cell(length(balancings), 1);
                
                
                for b=1:length(balancings)
                    bLabel = balancings{b};

                    params = {TAG, bLabel, ...
                              sstype, quartile, mid,...
                              EXPERIMENT.pattern.identifier.split(splitID, smpl), ...
                              trackID};


                    %upload data

                    %standard ANOVA
                    anovaID = EXPERIMENT.pattern.identifier.anova.analysis(params{:});

                    anovaStsID = EXPERIMENT.pattern.identifier.anova.sts(params{:});


                    serload2(EXPERIMENT.pattern.file.analysis.shard(trackID, splitID, anovaID), ...
                      'WorkspaceVarNames', {'sts'}, ...
                      'FileVarNames', {anovaStsID});


                    n_systems = sts.nlevels(2);
                    N  = n_systems*(n_systems-1)/2;

                    [mc,~,~,gnames]  = multcompare(sts,'Alpha', alpha, 'dimension', [2], 'Display', 'off');
                    if b == 1
                        sgnames = cell(length(gnames), 1);
                        for i=1:length(gnames)
                            sgnames{i} = char(gnames{i,:}(8:end));
                        end
                        nSystems = length(sgnames);
                        mask = triu(true(nSystems), 1);
                    end

                    p_val_table = array2table(ones(length(gnames)), 'VariableNames', sgnames, 'RowNames', sgnames);

                    for r=1:length(mc)
                        p_val_table{sgnames{mc(r, 1)}, sgnames{mc(r, 2)}} = mc(r, 6);
                        p_val_table{sgnames{mc(r, 2)}, sgnames{mc(r, 1)}} = mc(r, 6);
                    end

                    z = p_val_table{sgnames, sgnames};
                    h1_ANOVA{b} = z<alpha;




                    %bootstrap ANOVA
                    params = {TAG, ... %model considered
                          bLabel, ... %balanced
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

                    if strcmp(direction, 'bi')
                        [pValBootstrapANOVAFDR, ~, ~, k] = BHcorrection_bidirectional(...
                            sortedSystems,...
                            bootstrapTable, EXPERIMENT.analysis.alpha.threshold); 
                    else
                        [pValBootstrapANOVAFDR, ~, ~, k] = BHcorrection_directional(...
                            sortedSystems,...
                            bootstrapTable, EXPERIMENT.analysis.alpha.threshold); 
                    end
                    %compute SSD pairs (by adjusting with BH)
                    h1_bANOVA{b} = (pValBootstrapANOVAFDR{s_order_ref,s_order_ref}*N/k)<alpha;
                    fprintf("h1 ANOVA:%d ",sum(h1_ANOVA{b}(mask)));
                    
                    fprintf("h1 bANOVA:%d\n",sum(h1_bANOVA{b}(mask)));
                end

                %TIRU
                for b1=1:length(balancings)
                    for b2=b1+1:length(balancings)
                        %comparisonsANOVA = sum(dataANOVA{b1}(mask) ~= dataANOVA{b2}(mask));
                        %resultsANOVA{smpl-startSample+1}(b1, b2) = comparisonsANOVA;
                        %comparisonsBootstrapANOVA = sum(dataBootstrapANOVA{b1}(mask) ~= dataBootstrapANOVA{b2}(mask));
                        %resultsBootstrapANOVA{smpl-startSample+1}(b1, b2) = comparisonsBootstrapANOVA;
                        
                        pdANOVA{smpl-startSample+1}(b1, b2)  = sum(h1_ANOVA{b1}(mask) ~= h1_ANOVA{b2}(mask));
                        pdbANOVA{smpl-startSample+1}(b1, b2) = sum(h1_bANOVA{b1}(mask) ~= h1_bANOVA{b2}(mask));
                    end
                end
                    

                full_h1_ANOVA{smpl-startSample+1} = h1_ANOVA;
                full_h1_bANOVA{smpl-startSample+1} = h1_bANOVA;


            end


            pd_across_sample_ANOVA  = cell(length(balancings), 1);
            pd_across_sample_bANOVA = cell(length(balancings), 1);
            
            
            %COMPUTE PD ACROSS SHARDS (FOR EACH BALANCING)
            for blc=1:length(balancings)
                vANOVA = zeros(nSamples*(nSamples-1)/2, 1); %PD on shard pairs
                vbANOVA = zeros(nSamples*(nSamples-1)/2, 1);
                k=1;
                for s1=1:nSamples-1
                    for s2=(s1+1):nSamples
                        vANOVA(k)  = sum(full_h1_ANOVA{s1}{blc}(mask) ~= full_h1_ANOVA{s2}{blc}(mask));
                        vbANOVA(k) = sum(full_h1_bANOVA{s1}{blc}(mask) ~= full_h1_bANOVA{s2}{blc}(mask));
                        k=k+1;
                    end
                end
                pd_across_sample_ANOVA{blc}  = sprintf("%.2f$\\pm$ %.3f&", mean(vANOVA), confidenceIntervalDelta(vANOVA, alpha));
                pd_across_sample_bANOVA{blc} = sprintf("%.2f$\\pm$ %.3f&", mean(vbANOVA), confidenceIntervalDelta(vbANOVA, alpha));

            end
            
            pdANOVA = cat(3, pdANOVA{:});
            pd_across_blc_ANOVA = mean(pdANOVA, 3);
            CIANOVA = confidenceIntervalDelta(pdANOVA, alpha, 3);
            
            
            %%%-----------PRINT RESULT TABLES---------------%%%
            fprintf("\n\nHSD TRADITIONAL ANOVA\n");

            fprintf("\\begin{table}[h]\n");
            fprintf("\\begin{tabular}{lcccc}\n");
            fprintf("\\toprule\n");
            for b1=1:length(balancings)
                fprintf("%s &", balancings{b1});
                for b2=1:length(balancings)
                    if b2<b1
                        fprintf("      ---       ");
                    elseif b2==b1
                        fprintf(" %s ", pd_across_sample_ANOVA{b1});
                    else
                        fprintf(" %.2f$\\pm$ %.3f", pd_across_blc_ANOVA(b1, b2), CIANOVA(b1, b2));
                    end
                    if b2<length(balancings)
                        fprintf(" &");
                    else
                        fprintf("\\\\\n");
                    end
                end
            end

            fprintf("\\end{tabular}\n");
            fprintf("\\end{table}\n\n");


            
            fprintf("\n\nBOOTSTRAP ANOVA\n");
            pdbANOVA = cat(3, pdbANOVA{:});
            pd_across_blc_bANOVA = mean(pdbANOVA, 3);
            CIBootstrapANOVA = confidenceIntervalDelta(pdbANOVA, alpha, 3);


            fprintf("\\begin{table}[h]\n");
            fprintf("\\caption{%s - %s}\n", TAG, splitID);
            fprintf("\\begin{tabular}{lcccc}\n");
            fprintf("\\toprule\n");
            for b1=1:length(balancings)
                fprintf("\\texttt{%s} &", balancings{b1});
                for b2=1:length(balancings)
                    if b2<b1
                        fprintf("       ---      ");
                    elseif b2==b1
                        fprintf("%s", pd_across_sample_bANOVA{b1});
                    else
                        fprintf(" %.2f $\\pm$ %.3f", pd_across_blc_bANOVA(b1, b2), CIBootstrapANOVA(b1, b2));
                    end
                    
                    if b2<length(balancings)
                        fprintf(" &");
                    else
                        fprintf("\\\\\n");
                    end
                end
                
            end
            fprintf("\\bottomrule\n");
            fprintf("\\end{tabular}\n");
            fprintf("\\end{table}\n\n");


        end
    end


end
