"""
Go through a folder of audio files and generate a wav.scp file required by Kaldi

Reference Usage :
```
python gen_wav_scp.py \\
    --audio_folder /media/shreyas/Data/ASR_IITB/kaldi/bin/kaldi/egs/digits/digits_audio/test \\
    --speakers_file /media/shreyas/Data/ASR_IITB/kaldi/bin/data/speakers.txt \\
    --output_file /media/shreyas/Data/ASR_IITB/kaldi/bin/kaldi/egs/digits/data/test/utt2spk \\
    --type utt2spk
```
"""

import argparse
import os


STR2NUM = {
    '0':'zero',
    '1':'one',
    '2':'two',
    '3':'three',
    '4':'four',
    '5':'five',
    '6':'six',
    '7':'seven',
    '8':'eight',
    '9':'nine'
}

def identify_speaker(fname, speaker_ids):
    for id in speaker_ids:
        if id in fname:
            return id
    
    return ""

def strip_extension(x):
    return x.split('.')[0]

if __name__=='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-a", "--audio_folder", type=str)
    parser.add_argument("-s", "--speakers_file", type=str)
    parser.add_argument("-o", "--output_file", type=str)
    parser.add_argument("-t", "--type", type=str, default="scp")
    args = parser.parse_args()

    lines = None
    with open(args.speakers_file, 'r') as f:
        lines = f.readlines()

    speaker_ids = []
    for line in lines:
        speaker_ids.append(line.split('\n')[0])
    
    # print(speaker_ids)

    f = open(args.output_file, 'w')

    for speaker_folder in sorted(os.listdir(args.audio_folder)):
        audio_path = os.path.join(args.audio_folder, speaker_folder)

        for audio_file in sorted(os.listdir(audio_path)):
            speaker_id = identify_speaker(audio_file, speaker_ids)
            utterance_id = speaker_id + '_' + strip_extension(audio_file)
            audio_file_with_path = os.path.join(audio_path, audio_file)

            if args.type == "scp":
                f.write(utterance_id + ' ' + audio_file_with_path + '\n')
            elif args.type == "text":
                f.write(utterance_id + ' ' + STR2NUM[audio_file[0]] + '\n')
            elif args.type == "utt2spk":
                f.write(utterance_id + ' ' + speaker_id + '\n')
    
    f.close()
