# Use Kaldi for ASR

Original repository : https://github.com/kaldi-asr/kaldi

This runs a basic example on custom data following : https://kaldi-asr.org/doc/kaldi_for_dummies.html#kaldi_for_dummies_tools

https://kaldi-asr.org/doc/kaldi_for_dummies.html
OpenFST installation : https://aghriss.github.io/posts/2018/01/01/OpenFSTubuntu.html
See slides IITB-ASR for OpenFST commands
Visualise FST : fstdraw HCLG.fst | dot -Tpdf > A.pdf

Idea :
The fst files are created based on phones.txt and words.txt as the input symbol tables. Basically each phone and word is mapped to integer id values and used in the FST. Can check the L.fst and G.fst rendered as pdfs to see the input and output mappings from phones to words and to the language model.

Kaldi Common Errors :
https://groups.google.com/g/kaldi-help/c/J1eobWsDMZo
https://groups.google.com/g/kaldi-help/c/mtzOAmWOoR8

Start Training : `bash run.sh` from `egs/digits`

Model : `*.mdl` file

## Notes from the full tutorial

Link : https://kaldi-asr.org/doc/tutorial_looking.html

The directory "tools/' is where we install things that Kaldi depends on in various ways. OpenFST is also installed here.

### OpenFST

Two files needed to create a FST : `isyms.txt` and `osyms.txt`. `isyms.txt` : Input alphabet to integer id mapping. Similar in `osyms.txt` as well. These are called `symbol tables`.

```
# arc format: src dest ilabel olabel [weight]
# final state format: state [weight]
# lines may occur in any order except initial state must be first line
# unspecified weights default to 0.0 (for the library-default Weight type)
cat >text.fst <<EOF
0 1 a x .5
0 1 b y 1.5
1 2 c z 2.5
2 3.5
EOF
```

Next create a binary-format FST:

`fstcompile --isymbols=isyms.txt --osymbols=osyms.txt text.fst binary.fst`

Let's execute an example command:

`fstinvert binary.fst | fstcompose - binary.fst > binary2.fst`

The resulting WFST, binary2.fst, should be similar to binary.fst but with twice the weights.

Print fst : `fstprint --isymbols=data/lang/phones.txt --osymbols=data/lang/words.txt data/lang/L.fst`


Look at the `src/` directory and documentaion in case you would be making changes to the source.




## Notes from Daniel Povey's lectures
Link : https://www.danielpovey.com/kaldi-lectures.html

Basic Idea : Open `run.sh` and read through the script

Important files as present in `data/train` i.e. `egs/{datasetname}/s5/` :
`spk2gender`, `spk2utt`, `text`, `utt2spk`, `wav.scp`

Most files map utterance-id and speaker-id to other things.

```
# Needs to be prepared by hand (or using self written scripts):
#
# spk2gender  [<speaker-id> <gender>]
# wav.scp     [<uterranceID> <full_path_to_audio_file>]
# text        [<uterranceID> <text_transcription>]
# utt2spk     [<uterranceID> <speakerID>]
# corpus.txt  [<text_transcription>]
```

`Table` Concept : A table is a collection of objects indexed by a string (non-empty, space free string). Eg.  a collection of matrices indexed by utteranceid, representing features.

Tables are stored on disk in two ways :
* `scp` or script meachanism : .scp file specifies mapping from key (the string) to filename or pipe
```
trn_adg04_sr009 /foo/rm1_audio1/rm1/ind_trn/adg0_4/sr009.wav
```
* `ark` or archive mechanism : data is all in one file with utterance-ids. Binary Format cannot be viewed as text.
```
trn_adg04_sr009 SHOW THE GRIDLEY+S TRACK IN BRIGHT ORANGE
```

`wspecifier` : determines how to write a table, `rspecifier` : determines how to read a table

wspecifier meaning
ark:foo.ark Write to archive “foo.ark”
scp:foo.scp Write to files using mapping in foo.scp
ark:- Write archive to stdout
ark,t:|gzip -c >foo.gz Write text-form archive to foo.gz
ark,t:- Write text-form archive to stdout
ark,scp:foo.ark,foo.scp Write archive and scp file (see below)

rspecifier meaning
ark:foo.ark Read from archive foo.ark
scp:foo.scp Read as specified in foo.scp
ark:- Read archive from stdin
ark:gunzip -c foo.gz| Read archive from foo.gz
ark,s,cs:- Read archive (sorted) from stdin...



Think of it this way : Tables store data in a specific form and they are read/written based on the above conventions.

See more details on Tables if required

* Feature Extraction

```
featdir=mfcc_feats ## Note: put this somewhere with disk space
for x in train test_mar87 test_oct87 test_feb89 test_oct89 \
 test_feb91 test_sep92; do
 steps/make_mfcc.sh data/$x exp/make_mfcc/$x $featdir 4
 #steps/make_plp.sh data/$x exp/make_plp/$x $featdir 4
done
```

Puts features e.g. in data/train/feats.scp

```
head data/train/feats.scp
trn_adg04_sr009 /home/dpovey/data/kaldi_rm_feats/raw_mfcc_train.1.ark:16
trn_adg04_sr049 /home/dpovey/data/kaldi_rm_feats/raw_mfcc_train.1.ark:23395
trn_adg04_sr089 /home/dpovey/data/kaldi_rm_feats/raw_mfcc_train.1.ark:37310
```

Computes NUM_FRAMESx13 matrix for each utterance

Look into `steps/make_mfcc.sh` :

```
$ head -1 exp/make_mfcc/train/make_mfcc.1.log
compute-mfcc-feats --verbose=2 --config=conf/mfcc.conf \
 scp:exp/make_mfcc/train/wav1.scp \
 ark,scp:/data/mfcc/raw_mfcc_train.1.ark,/data/mfcc/raw_mfcc_train.1.scp 
```

First Argument : How to find filenames (utterances to actual audio files)
Second Argument : Write to an arhive with utterance-id mapped to a NUM_FRAMESx13 matrix and write another scp file mapping utterance-id to this archive file. The archive file is written as a binary and hence not interpretable in a text format. The values `raw_mfcc_train.1.ark:23395` as in the number 23395 here is the line number in the file (seems like, better to check).

Tables are defined on `Holder` types which have custom implmentaions of methods that tables use.

* Monophone Training Steps

Setup paths in `path.sh` :

```
$ . path.sh ## set up your path-- will be needed later.
$ steps/train_mono.sh data/train.1k data/lang exp/mono
$ local/decode.sh --mono steps/decode_deltas.sh exp/mono/decode
```

`steps/train_mono.sh data/train.1k data/lang exp/mono` : Output saved to `exp/mono`

Steps in `train_mono.sh` :
1. Cepstral Normalization : Normalize cepstral coefficients of each speaker by mean and variance. Output statistics first in binary format as a archive table file.
```
$ cat exp/mono/cmvn.log
compute-cmvn-stats --spk2utt=ark:data/train.1k/spk2utt scp:data/train.1k\
/feats.scp ark:exp/mono/cmvn.ark
````

Viewing Statistics  `$ copy-matrix ark:exp/mono/cmvn.ark ark,t:- | head`

2. Model Initialization
```
$ head exp/mono/init.log
gmm-init-mono '--train-feats=ark:apply-cmvn --norm-vars=false --
utt2spk=ark:data/train.1k/utt2spk ark:exp/mono/cmvn.ark scp:data/train.1k/
feats.scp ark:- | add-deltas ark:- ark:- | subset-feats --n=10 ark:-
ark:-|' data/lang/topo 39 exp/mono/0.mdl exp/mono/tree
```

Input Topology in : `data/lang/topo` and dimension is `39`, Outputs : `O.mdl`, `tree` which is phoenetic-context decision tree (no splits in monophone case)

Viweing monophone tree : `$ draw-tree data/lang/phones.txt exp/mono/tree | \
 dot -Tps -Gsize=8,10.5 | ps2pdf - ~/tree.pdf`

Details in Topology :
* Specifies 3-state left-to-right HMM, and default transition probs (before training)
* Separate topology for silence (5 states, more transitions)

3. Compile Training Graphs
Done for each utterance separately. Stored to an arhive file. Encodes HMM structure for each training utterance.

These are precompiled and saved to file `exp/mono/fsts.1.gz`. All logs present in `exp/mono/log`.

```
$ cat exp/mono/compile_graphs.log
compile-train-graphs exp/mono/tree exp/mono/0.mdl data/lang/L.fst ark:exp/
mono/train.tra 'ark:|gzip -c >exp/mono/graphs.fsts.gz'
LOG (compile-train-graphs:main():compile-train-graphs.cc:150) compiletrain-graphs: succeeded for 1000 graphs, failed for 0

```

Archive format is: (utt-id graph utt-id graph...)
Graph format is:
from-state to-state input-symbol output-symbol cost
Costs include pronunciation probs, but for training
graphs, not transition probs (added later).

Symbols in graphs : Not PDF-ids directly but transition ids. See documentation for more information

4. Aligment Stage
```
$ Extract from steps/train_mono.sh
align-equal-compiled "ark:gunzip -c $dir/graphs.fsts.gz|" "$feats" \
 ark:- 2>$dir/align.0.log | \
 gmm-acc-stats-ali --binary=true $dir/0.mdl "$feats" ark:- \
 $dir/0.acc 2> $dir/acc.0.log 
```

Produces equally spaced alignments at the start. Uses the HMM topology graph constructed from the step before and the features computed.

Alignment is a vector of ints (per utterance)

Use Viterbi for best state sequence/path instead of Forward-Backward.

<b>Look at `exp/mono/log` to see the commands run and where intermediate results are saved.</b>

Files seem to be saved to `0.*.acc` of some sorts.

5. Update Stage and Train
```
$ cat exp/mono/update.0.log
gmm-est --min-gaussian-occupancy=3 --mix-up=70 --power=0.25 exp/mono/0.mdl 'gmm-sum-accs - exp/mono/0.*.acc|' exp/mono/1.mdl 
```

Initial model : `exp/mono/0.mdl`, Final model : `exp/mono/1.mdl`, Alignment information : `exp/mono/0.*.acc`

Viewing Models :
```
$ gmm-copy --binary=false exp/mono/30.mdl - | head
gmm-copy --binary=false exp/mono/30.mdl - 
```

<b> Model Building Schedule </b>

As in `steps/train_mono.sh`

```
beam=6 # will change to 10 below after 1st pass
# note: using slightly wider beams for WSJ vs. RM.
x=1
while [ $x -lt $num_iters ]; do
  echo "$0: Pass $x"
  if [ $stage -le $x ]; then
    if echo $realign_iters | grep -w $x >/dev/null; then
      echo "$0: Aligning data"
      mdl="gmm-boost-silence --boost=$boost_silence `cat $lang/phones/optional_silence.csl` $dir/$x.mdl - |"
      $cmd JOB=1:$nj $dir/log/align.$x.JOB.log \
        gmm-align-compiled $scale_opts --beam=$beam --retry-beam=$[$beam*4] --careful=$careful "$mdl" \
        "ark:gunzip -c $dir/fsts.JOB.gz|" "$feats" "ark,t:|gzip -c >$dir/ali.JOB.gz" \
        || exit 1;
    fi
    $cmd JOB=1:$nj $dir/log/acc.$x.JOB.log \
      gmm-acc-stats-ali  $dir/$x.mdl "$feats" "ark:gunzip -c $dir/ali.JOB.gz|" \
      $dir/$x.JOB.acc || exit 1;

    $cmd $dir/log/update.$x.log \
      gmm-est --write-occs=$dir/$[$x+1].occs --mix-up=$numgauss --power=$power $dir/$x.mdl \
      "gmm-sum-accs - $dir/$x.*.acc|" $dir/$[$x+1].mdl || exit 1;
    rm $dir/$x.mdl $dir/$x.*.acc $dir/$x.occs 2>/dev/null
  fi
  if [ $x -le $max_iter_inc ]; then
     numgauss=$[$numgauss+$incgauss];
  fi
  beam=10
  x=$[$x+1]
done
```

Note `0.*.acc` is removed after first iteration and so in other iterations hence intermediate values of alignments is not preserved.

Use delta features along with MFCC (Takes into account dynamics of the speech signal).

```
feats="ark,s,cs:apply-cmvn $cmvn_opts --utt2spk=ark:$sdata/JOB/utt2spk scp:$sdata/JOB/cmvn.scp scp:$sdata/JOB/feats.scp ark:- | add-deltas ark:- ark:- |"
```

This is used as `$feats` during training as in :

```
gmm-acc-stats-ali  $dir/$x.mdl "$feats" "ark:gunzip -c $dir/ali.JOB.gz|" \
      $dir/$x.JOB.acc || exit 1;
```

6. Decode

Find best sentence given the model.

`steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/tri1/graph data/test exp/tri1/decode`

Can pass in custom folders as paths to get results.

Decoding script as seen in `steps/decode.sh` generates a word lattice.
Skimminng through, first it checks if transforms to features are required and applies if so.

These are rescored with different acoustic scales
and all the WERs are printed out.
We generally quote the best one
It’s considered more proper to use a “dev set”.

These form the `wer_*` files.
The `wer_*` files are computed in `local/score.sh`. It reads lattices saved to `exp/mono/decode/lat.*.gz` and runs a loop through parameters `min_lmwt:max_lmwt` as defined in the script.

Viewing all `wer_*` files : ` grep WER exp/mono/decode/wer_*`

See lectures 3 and 4 code details as and when need arises.

### Lecture 3

Simplest model for context dependency : Build separate model for each triphone context : N^3 models to train thus too many parameters

Generally train a monophone model. After this use it align a lot of data (if more available than training then do it) and use these alignemnts to initialise triphone model.

Summary statistics for the triphones are obtained and decision tree is constructed by obtaining splits that increase the log likelihood thus clustering states.

### Lecture 4


Viterbi with beam pruning : Beam-pruning accesses the frames one by one and prunes away states with score worse than best-score minus beam. For reasonable beam values this gives good results.

```
$ less scripts/decode.sh
#!/bin/bash
# This is somewhat simplified:
script=$1
decode_dir=$2
# (1) Make the decoding graph
scripts/mkgraph.sh data/lang_test $dir $dir/graph
# (2) Decode the various different test sets (of Resource Management)
for test in mar87 oct87 feb89 oct89 feb91 sep92; do
 $script $dir data/test_$test data/lang $decode_dir_1/$test &
done
```

Language models used with backoff and ARPA formats.
ARPA Format : https://cmusphinx.github.io/wiki/arpaformat/#:~:text=Statistical%20language%20describe%20probabilities%20of,text%20format%20called%20ARPA%20format.

3 extra tokens in vocabular : `<s>` sentence begin, `</s>` sentence end, `<unk>` unknown word
In a N-gram language model, generally all N-1 grams have a backoff weight associated with them.
Katz Backoff Smoothing : https://www.cse.iitb.ac.in/~pjyothi/cs753/slides/lecture10.pdf
Basic Idea : If N-gram counts are not available then use backoff weight for N-1 gram, if again not available then go for N-2 gram and so on recursively till value found.

General ARPA format :

```
P(N-gram sequence) sequence BP(N-gram sequence)
```

In general probabilities replaced by log_base10 values.

Example :

```
\data\
ngram 1=7
ngram 2=7

\1-grams:
-1.0000 <unk> -0.2553
-98.9366 <s>   -0.3064
-1.0000 </s>   0.0000
-0.6990 wood   -0.2553
-0.6990 cindy -0.2553
-0.6990 pittsburgh    -0.2553
-0.6990 jean   -0.1973

\2-grams:
-0.2553 <unk> wood
-0.2553 <s> <unk>
-0.2553 wood pittsburgh
-0.2553 cindy jean
-0.2553 pittsburgh cindy
-0.5563 jean </s>
-0.5563 jean wood 

\end\
```

We actually don’t do Viterbi, we generate
“lattices” (a graph-based record of the most likely
utterances)
These are later rescored at various acoustic
weights, and we pick the best.
The option for the acoustic scale during lattice
generation only affects pruning behavior.