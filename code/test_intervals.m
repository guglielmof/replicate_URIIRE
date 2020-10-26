clear; 
startMeasure = 1;
 endMeasure = 2;
 splitsID = {'TIP12_NEMP_02', 'TIP12_NEMP_03', 'TIP12_NEMP_05'};
 trackID = 'T03';
 common_parameters;
 startSample = 1;
 endSample = 5;
 %{
 reported_intervals = [[[[0.075, 0.071, 0.082], [0.029, 0.026, 0.031]], ... %2 partition - AP - noint/int
                        [[0.130, 0.122, 0.140], [0.065, 0.061, 0.069]]],... %2 partition - P@10 - noint/int
                        [[[0.064, 0.060, 0.069], [0.032, 0.030, 0.034]], ... %3 partition - AP - noint/int
                        [[0.106, 0.099, 0.112], [0.065, 0.061, 0.071]]], ...%3 partition - P@10 - noint/int
                        [[[0.055, 0.052, 0.058], [0.033, 0.031, 0.034]],...
                        [[0.081, 0.076, 0.086], [0.055, 0.052, 0.060]]]];
 %reported_intervals = reshape(reported_intervals, 3,2,2,3);
 %}
 reported_intervals = zeros(3, 2, 2, 3);
 reported_intervals(1, 1, :, :) = [[0.075, 0.071, 0.082]; [0.029, 0.026, 0.031]];
 reported_intervals(1, 2, :, :) = [[0.130, 0.122, 0.140]; [0.065, 0.061, 0.069]];    
 reported_intervals(2, 1, :, :) = [[0.064, 0.060, 0.069]; [0.032, 0.030, 0.034]];
 reported_intervals(2, 2, :, :) = [[0.106, 0.099, 0.112]; [0.065, 0.061, 0.071]];
 reported_intervals(3, 1, :, :) = [[0.055, 0.052, 0.058]; [0.033, 0.031, 0.034]];
 reported_intervals(3, 2, :, :) = [[0.081, 0.076, 0.086]; [0.055, 0.052, 0.060]];
 %split, measure, md, stat
 results = zeros(3, 2, 2, 5, 3);
 
 for spl=1:length(splitsID)
    splitID = splitsID{spl};
    for m = startMeasure:endMeasure
        

        fprintf('\n+ Analysing %s\n', EXPERIMENT.measure.getAcronym(m));

        estMeasures = cell(1, EXPERIMENT.split.(splitID).shard);
        mid = EXPERIMENT.measure.list{m};


        
        % repeat this "sample" time, to have a more precise statistics.
        % smpl is not directly involved in the model.
        for md=1:2
            for smpl = startSample:endSample

                for shr = 1:EXPERIMENT.split.(splitID).shard
                    shardID = EXPERIMENT.pattern.identifier.shard(splitID, shr, smpl);
                    sh = strcat("Shard=shr",char(sprintf("%03d", shr)));

                    measureID = EXPERIMENT.pattern.identifier.measure(mid, shardID, trackID);

                    serload2(EXPERIMENT.pattern.file.measure.shard(trackID, splitID, measureID), ...
                        'WorkspaceVarNames', {'measure'}, ...
                        'FileVarNames', {measureID});

                    %[idx, mm] = compute_quartile(quartile, measure);

                    measures{shr} = measure;


                    clear tmp measure;
                end
                sys_effects = [];
                
                temp = cellfun(@(x) mean(x{:,:}, 1), measures,'UniformOutput', false);
                for t=1:length(temp)
                    sys_effects =[sys_effects;temp{t}];
                end
                sys_effects = mean(sys_effects,1);
                for ii=1:3
                    max_se = sys_effects + reported_intervals(spl, m, md, ii)/2;
                    min_se = sys_effects - reported_intervals(spl, m, md, ii)/2;

                    ssd_pairs = 0;
                    for i=1:length(sys_effects)-1
                        for j=i+1:length(sys_effects)
                            if sys_effects(i)<min_se(j) || sys_effects(i)>max_se(j)
                                ssd_pairs = ssd_pairs+1;
                            end
                        end
                    end
                
                    results(spl, m, md, smpl, ii) = ssd_pairs;
                end
            end
        end


     end
 end
 
meanResults = mean(results, 4);

fprintf("\\begin{table}[!h]\n");
fprintf("\\centering\n");
fprintf("\\mycaption{}\n");
fprintf("\\label{tbl:inference_with_interval}\n");
fprintf("\\resizebox{\\columnwidth}{!}{\n");
fprintf("\\begin{tabularx}{\\textwidth}{@{}lr *{6}{Y}@{}}\n");
fprintf("\\toprule\n");
fprintf("& & \\multicolumn{3}{c}{\\textbf{no interactions} (\\ref{eq:md2})} & \\multicolumn{3}{c}{\textbf{interactions} (\\ref{eq:md3})} \\\\\n");
fprintf("\\midrule\n");
fprintf("\\textbf{sample} & \\textbf{measure} & \\textbf{mean} & \\textbf{min} & \\textbf{max}  & \\textbf{mean} & \\textbf{min} & \\textbf{max}  \\\\\n");
fprintf("\\midrule\n");

for spl=1:length(splitsID)
    fprintf("\\multirow{2}{*}{2 shards} ");
    for m=1:2
        fprintf("& ");
        for md=1:2
            if md==1
                fprintf("%s  &", EXPERIMENT.measure.getAcronym(m));
            end
            fprintf(" %.2f & %.2f & %.2f ",meanResults(spl, m, md, 1, :));
            if md==1
                fprintf("&");
            else
                fprintf("\\\\");
            end
            
        end
        fprintf("\n");
    end
    if spl~=length(splitsID)
        fprintf("\\midrule\n");
    else
        fprintf("\\bottomrule\n");
    end
end

fprintf("\\end{tabularx}\n");
fprintf("}\n");
fprintf("\\end{table}\n");
