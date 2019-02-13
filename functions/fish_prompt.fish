

function visual_length
    printf $argv | perl -pe 's/\x1b.*?[mGKH]//g' | wc -m
end

function fish_prompt
  set -l state $status
  if not set -q -g __mac_primary_color
      set -l _mac (cat /sys/class/net/????*/address)[1]
      set -g  __mac_primary_color (set_color -o (echo $_mac |cut -d':' -f 4- |sed s/://g))
      set -g  __mac_secondary_color (set_color -o (echo $_mac |cut -d':' -f -3 |sed s/://g))
  end

  set -l black (set_color -o black)
  set -l red (set_color -o red)
  set -l green (set_color -o green)
  set -l yellow (set_color -o yellow)
  set -l blue (set_color -o blue)
  set -l magenta (set_color -o magenta)
  set -l cyan (set_color -o cyan)
  set -l white (set_color -o white)

  set -l l_cyan (set_color normal)(set_color cyan)
  set -l normal (set_color normal)

  set -l arrow " $red➜ "
  set -l cwd $cyan(prompt_pwd)

  set -l ssh ""
  if test $SSH_CONNECTION
    set ssh $red$arrow$magenta"ssh"
  end

  set -l host (hostname|cut -d . -f 1)
  set -l user_host $__mac_primary_color$USER$ssh$red$arrow$__mac_secondary_color$host

  set -l dircount $red" · "$l_cyan(ls|wc -w)

  set -l cmdtime ""
  if test $CMD_DURATION
    if test $CMD_DURATION -gt 1000
      set cmdtime (math "$CMD_DURATION / 1000")$red"s"
    else
      set cmdtime $CMD_DURATION$cyan"ms"
    end
  end
  set cmdtime $black"["$white$cmdtime$black"] "

  set -l exitstatus ""
  if test $state -eq 0
    set exitstatus $green✔" "$black"("$green$state$black") "
  else
    set exitstatus $red✘" "$black"("$red$state$black") "
  end

  set -l left_prompt $user_host$arrow$cwd$dircount
  set -l right_prompt $exitstatus$cmdtime"  "
  set -l left_length (visual_length $left_prompt)
  set -l right_length (visual_length $right_prompt)
  set -l spaces (math "$COLUMNS - $left_length - $right_length")

  echo
  echo -n $left_prompt
  printf "%-"$spaces"s" " "
  echo $right_prompt
  echo -n $__mac_primary_color">" $normal
end
