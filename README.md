
MACRO-STEP 1
* set up the collections 
	* put into the directories ./experiment/runs/T03 and ./experiment/runs/T08 the runs from the two collections as separate files.
	* put into the directories ./experiment/pool/T03 and ./experiment/runs/T08 the qrels from the two collections. the expected names for the qrels are in ./code/shared_files/tracks.m: change them in case it is necessary.
* import shard the runs and import them
	* run
		# ------------------ IMPORT COLLECTIONS ------------------ #
		code(matlab nodesktop -nodisplay -r "import_collection('T03')")
		# --------------- SPLIT CORPUS INTO SHARDS --------------- #
		code(
		# note that, in case you want to create a different splitting (e.g. with more shards, or a different)
		# corpus, it is necessary to have a directory with the same name in ./experiment/shard
		# and to have the code and description of the sharding into the ./code/common_parameters.m file
		# this is also true for splitting runs, pools and computing measures
		matlab nodesktop -nodisplay -r "random_split_corpus('TIP12_RNDE_02'); quit;"
		matlab nodesktop -nodisplay -r "random_split_corpus('TIP12_RNDE_03'); quit;"
		matlab nodesktop -nodisplay -r "random_split_corpus('TIP12_RNDE_05'); quit;")


		# --------------- SPLIT RUNS --------------- #
		matlab nodesktop -nodisplay -r "split_runs('T03', 'TIP12_RNDE_02');quit;"
		matlab nodesktop -nodisplay -r "split_runs('T03', 'TIP12_RNDE_03');quit;"
		matlab nodesktop -nodisplay -r "split_runs('T03', 'TIP12_RNDE_05');quit;"

		# --------------- SPLIT POOL --------------- #
		matlab nodesktop -nodisplay -r "split_pool('T03', 'TIP12_RNDE_02');quit;"
		matlab nodesktop -nodisplay -r "split_pool('T03', 'TIP12_RNDE_03');quit;"
		matlab nodesktop -nodisplay -r "split_pool('T03', 'TIP12_RNDE_05');quit;"
      
	* compute measures (AP, P@10)
		* run
		# to compute measures bisides AP and P@10, it is necessary to changes the last 2 parameters, according to the
		# list in measures
		matlab nodesktop -nodisplay -r "compute_measures_shards('T03', 'TIP12_RNDE_02', 1, 2);quit;"
		matlab nodesktop -nodisplay -r "compute_measures_shards('T03', 'TIP12_RNDE_03', 1, 2);quit;"
		matlab nodesktop -nodisplay -r "compute_measures_shards('T03', 'TIP12_RNDE_05', 1, 2);quit;"



MACRO-STEP 2: 
	
	- compute bootstrap ANOVA
		- run:

			# --------------- TRADITIONAL ANOVA --------------- #
			matlab nodesktop -nodisplay -r "compute_md2to6_analysis('md2', 'T03', 'TIP12_RNDE_02', 'zero', 3, 'q4', 1, 2, 1, 5, 24);quit;"
			matlab nodesktop -nodisplay -r "compute_md2to6_analysis('md3', 'T03', 'TIP12_RNDE_02', 'zero', 3, 'q4', 1, 2, 1, 5, 24);quit;"

			matlab nodesktop -nodisplay -r "compute_md2to6_analysis('md2', 'T03', 'TIP12_RNDE_03', 'zero', 3, 'q4', 1, 2, 1, 5, 24);quit;"
			matlab nodesktop -nodisplay -r "compute_md2to6_analysis('md3', 'T03', 'TIP12_RNDE_03', 'zero', 3, 'q4', 1, 2, 1, 5, 24);quit;"

			matlab nodesktop -nodisplay -r "compute_md2to6_analysis('md2', 'T03', 'TIP12_RNDE_05', 'zero', 3, 'q4', 1, 2, 1, 5, 24);quit;"
			matlab nodesktop -nodisplay -r "compute_md2to6_analysis('md3', 'T03', 'TIP12_RNDE_05', 'zero', 3, 'q4', 1, 2, 1, 5, 24);quit;"

			# --------------- BOOTSTRAP ANOVA --------------- #

			matlab nodesktop -nodisplay -r "compute_bootstrap_effects('md2', 'T03', 'TIP12_RNDE_02', 'zero', 3, 'q4', 2500, 1, 2, 1, 5, 24);quit;"
			matlab nodesktop -nodisplay -r "compute_bootstrap_effects('md3', 'T03', 'TIP12_RNDE_02', 'zero', 3, 'q4', 2500, 1, 2, 1, 5, 24);quit;"

			matlab nodesktop -nodisplay -r "compute_bootstrap_effects('md2', 'T03', 'TIP12_RNDE_03', 'zero', 3, 'q4', 2500, 1, 2, 1, 5, 24);quit;"
			matlab nodesktop -nodisplay -r "compute_bootstrap_effects('md3', 'T03', 'TIP12_RNDE_03', 'zero', 3, 'q4', 2500, 1, 2, 1, 5, 24);quit;"

			matlab nodesktop -nodisplay -r "compute_bootstrap_effects('md2', 'T03', 'TIP12_RNDE_05', 'zero', 3, 'q4', 2500, 1, 2, 1, 5, 24);quit;"
			matlab nodesktop -nodisplay -r "compute_bootstrap_effects('md3', 'T03', 'TIP12_RNDE_05', 'zero', 3, 'q4', 2500, 1, 2, 1, 5, 24);quit;"

			- outputs: system effects bootstrap sample matrix



	- replicate "Using Replicates in Information Retrieval Evaluation":
		- run:

			matlab nodesktop -nodisplay -r "replicate_URIIRE();quit;"

			- outputs: table 1 - Mean, Shortest, and Longest Lengths of 95% Confidence Intervals on the System Effect for TREC-3 Runs
					   table 2 - Number of Significantly Different Run Pairs Found for TREC-3, last column (partition)
					   table 3 - Mean [Minimum, Maximum] Lengths of 95% Confidence Intervals on the System Effect for Different Number of Partitions for Different TREC Datasets and Evaluation Measures. 

	What we did differently: i) different sampling, ii) bidirectional tests


Extend the Voohrees work, by adding new models


MACRO-STEP 3:
	- compute baselines: 
		- compute traditional ANOVA + HSD
			- outputs: pvalue matrix

		- compute traditional ANOVA + BH
			???
			- outputs: pvalue matrix

MACRO-STEP 4:

	- compute anlyses:
		- table 1
		- table 2
		- table 3-4: 



Folder structure

	-> matters
	-> code
	-> experiments
		|
		|
		-> runs
			|
			|
			-> TO3
		-> pool
			|
			|
			-> TO3	
		-> analysis
			|
			|
			-> TO3
		-> dataset
			|
			|
			-> TO3
		-> measure
			|
			|
			-> TO3
		-> shard
		-> corpus
			|
			|
			-> TIP12.txt: list of tipster disks 1-2 document ids (one for each line)
