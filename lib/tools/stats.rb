class Stats
  COLUMNS = [[:name, 10], [:lines, 10], [:loc, 10], [:classes, 10], [:modules, 10], [:methods, 10]]
  
  attr_accessor :data, :name
  def initialize(name = nil)
    @name = name
    @data = {}
    [:lines, :loc, :classes, :modules, :methods].each do |name|
      @data[name] = 0
    end
  end
  
  def add!(stats)
    stats.data.each_pair do |key, value|
      @data[key] += value
    end
  end  
  
  def show(color = nil)
  end
    
    
  class << self
    
    
    def count
      @code = Stats.new("code")
      @test = Stats.new("test")


      Dir["**/*.rb"].each do |filepath|
        stats = Stats.new

        File.readlines(filepath).each do |line|
          stats.data[:lines]    += 1
          stats.data[:loc]      += 1 unless line =~ /^\s*$/ || line =~ /^\s*#/
          stats.data[:classes]  += 1 if line =~ /class [A-Z]/
          stats.data[:modules]  += 1 if line =~ /module [A-Z]/
          stats.data[:methods]  += 1 if line =~ /def [a-z]/
        end

        if filepath =~ /^spec|test/
          color = :cyan
          @test.add!(stats)
        else
          colro = nil
          @code.add!(stats)
        end
        
        puts "#{filepath} (#{stats.data[:lines]} / #{stats.data[:loc]} LOC)".colorize(color)
            
        
        @total = Stats.new("total")
        @total.add! @code
        @total.add! @test
      end
    end
    
    def show
      count
      separator
      header
      separator
      line @code
      separator
      line @test, :cyan
      separator
      line @total, :red
      separator
      summary
    end
        
    def separator
      puts "+" + COLUMNS.map {|name, width| "-" * width}.join("+") + "+"
    end
    
    def header
      puts "|" + COLUMNS.map {|name, width| " #{name} ".ljust(width).colorize(:green) }.join("|") + "|"
    end
    
    def line(stats, color = nil)
      puts "|" + COLUMNS.map {|name, width| (name == :name ? " #{stats.name} ".to_s.ljust(width) : " #{stats.data[name].to_s.reverse.scan(/(.{1,3})/).join(".").reverse} ".to_s.rjust(width)).colorize(color) }.join("|") + "|"
    end
    
    def summary
      puts "code to test radio:".ljust(COLUMNS.inject(0) {|s,i| s+i.last }) + ("1:%0.2f" % (@test.data[:loc].to_f / @code.data[:loc].to_f)).colorize(:magenta)
    end
    
    
  end

end