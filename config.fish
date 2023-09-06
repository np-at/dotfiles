﻿## Set values
# Hide welcome message
set fish_greeting
set VIRTUAL_ENV_DISABLE_PROMPT "1"
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

switch (uname)
    case Linux
            echo Hi Tux!
    case Darwin
            # echo Hi Hexley!
    case FreeBSD NetBSD DragonFly
            echo Hi Beastie!
    case '*'
            echo Hi, stranger!
end
## Export variable need for qt-theme
if type "qtile" >> /dev/null 2>&1
   set -x QT_QPA_PLATFORMTHEME "qt5ct"
end

# Set settings for https://github.com/franciscolourenco/done
set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low


## Environment setup
# Apply .profile: use this to put fish compatible .profile stuff in
if test -f "$HOME/.fish_profile"
  source "$HOME/.fish_profile"
end

# Add ~/.local/bin to PATH
if test -d "$HOME/.local/bin"
    if not contains -- "$HOME/.local/bin" $PATH
        set -p PATH "$HOME/.local/bin"
    end
end

# Add depot_tools to PATH
if test -d ~/Applications/depot_tools
    if not contains -- "$HOME/Applications/depot_tools" $PATH
        set -p PATH "$HOME/Applications/depot_tools"
    end
end


## Starship prompt
## if non interactive or not running in ITERM2, don't bother initiliazing
if status --is-interactive && test -n "$ITERM_PROFILE"
   if test -f /usr/bin/starship
    source ("/usr/bin/starship" init fish --print-full-init | psub)
   else if test -f /usr/local/bin/starship
     source ("/usr/local/bin/starship" init fish --print-full-init | psub)
   else if test -f /opt/homebrew/bin/starship		
     source ("/opt/homebrew/bin/starship" init fish --print-full-init | psub)
   else
       echo "fail!"
       exit 1
   end
end

## Advanced command-not-found hook
if test -f /usr/share/doc/find-the-command/ftc.fish
  source /usr/share/doc/find-the-command/ftc.fish
end


## Functions
# Functions needed for !! and !$ https://github.com/oh-my-fish/plugin-bang-bang
function __history_previous_command
  switch (commandline -t)
  case "!"
    commandline -t $history[1]; commandline -f repaint
  case "*"
    commandline -i !
  end
end

function __history_previous_command_arguments
  switch (commandline -t)
  case "!"
    commandline -t ""
    commandline -f history-token-search-backward
  case "*"
    commandline -i '$'
  end
end

if [ "$fish_key_bindings" = fish_vi_key_bindings ];
  bind -Minsert ! __history_previous_command
  bind -Minsert '$' __history_previous_command_arguments
else
  bind ! __history_previous_command
  bind '$' __history_previous_command_arguments
end

# Fish command history
function history
    builtin history --show-time='%F %T '
end

function backup --argument filename
    cp $filename $filename.bak
end

# Copy DIR1 DIR2
function copy
    set count (count $argv | tr -d \n)
    if test "$count" = 2; and test -d "$argv[1]"
	set from (echo $argv[1] | trim-right /)
	set to (echo $argv[2])
        command cp -r $from $to
    else
        command cp $argv
    end
end

## Useful aliases
# Replace ls with eza
alias ls='eza -al --color=always --group-directories-first --icons' # preferred listing
alias la='eza -a --color=always --group-directories-first --icons'  # all files and dirs
alias ll='eza -l --color=always --group-directories-first --icons'  # long format
alias lt='eza -aT --color=always --group-directories-first --icons' # tree listing
alias l.="eza -a | egrep '^\.'"                                     # show only dotfiles

# Replace some more things with better alternatives
alias cat='bat --style header --style rule --style snip --style changes --style header'
[ ! -x /usr/bin/yay ] && [ -x /usr/bin/paru ] && alias yay='paru'

# Common use
alias grubup="sudo update-grub"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias tarnow='tar -acf '
alias untar='tar -zxvf '
alias wget='wget -c '
alias rmpkg="sudo pacman -Rdd"
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias upd='/usr/bin/update'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias hw='hwinfo --short'                                   # Hardware Info
alias big="expac -H M '%m\t%n' | sort -h | nl"              # Sort installed packages according to size in MB
alias gitpkg='pacman -Q | grep -i "\-git" | wc -l'			# List amount of -git packages

# Get fastest mirrors
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

# Help people new to Arch
alias apt='man pacman'
alias apt-get='man pacman'
alias please='sudo'
alias tb='nc termbin.com 9999'

# Cleanup orphaned packages
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'

# Get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# Recent installed packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"


## Run paleofetch if session is interactive
if status --is-interactive
  if test -n "$ITERM_PROFILE"
     neofetch
  end
end

set -p EDITOR vim


alias lynx="lynx -cfg=$HOME/.config/lynx.cfg"


# if test -d ~/.platformio/penv/bin
#   if not contains -- ~/platformio/penv/bin $PATH
#     set -p PATH ~/.platformio/penv/bin
#   end
# end
if test -d /usr/local/go/bin
 if not contains -- /usr/local/go/bin $PATH
        set -p PATH /usr/local/go/bin
  end
end
if test -d "$HOME/go/bin"
 if not contains -- "$HOME/go/bin" $PATH
   set -p PATH "$HOME/go/bin"
 end
end


# # using cntl+delete will delete whole word
function fish_user_key_bindings
    switch $TERM
        case rxvt-unicode-256color
            echo "error"
            # bind \cH backward-kill-path-component
        case xterm-256color
            bind \b backward-kill-path-component
    end
end


if test -d ~/.myprofile
  alias vs ~/.myprofile/bin/ldkeys.sh
else if test -d ~/.dotfiles
  alias vs ~/.dotfiles/bin/ldkeys.sh
else
  echo "WARN: unable to locate dotfile directory"
end


# # set os specific stuff
switch (uname)
    case Linux
                        
            alias sy "/usr/bin/onedrive --synchronize"
            alias which 'alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
    case Darwin

            if test -d /Applications/VeraCrypt.app/Contents/MacOS
              if not contains -- /Applications/VeraCrypt.app/Contents/MacOS
                set -p PATH /Applications/VeraCrypt.app/Contents/MacOS
              end
            end
            if test -e /Users/np/.iterm2_shell_integration.fish
              source /Users/np/.iterm2_shell_integration.fish;
            end
            
            fish_add_path /opt/homebrew/bin            
            fish_add_path /opt/homebrew/sbin
            fish_add_path "$HOME/Library/Python/3.11/bin"
            alias safari="open -a safari"
            alias firefox="open -a firefox"
            alias opera="open -a opera"
            alias chrome="open -a google\ chrome"
            alias canary="open -a google\ chrome\ canary"
            # mactex path_helper
            # set PATH "$(/usr/libexec/path_helper)"
  ## BROWSER STUFF 
            # Launch installed browsers for a specific URL
            # Usage: browsers "http://www.google.com"
            function browsers
            	chrome $1
            	# opera $1
            	firefox $1
            	safari $1
            end

            # Start an HTTP server from a directory, optionally specifying the port
            function server
                set -q argv[1]; or set argv[1] 8000
              
            	set --local port "$argv[1]"
            	open "http://localhost:$port/"
            	# Set the default Content-Type to `text/plain` instead of `application/octet-stream`
            	# And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)

            	python3 -c 'import http.server,sys
ext_map = http.server.SimpleHTTPRequestHandler.extensions_map
ext_map[""] = "text/plain"
for key, value in ext_map.items():
    ext_map[key] = value + ";charset=UTF-8"
s = http.server.HTTPServer(server_address=("", int(sys.argv[1])), RequestHandlerClass=http.server.SimpleHTTPRequestHandler)
try:
    s.serve_forever()
except KeyboardInterrupt:
    pass

' "$port"
            end
            


    case FreeBSD NetBSD DragonFly
            echo Hi Beastie!
    case '*'
            echo Hi, stranger!
end

set -gx MOCWORD_DATA /usr/share/mocword_data.sqlite

if test -d /usr/local/opt/gnu-tar/libexec/gnubin
  if not contains -- /usr/local/opt/gnu-tar/libexec/gnubin
    set -p PATH /usr/local/opt/gnu-tar/libexec/gnubin
  end
end

if test -d "$HOME/.dotnet/tools"
  if not contains -- "$HOME/.dotnet/tools"
    set -p PATH "$HOME/.dotnet/tools"
  end
end
if test -d "$HOME/.cargo/bin"
  if not contains -- "$HOME/.cargo/bin"
    set -p PATH "$HOME/.cargo/bin"
  end
end
# rvm default

if test -d ~/esp/xtensa-esp32-elf/bin
  if not contains -- "$HOME/exp/xtensa-esp32-elf/bin"
    set -p PATH "$HOME/esp/xtensa-esp32-elf/bin"
  end
end

fish_add_path /usr/local/sbin



if test -d "$HOME/.wdm/drivers/chromedriver"
  if not contains -- "$HOME/.wdm/drivers/chromedriver"
    set -p PATH "$HOME/.wdm/drivers/chromedriver"
  end
end




function urlencode
  set str (string join ' ' $argv)

  for c in (string split '' $str)
    if string match -qr '[a-zA-Z0-9.~_-]' $c
      env LC_COLLATE=C printf "$c"
    else
      env LC_COLLATE=C printf '%%%02X' "'$c"
    end
  end
end

function urldecode
    set url_encoded (string replace -a '+' ' ' $argv[1])
    printf '%b' (string replace -a '%' '\\x' $url_encoded)
end
nvm use --silent

# pnpm
set -gx PNPM_HOME "/Users/np/Library/pnpm"
set -gx PATH "$PNPM_HOME" $PATH


# pnpm endop completion fish | source
op completion fish | source



# Copy w/ progress
function cp_p 
  rsync -WavP --human-readable --progress argv[1] argv[2]
end

set -g RUSTC_WRAPPER "cargo install {package}"

