# README

## Name

tiny-classifier

## Description

Command line tool to run text classifier based on naive bayes.

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

Classifying:

~~~
% echo "Happy day?" | tc-classify --labels=positive,negative
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

### Trainer

The `tc-train` requires one command line argument: the label. You need to specify one of labels given via the `--labels` parameter.

## Copyright

Copyright (c) 2017 YUKI "Piro" Hiroshi

## License

GPLv3 or later. See LICENSE.txt for details.
