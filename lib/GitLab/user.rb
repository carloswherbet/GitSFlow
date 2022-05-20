class GitLab::User
  attr_accessor :id, :email, :name

  def initialize(params = {})
    @name = params[:name]
  end

  def self.me
    user = GitLab.request_get('user')

    return user if user

    raise "Who are you?! \nVerify your data em .env"
  end

  def self.all
    GitLab.request_get("projects/#{$GITLAB_PROJECT_ID}/users")
  end

  def to_s; end
end
