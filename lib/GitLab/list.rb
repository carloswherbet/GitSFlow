class GitLab::List 
  attr_accessor :id, :email, :name

  def initialize(params = {})
    @name = params[:name]
  end

  def self.get_next_release_list
    self.all.select{|list| list["label"]["name"] == $GITLAB_NEXT_RELEASE_LIST}  end

  def self.all
    board_id = GitLab.request_get("projects/#{$GITLAB_PROJECT_ID}/boards")[0]["id"] rescue nil
    if board_id
        return GitLab.request_get("projects/#{$GITLAB_PROJECT_ID}/boards/#{board_id}/lists")
    end
  end

  def to_s
  end


end