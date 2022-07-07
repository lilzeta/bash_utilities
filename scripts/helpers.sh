# trick bash to look if $1 is also an alias after sudo (extends aliasing)
alias sudo="sudo "
alias so="sudo "

alias nd="mkdir -p " # create dir even if missing path
alias cod="so chmod +x "
alias ec="echo "
# print files one per line w/details
alias ll='ls -alF'

# _ prefix for beware unsafe
alias _rf="rm -rf "
# _ post-fix for sudo
alias _rf_="so rm -rf "

alias to="touch "

NOCOLOR='\033[0m'
PURPLE='\033[0;35m'

# echo & execute
e__e () {
	echo -e "${PURPLE}\$: $@${NOCOLOR}" ; "$@" ;
}
# secret santa aliased chaining (passthrough for now)
alias e_e='e__e '

yes_or_no () {
	if [ $# -ge 3 ] && [ $3 = "invert" ]; then
		q="$1 y/n [n]: "
		def=n
	else
		q="$1 y/n [y]: "
		def=y
	fi
	while true; do
		read -p "$q" yn
		yn=${yn:-$def}
		case $yn in
			[Yy]*) return 1 ;;
			[Nn]*)
				echo "$2"
				return 0 ;;
		esac
	done
}

# Prompt to confirm, defaulting to YES on <enter>
function confirm_yes {
  local prompt="${*:-Are you sure} [Y]/n? "
  get_yes_keypress "$prompt" 0
}

# Prompt to confirm, defaulting to YES on <enter>
function confirm {
    local prompt="${*:-Are you sure} [Y]/n? "
    get_yes_keypress "$prompt"
}

# hard exit process (from func, exit the command)
function peace {
    echo "***exiting***"
    exit
}

# set i(from) & t(to) to first two ints and set/strip args to the rest
indexi_t_args () {
  is_num="^[0-9]+$"
  args=()
  for var in "$@"
  do
    if [[ $var =~ $is_num ]] ; then
      if [[ ! "$i" =~ $is_num ]] ; then
        i="$var"
    elif [[ ! "$t" =~ $is_num ]] ; then
        t="$var"
      else
        args+=("$var")
      fi
    else
      args+=("$var")
    fi
  done
  # set defaults if from/to not found
  if ! [[ "$i" =~ $is_num ]] ; then
    i=0
  fi
  if ! [[ "$t" =~ $is_num ]] ; then
    t=999
  fi
}
