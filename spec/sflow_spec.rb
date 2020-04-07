require 'pry'
require "sflow"
RSpec.describe SFlow do
    it "has a version number" do
      expect(SFlow::VERSION).not_to be nil
    end

    it "has one or more users from gitlab" do
      users = GitLab::User.all
      expect(users).not_to be_empty
       
    end
    it "has empty or more issues from gitlab" do
      issues = GitLab::Issue.all
      issues.size.should be >= 0
    end
  
  end
  