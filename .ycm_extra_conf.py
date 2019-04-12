#!/usr/bin/env python
# encoding: utf-8

def Settings( **kwargs ):
  return {
    # 'flags': [ '-x', 'c', '-std=c99', '-Werror' ],
    'flags': [ '-x', 'c',
        '-isystem',
        '/usr/local/include/'],
  }
