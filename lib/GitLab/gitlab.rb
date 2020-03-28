require 'json'

module GitLab
  autoload :User, 'GitLab/user.rb'
  autoload :Issue, 'GitLab/issue.rb'
  autoload :MergeRequest, 'GitLab/merge_request.rb'
  def self.request_post url, params 
    request = "#{$GITLAB_URL_API}/#{url}" 
    uri = URI(request) 
    req = Net::HTTP::Post.new(uri) 
    req['PRIVATE-TOKEN'] = $GITLAB_TOKEN 
    req.set_form_data(params)
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) {|http| http.request(req) } 
    JSON.parse(res.body)
  end

  def self.request_put url, params 
    request = "#{$GITLAB_URL_API}/#{url}" 
    uri = URI(request) 
    req = Net::HTTP::Put.new(uri) 
    req['PRIVATE-TOKEN'] = $GITLAB_TOKEN 
    req.set_form_data(params)
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) {|http| http.request(req) } 
    JSON.parse(res.body)
  end
  
  def self.request_get url 
    request = "#{$GITLAB_URL_API}/#{url}" 
    uri = URI(request) 
    req = Net::HTTP::Get.new(uri) 
    req['PRIVATE-TOKEN'] = $GITLAB_TOKEN 
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) {|http| http.request(req) } 
    JSON.parse(res.body)
  end



  def self.exist_issue? (iid)

  end

   
end