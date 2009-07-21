module Tools
  desc "hex2rgb [hex]", "convert hex color to rgb decimal color"
  def hex2rgb(hex)
    hex.gsub!('#', '')
    if hex.size == 3
      rgb = hex.split(//).map {|e| (e*2).to_i(16) }
    elsif hex.size == 6
      rgb = hex.scan(/.{2}/).map {|e| e.to_i(16)}
    else
      puts "Invalid HEX"
      exit
    end
  
    puts "rgb(#{rgb.join(", ")})"
    rgb.map! {|e| e / 255.0 }
    puts "rgb(#{rgb.join(", ")})"
  end
  
  desc "rgb2hex R G B", "convert rgb color to hex decimal color"
  def rgb2hex(r,g,b)
    puts "#" + [r,g,b].map { |val|
      val = val.to_f * 255 if val["."]
      val = val.to_i.to_s(16)
      val = "0#{val}" if val.size == 1
      val
    }.join
  end
  
  desc "ifconfig", "a bit nicer ifconfig"
  def ifconfig
    `ifconfig`.scan(/(\S+?):.+\n.+\n.+inet (.+)/) { |name, var| puts "#{name}: #{var}" }
  end
  
  desc "webkit2png [options] [url]", "save full webpage to png file"
  def webkit2png(*args)
    system("python #{File.dirname(__FILE__)}/webkit2png.py #{args.join(" ")}")
  end
  
  desc "pwr", "points counter"
  def pwr
    points = {}
    %w[mat fiz pol ang].each do |a|
      print "#{a}: "
      p = STDIN.gets.chomp
      points[a.to_sym] = p[-1,1] == 'r' ? p[0, p.length-1].to_i * 2.5 : p.to_i
    end
    puts points.inspect
    w = points[:mat] + points[:fiz] + 0.1 * points[:pol] + 0.1 * points[:ang]
    puts "-----\nrazem: #{w}"
  end
  
  desc "ggping", "i do not remember..."
  def ggping
    require 'net/http'

    def check(ip)
      [80, 8074].each do |port|
        if o = `nmap #{ip[0]} -p #{port} -PN` =~ %r|#{port}/tcp open|
          ip[1] = true
          return
        end
      end
      ip[1] = false
    end

    # servers = (1..255).to_a.map {|i| ["91.197.13.#{i}"]}
    servers = [["91.197.13.2"], ["91.197.13.2"], ["91.197.13.26"], ["91.197.13.24"], ["91.197.13.29"], ["91.197.13.12"], ["91.197.13.17"], ["91.197.13.18"], ["91.197.13.13"], ["91.197.13.28"], ["91.197.13.27"], ["91.197.13.25"], ["91.197.13.21"], ["91.197.13.20"], ["91.197.13.33"], ["91.197.13.6"], ["91.197.13.19"], ["91.197.13.7"], ["91.197.13.4"], ["91.197.13.14"], ["91.197.13.5"]]

    threads = []
    servers.each do |server|
      threads << Thread.new(server) {|ip| check(ip)}
    end

    threads.each {|t| t.join}

    on, off = 0, 0
    servers.each do |server|
      if server[1]
        on += 1
        success "#{server[0]}: ON"
      else
        off += 1
        error "#{server[0]}: OFF"
      end
    end

    puts "on: #{on}, off: #{off}"
  end
  
  desc "pastie", "send input to pastie"
  def pastie
    require "net/http"
    require "cgi"

    http = Net::HTTP.new("pastie.org")
    data = {:paste => {
      :body => CGI.escape(readlines.join),
      :parser => "ruby",
      :restricted => 1,
      :authorization => 'burger'
    }}.to_query_string
    resp, body = http.post("/pastes", data)
    puts resp.response['Location']
  end
  
  desc "colors", "show console colors"
  def colors
    (30..37).each do |color|
      puts "\033[0;#{color}mThe quick brown fox jumps over the lazy dog\033[0m"
      puts "\033[1;#{color}mThe quick brown fox jumps over the lazy dog\033[0m"
    end
  end
  
  desc "download", "download all files"
  def download
    readlines.each do |file|
      system "curl -O #{file}"
    end
  end
  
  desc "links [url]", "get all .mp4 links from website"
  def links(url)
    require 'mechanize'
    puts WWW::Mechanize.new.get(url).links.select {|e| e.href =~ /mp4$/ }.map {|e| e.href}.uniq
  end
  
  desc "haml_server [filepath]", "serve page rendered by haml"
  def haml_server(filepath)
    require 'sinatra'
    require "haml"
    get "/" do
      Haml::Engine.new(File.read(path)).render
    end
  end
  
  desc "code_stats", "Code stats for ruby files"
  def code_stats
    Stats.show
  end
  
  desc "combine_image [normal] [hover] [new_name]", "combine 2 images into one"
  def combine_image(normal, hover, new_name)
    normal = ImageList.new(normal)
    hover = ImageList.new(hover)
    
    Css.combine(normal, hover, new_name)
  end
  
  desc "combine_all [files]", "combine 2 images: NAME.ext and NAME_hover.ext into one"
  def combine_images(*args)
    args.each do |filename|
      ext = filename.split(".").last
      filename = filename.sub(".#{ext}", "")
      new_name = "#{filename}_combined.#{ext}"
      
      normal = ImageList.new("#{filename}.#{ext}")
      hover = ImageList.new("#{filename}_hover.#{ext}")
      
      Css.combine(normal, hover, new_name)
    end
  end
  
  desc "menu", "-- some description --"
  def menu
    print "Height: "
    height = STDIN.gets.chomp
    print "Elements: "
    elements = STDIN.gets.chomp.split(",").map {|e| e.to_i}
    css = "
    a {
      height: #{height}px;
      background-image: url('/images/.png');
    }
    "
    total = 0
    elements.each_with_index do |e,i|
      css << "
    a.menu#{i} {
      width: #{e}px;
      background-position: #{total}px 0;
    }
    a.menu#{i}:hover {
      width: #{e}px;
      background-position: #{total}px #{height}px;
    }
    "
      total -= e
    end

    puts css
    puts "Total width: #{total.abs}"
  end
  
  desc "gem_uninstall [name]", "uninstall gems that starts with NAME"
  def gem_uninstall(name)
    system("gem list #{name} --no-versions | xargs gem uninstall")
  end
  

  
end
