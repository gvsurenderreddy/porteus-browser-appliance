#!/bin/bash

for f in /home/guest/share/modules/*
do
  activate "$f"
done

VBoxControl guestproperty get FIREFOX_SYNCMODE | gawk 'match($0, "Value: (.*)$", a) {print "export FIREFOX_SYNCMODE="(a[1]); }; ' >>  /home/guest/.profile