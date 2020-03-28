#!/usr/bin/env ruby
# frozen_string_literal: true

#!/usr/bin/ruby
require 'pry'

require 'net/http'
require "open3"
require 'uri'
load 'config.rb'
load 'string.rb'
load 'GitLab/gitlab.rb'
load 'Git/git.rb'

# require './lib/gitlab/issue.rb'
# require './lib/gitlab/merge_request.rb'
class SFlow
  VERSION = "0.1.0"
  $TYPE   = ARGV[0]
  $ACTION = ARGV[1]
  $PARAM1 = ARGV[2]
  $PARAM2 = ARGV[3..-1]&.join(' ')

  def self.call
    begin
      validates
      send("#{$TYPE}_#{$ACTION}")
    rescue => e
     set_error e

    end
  end

  def self.feature_start
    title = $PARAM2 == "" ? $PARAM1 : $PARAM2
    p "feature_start #{$PARAM1} #{$PARAM2}"
    Git.fetch "develop"
    Git.checkout "develop"
    Git.pull "develop"
    issue = GitLab::Issue.new(title: title, labels: ['Feature'])
    issue.create

    branch = "#{issue.iid}-feature/#{$PARAM1}"
    description = "Default branch: #{branch}"
    
    issue.description = description
    issue.update

    Git.new_branch branch
    Git.push branch

    print "\nYou are on branch: #{branch}\n\n".yellow
  end

  def feature_finish
    self.feature_reintegration
  end

  def self.feature_reintegration
    p "feature_reintegration #{$PARAM1} "
    Git.fetch "develop"
    Git.checkout "develop"
    Git.pull "develop"
    source_branch = $PARAM1
    issue = GitLab::Issue.find_by_branch(source_branch)
    # source_branch = "#{issue.iid}-feature/#{$PARAM1}"
    source_branch = $PARAM1
    # issue.move
    mr = GitLab::MergeRequest.new(
      source_branch: source_branch,
      target_branch: 'develop',
      title: 'Teste',
      issue_iid: issue.iid
      )
    mr.create
    issue.labels = (issue.obj_gitlab["labels"] + ["merge_request"]).uniq
    issue.update
  end

  def self.feature_code_review
    p "feature_code_review #{$PARAM1} "
    Git.fetch "develop"
    Git.checkout "develop"
    Git.pull "develop"
    source_branch = $PARAM1
    issue = GitLab::Issue.find_by_branch(source_branch)
    # issue.move
    mr = GitLab::MergeRequest.new(
      source_branch: source_branch,
      target_branch: 'develop',
      title: 'Teste',
      issue_iid: issue.iid
      )
    mr.create_code_review
    issue.labels = (issue.obj_gitlab["labels"] + ['code_review']).uniq
    issue.update


  end
  
  def self.feature_staging
    p "feature_staging #{$PARAM1} #{$PARAM2}"
    p "TODO:".red
  end
  
  def self.release_start
    release = $release
    # title = $PARAM2
    Git.fetch "develop"
    Git.checkout "develop"
    Git.pull "develop"
    Git.new_branch release
    Git.merge branch
    binding.pry

  end
  
  def self.release_finish
    p "release_start #{$PARAM1} #{$PARAM2}"
    p "TODO:".red
  end

  def self.uninstall_
    puts "\n\Uninstall git alias\n\n".yellow
    print "      \u{1F611}   git sflow alias"
    print " (removing...) \r".yellow
    sleep 2
    system('git config --local --unset alias.sflow')
    print "    \u{1F601}\  git sflow alias"
    print " (removed) \u{2714}     ".green
    print "\n\n"
    print "Bye Bye"
    print "\n\n"

  end

  def self.install_
    puts "\n\nInstalling git alias\n\n".yellow
    print "      \u{1F611}   git sflow alias"
    print " (instaling...) \r".yellow
    sleep 2
    system("git config --local alias.sflow '!sh -c \" sflow $1 $2 $3 $4\" - '")
    print "    \u{1F601}\  git sflow alias"
    print " (instaled) \u{2714}     ".green
    print "\n\n"
    print "git sflow help\n\n"
    print "git sflow config\n\n"
    print "Sucesso!\n\n".green
    # self.help_
    # self.config_

  end

  private

  def self.config_
    print "\n\---------- Configuration ---------- \n".light_blue
    print "\n Add export in source file ~/.bashrc:\n\n"
    print "export GITLAB_PROJETO_ID=#########\n".pink
    print "export GITLAB_TOKEN==#########\n".pink
    print "export GITLAB_URL_API==#########\n".pink
    print "export GITLAB_EMAIL=     -- OPTIONAL\n".pink

  end

  def self.set_error(e)
    print "\n\nErro!\n".yellow
    print "\n#{e.message}\n".yellow
    # print "\nComando não encontrado:".yellow 
    # print "\n     \u{274C} git sflow #{$TYPE} #{$ACTION} #{$PARAM1} #{$PARAM2} \n".red
    # print "\nDigite o comando baixo para obter ajuda:"
    # print "\n    git sflow --help  \n\n".yellow
  end

  def self.validates
    if !$GITLAB_PROJETO_ID || !$GITLAB_TOKEN || !$GITLAB_URL_API 
      raise "Variables not configured\nRun `git sflow config` for help".red
    end

  end

  def self.help_
binding.pry
    print "\n\n---------- Help ---------- \n".light_blue
    print "\ngit sflow help \n\n".light_blue
    print "  git sflow feature start FEATURE_BRANCH DESCRIPTION\n".yellow
    print "     git sflow feature start Ticket#9999 'Ticket#9999 Problema em...'\n"
    # print "     -> Create branch FEATURE_BRANCH from develop\n".green
    # print "     -> Create GitLab Issue with title DESCRIPTION \n".green
    print "\n\n"

    print "  git sflow feature reintegration BRANCH\n".yellow
    print "     git sflow feature reintegration Ticket#9999\n"
    # print "     -> Create Merge Request from BRANCH to branch develop\n".green
    print "\n\n"
    
    print "  git sflow feature codereview BRANCH\n".yellow
    print "     git sflow feature codereview Ticket#9999\n"
    # print "     -> Create Merge Request like Working in Progress (WIP)\n".green
    print "\n\n"
    
    print "  git sflow feature staging BRANCH_ORIGEN BRANCH_STAGING\n".yellow
    print "     git sflow feature staging Ticket#9999 homologacao\n"
    # print "     -> Reset branch BRANCH_STAGING with develop \n".green
    # print "     -> Merge BRANCH_ORIGEN into BRANCH_STAGING\n".green
    print "\n\n"


    print "  git sflow hotfix start HOTFIX_BRANCH DESCRIPTION\n".yellow
    print "     git sflow hotfix start Ticket#9999 'Ticket#9999 Problema em...'\n"
    # print "     -> Create branch HOTFIX_BRANCH from master\n".green
    # print "     -> Create GitLab Issue with title DESCRIPTION \n".green
    print "\n\n"

    print "  git sflow hotfix finish HOTFIX_BRANCH\n".yellow
    print "     git sflow hotfix finish Ticket#9999'\n"
    # print "     -> Merge branch HOTFIX_BRANCH into master\n".green
    # print "     -> Merge branch HOTFIX_BRANCH into develop\n".green
    # print "     -> Remove branch HOTFIX_BRANCH\n".green
    print "\n\n"


    print "  git sflow bugfix start BUGFIX_BRANCH DESCRIPTION\n".yellow
    print "     git sflow bugfix start Ticket#9999 'Ticket#9999 Problema em...'\n"
    # print "     -> Create branch BUGFIX_BRANCH from develop\n".green
    # print "     -> Create GitLab Issue with title DESCRIPTION \n".green
    print "\n\n"

    print "  git sflow bugfix reintegration BUGFIX_BRANCH\n".yellow
    print "     git sflow bugfix reintegration Ticket#9999'\n"
    # print "     -> Merge Request branch BUGFIX_BRANCH into develop\n".green
    print "\n\n"

    print ":\n\n".light_blue

  end

end

