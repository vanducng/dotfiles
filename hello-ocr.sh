#!/bin/bash
greet() {
  name=$1
  echo Hello $name
}
greet $USER
