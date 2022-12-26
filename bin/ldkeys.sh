#!/bin/bash
declare keep=false
declare local_keys_path="$HOME/local_keys"
declare -i verbose=0
declare dismount=false
declare os
function log_fatal {
	echo "[FATAL] $1"
	exit 1
}
function log_warning {
	echo "[WARNING] $1"
}
function log_info {
	if [[ $verbose -ge 0 ]]; then
		echo "[INFO] $1"
	fi
}
function log_verbose {
	if [[ $verbose -ge 1 ]]; then
		echo "[VRB] $1"
	fi
}
function log_debug {
	if [[ $verbose -ge 2 ]]; then
		echo "[DBG] $1"
	fi
}
# normalize os variant names
function get_os {
	if [[ $(uname -s) == 'Darwin' ]]; then
		echo "darwin"
	elif [[ $(uname -n) == 'no-buntu' ]]; then
		echo "linux"
	elif uname -r | grep --quiet 'microsoft'; then
		echo "wsl"
		# [[ $(uname -r) == 'Microsoft' ]] && [[ $(uname -n) == 'no-buntu'
	elif [[ $(uname -n) == 'test' ]]; then
		echo "test"
	else
		echo "unknown"
	fi
}

# check if keep flag is passed, if so then mount keys in read/write mode
while getopts ":kdv" opt; do
	case $opt in
	d)
		echo "dismount flag passed, will dismount all volumes after copy"
		dismount=true
		;;
	k)
		echo "keep flag passed, mounting keys in read/write mode"
		keep=true
		;;
	v)
		verbose=$((verbose + 1))
		log_debug "verbose flag passed, setting verbose to $verbose"
		;;
	\?)
		log_fatal "Invalid option: -$OPTARG"
		;;
	:)
		log_fatal "Option -$OPTARG requires an argument."
		;;
	*)
		log_fatal "unknown option encountered, exiting"
		;;
	esac
done

os=$(get_os)
log_verbose "normalized os is $os"
# check for valid options
if $keep && $dismount; then
	log_fatal "cannot use both -k and -d flags"
fi

# check for prereqs
declare missing_prereqs=false
if ! command -v veracrypt &>/dev/null; then
	log_warning "veracrypt not found, please install it"
	missing_prereqs=true
elif ! command -v ssh-add &>/dev/null; then
	log_warning "ssh-add not found, please install it"
	missing_prereqs=true
elif ! command -v ssh-keygen &>/dev/null; then
	log_warning "ssh-keygen not found, please install it"
	missing_prereqs=true
elif ! command -v ntfs-3g &>/dev/null; then
	if [[ $os == "darwin" ]]; then
		log_warning "ntfs-3g not found, please install it with brew install ntfs-3g"
	else
		log_warning "ntfs-3g not found, please install it"
	fi
	missing_prereqs=true
fi
if $missing_prereqs; then
	log_fatal "missing prereqs, exiting"
fi

# elevate to root if not already
if [[ $EUID -ne 0 ]]; then
	case $os in
	darwin) ;&

	linux) ;&

	wsl)
		# log_verbose "no need to elevate to root"
		log_verbose "elevating to root"
		exec sudo --preserve-env "$0" "$@"
		exit $?
		;;
	*)
		log_fatal "unknown os encountered, exiting"
		;;
	esac
fi

declare -r od_key_path="OneDrive/tools/keys"
if [[ ! -d /tmp/vc ]]; then
	log_warning "/tmp/vc directory not found, creating now"
	mkdir -p /tmp/vc
fi

if [[ ! -d "$HOME/.ssh" ]]; then
	log_warning "$HOME/.ssh directory not found, creating now"
	mkdir -p "$HOME/.ssh"
	chmod 700 "$HOME/.ssh"
fi

## STEP 1 Check if local_keys volume exists, if not create it
if [[ ! -e $local_keys_path ]]; then
	echo "local keys not found, creating now"
	case $os in
	darwin)
		veracrypt -t -c "$HOME/local_keys"
		;;
	linux)
		veracrypt -t -k "" -c "$HOME/local_keys"
		;;
	wsl)
		veracrypt -t -k "" -m=nokernelcrypto -c "$HOME/local_keys"
		;;
	test)
		log_fatal "test, not implementated"
		;;
	*)
		log_fatal "unknown os encountered, exiting"
		;;
	esac
fi

## STEP 2 Mount local_keys and one drive keys volumes
log_verbose "mounting local_keys volume"
declare local_keys_mounted=false
if veracrypt -t -l | grep --quiet "$HOME/local_keys"; then
	log_warning "local_keys volume already mounted"
	local_keys_mounted=true
fi
case $os in
darwin)
	if ! $local_keys_mounted; then
		if ! veracrypt -t -k "" -m=ts --protect-hidden=no --pim=0 "$HOME/local_keys" ~/.ssh; then
			log_fatal "failed to mount local_keys volume, exiting"
		fi
	fi

	if $keep; then
		if ! veracrypt -t -k "" -m=ts --filesystem=none --protect-hidden=no --pim=0 "$HOME/$od_key_path"; then
			log_fatal "failed to mount OneDrive keys volume, exiting"
		fi
		KeysVol=$(VeraCrypt -t -l | grep -e "$od_key_path" | sed 's/ /\n/g' | grep "/dev/")
	else
		if ! veracrypt -t -k "" -m=ts,ro --filesystem=none --protect-hidden=no --pim=0 "$HOME/$od_key_path" /tmp/vc; then
			log_fatal "failed to open OneDrive keys volume, exiting"
		fi
		KeysVol=$(VeraCrypt -t -l | grep -e "$od_key_path" | sed 's/ /\n/g' | grep "/dev/")
		if ! ntfs-3g "$KeysVol" /tmp/vc -o local,ro; then
			veracrypt -t -d "$HOME/$od_key_path"
			log_fatal "failed to mount Onedrive keys volume, exiting"
		fi
	fi
	;;
linux)
	if ! $local_keys_mounted; then
		if ! veracrypt -t -k "" -m=ts --protect-hidden=no --pim=0 "$HOME/local_keys" "$HOME/.ssh"; then
			log_fatal "failed to mount local_keys volume, exiting"
		fi
	fi
	if [[ ! -d /tmp/vc ]]; then
		mkdir /tmp/vc
	fi
	if $keep; then
		if ! veracrypt -t -k "" -m=ts --protect-hidden=no --pim=0 "$HOME/$od_key_path" /tmp/vc; then
			log_fatal "failed to mount OneDrive keys volume, exiting"
		fi
	else
		if ! veracrypt -t -k "" -m=ts,ro --protect-hidden=no --pim=0 "$HOME/$od_key_path" /tmp/vc; then
			log_fatal "failed to open OneDrive keys volume, exiting"
		fi
	fi

	veracrypt -t -k "" -m=ts --protect-hidden=no --pim=0 "$HOME/local_keys" "$HOME/.ssh"
	if [[ ! -d /tmp/vc ]]; then
		mkdir /tmp/vc
	fi
	if $keep; then
		veracrypt -t -k "" -m=ts --protect-hidden=no --pim=0 "$HOME/$od_key_path" /tmp/vc
	else
		veracrypt -t -k "" -m=ts,ro --protect-hidden=no --pim=0 "$HOME/$od_key_path" /tmp/vc
	fi
	;;
wsl)
	if [[ ! -d "$HOME/.ssh" ]]; then
		echo "$HOME/.ssh not found, creating now"
		mkdir -p ~/.ssh
		chmod 700 ~/.ssh
		chown -R "$USER":"$USER" ~/.ssh
	fi
	if ! $local_keys_mounted; then
		if ! veracrypt -t -k "" -m=nokernelcrypto,ts --protect-hidden=no --pim=0 "$HOME/local_keys" "$HOME/.ssh"; then
			log_fatal "failed to mount local_keys volume, exiting"
		fi
	fi
	log_info "mounted local keys"

	un=('curio' 'np')
	un_len="${#un[@]}"

	declare user_dir_path
	for ((i = 0; i <= un_len; i++)); do
		log_debug "testing ${un[$i]}"
		test_path="/mnt/c/Users/${un[$i]}"
		if [[ -e $test_path ]]; then
			log_verbose "user dir path is $test_path"
			user_dir_path="$test_path"
			break
		fi
	done

	log_verbose "pathcheck is $user_dir_path/$od_key_path"
	if [[ -e "$user_dir_path/$od_key_path" ]]; then
		if $keep; then
			log_verbose "keep flag passed, mounting $user_dir_path/$od_key_path on /tmp/vc as read/write"
			if ! veracrypt -t -k "" -m=nokernelcrypto,ts --protect-hidden=no --pim=0 "$user_dir_path/$od_key_path" /tmp/vc; then
				log_fatal "failed to mount OneDrive keys volume, exiting"
			fi
		else
			log_verbose "keep flag not passed, mounting $user_dir_path/$od_key_path on /tmp/vc as read only"
			if ! veracrypt -t -k "" -m=ts,nokernelcrypto,ro --protect-hidden=no --pim=0 "$user_dir_path/$od_key_path" /tmp/vc; then # --filesystem=none
				log_fatal "failed to mount OneDrive keys volume, exiting"
			fi
		fi
	else
		log_warning "unknown Environment, dismounting all and exiting now"
		veracrypt -t -d
		exit 1
	fi
	;;
esac

### STEP 3: copy ssh keys #######################################################

log_info "copying ssh keys"
if [[ -e /tmp/vc/config ]]; then
	sed 's/M\:\/ssh_keys\//~\/\.ssh\//g' /tmp/vc/config |
		sed 's/C\:\\Windows\\System32\\OpenSSH\\ssh\.exe/ssh/g' |
		sed 's/\r$//' >"$HOME/.ssh/config"
	if [[ $os == 'darwin' ]]; then
		MAC_1P="$(find "$HOME"/Library/Group\ Containers -type d -name "*1password" 2>/dev/null)"
		echo "mac_1p is $MAC_1P"

		sed -i -E "1i\\
Host * \\
    IdentityAgent \"$MAC_1P/t/agent.sock\"
                  " "$HOME/.ssh/config"
		sed -i -E "1i\\
Host github.com\\
    hostname github.com\\
    user git\\
    Identityfile $HOME/.ssh/np_at_gh2\\
    IdentityAgent none\\
" "$HOME/.ssh/config"
	fi
	# set 1Password to handle ssh identities if no-buntu
	if [[ $os == 'linux' ]]; then
		sed --in-place -e '1i\
Host * \
    IdentityAgent ~/.1password/agent.sock
                  ' "$HOME/.ssh/config"
	fi
	cp -r /tmp/vc/ssh_keys/* "$HOME/.ssh"
	# fix permissions

	chmod 0600 "$HOME"/.ssh/*
else
	log_fatal "config file was not found"
fi

if $keep; then
	log_info "keep flag passed, keeping veracrypt volume mounted"
	echo "$1"
elif $dismount; then
	log_info "mounted vol and copied keys.  dismounting all volumes now (-d flag passed)"
	veracrypt -t -d
else
	log_verbose "dismounting onedrive veracrypt file, keeping local ssh ssh_keys"
	if [[ -d '/private/tmp/vc' ]]; then
		veracrypt -t -d '/private/tmp/vc'
	else
		veracrypt -t -d '/tmp/vc'
	fi
fi
