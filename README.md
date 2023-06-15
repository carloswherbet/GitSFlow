[![Gem Version](https://badge.fury.io/rb/gitsflow.svg)](https://badge.fury.io/rb/gitsflow)
[![Build Status](https://travis-ci.org/carloswherbet/GitSFlow.svg?branch=master)](https://travis-ci.org/carloswherbet/GitSFlow)
# GitSFlow 0.8.0
GitSFlow is a tool that integrate Git custom commands with GitLab and it's inspired GitFlow
## Installation


```ruby
gem 'gitsflow',  group: :development
```

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
SFLOW_TEMPLATE_RELEASE=Version {version} - {date}
SFLOW_TEMPLATE_RELEASE_DATE_FORMAT=Y/m/d
    
```

## Usage

For help:
```bash
 sflow
```
## Uninstall
   gem uninstall gitsflow

## Get a GitLab Token

![Get a GitLab Token](https://github.com/carloswherbet/GitSFlow/raw/master/src/common/images/get_token.gif "Get a GitLab Token")

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/carloswherbet/GitSFlow. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SFlow project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/carloswherbet/GitSFlow/blob/master/CODE_OF_CONDUCT.md).
