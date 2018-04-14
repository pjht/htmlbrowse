require "nokogiri"
$mode=""
pages={}

pages["/"]=<<-ENDPAGE
<html>
<p>Welcome to my website!</p>
<p><b>Bold</b></p>
<p><i>Italics</b><p>
<a href="/page">A page</a>
<a href="/anotherpage">Another page</a>
</html>
ENDPAGE

pages["/page"]=<<-ENDPAGE
<html>
<p>A page</p>
<p><b><i>Bold and Italic</i></b></p>
<a href="/">Home</a>
<a href="/anotherpage">Another page</a>
</html>
ENDPAGE

pages["/anotherpage"]=<<-ENDPAGE
<html>
<p>Here is more info</p>
<a href="/page">A page</a>
<a href="/">Home</a>
</html>
ENDPAGE
currentpage="/"

def showtext(text,nline=true)
  case $mode
  when "b"
    puts "\e[1m#{text}\e[0m" if nline
    print "\e[1m#{text}\e[0m" if !nline
  when "i"
    puts "\e[3m#{text}\e[0m" if nline
    print "\e[3m#{text}\e[0m" if !nline
  when "ib"
    puts "\e[1m\e[3m#{text}\e[0m" if nline
    print "\e[1m\e[3m#{text}\e[0m" if !nline
  when ""
    puts text if nline
    print text if !nline
  end
end
def dispelem(elem)
  if elem.class==Nokogiri::XML::Text
    showtext(elem)
    return
  end
  case elem.name
  when "p"
    elem.children.each do |elem|
      dispelem(elem)
    end
  when "a"
    $links.push(elem["href"])
    showtext(elem.children[0],false)
    puts "[#{$linkid}]"
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
    $mode=""
  when "i"
    if $mode=="b"
      $mode="ib"
    else
      $mode="i"
    end
    elem.children.each do |elem|
      dispelem(elem)
    end
    $mode=""
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
