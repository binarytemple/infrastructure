#!/bin/sh

install_dir=$(dirname $0)

ansible-playbook "${install_dir}/books/${@}.yml"
