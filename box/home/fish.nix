{ pkgs, ... }:
{
  programs.fish = {
    enable = true;

    plugins = [
      {
        name = "fzf-fish";
        src = pkgs.writeTextFile {
          name = "fzf-fish";
          destination = "/init.fish";
          text = ''
            if command -s fzf-share >/dev/null
              source (fzf-share)/key-bindings.fish
              fzf_key_bindings
            end
          '';
        };
      }
    ];

    interactiveShellInit = ''
      set -x TIME '\n\n%U user, %S system, %E elapsed, %P CPU (%X text, %D data, %M max)k\n%I inputs, %O outputs (%F major, %R minor) pagefaults, %W swaps'

      # Nightfox Color Palette
      # Style: nightfox
      # Upstream: https://github.com/edeneast/nightfox.nvim/raw/main/extra/nightfox/nightfox.fish
      set -l foreground cdcecf
      set -l selection 2b3b51
      set -l comment 738091
      set -l red c94f6d
      set -l orange f4a261
      set -l yellow dbc074
      set -l green 81b29a
      set -l purple 9d79d6
      set -l cyan 63cdcf
      set -l pink d67ad2

      # Syntax Highlighting Colors
      set -g fish_color_normal $foreground
      set -g fish_color_command $cyan
      set -g fish_color_keyword $pink
      set -g fish_color_quote $yellow
      set -g fish_color_redirection $foreground
      set -g fish_color_end $orange
      set -g fish_color_error $red
      set -g fish_color_param $purple
      set -g fish_color_comment $comment
      set -g fish_color_selection --background=$selection
      set -g fish_color_search_match --background=$selection
      set -g fish_color_operator $green
      set -g fish_color_escape $pink
      set -g fish_color_autosuggestion $comment

      # Completion Pager Colors
      set -g fish_pager_color_progress $comment
      set -g fish_pager_color_prefix $cyan
      set -g fish_pager_color_completion $foreground
      set -g fish_pager_color_description $comment

      # Keymaps
      function cdup --description 'cd upwards looking for a project root'
        set -f dir (path dirname (pwd))

        while true
          if test "$dir" = /
            return
          end

          if test -e "$dir/.git" -o -e "$dir/justfile"
            cd "$dir"
            return
          end

          set -f dir (path dirname "$dir")
        end
      end

      bind \cg 'cdup; commandline -f repaint'
      bind \ch 'echo; cdh; commandline -f repaint'
      bind \cj 'nextd; commandline -f repaint'
      bind \ck 'prevd; commandline -f repaint'

      # `reaver` is a fish prompt featuring
      # - A minimal left prompt with git status integration
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

      set -g __fish_git_prompt_show_informative_status 1
      set -g __fish_git_prompt_showcolorhints 1
      set -g __fish_git_prompt_showuntrackedfiles 1

      function _reaver_left_prompt
        printf '%s%s%s%s$ ' (set_color yellow) (prompt_pwd) (set_color normal) (fish_git_prompt)
      end

      function fish_prompt
        _reaver_osc_133_prompt "i" (_reaver_left_prompt)
      end
    '';
  };
}
