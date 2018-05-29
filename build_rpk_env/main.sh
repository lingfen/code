#!/bin/bash
#
#       DESCRIPTION:    Download the specified code from svn server
#
#       SCRIPT NAME:    gn_checkout_code.sh
#
#       Usage:   gn_checkout_code.sh 
#                
#
#       Input:  stdin
#                       1. alps url
#                       2. apps url
#
#       Output: 
#
#       AUTHOR:         Ling Fen
#
#       EMAIL:          lingfen@gionee.com
#
#       DATE:           2012-11-03
#
#       HISTORY:
#       REVISOR         DATE                    MODIFICATION
#       LingFen         2012-11-03              create

usage(){
printf "
built env for rpk 

Usage : $0 rpk_01.mk

options:
    [--help] Show help message

example: 
"
}

getOptions(){
    opts=$(getopt -o v:g:shad --long version:,debug,help -- "$@")     
    if [ $? -ne 0 ];then
        usage 
        exit 1
    fi

    eval set -- "$opts"
    while true 
    do
        case "$1" in 
            -v|--version)
                RPK_VERSION_NAME=$2
                export RPK_VERSION_NAME
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            --)
                shift
                break
                ;;
            *)
                usage
                exit 1
                ;;
        esac
    done

    GN_BUILD_APP_CONFIG_PATHFILE="$@"
    RPK_BUILD_CONFIG_PATHFILE="$@"
    if [ -f "$RPK_BUILD_CONFIG_PATHFILE" ];then
        RPK_BUILD_CONFIG_PATHDIR=$(cd "$(dirname $RPK_BUILD_CONFIG_PATHFILE)"; pwd -P)  
        RPK_BUILD_CONFIG_PATHFILE=$RPK_BUILD_CONFIG_PATHDIR/$(basename $RPK_BUILD_CONFIG_PATHFILE)
        RPK_BUILD_PROJECT_ROOT=$RPK_BUILD_CONFIG_PATHDIR
    fi
}

setBuildEnv(){
    CURRENT_DIRECTORY=$(pwd -P)
    RPK_BUILD_ENV=$CURRENT_DIRECTORY/env
    RPK_BUILD_OUT=$CURRENT_DIRECTORY/out
    RPK_BUILD_ENV_TOOLS=$CURRENT_DIRECTORY/env/tools
    RPK_BUILD_ENV_TOOLS_PY=$CURRENT_DIRECTORY/env/tools/py
    RPK_BUILD_ENV_NODE_TOOLS=$CURRENT_DIRECTORY/env/node-tools
    cp -r $RPK_BUILD_ENV/sign/release   $RPK_BUILD_PROJECT_ROOT/sign
    export PATH=$RPK_BUILD_ENV_NODE_TOOLS/node-v8.11.2-linux-x64/bin/:$PATH


}

cleanBuildEnv(){
    rm -rf $RPK_BUILD_OUT
    rm -rf $RPK_BUILD_PROJECT_ROOT/build
}

buildRPK(){
    pushd $RPK_BUILD_PROJECT_ROOT >/dev/null
    if [ -n "$RPK_VERSION_NAME" ];then
        $RPK_BUILD_ENV_TOOLS_PY/setVersion.py  -f src/manifest.json  -v $RPK_VERSION_NAME
    fi

    if [ -d "node_modules" ];then
        npm update --force
    else
        npm install
    fi
    npm run release
    popd >/dev/null
}

copyTarget(){
    if [ -f $RPK_BUILD_PROJECT_ROOT/dist/*.rpk ];then
       mkdir -p $RPK_BUILD_OUT
       cp -r $RPK_BUILD_PROJECT_ROOT/dist/*.rpk $RPK_BUILD_OUT
    fi
}
main(){
   getOptions "$@" 
   setBuildEnv
   cleanBuildEnv
   buildRPK 
   copyTarget
}


main "$@"
