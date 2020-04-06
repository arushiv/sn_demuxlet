#!/bin/bash

nextflow -C path/to/nextflow.config run path/to/main.nf -params-file library-config.json -with-report report.html -with-timeline time.html -resume -with-trace trace.txt -with-dag dag.html
