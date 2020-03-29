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
    issue = GitLab::Issue.new(title: title, labels: ['feature'])
    issue.create
    branch = "#{issue.iid}-feature/#{$PARAM1}"
    self.start(branch, issue)
  end

  def self.bugfix_start
    title = $PARAM2 == "" ? $PARAM1 : $PARAM2
    issue = GitLab::Issue.new(title: title, labels: ['bugfix'])
    issue.create
    branch = "#{issue.iid}-bugfix/#{$PARAM1}"
    self.start(branch, issue)
  end

  def self.hotfix_start
    title = $PARAM2 == "" ? $PARAM1 : $PARAM2
    issue = GitLab::Issue.new(title: title, labels: ['hotfix', 'production'])
    issue.create
    branch = "#{issue.iid}-hotfix/#{$PARAM1}"
    self.start(branch, issue, "master")
  end

  def self.feature_finish
    self.feature_reintegration
  end

  def self.feature_reintegration
    self.reintegration 'feature'
  end

  def self.bugfix_reintegration
    self.reintegration 'bugfix'
  end

  def self.bugfix_finish
    self.bugfix_reintegration
  end

  def self.hotfix_reintegration
    self.reintegration 'hotfix'
  end

  def self.hotfix_finish
    self.hotfix_reintegration
  end

  def self.feature_code_review
    self.code_review()
  end

  def self.bugfix_code_review
    self.code_review()
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

    print "\nIn your project create or update file .env with below lines:\n\n"
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
    print "\n\n---------- Help ---------- \n".light_blue
    print "\ngit sflow help \n\n".light_blue
    print "1 - git sflow feature start FEATURE DESCRIPTION \n".yellow
    print "2 - git sflow feature [reintegration|finish] FEATURE_BRANCH\n".yellow
    print "3 - git sflow feature codereview BRANCH\n".yellow
    print "4 - git sflow feature staging SOURCE_BRANCH STAGING_BRANCH\n".yellow
    print "5 - git sflow bugfix start BUGFIX DESCRIPTION\n".yellow
    print "6 - git sflow bugfix [reintegration|finish] BUGFIX_BRANCH\n".yellow
    print "7 - git sflow bugfix codereview BUGFIX_BRANCH\n".yellow
    print "8 - git sflow hotfix start HOTFIX DESCRIPTION\n".yellow
    print "9 - git sflow hotfix [reintegration|finish] HOTFIX_BRANCH\n".yellow

    choice = -1
    question = "Choice a number for show a example or 0 for exit:\n\n".light_blue
    print question
    choice = STDIN.gets.chomp
    print ""
    case choice
    when '1'
      print "-> git sflow feature start Ticket#9999 'Ticket#9999 Problema em...'\n\n"
    when '2'
      print "-> git sflow feature reintegration 11-feature/Ticket#9999\n\n"
    when '3'
      print "-> git sflow feature codereview 11-feature/Ticket#9999\n\n"
    when '4'
      print "-> git sflow feature staging Ticket#9999 homologacao\n\n"
    when '5'
      print "-> git sflow bugfix start Ticket#9999 'Ticket#9999 Problema em...'\n\n"
    when '6'
      print "-> git sflow bugfix finish 12-bugfix/Ticket#9999'\n\n"
    when '7'
      print "-> git sflow bugfix codereview 12-bugfix/Ticket#9999\n"
    when '8'
      print "-> git sflow hotfix start Ticket#9999 'Ticket#9999 Problema em...'\n\n"
    when '9'
      print "-> git sflow hotfix reintegration Ticket#9999'\n\n"
    when '0'
    else
    end
    print "See you soon!".green
    print "\n\n"


  end


  
  def self.reintegration type = "feature"
    # Git.fetch ref_branch
    # Git.checkout ref_branch
    # Git.pull ref_branch
    source_branch = $PARAM1
    issue = GitLab::Issue.find_by_branch(source_branch)
    source_branch = $PARAM1
    new_labels = []
    if (type == 'hotfix')
      mr_master = GitLab::MergeRequest.new(
      source_branch: source_branch,
      target_branch: 'master',
      issue_iid: issue.iid,
      type: 'hotfix'
      )
      mr_master.create

      mr = GitLab::MergeRequest.new(
        source_branch: source_branch,
        target_branch: 'develop',
        issue_iid: issue.iid,
        type: 'hotfix'
      )
      mr.create
      
    else
      mr = GitLab::MergeRequest.new(
        source_branch: source_branch,
        target_branch: 'develop',
        issue_iid: issue.iid
      )
      mr.create
      
      new_labels << 'merge_request'
    end
   
    issue.labels = (issue.obj_gitlab["labels"] + new_labels).uniq
    issue.update
    
  end


  def self.start branch, issue, ref_branch = "develop"
    Git.fetch ref_branch
    Git.checkout ref_branch
    Git.pull ref_branch

    description = "Default branch: #{branch}"
    
    issue.description = description
    issue.update

    Git.new_branch branch
    Git.push branch

    print "\nYou are on branch: #{branch}\n\n".yellow
  end

  def self.code_review
    Git.fetch "develop"
    Git.checkout "develop"
    Git.pull "develop"
    source_branch = $PARAM1
    issue = GitLab::Issue.find_by_branch(source_branch)
    # issue.move
    mr = GitLab::MergeRequest.new(
      source_branch: source_branch,
      target_branch: 'develop',
      issue_iid: issue.iid
      )
    mr.create_code_review
    issue.labels = (issue.obj_gitlab["labels"] + ['code_review']).uniq
    issue.update
  end
end

