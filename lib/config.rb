require 'dotenv'
Dotenv.load('./sflow.env')
$GITLAB_PROJETO_ID = ENV['GITLAB_PROJETO_ID']
$GITLAB_TOKEN = ENV['GITLAB_TOKEN']
$GITLAB_URL_API = ENV['GITLAB_URL_API']
$GITLAB_EMAIL = ENV['GITLAB_EMAIL'] == "" ? Open3.popen3("git config --global user.email") { |i, o| o.read }.chomp : ENV['GITLAB_EMAIL']
