The status of this project is early and ongoing. It is not yet feature complete. Consider yourself invited to contribute, fork, and create issues; even for matters of bash code style.

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

# using hub-get

## install
*todo*

## configure

hub-get uses a user config file at `~/.hub-get.cfg`.
If it does not exist, one will be created when you set a custom parameter.
The default location for downloaded repos is `~/github/`. To change this, issue the configure command to set `hubget_dir`:

    hub-get configure hubget_dir ~/hubget

In order to use the [search feature](#search), you will first have to get a personal OAuth token from github. Once obtained, you may configure that as `github_oauth`:

    hub-get configure github_oauth '0bc4d33...'

## search

Search for projects by keyword

    hub-get search "options parser"

The output of which is similar to the following:

+----------------------------------------------
| Repo#  00047
| Project:  optimal
| User:  cowboyd
| URL:  https://github.com/cowboyd/optimal
| About:  th
+----------------------------------------------
| Repo#  00062
| Project:  argparser
| User:  shinout
| Language:  JavaScript
| URL:  https://github.com/shinout/argparser
| About:  (simplest
+----------------------------------------------
| Repo#  00055
| Project:  argumentum
| User:  paulmillr
| Language:  JavaScript
| URL:  https://github.com/paulmillr/argumentum
| About:  No-bullshi
+----------------------------------------------

## install (clone)

To clone a project, call `hub-get install {user}/{project}`

    $ hub-get install bibby/hub-get

Commands `clone` and `get` are aliases of `install`.

The repository will be cloned into `{hubget_dir}/{user}/{project}`. Using the defaults, this would create `~/github/bibby/hub-get`.

## list

To list the repos you've cloned, call `hub-get list`

    $ hub-get list
    bibby/hub-get
    bibby/sscfg
    christopher-barry/revpipe

You can also list projects for a single user

    $ hub-get list christopher-barry
    christopher-barry/revpipe

## upgrade (pull)

To get the latest version of a project, call `hub-get upgrade {user}/{project}`

    $ hub-get upgrade bibby/hub-get

Command `pull` is an alias of `upgrade`, since that's what it actually does.

## remove

Remove a project with `hub-get remove {user}/{project}` or by its aliases `rm`, `del`, or `delete`.

# Submodules

`hub-get` uses project [sscfg](http://path/to/sscfg) (mine) for configuration management. You are invited to contribute to that project as well.

Also used is [JSON.sh](https://github.com/bibby/JSON.sh/), which was forked from [dominictarr](https://github.com/dominictarr/JSON.sh) to maintain stability as it is an active project.
