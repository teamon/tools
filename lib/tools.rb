require File.dirname(__FILE__) + "/tools/utils"

module Tools
  include ::ColorfulMessages

  protected
  
  class << self
  
    def desc(execution, description)
      @description = [execution.to_s, description.to_s]
    end
    
    def run(argv)
      if argv.size == 0
        puts "Task not found"
        puts
        return list 
      end
      
      Class.new { include Tools }.new.send(argv.shift, *argv)
    end
        
    def list
      puts "Availible tasks:"
      
      max = @descriptions.max {|a, b| a.last.first.size <=> b.last.first.size}.last.first.size
      
      @descriptions.each_pair do |name, desc|
        puts "#{desc.first.ljust(max)}  #{desc.last}"
      end
    end
  
    def method_added(method_name)
      @descriptions ||= {}
      @descriptions[method_name] = @description
    end
    
  end
end

require File.dirname(__FILE__) + "/tools/stats"
require File.dirname(__FILE__) + "/tools/tasks"
