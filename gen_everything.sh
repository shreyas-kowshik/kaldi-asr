python gen_wav_scp.py --audio_folder /media/shreyas/Data/ASR_IITB/kaldi/bin/kaldi/egs/digits/digits_audio/train --speakers_file /media/shreyas/Data/ASR_IITB/kaldi/bin/data/speakers.txt --output_file /media/shreyas/Data/ASR_IITB/kaldi/bin/kaldi/egs/digits/data/train/wav.scp --type scp

python gen_wav_scp.py --audio_folder /media/shreyas/Data/ASR_IITB/kaldi/bin/kaldi/egs/digits/digits_audio/train --speakers_file /media/shreyas/Data/ASR_IITB/kaldi/bin/data/speakers.txt --output_file /media/shreyas/Data/ASR_IITB/kaldi/bin/kaldi/egs/digits/data/train/text --type text

python gen_wav_scp.py --audio_folder /media/shreyas/Data/ASR_IITB/kaldi/bin/kaldi/egs/digits/digits_audio/train --speakers_file /media/shreyas/Data/ASR_IITB/kaldi/bin/data/speakers.txt --output_file /media/shreyas/Data/ASR_IITB/kaldi/bin/kaldi/egs/digits/data/train/utt2spk --type utt2spk

python gen_wav_scp.py --audio_folder /media/shreyas/Data/ASR_IITB/kaldi/bin/kaldi/egs/digits/digits_audio/test --speakers_file /media/shreyas/Data/ASR_IITB/kaldi/bin/data/speakers.txt --output_file /media/shreyas/Data/ASR_IITB/kaldi/bin/kaldi/egs/digits/data/test/wav.scp --type scp

python gen_wav_scp.py --audio_folder /media/shreyas/Data/ASR_IITB/kaldi/bin/kaldi/egs/digits/digits_audio/test --speakers_file /media/shreyas/Data/ASR_IITB/kaldi/bin/data/speakers.txt --output_file /media/shreyas/Data/ASR_IITB/kaldi/bin/kaldi/egs/digits/data/test/text --type text

python gen_wav_scp.py --audio_folder /media/shreyas/Data/ASR_IITB/kaldi/bin/kaldi/egs/digits/digits_audio/test --speakers_file /media/shreyas/Data/ASR_IITB/kaldi/bin/data/speakers.txt --output_file /media/shreyas/Data/ASR_IITB/kaldi/bin/kaldi/egs/digits/data/test/utt2spk --type utt2spk
