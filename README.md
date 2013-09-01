# sscfg

a basic user config-file manager for shell scripts; "shell script config"

## meta-info

*author* bibby <bibby@bbby.org>

*license* MIT (provided)

## About

**sscfg** is a small script to create and edit configuration files, typically user settings in the form of a *dotfile*. The format is that of a simple properties file as shown below.

    #!/bin/bash
    mySetting="apple"
    otherSetting="banana"

That's it. **sscfg** is intended to make future scripts easier to write by assuming the responsibility of managing the content of these settings files.
The consumer of this script was not meant to be a user in a terminal (though that works),  but rather a command line program looking to make use of user settings.

## Install

For the interest of public projects, it may be prudent to `git subtree` this project into your own should it depend on **sscfg**. For local development, it can be linked to a common `$PATH` item.

A checkout contains `install` and `uninstall`, neither of which take arguments. Run them to perform the desired action. Please note that the behavior is different if you run as root.

    $ ./install.   # as regular user
    Installing as regular user. bash_completion not included (requires root)
    Symlinked sscfg to ~/bin/sscfg
    Install complete!

    $ sudo ./install. # as root
    Installing as root.
    Symlinked sscfg to /usr/local/bin/sscfg
    installed /etc/bash_completion.d/sscfg 
    Install complete!

## Uninstall

The `uninstall` script will cleanly reverse the actions of `install`, taking into account the user context for which it is executed (root v regular user).

## Contribute!

I'm no bash expert, and often do not consider environments other than Ubuntu. So I openly invite pull requests, issues, and other communication regarding this program; particularly when it comes to portability and overall bash style.  

### sscfg --help

	$ sscfg --help
    sscfg - shell script configuration manager
    Create and update a user config file for your shell script.
     
    use:
    sscfg [options] cfgfile command [key] [value]
     
    commands:
    set [key] [value] - add a variable assignment to cfg file
    unset [key] - removes variable assignment from cfg file
    print
     
    options:
    -h|--help    displays this help
    -v|--version displays sscfg version
    -c|--create  create the cfg file if it doesn't exist
    -x|--debug prints actions
     
    examples:
    Create a new config
        sscfg --create /tmp/foo set alpha apples
    Add a variable
        sscfg /tmp/foo set beta bananas
    Remove a variable
        sscfg /tmp/foo unset alpha
