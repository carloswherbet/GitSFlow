module Git
  def self.checkout(branch, options = :with_fetch)
    fetch(branch) if options == :with_fetch
    print "checkout: ".yellow
    print "#{branch}\n\n".green
    system "git checkout #{branch}"
    self.pull branch
  end
  
  def self.merge from, to
    # self.checkout(from)
    checkout(to, :local)
    print "Merge ".yellow
    print "#{from} ".green
    print "into ".yellow
    print "#{to} \n\n".green
    processs, stderr , stdout= Open3.popen3("git pull origin #{from}") do |i, o, stderr, wait_thr|
      [wait_thr.value, stderr.read, o.read] 
    end
    if processs.success?
      return stdout
    else
      print "Conflicts on merge!".yellow.bg_red
      print "\n\nResolve conflicts and commit. \n"
      print "After type '1' for to continue or '0' for abort\n".yellow
      choice = STDIN.gets.chomp
      print "\n#{choice}, "
      print "ok!\n".green

      case choice
      when '1'
        print "Continuing...\n\n"
      else
        print "Aborting merge...\n\n"
        system ('git merge --abort')
        raise 'Aborting...'
      end

    end

    # execute {"git pull origin #{from}"}
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

  def self.push_force branch
    print "Push --force: ".yellow
    print "#{branch}\n\n".green
    execute {"git push origin #{branch} -f"}
  end

  def self.log_last_changes branch
    execute {"git log origin/#{branch}..HEAD --oneline --format='%ad - %B'"}
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
    processs, stderr , stdout= Open3.popen3(yield) do |i, o, stderr, wait_thr|
      [wait_thr.value, stderr.read, o.read] 
    end
    if processs.success?
      return stdout
    end
    raise "#{stderr}"
  end
end