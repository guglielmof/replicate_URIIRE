%% Configuration for Splits

%EXPERIMENT.split.list = {'WT10g_ALL_TLD_EVEN_SIZE', 'WT10g_ALL_TLD', 'WT10g_HALF_TLD', 'WT10g_QUARTER_TLD', 'WT10g_EIGHTH_TLD', ...
%    'WT10g_ALL_TLD_RANDOM_SIZE', 'WT10g_ALL_TLD_RANDOM_EVEN_SIZE', ...
%    'WT10g_ALL_TLD_RANDOM_EVEN_SIZE_25', 'WT10g_ALL_TLD_RANDOM_EVEN_SIZE_10','WT10g_ALL_TLD_RANDOM_EVEN_SIZE_5', 'WT10g_ALL_TLD_RANDOM_EVEN_SIZE_2',  ...
%    'TIPSTER_DS'};
EXPERIMENT.split.list = {'WT10g_RNDE_02', 'WT10g_RNDE_03', 'WT10g_RNDE_04', 'WT10g_RNDE_05', 'WT10g_RNDE_10', 'WT10g_RNDE_25', 'WT10g_RNDE_50', ...
                         'TIP_RNDE_02', 'TIP_RNDE_03', 'TIP_RNDE_04', 'TIP_RNDE_05', 'TIP_RNDE_10', 'TIP_RNDE_25', 'TIP_RNDE_50', ...
                         'TIP12_RNDE_02', 'TIP12_RNDE_03', 'TIP12_RNDE_04', 'TIP12_RNDE_05', 'TIP12_RNDE_10', 'TIP12_RNDE_25', 'TIP12_RNDE_50', ...
                         'WAPO_RNDE_02', 'WAPO_RNDE_03', 'WAPO_RNDE_04', 'WAPO_RNDE_05', 'WAPO_RNDE_10', 'WAPO_RNDE_25', 'WAPO_RNDE_50', ...
                         'TIP12_NEMP_02', 'TIP12_NEMP_03', 'TIP12_NEMP_04', 'TIP12_NEMP_05'};
EXPERIMENT.split.number = length(EXPERIMENT.split.list);

% The total number of sample for each split
EXPERIMENT.split.sample = 5;

EXPERIMENT.split.WT10g_RNDE_02.id = 'WT10g_RNDE_02';
EXPERIMENT.split.WT10g_RNDE_02.name = 'WT10g divided in 2 even size shards';
EXPERIMENT.split.WT10g_RNDE_02.corpus = 'WT10g';
EXPERIMENT.split.WT10g_RNDE_02.shard = 2;
EXPERIMENT.split.WT10g_RNDE_02.ratio = repmat(1/EXPERIMENT.split.WT10g_RNDE_02.shard, 1, EXPERIMENT.split.WT10g_RNDE_02.shard);

EXPERIMENT.split.WT10g_RNDE_03.id = 'WT10g_RNDE_03';
EXPERIMENT.split.WT10g_RNDE_03.name = 'WT10g divided in 3 even size shards';
EXPERIMENT.split.WT10g_RNDE_03.corpus = 'WT10g';
EXPERIMENT.split.WT10g_RNDE_03.shard = 3;
EXPERIMENT.split.WT10g_RNDE_03.ratio = repmat(1/EXPERIMENT.split.WT10g_RNDE_03.shard, 1, EXPERIMENT.split.WT10g_RNDE_03.shard);

EXPERIMENT.split.WT10g_RNDE_04.id = 'WT10g_RNDE_04';
EXPERIMENT.split.WT10g_RNDE_04.name = 'WT10g divided in 4 even size shards';
EXPERIMENT.split.WT10g_RNDE_04.corpus = 'WT10g';
EXPERIMENT.split.WT10g_RNDE_04.shard = 4;
EXPERIMENT.split.WT10g_RNDE_04.ratio = repmat(1/EXPERIMENT.split.WT10g_RNDE_04.shard, 1, EXPERIMENT.split.WT10g_RNDE_04.shard);

EXPERIMENT.split.WT10g_RNDE_05.id = 'WT10g_RNDE_05';
EXPERIMENT.split.WT10g_RNDE_05.name = 'WT10g divided in 5 even size shards';
EXPERIMENT.split.WT10g_RNDE_05.corpus = 'WT10g';
EXPERIMENT.split.WT10g_RNDE_05.shard = 5;
EXPERIMENT.split.WT10g_RNDE_05.ratio = repmat(1/EXPERIMENT.split.WT10g_RNDE_05.shard, 1, EXPERIMENT.split.WT10g_RNDE_05.shard);

EXPERIMENT.split.WT10g_RNDE_10.id = 'WT10g_RNDE_10';
EXPERIMENT.split.WT10g_RNDE_10.name = 'WT10g divided in 10 even size shards';
EXPERIMENT.split.WT10g_RNDE_10.corpus = 'WT10g';
EXPERIMENT.split.WT10g_RNDE_10.shard = 10;
EXPERIMENT.split.WT10g_RNDE_10.ratio = repmat(1/EXPERIMENT.split.WT10g_RNDE_10.shard, 1, EXPERIMENT.split.WT10g_RNDE_10.shard);

EXPERIMENT.split.WT10g_RNDE_25.id = 'WT10g_RNDE_25';
EXPERIMENT.split.WT10g_RNDE_25.name = 'WT10g divided in 25 even size shards';
EXPERIMENT.split.WT10g_RNDE_25.corpus = 'WT10g';
EXPERIMENT.split.WT10g_RNDE_25.shard = 25;
EXPERIMENT.split.WT10g_RNDE_25.ratio = repmat(1/EXPERIMENT.split.WT10g_RNDE_25.shard, 1, EXPERIMENT.split.WT10g_RNDE_25.shard);

EXPERIMENT.split.WT10g_RNDE_50.id = 'WT10g_RNDE_50';
EXPERIMENT.split.WT10g_RNDE_50.name = 'WT10g divided in 50 even size shards';
EXPERIMENT.split.WT10g_RNDE_50.corpus = 'WT10g';
EXPERIMENT.split.WT10g_RNDE_50.shard = 50;
EXPERIMENT.split.WT10g_RNDE_50.ratio = repmat(1/EXPERIMENT.split.WT10g_RNDE_50.shard, 1, EXPERIMENT.split.WT10g_RNDE_50.shard);

EXPERIMENT.split.TIP_RNDE_02.id = 'TIP_RNDE_02';
EXPERIMENT.split.TIP_RNDE_02.name = 'TIPSTER divided in 2 even size shards';
EXPERIMENT.split.TIP_RNDE_02.corpus = 'TIP';
EXPERIMENT.split.TIP_RNDE_02.shard = 2;
EXPERIMENT.split.TIP_RNDE_02.ratio = repmat(1/EXPERIMENT.split.TIP_RNDE_02.shard, 1, EXPERIMENT.split.TIP_RNDE_02.shard);

EXPERIMENT.split.TIP_RNDE_03.id = 'TIP_RNDE_03';
EXPERIMENT.split.TIP_RNDE_03.name = 'TIPSTER divided in 3 even size shards';
EXPERIMENT.split.TIP_RNDE_03.corpus = 'TIP';
EXPERIMENT.split.TIP_RNDE_03.shard = 3;
EXPERIMENT.split.TIP_RNDE_03.ratio = repmat(1/EXPERIMENT.split.TIP_RNDE_03.shard, 1, EXPERIMENT.split.TIP_RNDE_03.shard);

EXPERIMENT.split.TIP_RNDE_04.id = 'TIP_RNDE_04';
EXPERIMENT.split.TIP_RNDE_04.name = 'TIPSTER divided in 4 even size shards';
EXPERIMENT.split.TIP_RNDE_04.corpus = 'TIP';
EXPERIMENT.split.TIP_RNDE_04.shard = 4;
EXPERIMENT.split.TIP_RNDE_04.ratio = repmat(1/EXPERIMENT.split.TIP_RNDE_04.shard, 1, EXPERIMENT.split.TIP_RNDE_04.shard);

EXPERIMENT.split.TIP_RNDE_05.id = 'TIP_RNDE_05';
EXPERIMENT.split.TIP_RNDE_05.name = 'TIPSTER divided in 5 even size shards';
EXPERIMENT.split.TIP_RNDE_05.corpus = 'TIP';
EXPERIMENT.split.TIP_RNDE_05.shard = 5;
EXPERIMENT.split.TIP_RNDE_05.ratio = repmat(1/EXPERIMENT.split.TIP_RNDE_05.shard, 1, EXPERIMENT.split.TIP_RNDE_05.shard);

EXPERIMENT.split.TIP_RNDE_10.id = 'TIP_RNDE_10';
EXPERIMENT.split.TIP_RNDE_10.name = 'TIPSTER divided in 10 even size shards';
EXPERIMENT.split.TIP_RNDE_10.corpus = 'TIP';
EXPERIMENT.split.TIP_RNDE_10.shard = 10;
EXPERIMENT.split.TIP_RNDE_10.ratio = repmat(1/EXPERIMENT.split.TIP_RNDE_10.shard, 1, EXPERIMENT.split.TIP_RNDE_10.shard);

EXPERIMENT.split.TIP_RNDE_25.id = 'TIP_RNDE_25';
EXPERIMENT.split.TIP_RNDE_25.name = 'TIPSTER divided in 25 even size shards';
EXPERIMENT.split.TIP_RNDE_25.corpus = 'TIP';
EXPERIMENT.split.TIP_RNDE_25.shard = 25;
EXPERIMENT.split.TIP_RNDE_25.ratio = repmat(1/EXPERIMENT.split.TIP_RNDE_25.shard, 1, EXPERIMENT.split.TIP_RNDE_25.shard);

EXPERIMENT.split.TIP_RNDE_50.id = 'TIP_RNDE_50';
EXPERIMENT.split.TIP_RNDE_50.name = 'TIPSTER divided in 50 even size shards';
EXPERIMENT.split.TIP_RNDE_50.corpus = 'TIP';
EXPERIMENT.split.TIP_RNDE_50.shard = 50;
EXPERIMENT.split.TIP_RNDE_50.ratio = repmat(1/EXPERIMENT.split.TIP_RNDE_50.shard, 1, EXPERIMENT.split.TIP_RNDE_50.shard);





EXPERIMENT.split.TIP12_RNDE_02.id = 'TIP12_RNDE_02'; EXPERIMENT.split.TIP12_RNDE_02.name = 'TIPSTER disks 1-2 divided in 2 even size shards';
EXPERIMENT.split.TIP12_RNDE_02.corpus = 'TIP12';
EXPERIMENT.split.TIP12_RNDE_02.shard = 2;
EXPERIMENT.split.TIP12_RNDE_02.ratio = repmat(1/EXPERIMENT.split.TIP12_RNDE_02.shard, 1, EXPERIMENT.split.TIP12_RNDE_02.shard);

EXPERIMENT.split.TIP12_RNDE_03.id = 'TIP12_RNDE_03';
EXPERIMENT.split.TIP12_RNDE_03.name = 'TIPSTER disks 1-2 divided in 3 even size shards';
EXPERIMENT.split.TIP12_RNDE_03.corpus = 'TIP12';
EXPERIMENT.split.TIP12_RNDE_03.shard = 3;
EXPERIMENT.split.TIP12_RNDE_03.ratio = repmat(1/EXPERIMENT.split.TIP12_RNDE_03.shard, 1, EXPERIMENT.split.TIP12_RNDE_03.shard);

EXPERIMENT.split.TIP12_RNDE_04.id = 'TIP12_RNDE_04';
EXPERIMENT.split.TIP12_RNDE_04.name = 'TIPSTER disks 1-2 divided in 4 even size shards';
EXPERIMENT.split.TIP12_RNDE_04.corpus = 'TIP12';
EXPERIMENT.split.TIP12_RNDE_04.shard = 4;
EXPERIMENT.split.TIP12_RNDE_04.ratio = repmat(1/EXPERIMENT.split.TIP12_RNDE_04.shard, 1, EXPERIMENT.split.TIP12_RNDE_04.shard);

EXPERIMENT.split.TIP12_RNDE_05.id = 'TIP12_RNDE_05';
EXPERIMENT.split.TIP12_RNDE_05.name = 'TIPSTER disks 1-2 divided in 5 even size shards';
EXPERIMENT.split.TIP12_RNDE_05.corpus = 'TIP12';
EXPERIMENT.split.TIP12_RNDE_05.shard = 5;
EXPERIMENT.split.TIP12_RNDE_05.ratio = repmat(1/EXPERIMENT.split.TIP12_RNDE_05.shard, 1, EXPERIMENT.split.TIP12_RNDE_05.shard);

EXPERIMENT.split.TIP12_RNDE_10.id = 'TIP12_RNDE_10';
EXPERIMENT.split.TIP12_RNDE_10.name = 'TIPSTER disks 1-2 divided in 10 even size shards';
EXPERIMENT.split.TIP12_RNDE_10.corpus = 'TIP12';
EXPERIMENT.split.TIP12_RNDE_10.shard = 10;
EXPERIMENT.split.TIP12_RNDE_10.ratio = repmat(1/EXPERIMENT.split.TIP12_RNDE_10.shard, 1, EXPERIMENT.split.TIP12_RNDE_10.shard);

EXPERIMENT.split.TIP12_RNDE_25.id = 'TIP12_RNDE_25';
EXPERIMENT.split.TIP12_RNDE_25.name = 'TIPSTER disks 1-2 divided in 25 even size shards';
EXPERIMENT.split.TIP12_RNDE_25.corpus = 'TIP12';
EXPERIMENT.split.TIP12_RNDE_25.shard = 25;
EXPERIMENT.split.TIP12_RNDE_25.ratio = repmat(1/EXPERIMENT.split.TIP12_RNDE_25.shard, 1, EXPERIMENT.split.TIP12_RNDE_25.shard);

EXPERIMENT.split.TIP12_RNDE_50.id = 'TIP12_RNDE_50';
EXPERIMENT.split.TIP12_RNDE_50.name = 'TIPSTER disks 1-2 divided in 50 even size shards';
EXPERIMENT.split.TIP12_RNDE_50.corpus = 'TIP12';
EXPERIMENT.split.TIP12_RNDE_50.shard = 50;
EXPERIMENT.split.TIP12_RNDE_50.ratio = repmat(1/EXPERIMENT.split.TIP12_RNDE_50.shard, 1, EXPERIMENT.split.TIP12_RNDE_50.shard);




EXPERIMENT.split.TIP12_NEMP_02.id = 'TIP12_NEMP_02'; 
EXPERIMENT.split.TIP12_NEMP_02.name = 'TIPSTER disks 1-2 divided in 2 non-empty even size shards';
EXPERIMENT.split.TIP12_NEMP_02.corpus = 'TIP12';
EXPERIMENT.split.TIP12_NEMP_02.shard = 2;
EXPERIMENT.split.TIP12_NEMP_02.ratio = repmat(1/EXPERIMENT.split.TIP12_NEMP_02.shard, 1, EXPERIMENT.split.TIP12_NEMP_02.shard);

EXPERIMENT.split.TIP12_NEMP_03.id = 'TIP12_NEMP_03';
EXPERIMENT.split.TIP12_NEMP_03.name = 'TIPSTER disks 1-2 divided in 3 non-empty even size shards';
EXPERIMENT.split.TIP12_NEMP_03.corpus = 'TIP12';
EXPERIMENT.split.TIP12_NEMP_03.shard = 3;
EXPERIMENT.split.TIP12_NEMP_03.ratio = repmat(1/EXPERIMENT.split.TIP12_NEMP_03.shard, 1, EXPERIMENT.split.TIP12_NEMP_03.shard);

EXPERIMENT.split.TIP12_NEMP_04.id = 'TIP12_NEMP_04';
EXPERIMENT.split.TIP12_NEMP_04.name = 'TIPSTER disks 1-2 divided in 4 non-empty even size shards';
EXPERIMENT.split.TIP12_NEMP_04.corpus = 'TIP12';
EXPERIMENT.split.TIP12_NEMP_04.shard = 4;
EXPERIMENT.split.TIP12_NEMP_04.ratio = repmat(1/EXPERIMENT.split.TIP12_NEMP_04.shard, 1, EXPERIMENT.split.TIP12_NEMP_04.shard);

EXPERIMENT.split.TIP12_NEMP_05.id = 'TIP12_NEMP_05';
EXPERIMENT.split.TIP12_NEMP_05.name = 'TIPSTER disks 1-2 divided in 5 non-empty even size shards';
EXPERIMENT.split.TIP12_NEMP_05.corpus = 'TIP12';
EXPERIMENT.split.TIP12_NEMP_05.shard = 5;
EXPERIMENT.split.TIP12_NEMP_05.ratio = repmat(1/EXPERIMENT.split.TIP12_NEMP_05.shard, 1, EXPERIMENT.split.TIP12_NEMP_05.shard);








EXPERIMENT.split.WAPO_RNDE_02.id = 'WAPO_RNDE_02';
EXPERIMENT.split.WAPO_RNDE_02.name = 'WAPO divided in 2 even size shards';
EXPERIMENT.split.WAPO_RNDE_02.corpus = 'WAPO';
EXPERIMENT.split.WAPO_RNDE_02.shard = 2;
EXPERIMENT.split.WAPO_RNDE_02.ratio = repmat(1/EXPERIMENT.split.WAPO_RNDE_02.shard, 1, EXPERIMENT.split.WAPO_RNDE_02.shard);

EXPERIMENT.split.WAPO_RNDE_03.id = 'WAPO_RNDE_03';
EXPERIMENT.split.WAPO_RNDE_03.name = 'WAPO divided in 3 even size shards';
EXPERIMENT.split.WAPO_RNDE_03.corpus = 'WAPO';
EXPERIMENT.split.WAPO_RNDE_03.shard = 3;
EXPERIMENT.split.WAPO_RNDE_03.ratio = repmat(1/EXPERIMENT.split.WAPO_RNDE_03.shard, 1, EXPERIMENT.split.WAPO_RNDE_03.shard);

EXPERIMENT.split.WAPO_RNDE_04.id = 'WAPO_RNDE_04';
EXPERIMENT.split.WAPO_RNDE_04.name = 'WAPO divided in 4 even size shards';
EXPERIMENT.split.WAPO_RNDE_04.corpus = 'WAPO';
EXPERIMENT.split.WAPO_RNDE_04.shard = 4;
EXPERIMENT.split.WAPO_RNDE_04.ratio = repmat(1/EXPERIMENT.split.WAPO_RNDE_04.shard, 1, EXPERIMENT.split.WAPO_RNDE_04.shard);

EXPERIMENT.split.WAPO_RNDE_05.id = 'WAPO_RNDE_05';
EXPERIMENT.split.WAPO_RNDE_05.name = 'WAPO divided in 5 even size shards';
EXPERIMENT.split.WAPO_RNDE_05.corpus = 'WAPO';
EXPERIMENT.split.WAPO_RNDE_05.shard = 5;
EXPERIMENT.split.WAPO_RNDE_05.ratio = repmat(1/EXPERIMENT.split.WAPO_RNDE_05.shard, 1, EXPERIMENT.split.WAPO_RNDE_05.shard);

EXPERIMENT.split.WAPO_RNDE_10.id = 'WAPO_RNDE_10';
EXPERIMENT.split.WAPO_RNDE_10.name = 'WAPO divided in 10 even size shards';
EXPERIMENT.split.WAPO_RNDE_10.corpus = 'WAPO';
EXPERIMENT.split.WAPO_RNDE_10.shard = 10;
EXPERIMENT.split.WAPO_RNDE_10.ratio = repmat(1/EXPERIMENT.split.WAPO_RNDE_10.shard, 1, EXPERIMENT.split.WAPO_RNDE_10.shard);

EXPERIMENT.split.WAPO_RNDE_25.id = 'WAPO_RNDE_25';
EXPERIMENT.split.WAPO_RNDE_25.name = 'WAPO divided in 25 even size shards';
EXPERIMENT.split.WAPO_RNDE_25.corpus = 'WAPO';
EXPERIMENT.split.WAPO_RNDE_25.shard = 25;
EXPERIMENT.split.WAPO_RNDE_25.ratio = repmat(1/EXPERIMENT.split.WAPO_RNDE_25.shard, 1, EXPERIMENT.split.WAPO_RNDE_25.shard);

EXPERIMENT.split.WAPO_RNDE_50.id = 'WAPO_RNDE_50';
EXPERIMENT.split.WAPO_RNDE_50.name = 'WAPO divided in 50 even size shards';
EXPERIMENT.split.WAPO_RNDE_50.corpus = 'WAPO';
EXPERIMENT.split.WAPO_RNDE_50.shard = 50;
EXPERIMENT.split.WAPO_RNDE_50.ratio = repmat(1/EXPERIMENT.split.WAPO_RNDE_50.shard, 1, EXPERIMENT.split.WAPO_RNDE_50.shard);



%---------------------

% WT10g divided in 59 even size TLD shards
EXPERIMENT.split.WT10g_ALL_TLD_EVEN_SIZE.id = 'WT10g_ALL_TLD_EVEN_SIZE';
EXPERIMENT.split.WT10g_ALL_TLD_EVEN_SIZE.name =  'WT10g divided in 59 even size shards, corresponding to all the Top Level Domains';
EXPERIMENT.split.WT10g_ALL_TLD_EVEN_SIZE.shard = 59;
EXPERIMENT.split.WT10g_ALL_TLD_EVEN_SIZE.corpus = 'WT10g';
EXPERIMENT.split.WT10g_ALL_TLD_EVEN_SIZE.label = 'WT10g_TLDE_59';

% WT10g divided in 59 TLD shards
EXPERIMENT.split.WT10g_ALL_TLD.id = 'WT10g_ALL_TLD';
EXPERIMENT.split.WT10g_ALL_TLD.name =  'WT10g divided in 59 uneven size shards, corresponding to the all Top Level Domains';
EXPERIMENT.split.WT10g_ALL_TLD.shard = 59;
EXPERIMENT.split.WT10g_ALL_TLD.corpus = 'WT10g';
EXPERIMENT.split.WT10g_ALL_TLD.label = 'WT10g_TLDU_59';

% WT10g divided in 30 TLD shards
EXPERIMENT.split.WT10g_HALF_TLD.id = 'WT10g_HALF_TLD';
EXPERIMENT.split.WT10g_HALF_TLD.name =  'WT10g divided in 30 uneven size shards, corresponding to half groupings of the Top Level Domains';
EXPERIMENT.split.WT10g_HALF_TLD.shard = 30;
EXPERIMENT.split.WT10g_HALF_TLD.corpus = 'WT10g';
EXPERIMENT.split.WT10g_HALF_TLD.label = 'WT10g_TLDU_30';

% WT10g divided in 15 TLD shards
EXPERIMENT.split.WT10g_QUARTER_TLD.id = 'WT10g_QUARTER_TLD';
EXPERIMENT.split.WT10g_QUARTER_TLD.name =  'WT10g divided in 15 uneven size shards, corresponding to quarter groupings of the Top Level Domains';
EXPERIMENT.split.WT10g_QUARTER_TLD.shard = 15;
EXPERIMENT.split.WT10g_QUARTER_TLD.corpus = 'WT10g';
EXPERIMENT.split.WT10g_QUARTER_TLD.label = 'WT10g_TLDU_15';

% WT10g divided in 8 TLD shards
EXPERIMENT.split.WT10g_EIGHTH_TLD.id = 'WT10g_EIGHTH_TLD';
EXPERIMENT.split.WT10g_EIGHTH_TLD.name =  'WT10g divided in 8 uneven size shards, corresponding to eighth groupings of the Top Level Domains';
EXPERIMENT.split.WT10g_EIGHTH_TLD.shard = 8;
EXPERIMENT.split.WT10g_EIGHTH_TLD.corpus = 'WT10g';
EXPERIMENT.split.WT10g_EIGHTH_TLD.label = 'WT10g_TLDU_8';

% WT10g divided in 59 random size TLD shards
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_SIZE.id = 'WT10g_ALL_TLD_RANDOM_SIZE';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_SIZE.name =  'WT10g divided in 59 random unven size shards';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_SIZE.shard = 59;
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_SIZE.corpus = 'WT10g';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_SIZE.label = 'WT10g_RNDU_59';

% WT10g divided in 59 random even size TLD shards
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE.id = 'WT10g_ALL_TLD_RANDOM_EVEN_SIZE';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE.name =  'WT10g divided in 59 random even size shards';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE.shard = 59;
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE.corpus = 'WT10g';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE.label = 'WT10g_RNDE_59';

% WT25g divided in 25 random even size TLD shards
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_25.id = 'WT10g_ALL_TLD_RANDOM_EVEN_SIZE_25';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_25.name =  'WT10g divided in 25 random even size shards';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_25.shard = 25;
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_25.corpus = 'WT10g';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_25.label = 'WT10g_RNDE_25';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_25.color = rgb('Goldenrod');

% WT10g divided in 10 random even size TLD shards
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_10.id = 'WT10g_ALL_TLD_RANDOM_EVEN_SIZE_10';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_10.name =  'WT10g divided in 10 random even size shards';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_10.shard = 10;
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_10.corpus = 'WT10g';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_10.label = 'WT10g_RNDE_10';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_10.color = rgb('ForestGreen');

% WT10g divided in 5 random even size TLD shards
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_5.id = 'WT10g_ALL_TLD_RANDOM_EVEN_SIZE_5';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_5.name =  'WT10g divided in 5 random even size shards';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_5.shard = 5;
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_5.corpus = 'WT10g';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_5.label = 'WT10g_RNDE_5';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_5.color = rgb('RoyalBlue');

% WT10g divided in 2 random even size TLD shards
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_2.id = 'WT10g_ALL_TLD_RANDOM_EVEN_SIZE_2';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_2.name =  'WT10g divided in 2 random even size shards';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_2.shard = 2;
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_2.corpus = 'WT10g';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_2.label = 'WT10g_RNDE_2';
EXPERIMENT.split.WT10g_ALL_TLD_RANDOM_EVEN_SIZE_2.color = rgb('FireBrick');


% TIPSTER divided in 4 shards by document source
EXPERIMENT.split.TIPSTER_DS.id = 'TIPSTER_DS';
EXPERIMENT.split.TIPSTER_DS.name =  'TIPSTER divided by document source';
EXPERIMENT.split.TIPSTER_DS.shard = 4;
EXPERIMENT.split.TIPSTER_DS.shardLabels = {'TIPFBIS', 'TIPFR', 'TIPFT', 'TIPLA'};
EXPERIMENT.split.TIPSTER_DS.shardNames = {'TIPSTER, Foreign Broadcast Information Service', 'TIPSTER, Financial Register', 'TIPSTER, Financial Times', 'TIPSTER, Los Angeles Times'};
EXPERIMENT.split.TIPSTER_DS.corpus = 'TIPSTER';
EXPERIMENT.split.TIPSTER_DS.label = 'TIPSTER_DS';

% Returns the label of a shard in its split, given its index
EXPERIMENT.split.getShardLabel = @(splitID, idx) ( EXPERIMENT.split.(splitID).shardLabels{idx} );

% Returns the name of a shard in its split, given its index
EXPERIMENT.split.getShardName = @(splitID, idx) ( EXPERIMENT.split.(splitID).shardNames{idx} );



