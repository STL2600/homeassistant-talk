#!/bin/bash
pandoc -t revealjs -s --slide-level 2 -V revealjs-url=https://unpkg.com/reveal.js@3.9.2/ talk.md -o talk.html
