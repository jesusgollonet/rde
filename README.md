# rde (remote development environment)
A cloud clone of my local development environment

## What is this?
This is a blueprint and toolchain to spin up a cloud instance that matches my local
development environment. 

## Why?
The main driving factor is enabling doing work from my iPad, which adds
resiliency when working outdoors or far from a power outlet. It has a couple
of nice side effects:
- It enables me to be productive very quickly on any machine as long as it has a terminal and a
  connection
- It forces me to consolidate a recipe for setting up my machine, which speeds
  up the process when getting a new one.
- My personal machine becomes [cattle, not a pet](http://cloudscaling.com/blog/cloud-computing/the-history-of-pets-vs-cattle/).

## General architecture
There are 2 main parts to this:
- Create an image: build an AMI with all the dependencies and
  configuration baked in.
- Spin up an instance: use pulumi to turn the computer on and off.

The current iteration is based on AWS but the implementation is portable to other
cloud vendors.

### Directory structure
- `bin`: top level scripts   
- `images`: packer and shell scripts to bake the AMI
- `instances`: terraform script to spin up instance 
- `keys`: ssh keys. keys are ignored but keeping a directory to have a
  predictable location. 

## How to run?
### Build Image:
```bash
./bin/build-image
```

### Spin up instance (TODO)
```bash
./bin/spin-up
```

### Destroy instance (TODO)
```bash
./bin/spin-down
```

## Dependencies
- Packer >=1.7.10
- Terraform >=1.1.7
- aws-cli >=2.4.7
- jq >=1.6

## Status
WIP

