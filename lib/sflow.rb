#!/usr/bin/ruby
begin
  require 'pry'
rescue LoadError
  # Gem loads as it should
end

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
  VERSION = "0.4.0"
  $TYPE   = ARGV[0]
  $ACTION = ARGV[1]
  $PARAM1 = ARGV[2]
  $PARAM2 = ARGV[3..-1]&.join(' ')

  def self.call
    begin
      print "Loading...\n".yellow
      validates if !['config_', 'help_'].include? ("#{$TYPE}_#{$ACTION}")
      # 
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
    if (!$PARAM1.match(/\-feature\//))
      raise "This branch is not a feature"
    end
    self.reintegration 'feature'
  end

  def self.bugfix_reintegration
    if (!$PARAM1.match(/\-bugfix\//))
      raise "This branch is not a bugfix"
    end
    self.reintegration 'bugfix'
  end

  def self.bugfix_finish
    self.bugfix_reintegration
  end

  def self.hotfix_reintegration
    if (!$PARAM1.match(/\-hotfix\//))
      raise "This branch is not a hotfix"
    end
    self.reintegration 'hotfix'
  end

  def self.hotfix_finish
    self.hotfix_reintegration
  end

  def self.feature_codereview
    if (!$PARAM1.match(/\-feature\//))
      raise "This branch is not a feature"
    end
    self.codereview()
  end

  def self.bugfix_codereview
    if (!$PARAM1.match(/\-bugfix\//))
      raise "This branch is not a bugfix"
    end
    self.codereview()
  end

  def bugfix_staging
    self.feature_staging
  end

  def self.feature_staging
    branch = $PARAM1
    issue = GitLab::Issue.find_by_branch(branch)

    print "Staging branches list:\n\n".yellow
    print "----------------------------\n".blue
    $GIT_BRANCHES_STAGING.each_with_index do |staging, index|
      print "#{index} - #{staging}\n".blue
    end
    print "----------------------------\n".blue
    print "Choice number of target branch:\n".yellow
    target_branch_id = STDIN.gets.chomp
    print "\n#{target_branch_id}, "
    target_branch = $GIT_BRANCHES_STAGING[target_branch_id.to_i]
    if !$GIT_BRANCHES_STAGING.include?(target_branch)
      raise "option invalid!"
    end
      print "ok!\n".green

    
    print "\nAttention: \n".yellow.bg_red
    print "Do you want clean first the target branch or only merge?\n\n".yellow
    print "----------------------------\n".blue
    print "0 - Clean it first, then do merge #{branch} into #{target_branch}\n".blue
    print "1 - Only Merge: Merge #{branch} into #{target_branch}\n".blue
    print "----------------------------\n".blue
    print "Choice number of target branch:\n".yellow
    option_merge = STDIN.gets.chomp
    print "\n#{option_merge}, "
    print "ok!\n".green

    if option_merge == "0"
      Git.reset_hard branch, target_branch
    elsif option_merge == "1"
      Git.merge branch, target_branch
    else
      raise "Wrong choice"
    end
    new_labels = [target_branch, 'Staging']
    remove_labels =  $GITLAB_LISTS
    old_labels = issue.obj_gitlab["labels"]
    old_labels.delete_if{|label| remove_labels.include? label} 
    issue.labels = (old_labels + new_labels).uniq
    issue.update

    self.codereview
  end

  def self.release_start
    version = $PARAM1
    if !version
      raise "param 'VERSION' not found"
    end
    issues  = GitLab::Issue.from_list($GITLAB_NEXT_RELEASE_LIST).select{|i| !i.labels.include? 'ready_to_deploy'}
    issues_total = issues.size 
    
    if issues_total == 0
      raise "Not exist issues ready for start release version" 
    end

    issues_urgent = issues.select{|i| i.labels.include? 'urgent'}
    issues_urgent_total = issues_urgent.size
    issue_title = "Release version #{version}\n"
    
    issue_release = GitLab::Issue.find_by(title: issue_title) rescue nil
    
    if issue_release
      print "This issue already exists, do you want to continue using it? (y/n):".yellow.bg_red
      
      print"\n If you choose 'n', a new issue will be created!\n"
      print "\n"
      option = STDIN.gets.chomp
    else
      option = 'n'
    end

    if option == 'n'
      issue_release = GitLab::Issue.new(title: issue_title)
      issue_release.create
    end

    new_labels = []
    changelogs = []

    release_branch = "#{issue_release.iid}-release/#{version}"
    print "Creating release version #{version}\n"

    begin

      Git.delete_branch(release_branch)
      Git.checkout 'develop'
      Git.new_branch release_branch
      
      print "Issue(s) title(s): \n".yellow
      issues.each do |issue|
        print "  -> #{issue.title}\n"
      end
      print "\n"
      
      # if issues_urgent_total > 0
        print "Attention!".yellow.bg_red
        print "\n\nChoose an option for merge:\n".yellow
        print "----------------------------\n".blue
        print "#{"0".ljust(10)} - Only #{issues_urgent_total} hotfix/urgent issues\n".blue if issues_urgent_total > 0
        print "#{"1".ljust(10)} - All #{issues_total} issues\n".blue
        print "----------------------------\n".blue
        print "Choice a number:\n".yellow
        option = STDIN.gets.chomp
      # else
      #   option = "1"
      # end
  
      case option
      when "0"
        print "Issue(s) title(s): \n"
        issues_urgent.each do |issue|
          print "  -> #{issue.title}\n"
        end
  
        issues_urgent.each do |issue|
  
          Git.merge(issue.branch, release_branch)
          changelogs << "* ~changelog #{issue.msg_changelog} \n"
          new_labels << 'hotfix'
         
        end
        issues = issues_urgent
      when "1"
        type = 'other'
        print "Next release has total (#{issues_total}) issues.\n\n".yellow
        print "Issue(s) title(s): \n".yellow
        issues.each do |issue|
          print "  -> #{issue.title}\n"
        end
        issues.each do |issue|
          Git.merge(issue.branch, release_branch)
          changelogs << "* ~changelog #{issue.msg_changelog} \n"

        end
      else
        raise "option invalid!"
      end
      print "Changelog messages:\n\n".yellow
      version_header = "Release version #{version}\n" 
      print version_header.blue
      msgs_changelog = []
      changelogs.each do |clog|
        msg_changelog = "#{clog.strip.chomp.gsub('* ~changelog ', '  - ')}\n"
        msgs_changelog << msg_changelog
        print msg_changelog.light_blue
      end
      print "\nSetting changelog message in CHANGELOG\n".yellow
      sleep 2
     
      system('touch CHANGELOG')
      file_changelog = IO.read 'CHANGELOG'
      IO.write 'CHANGELOG', version_header + msgs_changelog.join('') + file_changelog
        
      system('git add CHANGELOG')
      system("git commit -m 'update CHANGELOG version #{version}'")
      Git.push release_branch

      issue_release.description = "#{changelogs.join("")}\n * #{issues.map{|i| "##{i.iid},"}.join(' ')}"
      
      issue_release.labels = ['ready_to_deploy', 'Next Release']
      issue_release.set_default_branch(release_branch)
      issue_release.update
      issues.each do |issue|
        issue.labels  = (issue.labels + new_labels).uniq
        issue.close
      end
      print "\nYou are on branch: #{release_branch}\n".yellow
      print "\nRelease #{version} created with success!\n\n".yellow

      
    rescue => exception
      Git.delete_branch(release_branch)

      raise exception.message
    end
   
  end

  def self.release_finish 
    version = $PARAM1
    if !version
      raise "param 'VERSION' not found"
    end
    new_labels = []

    release_branch = "-release/#{version}"
    issue_release = GitLab::Issue.find_by_branch(release_branch)
    
    Git.merge issue_release.branch, 'develop'
    Git.push 'develop'


    type =  issue_release.labels.include?('hotfix') ? 'hotfix' : nil
    mr_master = GitLab::MergeRequest.new(
      source_branch: issue_release.branch,
      target_branch: 'master',
      issue_iid: issue_release.iid,
      title: "Reintegration release #{version}: #{issue_release.branch} into master",
      description: "Closes ##{issue_release.iid}",
      type: type
      )
    mr_master.create
     
    # end
    # mr_develop = GitLab::MergeRequest.new(
    #   source_branch: issue_release.branch,
    #   target_branch: 'develop',
    #   issue_iid: issue_release.iid,
    #   title: "##{issue_release.iid} - #{version} - Reintegration  #{issue_release.branch} into develop",
    #   type: 'hotfix'
    # )
    # mr_develop.create

  

    # remove_labels = [$GITLAB_NEXT_RELEASE_LIST]
    remove_labels = []
    old_labels = issue_release.obj_gitlab["labels"] + ['merge_request']
    old_labels.delete_if{|label| remove_labels.include? label} 
    issue_release.labels = (old_labels + new_labels).uniq
    issue_release.update
    print "\nRelease #{version} finished with success!\n\n".yellow


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
    GitLab.create_labels
    sleep 2
    system("git config --local alias.sflow '!sh -c \" sflow $1 $2 $3 $4\" - '")
    print "    \u{1F601}\  git sflow alias"
    print " (instaled) \u{2714}     ".green
    print "\n\n"
    print "git sflow help\n\n"
    print "git sflow config\n\n"
    print "GitSFlow installed with success!\n\n".green
    # self.help_
    # self.config_

  end


  def self.push_origin
    branch = $PARAM1
    log_messages = Git.log_last_changes branch
    issue = GitLab::Issue.find_by_branch branch
    Git.push branch 
    if (log_messages != "")
      print "Send messages commit for issue\n".yellow
      issue.add_comment(log_messages)
    end

    remove_labels = $GIT_BRANCHES_STAGING + ['Staging', $GITLAB_NEXT_RELEASE_LIST]
    old_labels = issue.obj_gitlab["labels"]
    old_labels.delete_if{|label| remove_labels.include? label} 

    issue.labels = old_labels +  ['Doing']
    issue.update
    print "Success!\n\n".yellow
  end

  private

  def self.config_
    print "\n\---------- Configuration ---------- \n".light_blue
    print "\nsflow config \nor\ngit sflow config \n\n".light_blue

    print "\In your project create or update file .env with variables below:\n\n"
    print "GITLAB_PROJECT_ID=\n".pink
    print "GITLAB_TOKEN=\n".pink
    print "GITLAB_URL_API=\n".pink
    print "GITLAB_EMAIL=\n".pink
    print "GITLAB_LISTS=To Do,Doing,Next Release,Staging\n".pink
    print "GITLAB_NEXT_RELEASE_LIST=Next Release\n".pink
    print "GIT_BRANCH_MASTER=master\n".pink
    print "GIT_BRANCH_DEVELOP=develop\n".pink
    print "GIT_BRANCHES_STAGING=staging_1,staging_2\n".pink

  end

  def self.set_error(e)
    print "\n\n"
    print "Error!".yellow.bg_red
    print "\n"
    print "#{e.message}".yellow.bg_red
    print "\n\n"
    print "#{e.backtrace}".yellow.bg_red
    print "\n\n"
  end

  def self.validates
    print "Running validations... \n\n".yellow
    if !$GITLAB_PROJECT_ID || !$GITLAB_TOKEN || !$GITLAB_URL_API || 
      !$GIT_BRANCH_MASTER || !$GIT_BRANCH_DEVELOP  || !$GITLAB_LISTS || !$GITLAB_NEXT_RELEASE_LIST
      print "Variables not configured\n".yellow
      raise "Run `sflow config` for help"
    end

    if !$TYPE && !$ACTION 
      print "Command invalid!\n".yellow
      raise "Run `sflow help` for help"
    end
    branchs_validations = $GIT_BRANCHES_STAGING + [$GIT_BRANCH_MASTER, $GIT_BRANCH_DEVELOP]
    Git.exist_branch?(branchs_validations.join(' ')) rescue raise "You need to create branches #{branchs_validations.join(', ')}"

  end

  def self.help_
    print "\n\n---------- Help ---------- \n".light_blue
    print "\nsflow help\nor\ngit sflow help\n\n".light_blue
    print "1 - git sflow feature start FEATURE DESCRIPTION \n".yellow
    print "2 - git sflow feature [reintegration|finish] FEATURE_BRANCH\n".yellow
    print "3 - git sflow feature codereview BRANCH\n".yellow
    print "4 - git sflow feature staging SOURCE_BRANCH\n".yellow
    print "5 - git sflow bugfix start BUGFIX DESCRIPTION\n".yellow
    print "6 - git sflow bugfix [reintegration|finish] BUGFIX_BRANCH\n".yellow
    print "7 - git sflow bugfix codereview BUGFIX_BRANCH\n".yellow
    print "8 - git sflow bugfix staging BUGFIX_BRANCH\n".yellow
    print "9 - git sflow hotfix start HOTFIX DESCRIPTION\n".yellow
    print "10 - git sflow hotfix [reintegration|finish] HOTFIX_BRANCH\n".yellow
    print "11 - git sflow release start RELEASE\n".yellow
    print "12 - git sflow release finish RELEASE\n".yellow
    print "13 - git sflow push origin BRANCH\n".yellow

    choice = -1
    question = "Choice a number for show a example or 0 for exit:\n\n".light_blue
    print question
    choice = STDIN.gets.chomp
    print ""
    case choice
    when '1'
      print "-> git sflow feature start Ticket#9999 'Ticket#9999 - Create new...'\n\n"
    when '2'
      print "-> git sflow feature reintegration 11-feature/Ticket#9999\n\n"
    when '3'
      print "-> git sflow feature codereview 11-feature/Ticket#9999\n\n"
    when '4'
      print "-> git sflow feature staging 11-feature/Ticket#9999\n\n"
    when '5'
      print "-> git sflow bugfix start Ticket#9999 'Ticket#9999 Bug ...'\n\n"
    when '6'
      print "-> git sflow bugfix finish 12-bugfix/Ticket#9999'\n\n"
    when '7'
      print "-> git sflow bugfix codereview 12-bugfix/Ticket#9999\n"
    when '8'
      print "-> git sflow bugfix staging 12-bugfix/Ticket#9999\n"
    when '9'
      print "-> git sflow hotfix start Ticket#9999 'Ticket#9999 Bug at production in...'\n\n"
    when '10'
      print "-> git sflow hotfix reintegration Ticket#9999'\n\n"
    when '11'
      print "-> git sflow release start v5.5.99'\n\n"
    when '12'
      print "-> git sflow release finish v5.5.99'\n\n"
    when '13'
      print "-> git sflow push BRANCH\n\n"
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
    print "Title: #{issue.title}\n\n"
    print "Changelog message:\n--> ".yellow
    message_changelog = STDIN.gets.chomp
    print "\n ok!\n\n".green
    new_labels = []
    if (type == 'hotfix')
      !source_branch.match('hotfix') rescue raise "invalid branch!"
      new_labels << 'hotfix'  
      new_labels << 'urgent'  
    else
      (!source_branch.match('feature') && !source_branch.match('bugfix'))  rescue  raise "invalid branch!"
    end
    remove_labels = $GIT_BRANCHES_STAGING + $GITLAB_LISTS + ['Staging']
    new_labels << 'changelog'
    new_labels << $GITLAB_NEXT_RELEASE_LIST
    old_labels = issue.obj_gitlab["labels"]
    old_labels.delete_if{|label| remove_labels.include? label} 
    issue.labels = (old_labels + new_labels).uniq
    issue.description.gsub!(/\* \~changelog .*\n?/,'')
    issue.description = "#{issue.description} \n* ~changelog #{message_changelog}"
    print "Setting changelog: ".yellow
    print "#{message_changelog}\n".green
    print "Moving issue to list: ".yellow 
    print "#{$GITLAB_NEXT_RELEASE_LIST}\n".green 
    issue.update
    
  end

  def self.start branch, issue, ref_branch = "develop"
    Git.fetch ref_branch
    Git.checkout ref_branch
    Git.pull ref_branch

    description = "* ~default_branch #{branch}"
    
    issue.description = description
    issue.update

    Git.new_branch branch
    Git.push branch

    print "\nYou are on branch: #{branch}\n\n".yellow
  end

  def self.codereview
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

