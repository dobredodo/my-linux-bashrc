git_branch() {
  git branch 2>/dev/null | grep '^*' | colrm 1 2
}

timer_now() {
  date +%s%N
}

timer_start() {
  timer_start=${timer_start:-$(timer_now)}
}

timer_stop() {
	local delta_us=$((($(timer_now) - $timer_start) / 1000))
	local us=$((delta_us % 1000))
	local ms=$(((delta_us / 1000) % 1000))
	local s=$(((delta_us / 1000000) % 60))
	local m=$(((delta_us / 60000000) % 60))
	local h=$((delta_us / 3600000000))

	# show around 3 digits of accuracy
	if ((h > 0)); then timer_show=${h}h${m}m
	elif ((m > 0)); then timer_show=${m}m${s}s
	elif ((s >= 10)); then timer_show=${s}.$((ms / 100))s
	elif ((s > 0)); then timer_show=${s}.$(printf %03d $ms)s
	elif ((ms >= 100)); then timer_show=${ms}ms
	elif ((ms > 0)); then timer_show=${ms}.$((us / 100))ms
	else timer_show=${us}us
	fi

	unset timer_start
}

# set_prompt() {
	# local LAST_COMMAND=$? # Must come first
	# local _BLUE='\[\e[01;34m\]'
	# local White='\[\e[01;37m\]'
	# local _RED='\[\e[01;31m\]'
	# local _GREEN='\[\e[01;32m\]'
	# local _RESET='\[\e[00m\]'
	# local FANCY_X='\342\234\227'
	# local CHECKMARK='\342\234\223'

	# PS1="$White\$? "

	# if [[ $LAST_COMMAND == 0 ]]; then
	# 		PS1+="$_GREEN$CHECKMARK "
	# else
	# 		PS1+="$_RED$FANCY_X "
	# fi

	# timer_stop
	# PS1+="($timer_show) \t "

	# if [[ $EUID == 0 ]]; then
	# 		PS1+="$_RED\\u$_GREEN@\\h "
	# else
	# 		PS1+="$_GREEN\\u@\\h "
	# fi

	# PS1+="$_BLUE\\w \\\$$_RESET "
# }

# trap 'timer_start' DEBUG

bash_prompt() {
	# timer_stop
	none="$(tput sgr0)"
	trap 'echo -ne "${none}"' DEBUG
}

function prompt_right() {
  echo -e "\033[0;36m\u23F1 \$(echo - ) \u23F2 \D{%H:%M:%S}\033[0m"
}

function prompt_left() {
	local LAST_COMMAND=$?
	local _BLUE='\[\e[01;34m\]'
	local _WHITE='\[\e[01;37m\]'
	local _RED='\[\e[01;31m\]'
	local _GREEN='\[\e[01;32m\]'
	local _RESET='\[\e[00m\]'
	local FANCY_X='\342\234\227'
	local CHECKMARK='\342\234\223'

	local BOLD='1'

	local DEFAULT='9'
	local GREEN='2'
	local LIGHT_GRAY='7'
	local DARK_GRAY='60'
	local LIGHT_GREEN='62'
	local WHITE='67'

	local EFFECT='0'
	local COLOR='30'
	local BG='40'

	local TOX_GREEN_BOLD="\[\033[1;38;5;118m\]"

	local GIT_BRANCH_ICON=$'\uE0A0'

	local USER_FORMAT
	local HOST_FORMAT
	local PWD_FORMAT
	local GIT_FORMAT
	format_font USER_FORMAT $(($BOLD+$EFFECT)) $(($WHITE+$COLOR)) $(($GREEN+$BG))
	format_font HOST_FORMAT $(($BOLD+$EFFECT)) $(($DARK_GRAY+$COLOR)) $(($WHITE+$BG))
	format_font PWD_FORMAT $(($DARK_GRAY+$COLOR)) $(($BOLD+$EFFECT)) $(($WHITE+$BG))
	format_font GIT_FORMAT $(($DARK_GRAY+$COLOR)) $(($BOLD+$EFFECT)) $(($LIGHT_GREEN+$BG))

	local PROMPT_USER=$"$USER_FORMAT \u "
	local PROMPT_PWD=$"$PWD_FORMAT \${_PWD} "
	local PROMPT_GIT=$"$GIT_FORMAT $GIT_BRANCH_ICON \$(git_branch) "
	local PROMPT_INPUT=$"$TOX_GREEN_BOLD "

	local PROMPT_USER_SEPARATOR_FORMAT
	local PROMPT_PWD_SEPARATOR_FORMAT
	local PROMPT_GIT_SEPARATOR_FORMAT
	format_font PROMPT_USER_SEPARATOR_FORMAT $(($GREEN+$COLOR)) $(($WHITE+$BG))
	format_font PROMPT_PWD_SEPARATOR_FORMAT $(($WHITE+$COLOR)) $(($LIGHT_GREEN+$BG))
	format_font PROMPT_GIT_SEPARATOR_FORMAT $(($LIGHT_GREEN+$COLOR)) $(($DEFAULT+$BG))

	local TRIANGLE=$'\uE0B0'
	local PROMPT_USER_SEPARATOR=$PROMPT_USER_SEPARATOR_FORMAT$TRIANGLE
	local PROMPT_PWD_SEPARATOR=$PROMPT_PWD_SEPARATOR_FORMAT$TRIANGLE
	local PROMPT_GIT_SEPARATOR=$PROMPT_GIT_SEPARATOR_FORMAT$TRIANGLE

	case $TERM in
	xterm*|rxvt*)
		local TITLE='\[\033]0;\u:${_PWD}\007\]'
		;;
	*)
		local TITLE=""
		;;
	esac

  echo -e "$TITLE\n${PROMPT_USER}${PROMPT_USER_SEPARATOR}${PROMPT_PWD}${PROMPT_PWD_SEPARATOR}${PROMPT_GIT}${PROMPT_GIT_SEPARATOR}${PROMPT_INPUT}"
}

function prompt() {
	_PWD=${PWD/#$HOME/\~}
	PS1=$(printf "%*s\r%s\n\$ " "$(($(tput cols)+27))" "$(prompt_right)" "$(prompt_left)")
}

format_font() {
	local output=$1

	case $# in
	2)
		eval $output="'\[\033[0;${2}m\]'"
		;;
	3)
		eval $output="'\[\033[0;${2};${3}m\]'"
		;;
	4)
		eval $output="'\[\033[0;${2};${3};${4}m\]'"
		;;
	*)
		eval $output="'\[\033[0m\]'"
		;;
	esac
}

PROMPT_COMMAND=prompt

bash_prompt
unset bash_prompt
