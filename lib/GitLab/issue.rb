class GitLab::Issue 
  attr_accessor :title, :labels, :assignee_id, :description, :branch, :iid, :obj_gitlab
  @labels = []

  def initialize(params = {})
    @title = params[:title]
    @labels = params[:labels] 
    @description = params[:description]
    @branch = params[:branch]
    @assignee_id = GitLab::User.me["id"]
  end

  def create
    params = {}
    params.merge!(title: @title)
    params.merge!(description: @description.to_s)
    params.merge!(labels: @labels.join(','))
    params.merge!(assignee_id: @assignee_id)
    
    # label = params.fetch(:label) || ''
    # assignee_id = params.fetch(:assignee_id) || ''
    print "\n Create new GitLab issue \n\n".yellow
    url = "projects/#{$GITLAB_PROJETO_ID}/issues" 
    issue_json = GitLab.request_post(url, params)
    @iid = issue_json["iid"]
    print "Issue created with success:\n".green
    print "URL: #{issue_json["web_url"]}\n\n"
  end

  def update
    params = {}
    params.merge!(title: @title)
    params.merge!(description: @description.to_s)
    params.merge!(labels: @labels.join(','))
    params.merge!(assignee_id: @assignee_id)
    
    # label = params.fetch(:label) || ''
    # assignee_id = params.fetch(:assignee_id) || ''
    print "\nUpdate GitLab issue '#{@title}' \n\n".yellow
    url = "projects/#{$GITLAB_PROJETO_ID}/issues/#{@iid}" 
    GitLab.request_put(url, params)
    print "Issue updated with success:\n".green
  end

  def self.find_by(search)
    url = "issues?search=#{search.values[0]}&in=#{search.keys[0]}"
    GitLab.request_get(url)
  end 

  def self.find_by_branch(branch)
    url = "issues?search=#{branch}"
    issue_json = GitLab.request_get(url)[0]
    issue = GitLab::Issue.new
    issue.iid = issue_json["iid"]
    issue.description = issue_json["description"]
    issue.title = issue_json["title"]
    issue.labels = issue_json["labels"].join(',')
    issue.obj_gitlab = issue_json
    issue
  end 
end