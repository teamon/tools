class Css
  def self.combine(normal, hover, new_name)
    combined = Image.new(normal.columns, normal.rows*2) {
      self.background_color = "transparent"
    }
    combined.composite!(normal, 0, 0, CopyCompositeOp)
    combined.composite!(hover, 0, normal.rows, CopyCompositeOp)
    combined.write(new_name)

    puts <<-CSS
     background: url(images/#{new_name}) 0 0;
     background-position: 0 #{normal.rows}px;
    CSS
    
  end
end