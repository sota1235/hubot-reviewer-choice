hubot reviewer choice
====

[![Build Status](https://travis-ci.org/sota1235/hubot-reviewer-choice.svg)](https://travis-ci.org/sota1235/hubot-reviewer-choice)
[![npm version](https://badge.fury.io/js/hubot-reviewer-choice.svg)](https://badge.fury.io/js/hubot-reviewer-choice)

Hubot script for choicing code reviewer.

### Description

You can choice code reviewer for some members.

You can also set group of code reviewer.

### Demo

#### choice from arguments

![Image of using 'choice' from arguments]()

#### choice from group

![Image of using 'choice' from group]()

### Requirement

- Node.js v4~6

### Usage

- choice from arguments

```
hubot choice a b c
```

- set code reviewer group

```
hubot choice set <groupename> <group members>
```

- list choice groupe

```
hubot choice list

> reviewers: Sota, Yuya, Kohei
> lunch: Pizza, Pasta, Sushi
```

- delete code reviewer group

```
hubot choice delete <groupename>
```

### Install

```shell
% npm install hubot-reviewer-choice --save
```

#### edit `external-script.json`

```json
["hubot-reviewer-choice"]
```

### Licence

This software is released under the MIT License, see LICENSE.txt.

## Author

[@sota1235](https://github.com/sota1235)
