require 'tty-option'
class Command
  include TTY::Option

  usage do
    program "sflow"

    desc "Run a command in a new container"
  end

  flag :help do
    short "-h"
    long "--help"
    desc "Print usage"
  end

end
cmd = Command.new
cmd.parse