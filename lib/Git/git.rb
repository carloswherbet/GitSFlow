require 'tty_integration.rb'
module Git
  extend TtyIntegration

  def self.checkout(branch, options = :with_fetch)
    fetch(branch) if options == :with_fetch
    # prompt.say(pastel.yellow("[checkout] ") + pastel.green(branch))
    execute {"git checkout #{branch}"}
    self.pull branch  if options == :with_fetch
  end
  
  def self.merge from, to
    # self.checkout(from)
    checkout(to, :local)
    # prompt.say(pastel.yellow('[Merge] '))
    # prompt.say(pastel.green("#{from} "))
    # prompt.say(pastel.yellow("into "))
    # prompt.say(pastel.green("#{to} \n\n"))
    result = cmd.run!("git pull origin #{from}")

    # processs, stderr , stdout= Open3.popen3("git pull origin #{from}") do |i, o, stderr, wait_thr|
    #   [wait_thr.value, stderr.read, o.read] 
    # end
    if result.success?
      return result.out
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
        execute { ('git merge --abort') }
        raise 'Aborting...'
      end

    end

    # execute {"git pull origin #{from}"}
  end

  def self.delete_branch branch
    # print "Delete branch: ".yellow
    # print "#{branch} \n\n".green
    execute {("git checkout develop && git branch -D #{branch}") }
  end

  def self.reset_hard from, to
    self.fetch from
    self.checkout(to)
    # print "Reset --hard:  #{to} is equal: ".yellow
    # print "origin/#{from}\n".green
    execute { "git reset --hard origin/#{from}\n\n" }
  end
  
  def self.push branch
    # prompt.say(pastel.yellow('[Push]: '))
    # prompt.say(pastel.green("#{branch}\n\n"))
    execute {"git push origin #{branch}"}
  end

  def self.push_force branch
    # print "Push --force: ".yellow
    # print "#{branch}\n\n".green
    execute {"git push origin #{branch} -f"}
  end

  def self.log_last_changes branch
    execute {%{git log origin/#{branch}..HEAD --oneline --format="%ad - %B}}
  end

  def self.pull branch
    # prompt.say(pastel.yellow('[Pull]: '))
    # prompt.say(pastel.yellow("#{branch}\n\n"))
    execute { "git pull origin #{branch}" }
  end

  def self.fetch branch
    # prompt.say(pastel.yellow('[Fetch]: '))
    # prompt.say(pastel.yellow("origin/#{branch}\n\n"))
    execute { "git fetch origin #{branch}" }
  end

  def self.new_branch branch
    # prompt.say(pastel.yellow('Create new branch: '))
    # prompt.say(pastel.green( "#{branch}\n"))
    execute {  "git checkout -b #{branch}" }
  end


  def self.exist_branch? branch
    execute {"git fetch origin #{branch}"}
  end

  private

  def self.execute

    result= cmd.run!(yield)

    raise result.err if result.failed?
    return result.out
  end
end