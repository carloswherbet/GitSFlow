module Git
  def self.checkout branch
    print "checkout: ".yellow
    print "#{branch}\n\n".green
    system "git checkout #{branch}"
  end
  
  def self.merge from,to
    self.checkout(to)
    print "Merge ".yellow
    print "#{from} ".green
    print "into ".yellow
    print "#{to} \n\n".green
    system "git pull origin #{from}"
  end
  
  def self.push branch
    print "Push: ".yellow
    print "#{branch}\n\n".green
    execute {"git push origin #{branch}"}
  end

  def self.pull branch
    print "Pull: ".yellow
    print "#{branch}\n\n".green
    system "git pull origin #{branch}"
  end

  def self.fetch branch
    print "Fetch: ".yellow
    print "#{branch}\n\n".green
    system "git fetch origin #{branch}"
  end

  def self.new_branch branch
    print "Create new branch: ".yellow
    print "#{branch}\n".green
    
    system  "git checkout -b #{branch}"
  end

  private

  def self.execute
    processs, stderr = Open3.popen3(yield) do |i, o, stderr, wait_thr|
        [wait_thr.value, stderr.read] 
    end
    if processs.success?
      # print "Success!\n\n".green
    else
        raise "\n\n #{stderr}".red
    end
  end

end