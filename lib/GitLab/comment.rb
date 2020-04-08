class GitLab::Comment 
  attr_accessor :id, :issue_iid, :body

  def initialize(params = {})
    @issue_iid = params[:issue_iid]
    @body = params[:body]
  end


  def create
    url = "projects/#{$GITLAB_PROJECT_ID}/issues/#{@issue_iid}/notes"
    params = {
        issue_iid: @issue_iid,
        body: @body
    }
    GitLab.request_post(url, params)
  end


end