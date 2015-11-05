require 'sinatra'
require 'data_mapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/wiki.db") #This directs DataMapper to open the wiki.db database or create it if it does not exist  
# may need dm-sqlite-adapter if not installed

class User #this defines the class of User as an object in the wiki.rb database
	include DataMapper::Resource
	property :id, Serial
	property :username, Text, :required => true
	property :password, Text, :required => true
	property :date_joined, DateTime
	property :edit, Boolean, :required => true, :default => false
end
  
DataMapper.finalize.auto_upgrade!  

helpers do #This section determines whether users have permission to edit the content displayed on the Home page.
	def protected!
		if authorized?
			return
		end
		redirect '/denied'
	end

	def authorized?
		if $credentials != nil
			@Userz = User.first(:username => $credentials[0])
			if @Userz
				if @Userz.edit == true
					return true
				else
					return false
				end
			else
				return false
			end
		end
	end
end

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
    @words = len3.to_s 
    
    erb :home
end 

get '/about' do     
    erb :about
end

get '/create' do 
    
    erb :create
end

get '/edit' do 
    info = "" 
    file = File.open("wiki.txt") 
    file.each do |line| 
                info = info + line 
    end 
    file.close 
    @info = info 
    
    erb :edit               # call up edit function
end

put '/edit' do
     info = "#{params[:message]}"
     @info = info
     file = File.open("wiki.txt","w")
     file.puts @info
     file.close
     redirect'/'
end

get '/login' do
    erb :login
end

post '/login' do  #This section manages user authentication
	$credentials = [params[:username],params[:password]]#This creates an object '$credentials' using parameters for strings inputed from the '/login' view.
	@Users = User.first(:username => $credentials[0]) #This compares the usernames stored in the database with the username the user has entered.
	if @Users #When the username is found to exist, the following occurs:
		if @Users.password == $credentials[1] #This compares the password entered by the user with the password associated with the username in the database.
			redirect '/' #If the passwords match, the user is redirected to the homepage, having logged in. 
		else
			$credentials = ['',''] #Otherwise the credentials they have entered are voided 
			redirect '/wrongaccount' #and they are directed to the "/wrongaccount" page.
		end
	else #the same occurs when the username the user has attempted to login with does not match an existing username
		$credentials = ['',''] 
		redirect '/wrongaccount'
	end
end
get '/wrongaccount' do
    erb :wrongaccount
end

get '/user/:uzer' do
    @Userz = User.first(:username => params[:uzer])
    if @Userz != nil
        erb :profile
    else
        redirect '/noaccount'
    end
end

get '/createaccount' do
    erb :createaccount
end

post '/createaccount' do
    n = User.new  
    n.username = params[:username]
    n.password = params[:password]   
    n.date_joined = Time.now
    if n.username == "Admin" and n.password == "Password"
        n.edit = true
    end
    n.save   
    redirect '/'
end

get '/login' do
    $credentials=['','']
    redirect '/'
end

get '/logout' do #when users select this link, it voids their credentials (and therefore their permissions) and redirects them to the home page. 
	$credentials = ['','']
	redirect '/'
end

get '/create' do #this opens the "/create" page and creates a global variable (@extant) for the text currently displayed on the home page, which serves as the default text in the textarea in the "/create" view. 
	protected!
	file = File.read("textfile.txt")
	info = file
	@extant = info
	erb :create
end

post '/save' do
	#The following 5 lines writes the contents of the textarea in the "/create" page to "textfile.txt" where it will be read by the Home page.
	info = "#{params[:message]}"
	@info = info
	file = File.open("textfile.txt", "w")
	file.puts @info
	file.close
	#The next 4 lines writes the saved text to the logfile "logfile.txt". It does this by assigning a variable to the text already in the log file (log1) and concatenating it with the additional text sent from the "/create" page.
	log1 = File.read("logfile.txt")
	log2 = File.open("logfile.txt", "w")
	log2.puts log1 + @info
	log2.close
	redirect "/" #This redirects the user to the home page after "save" is pressed, so they can see the content they have amended.
	erb	:create
end

get '/cancel' do
	redirect '/'
	erb	:edit
end

get '/admincontrols' do #This allows the administrator to access the Administration page
	protected!
	@list2 = User.all :order => :id.desc
	erb :admincontrols
end

get '/user/:uzer' do
	@Userz = User.first(:username => params[:uzer])
	if @Userz != nil
	erb :profile
	else
	redirect '/noaccount'
	end
end

put '/user/:uzer' do
	n = User.first(:username => params[:uzer])
	n.edit = params[:edit] ? 1 : 0
	n.save
	redirect '/'
end

get '/user/delete/:uzer' do  
	protected!
  	n = User.first(:username => params[:uzer])
	if n.username == "Admin"
		erb :denied
	else
		n.destroy   
		@list2 = User.all :order => :id.desc
		erb :admincontrols
	end
end

get '/reset' do #This allows the administrator to reset the text stored in "textfile.txt" to a 'default' text stored in "default.txt". This is then read by the homepage ("/"). As with the "/save" function, it writes the text to the logfile. 
	filed = File.read("default.txt")
	info = "#{filed}"
	@info = info
	file = File.open("textfile.txt", "w")
	file.puts @info
	file.close
	log1 = File.read("logfile.txt")
	log2 = File.open("logfile.txt", "w")
	log2.puts log1 + @info
	log2.close
	redirect '/'
	erb	:admincontrols
end 


not_found do  
    status 404  
    redirect '/'  
end
