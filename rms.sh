# private
__is_option()
{
    echo "$( [[ "$1" =~ ^-.*$ ]] && echo 1 || echo 0 )";
}
__are_you_sure()
{
    __yes="YES_IM_SURE";
    if [ -n "$1" ];
    then
        __yes=$1;
    fi
    read -r -p "[$__yes/no] " __response;
    echo "$( [[ $__response =~ ^$__yes$ ]] && echo 1 || echo 0 )";
}
__echo_red()
{
    echo -e "\e[31m$1\e[m"
}

# main
rms()
{
    if [ $# -eq 0 ];
    then
        rm;
        return;
    fi

    echo;
    echo ===== Target =====;
    echo;

    __root_items="";
    for __target in "$@"; do
        __result=$(__is_option $__target);
        if [[ $__result -eq 1 ]];
        then
            continue;
        fi
        if [[ $__target == "/*" ]] || [[ $__target == "/" ]];
        then
            echo Unsafe path=\""$__target"\" provided.;
            return;
        fi
        __target_abs="$(readlink -f "$__target")";

        __path_depth=${__target_abs//[!\/]}
        __path_depth=${#__path_depth};
        if [ $__path_depth -le 1 ];
        then
            __echo_red "$__target_abs";
            __root_items+="$__target_abs";
            __root_items+=" ";
        else
            echo $__target_abs;
        fi
    done
    __root_items=("$__root_items");

    echo;
    echo ==================;
    echo;

    __are_you_sure_message="Are you sure?";
    if [ -n "$__root_items" ];
    then
        __echo_red "⚠️Caution: Attempting to delete files in the root directory.⚠️"
        echo;

        for __root_item in $__root_items; do
            __echo_red "$__root_item"
        done
        echo;

        echo -e "Attempting to \e[31mDELETE\e[m files in the \e[31mROOT\e[m directory.";
        echo -e "This action may have the \e[31mPOTENTIAL\e[m to \e[31mDESTROY\e[m the \e[31mSYSTEM\e[m.";
        echo -e "Are you \e[31mREALLY\e[m sure you want to delete these files?";
        __result=$(__are_you_sure);
        if [ $__result -ne 1 ];
        then
            return;
        fi
        echo;
        __are_you_sure_message="Are you \e[31mREALLY\e[m sure? You will \e[31mDEFINITLY\e[m regret this!"
    fi

    echo -e $__are_you_sure_message;
    __result=$(__are_you_sure);
    if [ $__result -eq 1 ];
    then
        rm -r "$@";
    fi
}

rms "$@"