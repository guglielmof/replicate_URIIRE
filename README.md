The code has been tested and works with matlab version 2017b.

# MACRO-STEP 0
* replicate the following folder structure
```
-> matters
-> code
-> experiments
	|
	|
	-> runs
		|
		|
		-> TO3
			|
			|
			-> TIP12_RNDE_02
			-> TIP12_RNDE_03
			-> TIP12_RNDE_05
	-> pool
		|
		|
		-> TO3
			|
			|
			-> TIP12_RNDE_02
			-> TIP12_RNDE_03
			-> TIP12_RNDE_05
	-> analysis
		|
		|
		-> TO3
			|
			|
			-> TIP12_RNDE_02
			-> TIP12_RNDE_03
			-> TIP12_RNDE_05
	-> dataset
		|
		|
		-> TO3
			|
			|
			-> TIP12_RNDE_02
			-> TIP12_RNDE_03
			-> TIP12_RNDE_05
	-> measure
		|
		|
		-> TO3
			|
			|
			-> TIP12_RNDE_02
			-> TIP12_RNDE_03
			-> TIP12_RNDE_05
	-> shard
	-> corpus
		|
		|
		-> TIP12.txt: list of tipster disks 1-2 document ids (one for each line)
```

# MACRO-STEP 1
* set up the collections 
	* put into the directories ./experiment/runs/T03 and ./experiment/runs/T08 the runs from the two collections as separate files.
	* put into the directories ./experiment/pool/T03 and ./experiment/runs/T08 the qrels from the two collections. the expected names for the qrels are in ./code/shared_files/tracks.m: change them in case it is necessary.
* import shard the runs and import them
	* run
	
	```
	# ------------------ IMPORT COLLECTIONS ------------------ #
	matlab nodesktop -nodisplay -r "import_collection('T03')"
	
	# --------------- SPLIT CORPUS INTO SHARDS --------------- #
	# note that, in case you want to create a different splitting (e.g. with more shards, or a different)
	# corpus, it is necessary to have a directory with the same name in ./experiment/shard
	# and to have the code and description of the sharding into the ./code/common_parameters.m file
	# this is also true for splitting runs, pools and computing measures
	
	matlab nodesktop -nodisplay -r "random_split_corpus('TIP12_RNDE_02'); quit;"
	matlab nodesktop -nodisplay -r "random_split_corpus('TIP12_RNDE_03'); quit;"
	matlab nodesktop -nodisplay -r "random_split_corpus('TIP12_RNDE_05'); quit;"
	
	# If you intend to replicate the results found in [1] use the following instruction:
	matlab nodesktop -nodisplay -r "noempy_split_corpus('TIP12_NEMP_02', 'T03'); quit;" 
	
	# for all the possible number of shards. Substitute 'TIP12_RNDE_<number of shards>' with 
	# 'TIP12_NEMP_<number of shards>' in all the following instructions; 
	# to sample shards with at least one relevant document for each topic. Additionally, add
	# the directories named 'TIP12_NEMP_<number of shards>' in all the directories. Use the
	# same sharding code in all the following instructions
		
	# --------------- SPLIT RUNS --------------- #
	matlab nodesktop -nodisplay -r "split_runs('T03', 'TIP12_RNDE_02');quit;"
	matlab nodesktop -nodisplay -r "split_runs('T03', 'TIP12_RNDE_03');quit;"
	matlab nodesktop -nodisplay -r "split_runs('T03', 'TIP12_RNDE_05');quit;"
	
	# --------------- SPLIT POOL --------------- #
	matlab nodesktop -nodisplay -r "split_pool('T03', 'TIP12_RNDE_02');quit;"
	matlab nodesktop -nodisplay -r "split_pool('T03', 'TIP12_RNDE_03');quit;"
	matlab nodesktop -nodisplay -r "split_pool('T03', 'TIP12_RNDE_05');quit;"
	```
		
* compute measures (AP, P@10)
	* run
	```
	# to compute measures bisides AP and P@10, it is necessary to changes the last 2 parameters, according to the
	# list in ./code/shared_files/measures
	matlab nodesktop -nodisplay -r "compute_measures_shards('T03', 'TIP12_RNDE_02', 1, 2);quit;"
	matlab nodesktop -nodisplay -r "compute_measures_shards('T03', 'TIP12_RNDE_03', 1, 2);quit;"
	matlab nodesktop -nodisplay -r "compute_measures_shards('T03', 'TIP12_RNDE_05', 1, 2);quit;"
	```


# MACRO-STEP 2
* compute bootstrap ANOVA
	* run
	```
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
	```
	* outputs: system effects bootstrap sample matrix
* reproduce "Using Replicates in Information Retrieval Evaluation"
	* run
	```
	matlab nodesktop -nodisplay -r "replicate_URIIRE(1, 5, true);quit;"
	
	
	# if you intend to reproduce (shards without relevants and bidirectional system of hypotheses)  use
	matlab nodesktop -nodisplay -r "replicate_URIIRE();quit;"
	
	```
	* outputs
		* table 1 - Mean [Minimum, Maximum] Lengths of 95% Confidence Intervals on the System Effect for Different Number of Partitions
		* table 2 - Mean, Shortest, and Longest Lengths of Intervals on the System Effect for TREC-3 Runs and Number of Significantly Different Run Pairs Found for TREC-3




# MACRO-STEP 3
Extend the analyses on the original work, by adding the model md6
* compute anlyses:
 	* table 1 comparison between s.s.d pairs of systems found by different anova approaches
	```
	matlab nodesktop -nodisplay -r "analysis_across_approaches('T08', 'TIP_RNDE_05', 'zero', 3, 'q4', 'bi', 1, 1, 1, 5); quit"
	```
	* table 2
	* table 3-4: 



[1] E.  M.  Voorhees,  D.  Samarov,  and  I.  Soboroff.  2017.   Using  Replicates  inInformation  Retrieval  Evaluation.ACM TOIS36,  2  (September  2017),12:1–12:21.
