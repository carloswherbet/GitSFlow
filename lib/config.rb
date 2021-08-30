begin
  require 'dotenv'
  Dotenv.load(File.join( Dir.pwd, ".env"))
  rescue LoadError
  # Gem loads as it should
end

$GITLAB_PROJECT_ID = ENV['GITLAB_PROJECT_ID'].encode("UTF-8")
$GITLAB_TOKEN = ENV['GITLAB_TOKEN'].encode("UTF-8")
$GITLAB_URL_API = ENV['GITLAB_URL_API'].encode("UTF-8")
$GITLAB_EMAIL = ENV['GITLAB_EMAIL'].to_s.empty? ? Open3.popen3("git config --local user.email") { |i, o| o.read }.chomp : ENV['GITLAB_EMAIL'].encode("UTF-8")
$GITLAB_LISTS = ENV['GITLAB_LISTS'].encode("UTF-8").split(',') rescue nil
$GITLAB_NEXT_RELEASE_LIST = ENV['GITLAB_NEXT_RELEASE_LIST'].encode("UTF-8")
$GIT_BRANCH_MASTER= ENV["GIT_BRANCH_MASTER"].encode("UTF-8")
$GIT_BRANCH_DEVELOP= ENV["GIT_BRANCH_DEVELOP"].encode("UTF-8")
$GIT_BRANCHES_STAGING= ENV["GIT_BRANCHES_STAGING"].encode("UTF-8").split(',')rescue nil
$SFLOW_TEMPLATE_RELEASE= ENV["SFLOW_TEMPLATE_RELEASE"].to_s.empty? ? "Release version {version} - {date}" : ENV["SFLOW_TEMPLATE_RELEASE"].encode("UTF-8")
$SFLOW_TEMPLATE_RELEASE_DATE_FORMAT= ENV['SFLOW_TEMPLATE_RELEASE_DATE_FORMAT'].to_s.empty? ? 'Y/m/d': ENV['SFLOW_TEMPLATE_RELEASE_DATE_FORMAT'].encode("UTF-8") 