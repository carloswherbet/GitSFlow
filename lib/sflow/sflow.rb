
#!/usr/bin/ruby
begin
  require 'pry'
rescue LoadError
  # Gem loads as it should
end
# require 'i18n'

require 'net/http'
require "pastel"
require "open3"
require "date"
require 'uri'
require 'config'

require 'tty_integration.rb'
require 'string.rb'
require 'GitLab/gitlab.rb'
require 'Git/git.rb'
require 'Utils/changelog.rb'
require 'sflow/version.rb'
require 'menu.rb'

# require 'utils/putdotenv.rb'

# require './lib/gitlab/issue.rb'
# require './lib/gitlab/merge_request.rb'
module SFlow
  class SFlow
    extend TtyIntegration
    
    # $TYPE   = ARGV[0]&.encode("UTF-8")
    # $ACTION = ARGV[1]&.encode("UTF-8")

    # branch_name = ARGV[2]&.encode("UTF-8")
    # $PARAM2 = ARGV[3..-1]&.join(' ')&.encode("UTF-8")

    def self.call
      begin
        system('clear')
        Config.init()
        # prompt.ok("GitSflow #{VERSION}")
        box = TTY::Box.frame  align: :center, width: TTY::Screen.width, height: 4, title:  {bottom_right: pastel.cyan("(v#{VERSION})")}  do
          pastel.green("GitSflow")
        end
        print box
        validates()
        Menu.new.principal
      rescue => e
      set_error e

      end
    end
    def self.feature_start external_id_ref, branch_description
      @@bar = bar("Processando ")
      @@bar.start
      2.times { sleep(0.2) ; @@bar.advance }
      title = branch_description || external_id_ref
      issue = GitLab::Issue.new(title: title, labels: ['feature'])
      issue.create
      branch = "#{issue.iid}-feature/#{external_id_ref}"
      self.start(branch, issue)
    end

    def self.bugfix_start external_id_ref, branch_description
      @@bar = bar("Processando ")
      @@bar.start
      2.times { sleep(0.2) ; @@bar.advance }
      title = branch_description || external_id_ref
      issue = GitLab::Issue.new(title: title, labels: ['bugfix'])
      issue.create
      branch = "#{issue.iid}-bugfix/#{external_id_ref}"
      self.start(branch, issue)
    end

    def self.hotfix_start external_id_ref, branch_description
      @@bar = bar("Processando ")
      @@bar.start
      2.times { sleep(0.2) ; @@bar.advance }
      title = branch_description || external_id_ref
      issue = GitLab::Issue.new(title: title, labels: ['hotfix', 'production'])
      issue.create
      branch = "#{issue.iid}-hotfix/#{external_id_ref}"
      self.start(branch, issue, $GIT_BRANCH_MASTER)
    end

    def self.feature_finish branch_name
      self.feature_reintegration branch_name
    end

    def self.feature_reintegration branch_name
      if (!branch_name.match(/\-feature\//))
        raise "A branch informada não é do tipo feature"
      end
      @@bar = bar("Processando ")
      @@bar.start
      self.reintegration 'feature', branch_name
    end

    def self.bugfix_reintegration branch_name
      if (!branch_name.match(/\-bugfix\//))
        raise "A branch informada não é do tipo bugfix"
      end
      @@bar = bar("Processando ")
      @@bar.start
      self.reintegration 'bugfix', branch_name
    end

    def self.bugfix_finish branch_name
      self.bugfix_reintegration branch_name
    end

    def self.hotfix_reintegration branch_name
      if (!branch_name.match(/\-hotfix\//))
        raise "A branch informada não é do tipo hotfix"
      end
      @@bar = bar("Processando ")
      @@bar.start
      self.reintegration 'hotfix', branch_name
    end

    def self.hotfix_finish branch_name
      self.hotfix_reintegration branch_name
    end

    def self.feature_codereview branch_name
      if (!branch_name.match(/\-feature\//))
        raise "A branch informada não é do tipo feature"
      end
      self.codereview(branch_name)
    end

    def self.bugfix_codereview branch_name
      if (!branch_name.match(/\-bugfix\//))
        raise "A branch informada não é do tipo bugfix"
      end
      self.codereview(branch_name)
    end

    def self.hotfix_staging branch_name
      if (!branch_name.match(/\-hotfix\//))
        raise "A branch informada não é do tipo hotfix"
      end
      self.staging branch_name
    end

    def self.bugfix_staging branch_name
      if (!branch_name.match(/\-bugfix\//))
        raise "A branch informada não é do tipo bugfix"
      end
      self.staging branch_name
    end

    def self.feature_staging branch_name
      if (!branch_name.match(/\-feature\//))
        raise "A branch informada não é do tipo feature"
      end
      self.staging branch_name
    end

    def self.release_start
      version = prompt.ask("Por favor dígite o nº da versão:")
      if !version
        raise "parâmetro 'VERSION' não encontrado"
      end
      issues  = GitLab::Issue.from_list($GITLAB_NEXT_RELEASE_LIST).select{|i| !i.labels.include? 'ready_to_deploy'}
      issues_total = issues.size

      if issues_total == 0
        raise "Não existem issues disponíveis para inciar uma nova Versão de Release"
      end

      issues_urgent = issues.select{|i| i.labels.include? 'urgent'}
      issues_urgent_total = issues_urgent.size
      issue_title = "Release version #{version}\n"

      issue_release = GitLab::Issue.find_by(title: issue_title) rescue nil

      if issue_release
        option = prompt.yes? "Já existem uma Issue com mesmo nome criada previamente. Se você quer reutilizar a issue digite Y, caso deseja criar uma nova, digite n? :".yellow.bg_red
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
      # print "Creating release version #{version}\n"

      begin

      # Git.delete_branch(release_branch)
        Git.checkout $GIT_BRANCH_DEVELOP
        Git.new_branch release_branch

        prompt.say "\nIssues disponíveis para criar versão:"
        header = [pastel.cyan('Issue'), pastel.cyan('Labels')]
        prompt.say (
          table.new(header,
            issues.map do |i|
              [i.title, i.labels.join(',')]
            end, orientation: :vertical
        ).render(:unicode))

        # prompt.say pastel.yellow "Atenção!"

        option = prompt.select("\nEscolha uma opção de Branch:", symbols: { marker: ">" }) do |menu|
          menu.choice( "Somente as (#{issues_urgent_total}) issues de hotfix/urgent", "0" ) if issues_urgent_total > 0
          menu.choice "Todas as (#{issues_total}) issues", "1"
        end

        case option
        when "0"
          prompt.say "Título das Issues: \n"

          # header = [pastel.cyan('Issues'), pastel.cyan('Labels')]
          # prompt.say (
          #   table.new(header,
          #     issues_urgent.map do |i|
          #       [i.title, i.labels.join(',')]
          #     end
          # ).render(:unicode))

          issues_urgent.each do |issue|
            Git.merge(issue.branch, release_branch)
            changelogs << "* ~changelog #{issue.msg_changelog} \n"
            new_labels << 'hotfix'
          end
          issues = issues_urgent
        when "1"
          type = 'other'
          # promtp.say "Existem (#{issues_total}) issues disponíveis para Próxima Release.\n\n".yellow

          # header = [pastel.cyan('Issues'), pastel.cyan('Labels')]
          # prompt.say (
          #   table.new(header,
          #     issues.map do |i|
          #       [i.title, i.labels.join(',')]
          #     end
          # ).render(:unicode))
          issues.each do |issue|
            Git.merge(issue.branch, release_branch)
            changelogs << "* ~changelog #{issue.msg_changelog} \n"
          end
        else
          raise "Opção Inválida!"
        end
        prompt.say pastel.bold "Mensagens incluida no change CHANGELOG:"

        d_split = $SFLOW_TEMPLATE_RELEASE_DATE_FORMAT.split('/')
        date =  Date.today.strftime("%#{d_split[0]}/%#{d_split[1]}/%#{d_split[2]}")
        version_header =  "#{$SFLOW_TEMPLATE_RELEASE.gsub("{version}", version).gsub("{date}",date)}\n"

        # print version_header.blue
        msgs_changelog = []
        changelogs.each do |clog|
          msg_changelog = "#{clog.strip.chomp.gsub('* ~changelog ', '  - ')}\n"
          msgs_changelog << msg_changelog
          # print msg_changelog.light_blue
        end
        msgs_changelog << "\n"

        header = [pastel.cyan(version_header.delete("\n")) ]
          prompt.say (
            table.new(header,
              [
              msgs_changelog.map do |msg|
                msg.delete("\n")
              end
            ]
          ).render(:unicode))
        # print "\nConfigurando mensagem de changelog no arquivo CHANGELOG\n".yellow


        system('touch CHANGELOG')

        line = version_header + "  " + msgs_changelog.join('')
        File.write("CHANGELOG",line + File.open('CHANGELOG').read.encode('UTF-8') , mode: "w")

        system('git add CHANGELOG')
        system(%{git commit -m "update CHANGELOG version #{version}"})
        Git.push release_branch

        issue_release.description = "#{changelogs.join("")}\n"

        issue_release.labels = ['ready_to_deploy', 'Next Release']
        issue_release.set_default_branch(release_branch)

        tasks = []
        issues.each do |issue|
          if issue.description.match(/(\* \~tasks .*)+/)
            tasks << "* ~tasks #{issue.list_tasks} \n"
          end
        end

        if tasks.size > 0
          prompt.say  pastel.bold "Lista de Tasks:".yellow
          new_labels << 'tasks'

          header = [pastel.cyan('Tasks') ]
          prompt.say (
            table.new(header,
              [
                tasks.map do |task|
                  task.strip.chomp.gsub('* ~tasks ', '  - ').delete("\n")
              end
            ]
          ).render(:unicode))
          # tasks.each do |task|
          #   task = "#{task.strip.chomp.gsub('* ~tasks ', '  - ')}\n"
          #   print task.light_blue
          # end
          issue_release.description += "#{tasks.join("")}\n"
        end

        issues.each do |issue|
          issue.labels  = (issue.labels + new_labels).uniq
          issue.close
        end

        # print "\Você está na branch: #{release_branch}\n".yellow
        success "Release #{version} criada com sucesso!"

        issue_release.description += "* #{issues.map{|i| "##{i.iid},"}.join(' ')}"

        issue_release.update


      rescue => exception
        Git.delete_branch(release_branch)

        raise exception.message
      end

    end

    def self.release_finish branch_name
      version = branch_name
      
      new_labels = []

      release_branch = "-release/#{version}"
      issue_release = GitLab::Issue.find_by_branch(release_branch)

      Git.merge issue_release.branch, $GIT_BRANCH_DEVELOP
      Git.push $GIT_BRANCH_DEVELOP

      type =  issue_release.labels.include?('hotfix') ? 'hotfix' : nil
      mr_master = GitLab::MergeRequest.new(
        source_branch: issue_release.branch,
        target_branch: $GIT_BRANCH_MASTER,
        issue_iid: issue_release.iid,
        title: "Reintegration release #{version}: #{issue_release.branch} into #{$GIT_BRANCH_MASTER}",
        description: "Closes ##{issue_release.iid}",
        type: type
        )
      mr_master.create

      # end
      # mr_develop = GitLab::MergeRequest.new(
      #   source_branch: issue_release.branch,
      #   target_branch: $GIT_BRANCH_DEVELOP,
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
      success("Release #{version} finalizada com sucesso!")


    end

    def self.push_
      self.push_origin
    end

    def self.push_origin
      branch = !branch_name ?  Git.execute { 'git branch --show-current' } : branch_name
      branch.delete!("\n")
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

    def self.set_error(e)
      print "\n\n"
      print TTY::Box.error(e.message, border: :light)
      print e.backtrace
    end

    def self.validates
      @@bar = bar

      6.times {
        # sleep(0.1)
        @@bar.advance
      }
      if !$GITLAB_PROJECT_ID || !$GITLAB_TOKEN || !$GITLAB_URL_API ||
        !$GIT_BRANCH_MASTER || !$GIT_BRANCH_DEVELOP  || !$GITLAB_LISTS || !$GITLAB_NEXT_RELEASE_LIST
        @@bar.stop
        Menu.new.setup_variables()
        @@bar.finish
      end

      begin
        branchs_validations = $GIT_BRANCHES_STAGING + [$GIT_BRANCH_MASTER, $GIT_BRANCH_DEVELOP]
        Git.exist_branch?(branchs_validations.join(' '))
      rescue => e
        @@bar.stop
        raise "Você precisar criar as branchs: #{branchs_validations.join(', ')}"
        # Menu.new.setup_variables()
      end
      2.times {
        # sleep(0.1)
        @@bar.advance
      }

      # Git.exist_branch?(branchs_validations.join(' ')) rescue raise "You need to create branches #{branchs_validations.join(', ')}"

      2.times {
        # sleep(0.1)
        @@bar.advance
      }
      GitLab::Issue.ping
      @@bar.finish

    end


    def self.reintegration type = "feature", branch_name

      # Git.fetch ref_branch
      # Git.checkout ref_branch
      # Git.pull ref_branch
      source_branch = branch_name
      issue = GitLab::Issue.find_by_branch(source_branch)
      2.times { sleep(0.2) ; @@bar.advance }
      # Setting Changelog
      # print "Title: #{issue.title}\n\n"
      # print "CHANGELOG message:\n--> ".yellow
      @@bar.finish
      message_changelog = prompt.ask("Informe a mensagem de CHANGELOG:", require: true, default: issue.title)
      # message_changelog = STDIN.gets.chomp.to_s.encode('UTF-8')
      # print "\n ok!\n\n".green
      new_labels = []
      if (type == 'hotfix')
        !source_branch.match('hotfix') rescue raise "Branch inválida!"
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

      # Setting Tasks
      tasks = prompt.ask("Informe a lista de scripts ou tasks (opcional):")

      issue.update
      success("#{branch_name} foi finalizada e transferida por #{$GITLAB_NEXT_RELEASE_LIST} com sucesso!")
    end

    def self.start branch, issue, ref_branch = $GIT_BRANCH_DEVELOP
      2.times { sleep(0.2) ; @@bar.advance }
      Git.checkout ref_branch
      description = "* ~default_branch #{branch}"
      issue.description = description
      issue.update
      2.times { sleep(0.2) ; @@bar.advance }
      Git.new_branch branch
      Git.push branch

      @@bar.finish
      prompt.say(pastel.cyan("Você está na branch: #{branch}"))
      success("Issue criada com sucesso!\nURL: #{issue.web_url}")

      # print "\nYou are on branch: #{branch}\n\n".yellow
    end

    def self.codereview branch_name
      Git.checkout $GIT_BRANCH_DEVELOP
      source_branch = branch_name
      issue = GitLab::Issue.find_by_branch(source_branch)
      # issue.move
      mr = GitLab::MergeRequest.new(
        source_branch: source_branch,
        target_branch: $GIT_BRANCH_DEVELOP,
        issue_iid: issue.iid
        )
      mr.create_code_review
      issue.labels = (issue.obj_gitlab["labels"] + ['code_review']).uniq
      issue.update
    end

    def self.staging branch_name
      branch = branch_name
      issue = GitLab::Issue.find_by_branch(branch)
      prompt.say(pastel.cyan("\nVamos lá!"))
      target_branch = prompt.select("\nEscolha a branch de homologação:", $GIT_BRANCHES_STAGING ,symbols: { marker: ">" }, filter: true)

      options = []
      options << {name: 'Limpar primeiro a branch e depois fazer o merge', value: :clear }
      options << {name: 'Somente fazer o merge', value: :only_merge }
      option_merge = prompt.select("\nO que deseja fazer?:", options ,symbols: { marker: ">" }, filter: true)
      @@bar = bar("Realizando merge da branch em homologação")
      @@bar.start
      2.times { sleep(0.2) ; @@bar.advance }

      if option_merge == :clear
        2.times { sleep(0.2) ; @@bar.advance }
        issues_staging  = GitLab::Issue.from_list(target_branch).select{|i| i.branch != branch}
        issues_staging.each do |i|
          i.labels.delete(target_branch)
          i.labels.delete('Staging')
          i.labels.push('Doing')
          i.update
        end
        @@bar.advance
        Git.reset_hard branch, target_branch
        @@bar.advance
        Git.push_force target_branch

      elsif option_merge == :only_merge
        Git.reset_hard target_branch, target_branch
        @@bar.advance
        Git.merge branch, target_branch
        @@bar.advance
        Git.push target_branch
        @@bar.advance
      else
        @@bar.stop
        raise 'Escolha inválida'
      end

      new_labels = [target_branch, 'Staging']
      remove_labels =  $GITLAB_LISTS
      old_labels = issue.obj_gitlab["labels"]
      old_labels.delete_if{|label| remove_labels.include? label}
      issue.labels = (old_labels + new_labels).uniq
      issue.update
      @@bar.finish
      #self.codereview branch_name
      Git.checkout(branch)
      success("Merge em homologação realizado com sucesso")
    end
  end
end

