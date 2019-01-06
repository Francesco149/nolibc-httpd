#!/bin/sh

gcc \
  -std=c89 -pedantic \
  -Wall -Werror \
  -s -Os -no-pie \
  -nostdlib \
  -ffreestanding \
  -fno-stack-protector \
  -fdata-sections \
  -fno-unwind-tables \
  -fno-asynchronous-unwind-tables \
  -ffunction-sections \
  -Wl,-n \
  -Wl,--gc-sections \
  -Wl,--build-id=none \
  start.S httpd.c \
  -o httpd &&
strip -R .comment httpd
