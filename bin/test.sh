#!/bin/bash
echo "Content-Type: text/plain"
echo ""
echo "CGI Test Script Working"
echo "Current date: $(date)"
echo "Environment: $(env | sort)"
