#!/bin/bash

service redis-server start

redis-cli $@

