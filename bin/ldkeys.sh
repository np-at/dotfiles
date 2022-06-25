#!/bin/zsh


# check if config folder exists where the veracrypt volume should be mounted, if not then attempt to mount
if [[ $EUID -ne 0 ]]; then
  exec sudo --preserve-env "$0" "$@"
  exit $?
fi
od_key_path="OneDrive/tools/keys"
if [[ ! -d /tmp/vc ]]; then
    mkdir -p /tmp/vc
fi
if [[ ! -d ~/.ssh ]]; then
    echo "~/.ssh not found, creating now"
    mkdir -p ~/.ssh
fi
if [[ $(uname -s) == 'Darwin' ]]; then
    echo "darwin";
    veracrypt -t -k "" -m=ts --protect-hidden=no --pim=0 ~/local_keys  ~/.ssh

    # If keep flag is passed, we need to use ntfs-3g to mount filesystem in read/write mode
    if [[ $1 == '-k'  ]]; then

        veracrypt -t -k "" -m=ts --filesystem=none --protect-hidden=no --pim=0 "$HOME/$od_key_path";
        KeysVol=$(VeraCrypt -t -l | grep -e "$od_key_path" |  sed 's/ /\n/g' | grep "/dev/") ;
        sudo ntfs-3g $KeysVol /tmp/vc -o local -o allow_other -o auto_xattr -o auto_cache ;
    else
        veracrypt -t -k "" -m=ts -m=ro --filesystem=none --protect-hidden=no --pim=0 "$HOME/$od_key_path" /tmp/vc ;
        KeysVol=$(VeraCrypt -t -l | grep -e "$od_key_path" |  sed 's/ /\n/g' | grep "/dev/") ;
        sudo ntfs-3g $KeysVol /tmp/vc -o local,ro ;
    fi
    elif [[ $(uname -n) == 'no-buntu' ]]; then
    echo "no-buntu";
    veracrypt -t -k "" -m=ts --protect-hidden=no --pim=0 ~/local_keys ~/.ssh
    if [[ ! -d /tmp/vc ]]; then
        mkdir /tmp/vc;
    fi
    if [[ $1 == '-k' ]]; then
        veracrypt -t -k "" -m=ts --protect-hidden=no --pim=0 "$HOME/$od_key_path" /tmp/vc;
    else
        veracrypt -t -k "" -m=ts -m=ro --protect-hidden=no --pim=0 "$HOME/$od_key_path" /tmp/vc;
    fi

else
    echo "test";
    if [[ ! -d ~/.ssh ]]; then
        echo "~/.ssh not found, creating now"
        mkdir -p ~/.ssh
    fi
    veracrypt -t -k "" -m=nokernelcrypto,ts --protect-hidden=no --pim=0 ~/local_keys  ~/.ssh
    un=['curio']
    un_len = "${#un[@]}"
    declare user_dir_path
    for (( i=0; i<${un_len}; i++ ));
    do
        test_path="/mnt/c/Users/${un[$i]}"
        if [[ -a "$test_path" ]]; then
            key_path="$test_path"
            break
        fi
    done
    if [[ -a "$user_dir_path/$od_key_path" ]]; then
        veracrypt -t -k "" -m=nokernelcrypto,ts --protect-hidden=no --pim=0 "$user_dir_path/$od_key_path" /tmp/vc
    else
        echo "unknown Environment, dismounting all and exiting now"
        veracrypt -t -d
        exit 1
    fi

fi
if [[ -a /tmp/vc/config ]]; then
    sed 's/M\:\/ssh_keys\//~\/\.ssh\//g' /tmp/vc/config \
    | sed 's/C\:\\Windows\\System32\\OpenSSH\\ssh\.exe/ssh/g' \
    | sed 's/\r$//' > ~/.ssh/config

    # set 1Password to handle ssh identities if no-buntu
    if [[ $(uname -n) == 'no-buntu' ]]; then
        sed --in-place -e '1i\
Host * \
    IdentityAgent ~/.1password/agent.sock
        ' ~/.ssh/config
    fi
    cp -r /tmp/vc/ssh_keys/* ~/.ssh
    # fix permissions
    chmod 0600 ~/.ssh/*
else
    echo "config file was not found"
fi

if [[ $1 == '-k'  ]]; then
    echo "keeping veracrypt vol mounted"
    echo $1
    elif [[ $1 == '-d' ]]; then
    echo "mounted vol and copied keys.  dismounting all volumes now (-d flag passed)"
    veracrypt -t -d
else
    echo "dismounting onedrive veracrypt file, keeping local ssh ssh_keys"
    if [[ -d '/private/tmp/vc' ]]; then
        veracrypt -t -d '/private/tmp/vc'
    else
        veracrypt -t -d '/tmp/vc'
    fi
fi



