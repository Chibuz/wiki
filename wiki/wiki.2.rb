require 'sinatra'

$myinfo = "Emmanuel Iwegbu"              # replace Firstnameand Lastname with your name
@info = ""

def readFile(filename) 
    info = "" 
    file = File.open(filename) 
    file.each do |line| 
        info = info + line 
    end 
    file.close 
    $myinfo = info  
end 


get '/' do 
    info =  "Hello there!" 
    len = info.length 
    len1 = len 
    readFile("wiki.txt") 
    @info = info + " " + $myinfo  
    len = @info.length 
    len2 = len - 1 
    len3 = len2 - len1      
    @info = @info + len3.to_s 
    '<html><body>' + 
    '<b>Menu</b><br>' + 
    '<a href="/">Home</a><br>' + 
    '<a href="/create">Create</a><br>' + 
    '<a href="/about">About</a><br>' +      
    '<a href="/edit">Edit</a><br>' +      
    '<br><br>' + @info +  
    '</body></html>' 
end 

get '/about' do 
    '<html><body>' + 
    '<b>Menu</b><br>' + 
    '<a href="/">Home</a><br>' + 
    '<a href="/create">Create</a><br>' + 
    '<a href="/about">About</a><br>' + 
    '<a href="/edit">Edit</a><br>' + 
    '<br><br>' +  
    '<h2>About us</h2>' + 
    '<p>This wiki was created by </p>' + $myinfo +
    '<p>Student ID:51555401</p>' + '</Student>' +
    '<p>Computer science student' + '<Computer>' +
    '<p>University of Aberdeen' +  '<University>' +
    '</body></html>' 
end

get '/create' do 
    '<html><body>' + 
    '<b>Menu</b><br>' + 
    '<a href="/">Home</a><br>' + 
    '<a href="/create">Create</a><br>' + 
    '<a href="/about">About</a><br>' + 
    '<a href="/edit">Edit</a><br>' + 
    '<br><br>' + 
    '<section id="add">' +
    '<p>Enter text in the field below to save.</p>' +
    '<form action="/save" method="post">' +
    '<textarea rows="20" cols="90" name="message" placeholder="<%= @extant %>">' +
    '</textarea> <br /r>' +
    '<button type="submit" name="save">save</button>' +
    '<button type="reset" name="cancel" onclick=location.href="/">Cancel</button>' +
    '</form>' +
    '</section>' + 
    '<h2>This is your own personal create page!</h2>' +
    '<section id="add">'  + $myinfo + '</section>' + 
    '</body></html>'
end

not_found do  
    status 404  
    redirect '/'  
end
