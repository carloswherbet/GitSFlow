class GitLab::MergeRequest

  @options = {}
  attr_accessor :source_branch, :target_branch, :title, :options, :assignee_id, :labels, :issue_iid, :obj_gitlab, :type
  @labels = []
  def initialize(params = {})
    @source_branch = params[:source_branch]
    @target_branch = params[:target_branch]
    @title      = params[:title]
    @labels     = params[:labels]
    @issue_iid  = params[:issue_iid]
    @type       = params[:type]
    @options    = params[:options]
  end

  def create
    print "Create Merge Request: ".yellow
    print "#{@source_branch} into #{@target_branch}\n\n".green
    assignee_id = GitLab::User.me["id"]
    if type != 'hotfix'
      users = GitLab::User.all
      print "Users list:\n\n".yellow
      print "----------------------------\n".blue
      print "#{"0".ljust(10)} - Empty\n".blue
      users.each do |user|
        print "#{user['id'].to_s.ljust(10)} - #{user['name']}\n".blue
      end
      print "----------------------------\n".blue
      print "Choice user ID for assignee:\n".yellow
      assignee_id = STDIN.gets.chomp
      print "\n#{assignee_id}, "
      print "ok!\n".green
    end
    
    url = "projects/#{$GITLAB_PROJETO_ID}/merge_requests" 
    title = "##{@issue_iid} - Reintegration #{@source_branch} into #{@target_branch}"
    labels = ['merge_request']
    labels << type if type
    @obj_gitlab = GitLab.request_post(url, {
      source_branch: @source_branch,
      target_branch: @target_branch,
      title: title,
      labels: labels.join(','),
      assignee_id: assignee_id.to_i
    })
    
    print "Merge request created with success!\n\n".green
  end


  def create_code_review
    print "Create merge request for code review: ".yellow
    print "#{@source_branch} into #{@target_branch}\n\n".green
    users = GitLab::User.all
    print "Users list:\n\n".yellow
    print "----------------------------\n".blue
    print "#{"0".ljust(10)} - Empty\n".blue
    users.each do |user|
      print "#{user['id'].to_s.ljust(10)} - #{user['name']}\n".blue
    end
    print "----------------------------\n".blue
    print "Choice user ID for assignee code review:\n".yellow
    assignee_id = STDIN.gets.chomp
    print "\n#{assignee_id}, "
    print "ok!\n".green
    
    url = "projects/#{$GITLAB_PROJETO_ID}/merge_requests" 
    title = "WIP: ##{@issue_iid} - Code review #{@source_branch}"
    @obj_gitlab = GitLab.request_post(url, {
      source_branch: @source_branch,
      target_branch: @target_branch,
      title: title,
      labels: @labels,
      assignee_id: assignee_id.to_i
    })
    
    print "Merge request for Code Review created with success!\n\n".green
  end


end