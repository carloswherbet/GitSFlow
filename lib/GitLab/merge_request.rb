require 'tty_integration'

class GitLab::MergeRequest
  include TtyIntegration
  @options = {}
  attr_accessor :source_branch, :target_branch, :title, :options, :assignee_id, :labels, :issue_iid, :obj_gitlab,
                :type, :description

  @labels = []
  def initialize(params = {})
    @source_branch = params[:source_branch]
    @target_branch = params[:target_branch]
    @title      = params[:title]
    @labels     = params[:labels]
    @issue_iid  = params[:issue_iid]
    @type       = params[:type]
    @description = params[:description]
    @options = params[:options]
  end

  def create
    # if type != 'hotfix'
    #   users = GitLab::User.all
    #   print "Users list:\n\n".yellow
    #   print "----------------------------\n".blue
    #   print "#{"0".ljust(10)} - Empty\n".blue
    #   users.each do |user|
    #     print "#{user['id'].to_s.ljust(10)} - #{user['name']}\n".blue
    #   end
    #   print "----------------------------\n".blue
    #   print "Choice user ID for assignee:\n".yellow
    #   assignee_id = STDIN.gets.chomp
    #   print "\n#{assignee_id}, "
    #   print "ok!\n".green
    # end
    users_list = GitLab::User.all.map { |u| "#{u['id']} - #{u['name']}" }
    user_selected = prompt.select('Quem vai aprovar o MR?', users_list, symbols: { marker: '>' }, filter: true)
    assignee_id = user_selected.delete("\n").split('-')[0].strip

    url = "projects/#{$GITLAB_PROJECT_ID}/merge_requests"

    labels = ['merge_request']
    labels << type if type
    @obj_gitlab = GitLab.request_post(url, {
                                        source_branch: @source_branch,
                                        target_branch: @target_branch,
                                        title: @title,
                                        labels: labels.join(','),
                                        description: @description,
                                        assignee_id: assignee_id.to_i,
                                        squash: true,
                                        squash_on_merge: true

                                      })

    prompt.say(pastel.cyan("Merge request criado com sucesso!\n\n"))
  end

  def create_code_review
    # print "Create merge request for code review: ".yellow
    # print "#{@source_branch} into #{@target_branch}\n\n".green
    # users = GitLab::User.all
    # print "Users list:\n\n".yellow
    # print "----------------------------\n".blue
    # print "#{"0".ljust(10)} - Empty\n".blue
    # users.each do |user|
    #  print "#{user['id'].to_s.ljust(10)} - #{user['name']}\n".blue
    # end
    # print "----------------------------\n".blue
    # print "Choice user ID for assignee code review:\n".yellow
    # assignee_id = STDIN.gets.chomp
    # print "\n#{assignee_id}, "
    # print "ok!\n".green

    users = GitLab::User.all
    assignee_id = prompt.select('Quem vai fazer o codereview?', symbols: { marker: '>' }, filter: true) do |menu|
      users.each do |user|
        menu.choice  user['name'], user['id']
      end
    end

    url = "projects/#{$GITLAB_PROJECT_ID}/merge_requests"
    title = "Draft: ##{@issue_iid} - Code review #{@source_branch}"
    description = 'Este Merge Request de codereview foi criado pelo gitsflow'
    @obj_gitlab = GitLab.request_post(url, {
                                        source_branch: @source_branch,
                                        target_branch: @target_branch,
                                        title:,
                                        description:,
                                        labels: @labels,
                                        assignee_id: GitLab::User.me['id'].to_i,
                                        reviewer_ids: [assignee_id.to_i]
                                      })

    return error(@obj_gitlab.dig('message').join('.')) if @obj_gitlab.has_key? 'message'

    success('Code Review para Code Review criado com sucesso!')

    # print "Merge request for Code Review created with success!\n\n".green
  end
end
