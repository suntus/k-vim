#!/bin/bash

# refer  spf13-vim bootstrap.sh`
BASEDIR=$(dirname $0)
cd $BASEDIR
CURRENT_DIR=`pwd`

# parse arguments
function show_help
{
    echo "install.sh [option]
    --for-vim       Install configuration files for vim, default option
    --help          Show help messages
For example:
    install.sh --for-vim
    install.sh --help"
}
FOR_VIM=true

lnif() {
    if [ -e "$1" ]; then
        ln -sf "$1" "$2"
    fi
}


echo "Step1: backing up current vim config"
today=`date +%Y%m%d`
if $FOR_VIM; then
    for i in $HOME/.vim $HOME/.vimrc $HOME/.gvimrc $HOME/.vimrc.bundles; do [ -e $i ] && [ ! -L $i ] && mv $i $i.$today; done
    for i in $HOME/.vim $HOME/.vimrc $HOME/.gvimrc $HOME/.vimrc.bundles; do [ -L $i ] && unlink $i ; done
fi

echo "Step2: setting up symlinks"
if $FOR_VIM; then
    lnif $CURRENT_DIR/vimrc $HOME/.vimrc
    lnif $CURRENT_DIR/vimrc.bundles $HOME/.vimrc.bundles
    lnif "$CURRENT_DIR/" "$HOME/.vim"
fi

echo "Step3: update/install plugins using Vim-plug"
system_shell=$SHELL
export SHELL="/bin/sh"
if $FOR_VIM; then
    vim -u $HOME/.vimrc.bundles +PlugInstall! +PlugClean! +qall
fi
export SHELL=$system_shell


echo "Step4: compile YouCompleteMe"
echo "It will take a long time, just be patient!"
echo "If error,you need to compile it yourself"
echo "cd $CURRENT_DIR/bundle/YouCompleteMe/ && python install.py --clang-completer"
cd $CURRENT_DIR/bundle/YouCompleteMe/
git submodule update --init --recursive

# 使用文件中的clang去编译
clang=$CURRENT_DIR/libclang.dylib
if [ `which clang` ]   # check system clang
then
    if [ `uname -s` = "Darwin" ]
    then
        EXTRA_CMAKE_ARGS="-DEXTERNAL_LIBCLANG_PATH=$clang" python install.py --clang-completer
    else
        python install.py --clang-completer --system-libclang   # use system clang
    fi
else
    python install.py --clang-completer
fi

echo "Install Done!"
