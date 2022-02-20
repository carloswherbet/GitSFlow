require 'sflow.rb'
require 'Git/git.rb'
require 'tty_integration.rb'
class Menu
  include TtyIntegration

  def principal()
    prompt.say("\n")

    result = prompt.select("\O que você gostaria de fazer?", symbols: { marker: ">" }, per_page: 10) do |menu|
      menu.choice "INICIAR uma nova BRANCH", :start_branch
      menu.choice "FINALIZAR uma BRANCH", :finish_branch
      menu.choice "ENVIAR para HOMOLOGAÇÃO", :staging_branch
      menu.choice "Fazer CODE REVIEW ", :codereview
      menu.choice "INICIAR uma RELEASE", :release_start
      menu.choice "FINALIZAR uma RELEASE", :release_finish
    #  menu.choice "MOVE a Issue", :staging_branch, disabled: '(Coming Soon)'
    #  menu.choice "List my Issues", :staging_branch, disabled: '(Coming Soon)'
      menu.choice "Config(.env)", :setup_variables
    #  menu.choice "Help", 5
      menu.choice "SAIR", :exit
    end
    self.send(result)
  end
  
  def setup_variables

    project_name = Git.execute { "git remote -v | head -n1 | awk '{print $2}' | sed -e 's,.*:\(.*/\)\?,,' -e 's/\.git$//'"}
    file = "#{Dir.home}/.config/gitsflow/#{project_name.gsub("\n","")}/config.yml"
    config = TTY::Config.new
    config.filename = file

    begin
      result_env = config.read(file).transform_keys(&:to_sym)
      result = prompt.collect do
        key(:GITLAB_PROJECT_ID).ask("GITLAB_PROJECT_ID:", required: true, default: result_env[:GITLAB_PROJECT_ID])
        key(:GITLAB_TOKEN).mask("GITLAB_TOKEN:", required: true, echo: true, default: result_env[:GITLAB_TOKEN])
        key(:GITLAB_URL_API).ask("GITLAB_URL_API:", required: true, default: result_env[:GITLAB_URL_API] || 'https://gitlab.com/api/v4')
        key(:GITLAB_EMAIL).ask("GITLAB_EMAIL:", required: true, default: result_env[:GITLAB_EMAIL]) {|q| q.validate(/[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+/, "Invalid email address")}
        key(:GITLAB_LISTS).ask("GITLAB_LISTS:", required: true, default:  result_env[:GITLAB_LISTS] || 'To Do,Doing,Next Release,Staging')
        key(:GITLAB_NEXT_RELEASE_LIST).ask("GITLAB_NEXT_RELEASE_LIST:", required: true, default: result_env[:GITLAB_NEXT_RELEASE_LIST] || 'Next Release')
        key(:GIT_BRANCH_MASTER).ask("GIT_BRANCH_MASTER:", required: true, default: result_env[:GIT_BRANCH_MASTER] || 'master')
        key(:GIT_BRANCH_DEVELOP).ask("GIT_BRANCH_DEVELOP:", required: true, default: result_env[:GIT_BRANCH_DEVELOP] || 'developer')
        key(:GIT_BRANCHES_STAGING).ask("GIT_BRANCHES_STAGING:", required: true, default: result_env[:GIT_BRANCHES_STAGING] || 'staging')
        key(:SFLOW_TEMPLATE_RELEASE).ask("SFLOW_TEMPLATE_RELEASE:", required: true, default:  result_env[:SFLOW_TEMPLATE_RELEASE] || 'Version {version} - {date}')
        key(:SFLOW_TEMPLATE_RELEASE_DATE_FORMAT).ask("SFLOW_TEMPLATE_RELEASE_DATE_FORMAT:", required: true, default: result_env['SFLOW_TEMPLATE_RELEASE_DATE_FORMAT'] || 'Y/m/d')
      end
    rescue TTY::Config::ReadError => read_error
      prompt.say(pastel.cyan("\n\nPor favor configure as variáveis .env"))
      result = prompt.collect do
        key(:GITLAB_PROJECT_ID).ask("GITLAB_PROJECT_ID:", required: true, default: ENV['GITLAB_PROJECT_ID'])
        key(:GITLAB_TOKEN).mask("GITLAB_TOKEN:", required: true, echo: true, default: ENV['GITLAB_TOKEN'])
        key(:GITLAB_URL_API).ask("GITLAB_URL_API:", required: true, default: ENV['GITLAB_URL_API'] || 'https://gitlab.com/api/v4')
        key(:GITLAB_EMAIL).ask("GITLAB_EMAIL:", required: true, default: ENV['GITLAB_EMAIL']) {|q| q.validate(/[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+/, "Invalid email address")}
        key(:GITLAB_LISTS).ask("GITLAB_LISTS:", required: true, default:  ENV['GITLAB_LISTS'] || 'To Do,Doing,Next Release,Staging')
        key(:GITLAB_NEXT_RELEASE_LIST).ask("GITLAB_NEXT_RELEASE_LIST:", required: true, default: ENV['GITLAB_NEXT_RELEASE_LIST'] || 'Next Release')
        key(:GIT_BRANCH_MASTER).ask("GIT_BRANCH_MASTER:", required: true, default: ENV["GIT_BRANCH_MASTER"] || 'master')
        key(:GIT_BRANCH_DEVELOP).ask("GIT_BRANCH_DEVELOP:", required: true, default: ENV["GIT_BRANCH_DEVELOP"] || 'developer')
        key(:GIT_BRANCHES_STAGING).ask("GIT_BRANCHES_STAGING:", required: true, default: ENV['GIT_BRANCHES_STAGING'] || 'staging')
        key(:SFLOW_TEMPLATE_RELEASE).ask("SFLOW_TEMPLATE_RELEASE:", required: true, default:  ENV["SFLOW_TEMPLATE_RELEASE"] || 'Version {version} - {date}')
        key(:SFLOW_TEMPLATE_RELEASE_DATE_FORMAT).ask("SFLOW_TEMPLATE_RELEASE_DATE_FORMAT:", required: true, default: ENV['SFLOW_TEMPLATE_RELEASE_DATE_FORMAT'] || 'Y/m/d')
      end
      config.set(:GITLAB_PROJECT_ID, value: result[:GITLAB_PROJECT_ID])
      config.set(:GITLAB_TOKEN, value: result[:GITLAB_TOKEN])
      config.set(:GITLAB_URL_API, value: result[:GITLAB_URL_API])
      config.set(:GITLAB_EMAIL, value: result[:GITLAB_EMAIL])
      config.set(:GITLAB_LISTS, value: result[:GITLAB_LISTS])
      config.set(:GITLAB_NEXT_RELEASE_LIST, value: result[:GITLAB_NEXT_RELEASE_LIST])
      config.set(:GIT_BRANCH_MASTER, value: result[:GIT_BRANCH_MASTER])
      config.set(:GIT_BRANCH_DEVELOP, value: result[:GIT_BRANCH_DEVELOP])
      config.set(:GIT_BRANCHES_STAGING, value: result[:GIT_BRANCHES_STAGING])
      config.set(:SFLOW_TEMPLATE_RELEASE, value: result[:SFLOW_TEMPLATE_RELEASE])
      config.set(:SFLOW_TEMPLATE_RELEASE_DATE_FORMAT, value: result[:SFLOW_TEMPLATE_RELEASE_DATE_FORMAT])
      config.write(file, force: true, create: true)

      print ("\n")
      success("Variáveis configuradas com sucesso!\n#{file}")
      
      if prompt.yes?("Vocẽ gostaria de voltar ao menu principal?")
        principal()
      end

      prompt.say(pastel.cyan("Até logo!"))
    end

    $GITLAB_PROJECT_ID = result[:GITLAB_PROJECT_ID]
    $GITLAB_TOKEN = result[:GITLAB_TOKEN]
    $GITLAB_URL_API = result[:GITLAB_URL_API]
    $GITLAB_EMAIL = result[:GITLAB_EMAIL]
    $GITLAB_LISTS = result[:GITLAB_LISTS].split(',')
    $GITLAB_NEXT_RELEASE_LIST = result[:GITLAB_NEXT_RELEASE_LIST]
    $GIT_BRANCH_MASTER = result[:GIT_BRANCH_MASTER]
    $GIT_BRANCH_DEVELOP = result[:GIT_BRANCH_DEVELOP]
    $GIT_BRANCHES_STAGING= result[:GIT_BRANCHES_STAGING].split(',')
    $SFLOW_TEMPLATE_RELEASE= result[:SFLOW_TEMPLATE_RELEASE]
    $SFLOW_TEMPLATE_RELEASE_DATE_FORMAT= result[:SFLOW_TEMPLATE_RELEASE_DATE_FORMAT]



  end

  private

  def codereview
    result = choice_branch('codereview')
    SFlow.send(:codereview, result[:branch_name])
  end

  def release_start
    SFlow.send(:release_start)
  end

  def release_finish
    result = choice_branch_release()

    SFlow.send(:release_finish, result[:branch_name])
  end

  def exit
    exit
  end

  def staging_branch
    result = choice_branch('staging')
    SFlow.send(result[:action], result[:branch_name])
  end

  def finish_branch
    result = choice_branch('finish')
    SFlow.send(result[:action], result[:branch_name])
  end

  def start_branch
    action =  prompt.select("Selecione o tipo de Branch:", symbols: { marker: ">" }) do |menu|
      menu.choice "Feature", :feature_start
      menu.choice "Bugfix", :bugfix_start
      menu.choice "Hotfix", :hotfix_start
    end

    result = prompt.collect do
      key(:external_id_ref).ask("Código de identificação da Branch, EX: [JiraIssueId, TicketOtrsID]:", required: true)
      key(:branch_description).ask("Descrição da branch:", required: true)
    end

    SFlow.send(action, result[:external_id_ref], result[:branch_description])
  end

  def choice_branch_release

    branchs_list =  Git.execute { "git branch -r --format='%(refname)' --sort=-committerdate  | grep release" }
    branchs_list = branchs_list.gsub('refs/remotes/origin/','').split("\n") - ($GIT_BRANCHES_STAGING + [$GIT_BRANCH_MASTER, $GIT_BRANCH_DEVELOP])
    branch_name = prompt.select("Selecione a Branch:", branchs_list ,symbols: { marker: ">" }, filter: true)
    return {
      branch_name: branch_name.delete("\n")
    }
  end

  def choice_branch type
    action = ''
    current_branch = Git.execute { "git branch --show-current" }
    branch_origin = prompt.select("Confirme a branch:", symbols: { marker: ">" }) do |menu|
      menu.choice "#{current_branch}(Atual)", :current
      menu.choice "Outra", :other_branch
    end

    case branch_origin
      when :current
        if current_branch.match(/\-feature\//)
          action = "feature_#{type}"
        elsif current_branch.match(/\-bugfix\//)
          action = "bugfix_#{type}"
        elsif current_branch.match(/\-hotfix\//)
          action = "hotfix_#{type}"
        end
        branch_name = current_branch.delete("\n")
      when :other_branch
        branchs_list =  Git.execute { "git branch -r --format='%(refname)' --sort=-committerdate" }
        branchs_list = branchs_list.gsub('refs/remotes/origin/','').split("\n") - ($GIT_BRANCHES_STAGING + [$GIT_BRANCH_MASTER, $GIT_BRANCH_DEVELOP])
        branch_name = prompt.select("Selecione a Branch:", branchs_list ,symbols: { marker: ">" }, filter: true)
        if branch_name.match(/\-feature\//)
          action = "feature_#{type}"
        elsif branch_name.match(/\-bugfix\//)
          action = "bugfix_#{type}"
        elsif branch_name.match(/\-hotfix\//)
          action = "hotfix_#{type}"
        end
    end
    return {
      action: action,
      branch_name: branch_name.delete("\n")
    }
  end


end