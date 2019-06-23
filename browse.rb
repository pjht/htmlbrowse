require "nokogiri"
require "colorize"
require "css_parser"
include CssParser
$mode=""
pages={}

pages["/"]=<<-ENDPAGE
<html>
<p>Welcome to my website!</p>
<p><b>Bold</b></p>
<p><i>Italics</b></p>
<p>
<a href="/page">A page</a>
<br>
<a href="/anotherpage">Another page</a>
</p>
</html>
ENDPAGE

pages["/page"]=<<-ENDPAGE
<html>
<p>A page</p>
<p><b><i>Bold and Italic</i>hi</b></p>
<p>
<a href="/">Home</a>
<pr>
<a href="/anotherpage">Another page</a>
</p>
</html>
ENDPAGE

pages["/anotherpage"]=<<-ENDPAGE
<html>
<p>Here is more info</p>
<p>
<a href="/page">A page</a>
<br>
<a href="/">Home</a>
</p>
</html>
ENDPAGE
currentpage="/"
color_codes={
    :black   => 0, :light_black    => 30,
    :red     => 1, :light_red      => 61,
    :green   => 2, :light_green    => 62,
    :yellow  => 3, :light_yellow   => 63,
    :blue    => 4, :light_blue     => 64,
    :magenta => 5, :light_magenta  => 65,
    :cyan    => 6, :light_cyan     => 66,
    :white   => 7, :light_white    => 67,
    :default => 9
  }
def showtext(text)
  case $mode
  when "b"
    print "\e[1m"
  when "i"
    print "\e[3m"
  when "ib"
    print "\e[1m"
    print "\e[3m"
  end
  print text
  print "\e[0m"
end
def dispelem(elem)
  if elem.class==Nokogiri::XML::Text
    showtext(elem.to_s)
    return
  end
  case elem.name
  when "p"
    elem.children.each do |elem|
      dispelem(elem)
    end
    puts "\n"
  when "br"
    puts "\n"
  when "a"
    $links.push(elem["href"])
    showtext(elem.children[0])
    print "[#{$linkid}]"
    $linkid+=1
  when "b"
    if $mode=="i"
      $mode="ib"
    else
      $mode="b"
    end
    elem.children.each do |elem|
      dispelem(elem)
    end
    if $mode=="ib"
      $mode="i"
    else
      $mode=""
    end
  when "i"
    if $mode=="b"
      $mode="ib"
    else
      $mode="i"
    end
    elem.children.each do |elem|
      dispelem(elem)
    end
    if $mode=="ib"
      $mode="b"
    else
      $mode=""
    end
  end
end
while true
  $links=[]
  $linkid=1
  system("clear")
  doctext=pages[currentpage].gsub("\n","")
  doc=Nokogiri::Slop(doctext)
  doc.html.body.children.each do |elem|
    dispelem(elem)
  end
  print "Link ID/exit:"
  id=gets.chomp!.downcase
  break if id=="exit"
  currentpage=$links[id.to_i-1]
end
