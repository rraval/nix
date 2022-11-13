{ pkgs, ... }: {
  enable = true;
  plugins = [
    {
      name = "fzf-fish";
      src = pkgs.runCommand "fzf-fish" {} ''
        mkdir -p $out
        cp ${pkgs.fzf}/share/fish/vendor_functions.d/fzf_key_bindings.fish $out/key_bindings.fish
        cp ${pkgs.fzf}/share/fish/vendor_conf.d/load-fzf-key-bindings.fish $out/init.fish
      '';
    }
  ];
  interactiveShellInit = ''
    set -x TIME '\n\n%U user, %S system, %E elapsed, %P CPU (%X text, %D data, %M max)k\n%I inputs, %O outputs (%F major, %R minor) pagefaults, %W swaps'

    # `reaver` is a fish prompt featuring
    # - A minimal left prompt with git status integration
    # - A right prompt with command duration and time
    # - Semantic prompt integration, see
    #   https://gitlab.freedesktop.org/Per_Bothner/specifications/blob/master/proposals/semantic-prompts.md
    #   and https://wezfurlong.org/wezterm/shell-integration.html

    # The `application identifier`, used by terminals to distinguish nested prompts.
    set _reaver_aid "fish_reaver_"$fish_pid

    # Empty string while the command is being edited or running
    # Numeric exit code if the command exited normally
    # Literal string `CANCEL` if the command was interrupted
    set _reaver_command_status ""

    function _reaver_osc_133 -a code -d 'Emit an arbitrary OSC 133 code, see https://gitlab.freedesktop.org/Per_Bothner/specifications/blob/master/proposals/semantic-prompts.md'
      printf "\033]133;%s\007" "$code"
    end

    function _reaver_osc_133_start -d 'First do a fresh-line, then start a new command, and enter prompt mode'
      _reaver_osc_133 "A;aid=$_reaver_aid;cl=m"
    end

    function _reaver_osc_133_end -a exit_code -d 'End of current command'
      _reaver_osc_133 "D;$exit_code;aid=$_reaver_aid"
    end

    function _reaver_osc_133_prompt -a kind prompt_contents -d 'Explicit start of a prompt'
      _reaver_osc_133 "P;k=$kind"
      printf "%s" "$prompt_contents"
      _reaver_osc_133 "B"
    end

    function _reaver_osc_133_output -d 'End of input, and start of output'
      _reaver_osc_133 "C"
    end

    function _reaver_on_fish_prompt --on-event fish_prompt
      # Emit codes about previous command exit.
      # Don't use `--on-event fish_postexec` because it is called before
      # omitted-newline output
      if [ -n "$_reaver_command_status" ]
        _reaver_osc_133_end "$_reaver_command_status"
      end

      _reaver_osc_133_start
    end

    function _reaver_on_pre_exec --on-event fish_preexec
      _reaver_osc_133_output
    end

    function _reaver_on_post_exec --on-event fish_postexec
      set _reaver_command_status "$status"
    end

    function _reaver_on_cancel --on-event fish_cancel
      set _reaver_command_status CANCEL
    end

    set -g __fish_git_prompt_show_informative_status
    set -g __fish_git_prompt_showcolorhints

    function _reaver_left_prompt
      printf '%s%s%s%s$ ' (set_color yellow) (prompt_pwd) (set_color normal) (fish_git_prompt)
    end

    function _reaver_right_prompt
      # FIXME: format CMD_DURATION
      set -l _reaver_right_prompt_seconds (math --scale=3 $CMD_DURATION / 1000 % 60)
      set -l _reaver_right_prompt_minutes (math --scale=0 $CMD_DURATION / 60000 % 60)
      set -l _reaver_right_prompt_hours (math --scale=0 $CMD_DURATION / 3600000)

      test "$_reaver_right_prompt_hours" -gt 0 && set -l -a _reaver_right_prompt_duration "$_reaver_right_prompt_hours"
      test "$_reaver_right_prompt_minutes" -gt 0 && set -l -a _reaver_right_prompt_duration "$_reaver_right_prompt_minutes"
      test "$_reaver_right_prompt_seconds" -gt 0 && set -l -a _reaver_right_prompt_duration "$_reaver_right_prompt_seconds"

      printf "%s+%s @ %s%s" (set_color brblack) (string join ":" $_reaver_right_prompt_duration) (date '+%H:%M:%S') (set_color normal)
    end

    function fish_prompt
      _reaver_osc_133_prompt "i" (_reaver_left_prompt)
    end

    function fish_right_prompt
      _reaver_osc_133_prompt "r" (_reaver_right_prompt)
    end

    set -x TIME '\n\n%U user, %S system, %E elapsed, %P CPU (%X text, %D data, %M max)k\n%I inputs, %O outputs (%F major, %R minor) pagefaults, %W swaps'
  '';
}
