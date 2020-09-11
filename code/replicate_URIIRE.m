function []=replicate_URIIRE(startSample, endSample)
    
    common_parameters;
    if nargin<2
        startSample=1;
        endSample=EXPERIMENT.split.sample;
    end
    
    
    
    %TABLE 1: Mean, Shortest, and Longest Lengths of 95% Confidence
    %Intervals on the System Effect for TREC-3 Runs (using 3 splits)
    tags = {'md2' 'md3'};
    sharingsIds = {'TIP12_RNDE_02', 'TIP12_RNDE_03', 'TIP12_RNDE_05'};
    
    intervals_without_correction = zeros(2, 6, endSample-startSample+1, length(sharingsIds));
    intervals = zeros(2, 6, endSample-startSample+1, length(sharingsIds));
    n_ssd_couples = zeros(2, endSample-startSample+1, 2, length(sharingsIds));
    for shrd=1:length(sharingsIds)
        for smpl=startSample:endSample %compute for each sample

            for m=1:2 %compute the row for each mesure

                for t=1:length(tags) %compute column for each model

                    tag = tags{t};
                    mid = EXPERIMENT.measure.list{m};
                    params = {tag, ... %model considered
                              'zero', ... %balanced
                              3, ... %sstype 
                              'q4', ... %quartile: consider all systems 
                              mid, ... % measure id 
                              EXPERIMENT.pattern.identifier.split(sharingsIds{shrd}, smpl),...
                              'T03',... %track ID 
                              char(2500)}; %number of samples 



                    bootsrapEffectsID = EXPERIMENT.pattern.identifier.bootsrapEffects.analysis(params{:});

                    serload2(EXPERIMENT.pattern.file.analysis.shard('T03', sharingsIds{shrd}, bootsrapEffectsID), ...
                                  'WorkspaceVarNames', {'bootstrapTable'}, ...
                                  'FileVarNames', {bootsrapEffectsID});

                    sMean = mean(bootstrapTable{:,:}, 1);
                    [~, sIdx] = sort(sMean);
                    sortedSystems = bootstrapTable.Properties.VariableNames(sIdx);

                    % COMPUTE P-VALUES
                    [~, ssdcouples, cutoff, ~] = BHcorrection_bidirectional(...
                        sortedSystems,...
                        bootstrapTable, EXPERIMENT.analysis.alpha.threshold); 

                    n_ssd_couples(m, smpl, t, shrd) = ssdcouples;
                    
                    % COMPUTE INTERVALS

                    % ---- intervals with correction ---- %


                    % ---- intervals without correction ---- %
                    interval_size =1;%.999;%0.95;
                    excluded_size = (1-interval_size)/2;
                    selected_effects = zeros(cast(interval_size*height(bootstrapTable),'int32'),...
                                             length(bootstrapTable.Properties.VariableNames));
                    selected_effects_cutoff = zeros(height(bootstrapTable)-cutoff*2,...
                                             length(bootstrapTable.Properties.VariableNames));
                    for c=1:length(bootstrapTable.Properties.VariableNames)
                        sbt = sort(bootstrapTable{:, c});
                        startIdx = cast(length(sbt)*excluded_size+1,'int32');
                        endIdx   = cast(length(sbt)*(1-excluded_size),'int32');
                        selected_effects(:,c) = sbt(startIdx:endIdx);
                        selected_effects_cutoff(:,c) = sbt(cutoff+1:(height(bootstrapTable)-cutoff));
                    end

                    intervals_without_correction(m, (1+3*(t-1)):(3+3*(t-1)),smpl, shrd) = [
                        mean(max(selected_effects, [], 1)-min(selected_effects, [], 1)), ...
                        min(max(selected_effects, [], 1)-min(selected_effects, [], 1)), ...
                        max(max(selected_effects, [], 1)-min(selected_effects, [], 1))];

                    intervals(m, (1+3*(t-1)):(3+3*(t-1)),smpl, shrd) = [
                        mean(max(selected_effects_cutoff, [], 1)-min(selected_effects_cutoff, [], 1)), ...
                        min(max(selected_effects_cutoff, [], 1)-min(selected_effects_cutoff, [], 1)), ...
                        max(max(selected_effects_cutoff, [], 1)-min(selected_effects_cutoff, [], 1))];
                end
            end
        end
    end
    


    
    
    for shrd=1:length(sharingsIds)
        
        fprintf("\\begin{table}[]\n")
        fprintf("\\begin{tabular}{llllllllll}\\hline\n")
        fprintf("& & \\multicolumn{4}{l}{\\textbf{no interactions}} & \\multicolumn{4}{l}{\\textbf{interactions}} \\\\\\hline\n")
        fprintf("\\textbf{sample} & \\textbf{measure} & \\textbf{mean} & \\textbf{min} & \\textbf{max} & \\textbf{ssd} & \\textbf{mean} & \\textbf{min} & \\textbf{max} & \\textbf{ssd}  \\\\\\hline\n")
        for smpl=startSample:endSample %compute for each sample
            fprintf("\\multirow{2}{*}{%d} &",smpl);
            for m=1:2 %compute the row for each mesure
                if m==1
                    fprintf("AP   &");
                else
                    fprintf("                  & P@10 &");
                end
                for t=1:length(tags) %compute column for each model
                    if t==2
                        fprintf("&");
                    end
                    fprintf(" %.3f\t& %.3f & %.3f\t& %d\t", intervals_without_correction(m, (1+3*(t-1)):(3+3*(t-1)),smpl, shrd),  n_ssd_couples(m, smpl, t, shrd));
                    
                end
                
                fprintf("\\\\\n");
            end
        end
        fprintf("\\hline\n");
        fprintf("\\multirow{2}{*}{avg}&");
        for m=1:2 %compute the row for each mesure
            if m==1
                fprintf("AP   &");
            else
                fprintf("                  & P@10 &");
            end
            for t=1:length(tags) %compute column for each model
                if t==2
                    fprintf("&");
                end
                fprintf(" %.3f\t& %.3f & %.3f\t& %.2f\t", mean(intervals_without_correction(m, (1+3*(t-1)):(3+3*(t-1)),:, shrd), [3]),...
                                                        mean(n_ssd_couples(m, :, t, shrd), 2));

            end

            fprintf("\\\\\n");
        end
        fprintf("\\hline\n");
        fprintf("\\end{tabular}\n");
        fprintf("\\end{table}\n");
    end
    
    
    shardings_text = {'2 shards', '3 shards', '5 shards'};

    fprintf("\\begin{table}[]\n")
    fprintf("\\begin{tabular}{llllllll}\\hline\n")   
    fprintf("& & \\multicolumn{3}{l}{\\textbf{no interactions}} & \\multicolumn{3}{l}{\\textbf{interactions}} \\\\\\hline\n")
    fprintf("\\textbf{sample} & \\textbf{measure} & \\textbf{mean} & \\textbf{min} & \\textbf{max} & \\textbf{mean} & \\textbf{min} & \\textbf{max} \\\\\n")
    fprintf("\\hline\n")
    for shrd=1:length(sharingsIds)
        fprintf("\\multirow{2}{*}{%s}&", shardings_text{shrd});
        for m=1:2 %compute the row for each mesure
            if m==1
                fprintf("AP   &");
            else
                fprintf("                  & P@10 &");
            end
            for t=1:length(tags) %compute column for each model
                if t==2
                    fprintf("&");
                end
                fprintf(" %.3f\t& %.3f & %.3f\t", mean(intervals(m, (1+3*(t-1)):(3+3*(t-1)),:, shrd), [3]));

            end

            fprintf("\\\\\n");
        end
        fprintf("\\hline\n");
    end

    fprintf("\\end{tabular}\n");
    fprintf("\\end{table}\n");
    
end