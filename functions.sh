#!/bin/bash

hello(){
  echo "hello world!"
}

hello_arg(){
  echo "hello world! $1"
}

add_annotation(){
pmm-admin annotate "hello function world $1" --node --tags "$2"
}
