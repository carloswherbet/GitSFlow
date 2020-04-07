module Git
  def self.checkout branch
    print "checkout: ".yellow
    print "#{branch}\n\n".green
    system "git checkout #{branch}"
    self.pull branch
  end
  
  def self.merge from, to
    # self.checkout(from)
    self.checkout(to)
    print "Merge ".yellow
    print "#{from} ".green
    print "into ".yellow
    print "#{to} \n\n".green
    execute {"git pull origin #{from}"}
  end

  def self.delete_branch branch
    print "Delete branch: ".yellow
    print "#{branch} \n\n".green
    system("git checkout develop && git branch -D #{branch}")
  end

  def self.reset_hard from, to
    self.fetch from
    self.fetch to
    self.checkout(to)
    print "Reset --hard:  #{to} is equal: ".yellow
    print "#{from}\n".green
    system "git reset --hard origin/#{from}\n\n"
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


  def self.exist_branch? branch
    execute {"git fetch origin #{branch}"}

  end
    

  private

  def self.execute
    processs, stderr = Open3.popen3(yield) do |i, o, stderr, wait_thr|
        [wait_thr.value, stderr.read] 
    end
    if processs.success?
      # print "Success!\n\n".green
    else
        raise "#{stderr}"
    end
  end

end