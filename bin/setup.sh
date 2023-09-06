#!/bin/bash
declare -i verbosity=0
declare MODE=""
declare FORCE=false

while getopts ":hiuv" opt; do
	case ${opt} in
	h)
		echo "Usage: $0"
		exit 1
		;;
	u)
		MODE="uninstall"
		;;
	i)
		echo "mode: install"
		MODE="install"
		;;
	v)
		verbosity=$((verbosity + 1))
		;;

	\?)
		echo "Invalid option: -${OPTARG}" >&2
		exit 1
		;;
	:)
		echo "Option -${OPTARG} requires an argument." >&2
		exit 1
		;;
	esac
done

# ensure we are in the correct directory
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# ensure logout script in .profile
if [[ ! -f "${HOME}/.profile" ]]; then
	echo "creating ~/.profile"
	touch "${HOME}/.profile"
fi
if ! sed -n '/logout.sh/p' "${HOME}/.profile"; then
	echo "adding logout script to ~/.profile"

	echo "trap '. ${DIR}/logout.sh; exit' 0" >>"${HOME}/.profile"
fi

# Setup tmux
if [[ ! -d ~/.tmux ]]; then
	git clone https://github.com/gpakosz/.tmux.git ~/.tmux
	ln -s -f ~/.tmux/.tmux.conf ~/.tmux.conf
	ln -s -f "${DIR}/../tmux.conf.local" ~/.tmux.conf.local
fi

# make sure undo directory exists for vim
mkdir -p ~/.undodir

function setupZSH() {

	#symlink .zshrc
	ln -s -f "${DIR}/../zshrc" ~/.zshrc

	# Install oh-my-zsh
	if [[ ! -d ~/.oh-my-zsh ]]; then
		echo "${HOME}/.oh-my-zsh not found. Installing..."
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	fi

	# Install zsh-autosuggestions
	if [[ ! -d "${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]]; then
		echo "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions not found. Installing..."
		git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
	fi

	# Install zsh-syntax-highlighting
	if [[ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]]; then
		echo "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting not found. Installing..."
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
	fi

	# setup powerlevel10k
	if [[ ! -d "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
		echo "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k not found. Installing..."
		git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/themes/powerlevel10k"
	fi
}

function installLinuxSpecific() {
	# link chromium-flags
	ln -s -f "${DIR}/../chromium-flags.conf" ~/.config/chromium-flags.conf

	if [[ -n ${FORCE} ]] || [[ ! -L ~/.config/onedrive/config ]]; then
		# link onedrive for linux client config
		mkdir -p ~/.config/onedrive
		ln -s -f "${DIR}/../Linux_Onedrive_Config" ~/.config/onedrive/config
	fi

}

function installHomebrewItems() {
	# install regular homebrew items
	brew install "$(cat brewlist | awk '{ if ($0 ~ /\[casks\]/) { i++; } else {if (i == 0 && $0 !~ /^#/ && $0 !~ /^\s+/ && $0 != "") print $0 } }')"
	# install brew casks
	brew install --cask "$(cat brewlist | awk '{ if ($0 ~ /\[casks\]/) { i++; } else {if (i > 0 && $0 !~ /^#/ && $0 !~ /^\s+/ && $0 != "") print $0 } }')"
}
function runInstall() {
	echo "starting install..."

	setupZSH

	#symlink .vimrc
	if [[ ! -L ~/.vimrc ]]; then
		echo "symlinking ~/.vimrc"
		ln -s -f "${DIR}/../vimrc" ~/.vimrc
	fi

	## nvim
	if [[ ! -L ~/.config/nvim/init.lua ]]; then

		echo "ensuring ~/.config/nvim/lua/custom exists"
		mkdir -p ~/.config/nvim/lua/custom

		echo "Symlinking ~/.config/nvim/init.vim"
		ln -s -f "${DIR}/../nvim.lua" "${HOME}/.config/nvim/init.lua"

		echo "Symlinking ~/.config/nvim/lua/custom/plugins.lua"
		ln -s -f "${DIR}/../plugins.lua" "${HOME}/.config/nvim/lua/custom/plugins.lua"
	fi

	if [[ ! -L ~/.config/fish/config.fish ]]; then

		echo "symlinking fish config to ${HOME}/.config/fish/config.fish"
		ln -s -f "${DIR}/../config.fish" "${HOME}/.config/fish/config.fish"
	fi

	#symlink .alacritty.yml
	if [[ ! -L ~/.alacritty.yml ]]; then
		echo "symlinking ~/.alacritty.yml"
		ln -s -f "${DIR}/../alacritty.yml" "${HOME}/.alacritty.yml"
	fi

}

case ${MODE} in
"install")
	runInstall

	if [[ ${OSTYPE} == "linux-gnu" ]]; then
		installLinuxSpecific
	fi
	;;
"uninstall")
	echo "not implemented yet"
	exit 1
	;;

*)
	echo "neither install nor uninstall specified, exiting with error"
	exit 1
	;;
esac
