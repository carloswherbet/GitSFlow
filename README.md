[![Gem Version](https://badge.fury.io/rb/gitsflow.svg)](https://badge.fury.io/rb/gitsflow)
[![Build Status](https://travis-ci.org/carloswherbet/GitSFlow.svg?branch=master)](https://travis-ci.org/carloswherbet/GitSFlow)
# GitSFlow
GitSFlow is a tool that integrate Git custom commands with GitLab and it's inspired GitFlow
## Installation


```ruby
gem 'gitsflow',  group: :development
```

1 - Add this line to your application's Gemfile:

    $ bundle install
    $ sflow install
    -> It will install the git alias

2 -  install it yourself as:

    $ gem install gitsflow

And in your application's:

    $ sflow install
    -> It will install the git alias


## Flow Sugestion


## Config

    $ git sflow config
    or 
    $ sflow config

In your project create or update file .env with variables below:

```shell
GITLAB_PROJECT_ID=
GITLAB_TOKEN=
GITLAB_URL_API=https://gitlab.com/api/v4
GITLAB_EMAIL=
GITLAB_LISTS=To Do,Doing,Next Release,Staging
GITLAB_NEXT_RELEASE_LIST=Next Release
GIT_BRANCH_MASTER=master
GIT_BRANCH_DEVELOP=develop
GIT_BRANCHES_STAGING=staging_1,staging_2
```

## Usage

For help:

    $ git sflow help
    or
    $ sflow help 

List of commands:
1. git sflow feature start FEATURE DESCRIPTION 
2. git sflow feature [reintegration|finish] FEATURE_BRANCH
3. git sflow feature codereview BRANCH
4. git sflow feature staging SOURCE_BRANCH
5. git sflow bugfix start BUGFIX DESCRIPTION
6. git sflow bugfix [reintegration|finish] BUGFIX_BRANCH
7. git sflow bugfix codereview BUGFIX_BRANCH
8. git sflow bugfix staging BUGFIX_BRANCH
9. git sflow hotfix start HOTFIX DESCRIPTION
10. git sflow hotfix [reintegration|finish] HOTFIX_BRANCH
11. git sflow hotfix staging HOTFIX_BRANCH
12. git sflow release start RELEASE
13. git sflow release finish RELEASE
14. git sflow push origin BRANCH



## Uninstall
    $ git sflow uninstall
    or 
    $ sflow uninstall

TODO: Write usage instructions here


## Get a GitLab Token

![Get a GitLab Token](https://github.com/carloswherbet/GitSFlow/raw/master/src/common/images/get_token.gif "Get a GitLab Token")

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/carloswherbet/GitSFlow. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SFlow project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/carloswherbet/GitSFlow/blob/master/CODE_OF_CONDUCT.md).
