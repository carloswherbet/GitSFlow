require 'tty_integration'
class GitLab::User
  attr_accessor :id, :email, :name

  def initialize(params = {})
    @name = params[:name]
  end

  def self.me
    user = GitLab.request_get('user')
    return user if user

    raise "Quem é você? \nNão consegui localizar seu usuário no gitlab,\nTente novamente mais tarde ou verifique o arquivos de configuração."
  end

  def self.all
    GitLab.request_get("projects/#{$GITLAB_PROJECT_ID}/users?per_page=100")
  end

  def to_s; end
end
