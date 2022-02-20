require 'tty_integration.rb'
class GitLab::User 
  attr_accessor :id, :email, :name

  def initialize(params = {})
    @name = params[:name]
  end

  def self.me 
    user = GitLab.request_get("projects/#{$GITLAB_PROJECT_ID}/users?email=#{$GITLAB_EMAIL}")[0] 
    return user if user
    raise "Quem é você? \nNão consegui localizar seu usuário no gitlab,\nTente novamente mais tarde ou verifique o arquivos de configuração."
  end

  def self.all
    GitLab.request_get("projects/#{$GITLAB_PROJECT_ID}/users")
  end

  def to_s
  end


end