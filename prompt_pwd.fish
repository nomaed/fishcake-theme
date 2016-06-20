function prompt_pwd --description 'Print the current working directory, shortened to fit the prompt'
    set -q argv[1]; and switch $argv[1]
        case -h --help
            __fish_print_help prompt_pwd
            return 0
    end

    # This allows overriding fish_prompt_pwd_dir_length from the outside (global or universal) without leaking it
    set -q fish_prompt_pwd_dir_length; or set -l fish_prompt_pwd_dir_length 5
    set -q __fish_prompt_max_dirs; or set -l __fish_prompt_max_dirs 5

    # Replace $HOME with "~"
    set realhome ~
    set -l tmp (string replace -r '^'"$realhome"'($|/)' '~$1' $PWD)

    if [ $fish_prompt_pwd_dir_length -eq 0 ]
        echo $tmp    
    else
        # Shorten to at most $fish_prompt_pwd_dir_length characters per directory
        set -l parts
        set -l all (string split "/" $tmp)
        set -l last $all[-1]
        set -l reduction (math (count $all) - $__fish_prompt_max_dirs )
        
        if [ (count $all) -gt 1 ]
            set all $all[1..-2]
            for part in $all
            
                if [ $reduction -gt 0 ]
                    set parts $parts (string sub -l 1 $part)
                    set reduction (math $reduction - 1)
                else if [ (string length $part) -gt $fish_prompt_pwd_dir_length ]
                    set parts $parts (string sub -l $fish_prompt_pwd_dir_length $part)"…"
                else
                    set parts $parts $part
                end

            end
        end
        
        set parts $parts $last
        ## replace all dirs above $__fish_prompt_max_dirs with an ellipsis
        #set -l num_parts (count $parts)
        #if test $num_parts -gt $__fish_prompt_max_dirs
        #  set parts … $parts[(math 0 - $__fish_prompt_max_dirs)..-1]
        #end
        string join "/" $parts
    end
end
