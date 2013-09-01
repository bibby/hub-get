# hub-get

`hub-get` is like __apt-get__ or __npm__, but for github repositories. It uses the [github api v3][] for basic repo searches, and can install (git clone) and list copied projects.

[github api v3]:    http://developer.github.com/v3/

## What hub-get is not

`hub-get` does not do the following

- create repos
- deal with issues, friends, stars, gists
- basically any github api resource other than [repository search][]

[repository search]:    http://developer.github.com/v3/search/#search-repositories

## What hub-get is

hub-get is a way to clone easily search and clone repositories from the console while keeping them neatly organized by user in a common directory.

It is also a fun side-project, and is not intending (or pretending) to be on the same level as the aforementioned legitimate package and repository managers.
The purpose is to sharpen my `bash`, learn from mistakes and feedback, and have something semi-useful at the same time.

## Install

A checkout contains `install` and `uninstall`, neither of which take arguments. Run them to perform the desired action. Please note that the behavior is different if you run as root.

	$ ./install
	Installing as regular user. bash_completion not included (requires root).
	Symlinked hub-get.sh to ~/bin/hub-get 
	copied default.cfg to ~/.hubget.cfg
 
	Install complete!

	$ sudo ./install
	Installing as root.
	Symlinked ~/hub-get.sh to /usr/local/bin/hub-get
	copied default.cfg to /etc/hubget/hubget.cfg
	installed /etc/bash_completion.d/hubget
 
	Install complete!

## Uninstall
The `uninstall` script will cleanly reverse the actions of `install`, taking into account the user context for which it is executed (root v regular user).

The repository checkout destination **remains untouched**, preserving anything you've downloaded.

## Using hub-get

	$ hub-get --help
	hub-get - github "package" manager
		hub-get <action> <repo>
		actions:  get remove upgrade list configure
		repo: username/project,  ie bibby/hub-get

### configure

hub-get uses a user config file at `~/.hub-get.cfg`.
If it does not exist, one will be created when you set a custom parameter.
The default location for downloaded repos is `~/github`. To change this, issue the configure command to set `repo.dir`:

    hub-get configure repo.dir ~/repos

In order to use the search feature, you will first have to get a personal OAuth token from github. Once obtained, you may configure that as `github.oauth`:

    hub-get configure github.oauth '0bc4d33...'

### search

Search for projects by keyword

    hub-get search "options parser"

The output of which is similar to the following:

    +----------------------------------------------
    | Project:  optconfig
    | User:  tmtm
    | Language:  Ruby
    | URL:  https://github.com/tmtm/optconfig
    | About:  Command line option parser
    +----------------------------------------------
    | Project:  OptionParserWithFileOption
    | User:  bianchimro
    | Language:  Python
    | URL:  https://github.com/bianchimro/OptionParserWithFileOption
    | About:  An extension of python optparse.OptionParser to read options and arguments from a file
    +----------------------------------------------
    | Project:  scala-optparse
    | User:  frugalmechanic
    | Language:  Scala
    | URL:  https://github.com/frugalmechanic/scala-optparse
    | About:  Command line option parsing for scala
    +----------------------------------------------

### get (install, clone)

To clone a project, call `hub-get install {user}/{project}`

    $ hub-get install bibby/hub-get

Commands `clone` and `get` are aliases of `install`.

The repository will be cloned into `{repo.dir}/{user}/{project}`. Using the defaults, this would create `~/github/bibby/hub-get`.

### list

To list the repos you've cloned, call `hub-get list`

    $ hub-get list
    bibby/hub-get
    bibby/sscfg
    christopher-barry/revpipe

You can also list projects for a single user

    $ hub-get list christopher-barry
    christopher-barry/revpipe

### upgrade (pull)

To get the latest version of a project, call `hub-get upgrade {user}/{project}`

    $ hub-get upgrade bibby/hub-get

Command `pull` is an alias of `upgrade`, since that's what it actually does.

### remove

Remove a project with `hub-get remove {user}/{project}` or by its aliases `rm`, `del`, or `delete`.

## SubTrees

`hub-get` uses project [sscfg](https://bitbucket.org/bibby/sscfg) for configuration management. You are invited to contribute to that project as well.

Also used is [JSON.sh](https://github.com/bibby/JSON.sh/), which was forked from [dominictarr](https://github.com/dominictarr/JSON.sh) to maintain stability, as it is an active project.

## Contribute!
I'm no bash expert, and often do not consider environments other than Ubuntu. So I openly invite pull requests, issues, and other communication regarding this program; particularly when it comes to portability and overall bash style.  

