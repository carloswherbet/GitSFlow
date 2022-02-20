require 'tty-prompt'
require 'tty-progressbar'
require 'tty-config'
require 'tty-command'
require 'tty-option'
require 'tty-box'
require 'tty-editor'
require 'tty-file'
require 'tty-table'
module TtyIntegration
  def prompt
    TTY::Prompt.new(track_history: true, interrupt: :exit)
  end

  def pastel
    Pastel.new
  end

  def cmd
    TTY::Command.new(printer: :null)
  end

  def bar message =  "Realizando validações "
    TTY::ProgressBar.new( "#{message}[:bar]", incomplete: red, complete: green,total: 10)
  end

  def table
    TTY::Table
  end

  def success message
    print TTY::Box.success(message, border: :light)
  end
  
  def green ; pastel.on_green(" ") end
  def red ; pastel.on_red(" ") end
  def yellow ; pastel.on_yellow(" ") end
  
end