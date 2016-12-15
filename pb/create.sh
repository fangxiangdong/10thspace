#!/bin/sh
SRC_DIR=./
DST_DIR=./gen

#C++
mkdir -p $DST_DIR/cpp
/home/neil/tools/protobuf-2.6.1/protobuf/bin/protoc -I=$SRC_DIR --cpp_out=$DST_DIR/cpp/ $SRC_DIR/*.proto

#JAVA
mkdir -p $DST_DIR/java
/home/neil/tools/protobuf-2.6.1/protobuf/bin/protoc -I=$SRC_DIR --java_out=$DST_DIR/java/ $SRC_DIR/*.proto

#Objective-C
mkdir -p $DST_DIR/oc
/home/neil/tools/protobuf-2.6.1/protobuf/bin/protoc -I=$SRC_DIR --objc_out=$DST_DIR/oc/ $SRC_DIR/*.proto

#PYTHON
mkdir -p $DST_DIR/python
/home/neil/tools/protobuf-2.6.1/protobuf/bin/protoc -I=$SRC_DIR --python_out=$DST_DIR/python/ $SRC_DIR/*.proto
