Follow this overall : https://kaldi-asr.org/doc/tutorial_setup.html

git clone https://github.com/kaldi-asr/kaldi.git
cd kaldi
cd tools
bash extras/check_dependencies.sh
# Install any dependencies based on output
make
cd ../src
./configure # If cuda version not supoprted and only cpu build then do below
# ./configure --use-cuda=no
