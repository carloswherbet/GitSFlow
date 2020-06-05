require 'json'

module GitLab
  autoload :User, 'GitLab/user.rb'
  autoload :Issue, 'GitLab/issue.rb'
  autoload :MergeRequest, 'GitLab/merge_request.rb'
  autoload :Comment, 'GitLab/comment.rb'
  autoload :List, 'GitLab/list.rb'

  def self.request_post url, params 
    request = "#{$GITLAB_URL_API}/#{url}" 
    uri = URI(request) 
    req = Net::HTTP::Post.new(uri) 
    req['PRIVATE-TOKEN'] = $GITLAB_TOKEN 
    req.set_form_data(params)
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) {|http| http.request(req) } 
    check_authorized res
    check_errors_404 res
    JSON.parse(res.body)
  end

  def self.request_put url, params 
    request = "#{$GITLAB_URL_API}/#{url}" 
    uri = URI(request) 
    req = Net::HTTP::Put.new(uri) 
    req['PRIVATE-TOKEN'] = $GITLAB_TOKEN 
    req.set_form_data(params)
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) {|http| http.request(req) } 
    check_authorized res
    check_errors_404 res
    JSON.parse(res.body)
  end
  
  def self.request_get url 
    request = "#{$GITLAB_URL_API}/#{url}" 
    uri = URI(request) 
    req = Net::HTTP::Get.new(uri) 
    req['PRIVATE-TOKEN'] = $GITLAB_TOKEN
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) {|http| http.request(req) } 
    check_authorized res
    check_errors_404 res
    JSON.parse(res.body)
  end

  def self.check_errors_404 res
    if res.code == "404"
      raise "Project: #{$GITLAB_PROJECT_ID} \n#{JSON.parse(res.body)['message']}"
    end
  end

  def self.check_authorized res
    if res.code == "401"
      raise "Unauthorized. Check GITLAB_TOKEN and file .env"
    end
  end

  def self.create_labels
    url = "projects/#{$GITLAB_PROJECT_ID}/labels"
    params = [ 
      {name: 'feature', color: "#5CB85C"},
      {name: 'default_branch', color: "#34495E"},
      {name: 'version', color: "#34495E"},
      {name: 'hotfix', color: "#d9534f"},
      {name: 'production', color: "#F45D43"},
      {name: 'urgent', color: "#d9534f"},
      {name: 'bugfix', color: "#D9534F"},
      {name: 'changelog', color: "#0033CC"},
      {name: 'Staging', color: "#FAD8C7"},
      ]
    $GIT_BRANCHES_STAGING.each do |staging|
      params << {name: staging, color: '#FAD8C7'}
    end
    
    params << {name: $GITLAB_NEXT_RELEASE_LIST, color: '#34495E'}
    
    params.each do |label_params|
      self.request_post(url, label_params)
    end

  end
   
end