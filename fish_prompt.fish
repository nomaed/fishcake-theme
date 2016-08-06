function fish_prompt
  # Cache exit status
  set -l last_status $status

  # Just calculate these once, to save a few cycles when displaying the prompt
  if not set -q __fish_prompt_hostname
    set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
  end
  if not set -q __fish_prompt_char
    switch (id -u)
      case 0
		set -g __fish_prompt_char '#'
      case '*'
  		set -g __fish_prompt_char '▶'
    end
  end

  set -l normal (set_color normal)
  set -l white (set_color FFFFFF)
  set -l red (set_color FF0000)
  set -l grey (set_color 999999)
  set -l turquoise (set_color 5fdfff)
  set -l orange (set_color df5f00)
  set -l hotpink (set_color df005f)
  set -l limegreen (set_color 87ff00)
  set -l purple (set_color af5fff)

  # set stuff according to last exit code
  set -l _prompt_prefix_color
  set -l _prompt_char

  if set -q last_status; and test "$last_status" -eq 0
	  set _prompt_prefix_color $white
	  set _prompt_char $__fish_prompt_char
  else
  	set _prompt_prefix_color $red
  	set _prompt_char '⛔ '
  end

  # Configure __fish_git_prompt
  set -g __fish_git_prompt_char_stateseparator ' '
  set -g __fish_git_prompt_color 5fdfff
  set -g __fish_git_prompt_color_flags df5f00
  set -g ___fish_git_prompt_color_untrackedfiles (set_color 666666) 
  set -g __fish_git_prompt_color_prefix white
  set -g __fish_git_prompt_color_suffix white
  set -g __fish_git_prompt_showdirtystate true
  set -g __fish_git_prompt_showuntrackedfiles true
  set -g __fish_git_prompt_showstashstate true
  set -g __fish_git_prompt_show_informative_status true

  # Line 1
  set -l prefix "$_prompt_prefix_color╭─$hotpink$USER$grey"
  if is_ssh_session
    set prefix "$prefix@$orange$__fish_prompt_hostname$grey"
  end
  set prefix "$prefix:$limegreen"
  set -l pwd (prompt_pwd)
  set -l suffix (__fish_git_prompt ' (%s)')
  set -l clock_and_status (get_clock_and_status $last_status)
  # set -l lengths (string length (strip_codes "$prefix$pwd$suffix"))
  echo -s $prefix $pwd $suffix $clock_and_status
  # [$lengths / $COLUMNS]"

  # Line 2
  echo -n -s $_prompt_prefix_color '╰' $_prompt_char $normal ' '
end

function get_clock_and_status
  set -l exitcode $argv[1]
  if test "$exitcode" -ne 0
    set_color red; echo -n ' '
    set_color -bred black; echo -n $exitcode; set_color normal
    set_color red; echo -n ''
    set_color normal
  end
  echo -n ' ⌚ '
  set_color 666
  date "+%H:%M:%S"
  set_color normal
end

function is_ssh_session
  if set -q SSH_TTY
    return 0
  end

  if set -q TMUX
    set -l tmux_ssh_con (tmux show-env SSH_CONNECTION)
    if not test -z "$tmux_ssh_con"; and not test "$tmux_ssh_con" = "-SSH_CONNECTION"
      return 0
    end
  end

  return 1
end
