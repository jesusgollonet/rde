# rde (remote development environment)
A cloud clone of my local development environment

## What is this?
This is a blueprint and toolchain to spin up a cloud instance that matches my local
development environment. 

## Why?
The main driving factor is enabling doing work from my iPad, which adds
resiliency when working outdoors or far from a power outlet. But it has a couple
of nice side effects:
- It enables me to be productive very quickly on any machine as long as it has a terminal and a
  connection
- It forces me to consolidate a recipe for setting up my machine, which speeds
  up the process when getting a new one.
- My personal machine becomes [cattle, not a pet](http://cloudscaling.com/blog/cloud-computing/the-history-of-pets-vs-cattle/).

## General architecture
At this stage the project consists of a packer template that creates an ec2
instance and a terraform configuration to spin it up and down.


## How to run?



## Status
