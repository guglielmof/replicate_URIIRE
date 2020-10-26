function []=replicate_URIIRE(trackID, splitID, startSample, endSample, replicate, direction)
    
    common_parameters;
    if nargin<2
        startSample=1;
        endSample=EXPERIMENT.split.sample;
        replicate = false;
        direction = 'uni';
    end
    
    
    
    %TABLE 1: Mean, Shortest, and Longest Lengths of 95% Confidence
    %Intervals on the System Effect for TREC-3 Runs (using 2, 3 and 5 splits)
    tags = {'md2' 'md3'};
    if ~replicate
        shardingsIds = {'_RNDE_02', '_RNDE_03', '_RNDE_05'};
    else
        shardingsIds = {'_NEMP_02', '_NEMP_03', '_NEMP_05'};
    end
    for shrd=1:length(shardingsIds)
        shardingsIds{shrd} = char(sprintf("%s%s",splitID, shardingsIds{shrd}));
    end
    
    intervals_without_correction = zeros(2, 6, endSample-startSample+1, length(shardingsIds));
    intervals = zeros(2, 6, endSample-startSample+1, length(shardingsIds));
    n_ssd_couples = zeros(2, endSample-startSample+1, 2, length(shardingsIds));
    for shrd=1:length(shardingsIds)
        fprintf("+ processing sharding %s \n", shardingsIds{shrd});
        for smpl=startSample:endSample %compute for each sample
            fprintf("    - processing %d sample \n", smpl);
            for m=1:2 %compute the row for each mesure

                for t=1:length(tags) %compute column for each model

                    tag = tags{t};
                    mid = EXPERIMENT.measure.list{m};
                    params = {tag, ... %model considered
                              'zero', ... %balanced
                              3, ... %sstype 
                              'q4', ... %quartile: consider all systems 
                              mid, ... % measure id 
                              EXPERIMENT.pattern.identifier.split(shardingsIds{shrd}, smpl),...
                              trackID,... %track ID 
                              char(10000)}; %number of samples 
                          
                    
                    %trackID = 'T03';

                    
                    %measureID = EXPERIMENT.pattern.identifier.measure(mid, EXPERIMENT.track.(trackID).corpus, trackID);

                    %serload2(EXPERIMENT.pattern.file.measure.corpus(trackID, measureID), ...
                    %    'WorkspaceVarNames', {'measure'}, ...
                    %    'FileVarNames', {measureID});
                    
                    
                    %sMeans = mean(measure{:, :});
                    
                    %[sMeans, sIdx] = sort(sMeans);
                    
                    fprintf("        * loading bootstrap ANOVA data and computing SSD pairs\n");

                    bootsrapEffectsID = EXPERIMENT.pattern.identifier.bootsrapEffects.analysis(params{:});

                    serload2(EXPERIMENT.pattern.file.analysis.shard(trackID, shardingsIds{shrd}, bootsrapEffectsID), ...
                                  'WorkspaceVarNames', {'bootstrapTable'}, ...
                                  'FileVarNames', {bootsrapEffectsID});

                    sMean = mean(bootstrapTable{:,:}, 1);
                    [sMean, sIdx] = sort(sMean);

                    sortedSystems = bootstrapTable.Properties.VariableNames(sIdx);

                    % COMPUTE P-VALUES
                    if strcmp(direction, 'uni')
                        [~, ssdcouples, cutoff, ~] = BHcorrection_directional(...
                            sortedSystems,...
                            bootstrapTable, EXPERIMENT.analysis.alpha.threshold); 
                    else
                        [~, ssdcouples, cutoff, ~] = BHcorrection_bidirectional(...
                            sortedSystems,...
                            bootstrapTable, EXPERIMENT.analysis.alpha.threshold); 
                    end
                    n_ssd_couples(m, smpl, t, shrd) = ssdcouples;
                    
                    % COMPUTE INTERVALS

                    % ---- intervals with correction ---- %


                    % ---- intervals without correction ---- %
                    %interval_size = 1-(double(cutoff)/(10000*100) * 2);
                    %excluded_size = (1-interval_size)/2;
                    excluded_size = double(cutoff)/(10000*100);
                    
                    H = height(bootstrapTable);
                    startIdx = cast(H*excluded_size+1, 'int32');
                    endIdx   = cast(H*(1-excluded_size)-1,'int32');
                    
                    selected_effects = zeros(endIdx-startIdx+1,...
                                             length(bootstrapTable.Properties.VariableNames));
                    selected_effects_cutoff = zeros(height(bootstrapTable)-cutoff*2,...
                                             length(bootstrapTable.Properties.VariableNames));
                                         
                    for c=1:length(bootstrapTable.Properties.VariableNames)
                        sbt = sort(bootstrapTable{:, c});
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
    


    
    print_full(intervals_without_correction, n_ssd_couples);
    print_aggregated(intervals_without_correction, n_ssd_couples);
    print_full(intervals, n_ssd_couples);
    print_aggregated(intervals, n_ssd_couples);

    

end


function [] = print_full(intervals, n_ssd_couples)    

    [~, nTags, nSamples, nShards] =  size(intervals);
    nTags = nTags/3;
    for shrd=1:nShards
        
        fprintf("\\begin{table}[]\n")
        fprintf("\\begin{tabular}{llllllllll}\\hline\n")
        fprintf("& & \\multicolumn{4}{l}{\\textbf{no interactions}} & \\multicolumn{4}{l}{\\textbf{interactions}} \\\\\\hline\n")
        fprintf("\\textbf{sample} & \\textbf{measure} & \\textbf{mean} & \\textbf{min} & \\textbf{max} & \\textbf{ssd} & \\textbf{mean} & \\textbf{min} & \\textbf{max} & \\textbf{ssd}  \\\\\\hline\n")
        for smpl=1:nSamples %compute for each sample
            fprintf("\\multirow{2}{*}{%d} &",smpl);
            for m=1:2 %compute the row for each mesure
                if m==1
                    fprintf("AP   &");
                else
                    fprintf("                  & P@10 &");
                end
                for t=1:nTags %compute column for each model
                    if t==2
                        fprintf("&");
                    end
                    fprintf(" %.3f\t& %.3f & %.3f\t& %d\t", intervals(m, (1+3*(t-1)):(3+3*(t-1)),smpl, shrd),  n_ssd_couples(m, smpl, t, shrd));
                    
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
            for t=1:nTags %compute column for each model
                if t==2
                    fprintf("&");
                end
                fprintf(" %.3f\t& %.3f & %.3f\t& %.2f\t", mean(intervals(m, (1+3*(t-1)):(3+3*(t-1)),:, shrd), [3]),...
                                                        mean(n_ssd_couples(m, :, t, shrd), 2));

            end

            fprintf("\\\\\n");
        end
        fprintf("\\hline\n");
        fprintf("\\end{tabular}\n");
        fprintf("\\end{table}\n");
    end
end



function [] = print_aggregated(intervals, n_ssd_couples)

    [~, nTags, ~, nShards] =  size(intervals);
    nTags = nTags/3;
    shardings_text = {'2 shards', '3 shards', '5 shards'};

    fprintf("\\begin{table}[]\n")
    fprintf("\\begin{tabular}{llllllll}\\hline\n")   
    fprintf("& & \\multicolumn{3}{l}{\\textbf{no interactions}} & \\multicolumn{3}{l}{\\textbf{interactions}} \\\\\\hline\n")
    fprintf("\\textbf{sample} & \\textbf{measure} & \\textbf{mean} & \\textbf{min} & \\textbf{max} & \\textbf{ssd} & \\textbf{mean} & \\textbf{min} & \\textbf{max} & \\textbf{ssd}  \\\\\n")
    fprintf("\\hline\n")
    for shrd=1:nShards
        fprintf("\\multirow{2}{*}{%s}&", shardings_text{shrd});
        for m=1:2 %compute the row for each mesure
            if m==1
                fprintf("AP   &");
            else
                fprintf("                  & P@10 &");
            end
            for t=1:nTags %compute column for each model
                if t==2
                    fprintf("&");
                end
                fprintf(" %.3f\t& %.3f & %.3f\t & %.2f\t", mean(intervals(m, (1+3*(t-1)):(3+3*(t-1)),:, shrd), [3]), mean(n_ssd_couples(m, :, t, shrd), 2));

            end

            fprintf("\\\\\n");
        end
        fprintf("\\hline\n");
    end

    fprintf("\\end{tabular}\n");
    fprintf("\\end{table}\n");
end