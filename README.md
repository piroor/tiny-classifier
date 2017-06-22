# README

## Name

tiny-classifier

## Description

On-memory text classifier command line tool, based on naive bayes.

## Install

```
% gem install tiny-classifier
```

If you hope to use `--tokenizer=mecab`, you need to install MeCab like:

```
% sudo apt install mecab mecab-ipadic-utf8
```

This is example on Ubuntu.

## Basic usage

Training:

```
% echo "Hello, world!"        | tc-train --labels=positive,negative positive
% echo "I'm very very happy!" | tc-train --labels=positive,negative positive
% echo "I'm so bad..."        | tc-train --labels=positive,negative negative
% echo "Oh my god!"           | tc-train --labels=positive,negative negative
```

The training data will be saved as `tc.negative-positive.dat` (`tc.` is the fixed prefix, `.dat` is the fixed suffix. The middle part is filled by given labels automatically.) in the current directory. If you hope the file to be saved in any different place, please specify `--base-dir=/path/to/data/directory`.

Testing to classify:

~~~
% echo "Happy day?" | tc-classify --labels=positive,negative
positive
~~~

If you think that the classifier has been enoughly trained, then you can generate a fixed classifier:

~~~
% tc-generate-classifier --labels=positive,negative --output-dir=/path/to/dir
~~~

Then a fixed classifier (executable Ruby script) will be generated as `tc-classify-negative-positive` (`tc-classify-` is the fixed prefix, rest is filled by given labels automatically.) 

~~~
% ls /path/to/dir/
tc-classify-negative-positive
% echo "Happy day?" | /path/to/dir/tc-classify-negative-positive
positive
~~~

## Command line parameters

### Common

`-l`, `--labels=LABELS` (required)
:  A comman-separated list of labels. You should use only alphabetic characters. (Non-alphabetical characters will cause problems.)

`-d`, `--data-dir=PATH` (optional)
: The path to the directory that the training data to be saved. The current directory is the default value.

`-t`, `--tokenizer=TOKENIZER` (optional)
: Tokenizer for input which is not separated by whitespaces. Possible values are: only `mecab`.

### `tc-train` specific parameters

The `tc-train` requires one command line argument: the label. You need to specify one of labels given via the `--labels` parameter.

### `tc-generate-classifier` specific parameters

`-o`, `--output-dir=PATH` (optional)
: The path to the directory that the classifier to be saved. The current directory is the default value.

## Copyright

Copyright (c) 2017 YUKI "Piro" Hiroshi

## License

GPLv3 or later. See LICENSE.txt for details.
