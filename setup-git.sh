#!/bin/bash

echo Name?
read name
echo Email?
read email

if [ "$name" != "" ] && [ "$email" != "" ]; then
	git config --global user.name "$name"
	git config --global user.email "$email"
	git config --global credential.helper store
fi
