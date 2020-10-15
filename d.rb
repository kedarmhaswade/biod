#!/usr/bin/env ruby

require 'nokogiri'

class Page
  attr_reader :affix_tables
  
  def initialize(path)
    doc = Nokogiri::HTML(File.open(path))
    tables_css = doc.css('//table.wikitable')
    #puts("class: #{tables_css.class}, length: #{tables_css.length}")
    @affix_tables = Array.new
    tables_css.each do |tcss|
      t = Table.new tcss
      affix_tables << t if t.affix?
    end
  end

  def search(arg)
    @affix_tables.each_with_index do |af, i|
      af.search arg
    end
  end

  def quiz
    trand = Random.new(Time.now.usec)
    loop do
      affix_tables[trand.rand(affix_tables.length)].quiz()
    end
  end
end

class Table
  attr_reader :heading
  attr_reader :rows
  attr_reader :element

  def initialize(element) # the Nokogiri::XML::Element
    @element = element
    trs = element.css('tr')
    if not trs.empty?
      heading_css = trs[0].css('th')
      @heading = Heading.new(heading_css)
      @affix = @heading.affix?
      @rows = Array.new
      #puts("trs.len : #{trs.length}")
      2.upto trs.length do |i|
        rows << Row.new(trs[i-1])
      end
    end
  end
  def affix?
    return @heading.affix?
  end

  def search(arg)
    #puts("finding #{arg}")
    @rows.each do |r|
      r.search arg
    end
  end

  def quiz
    rrand = Random.new(Time.now.usec)
    r = @rows[rrand.rand(@rows.length)]
    puts("What does #{r.affix} mean? (press enter to show, ^C to quit)")
    begin
      gets
    rescue Interrupt
      puts "Exiting ..."
      exit 130
    end
    puts("#{r.to_s}")
  end

end

class Heading
  attr_reader :cols
  def initialize(heading_css)
    @affix = heading_css[0].text.start_with?('Affix')
    @cols = Array.new
    heading_css.each do |th|
      @cols << th.text
    end
  end
  def affix?
    return @affix
  end
end

class Row
  attr_reader :affix, :meaning, :root, :examples
  def initialize(row_css)
    td_css = row_css.css('td')
    @affix = td_css[0].text.chomp
    @meaning = td_css[1].text.chomp
    @root = td_css[2].text.chomp
    @examples = td_css[3].text.chomp if td_css[3] != nil
  end

  def search(arg) 
    if @affix.match(arg)
      puts to_s
    end
  end
  
  def to_s
    sa = "prefix"
    sa = "suffix" if @affix.start_with?('-')
    <<-TOS
        #{sa}: #{@affix}
       meaning: #{@meaning}
      examples: #{@examples}
          root: #{@root}
      
    TOS
  end
end

# main program

command = ARGV.shift
arguments = ARGV

page = Page.new('d.html')

if command.start_with? 'f' or command.start_with? 's'
  # search or find
  page.search arguments[0]
elsif command.start_with? 'q'
  page.quiz
end
