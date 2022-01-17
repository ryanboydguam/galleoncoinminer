require 'json'
require 'zip'
require "fileutils"
require "down"
require 'seven_zip_ruby'
config_value = Hash.new
mining_software_data=nil
config_file_option=false
miner_download_link=""
miner_file_version=""
puts "Hello welcome to galleoncoin Miner 1.0"
puts "This miner supports galleoncoin.club untill there are future updates"
puts "_^V^_^V^_^V^_^V^_^V^_^V^_^V^_^V^_^V^_^V^_^V^_"
puts "              |    |    | "
puts "             )_)  )_)  )_) "
puts "            )___))___))___)\ "
puts "           )____)____)_____)\\"
puts "         _____|____|____|____\\\__ "
puts " ---------\                   /---------"
puts "  ^^^^^ ^^^^^^^^^^^^^^^^^^^^^"
puts "    ^^^^      ^^^^     ^^^    ^^"
puts "         ^^^^      ^^^"
puts "_^V^_^V^_^V^_^V^_^V^_^V^_^V^_^V^_^V^_^V^_^V^_"
puts "Please report all bugs to ryan#8929"
def get_mining_address #asks for the users mining address
  puts "To get started, give me your galleoncoin address"
	galleoncoin_address = $stdin.gets.chomp
  return galleoncoin_address
end
def look_for_setup
  config_search=false
  dir = Dir.entries(Dir.getwd)
  dir.each do |var|
    if var.to_s.match("galleonminer.txt")
      config_search=true
    else
    end
  end
  return config_search
end
def ask_user_about_config
  puts "A config file has been found!"
  puts "Would you like to use this config file? [yes,no]"
  response = $stdin.gets.chomp
  case response
		# If confirm, create the file
		when 'Y', 'y', 'j', 'J', 'yes', 'Yes'
		puts "OK we will use this config file"
    return true
		when 'No','N','no'
    puts "Ok. Lets set up your new config file"
    return false
	end
end
def check_for_miner
  miner_search=false
  dir = Dir.entries(Dir.getwd)
  dir.each do |var|
    if var.to_s == ("miner")
      miner_search=true
    else
    end
  end
  if miner_search==false
    FileUtils.mkdir_p 'miner'
    p "Mining software folder created"
    p "Downloading mining software from"
    p "https://github.com/andru-kun/wildrig-multi/releases/download/0.31.2/wildrig-multi-windows-0.31.2.7z"
    Down.download("https://github.com/andru-kun/wildrig-multi/releases/download/0.31.2/wildrig-multi-windows-0.31.2.7z", destination: Dir.getwd+"/miner")
    dir = Dir.entries(Dir.getwd+"/miner")
    dir.each do |var|
      if var.to_s.match("down")
        File.open(Dir.getwd+"/miner/"+var, "rb") do |file|
          SevenZipRuby::Reader.open(file) do |szr|
            szr.extract_all Dir.getwd+"/miner"
          end
        end
      end
    end
    p "Software Downloaded"
  end
end
def create_mining_file(mining_address)
  out_file = File.new(Dir.getwd+"/miner"+"/galleonminer.bat", "w")
  out_file.puts("
    :loop

    wildrig.exe -a sha256csm -o stratum+tcp://stratum.galleoncoin.club:4690 -u #{mining_address}.ryan -p c=GALE --multiple-instance --opencl-launch 30

    if ERRORLEVEL 1000 goto custom
    timeout /t 5
    goto loop

    :custom
    echo Some error happened, put custom command here
    timeout /t 5
    goto loop
    ")
  out_file.close
  puts "Mining file created"
end
def load_config
  puts "Loading Config File"
  file = File.open(Dir.getwd+"/galleonminer.txt")
  file_data= JSON.parse(file.read)
  return file_data
end
def start_mining
  #system(Dir.getwd+"/miner"+"/galleonminer.bat")
  Dir.chdir(Dir.getwd+"/miner")
  p Dir.pwd
  system("start galleonminer.bat")
end
#PROGRAM CONTROLLER
#LOOKS FOR THE CONFIG FILE
config_value[:config_setup]=look_for_setup()
#ASK THE USER WHAT THEY WANT TO DO TO THE CONFIG FILE IF FOUND
if config_value[:config_setup] == true
  config_file_option=ask_user_about_config()
end
#IF THERE IS NO CONFIG FILE OR IF THE USE WANTS TO SET UP A NEW CONFIG FILE
if config_value[:config_setup] == false || config_file_option==false
  config_value[:address]=get_mining_address()
  out_file = File.new("galleonminer.txt", "w")
  out_file.puts(config_value.to_json)
  out_file.close
end
check_for_miner()
mining_software_data=load_config()
create_mining_file(mining_software_data["address"])
start_mining()
response = $stdin.gets.chomp
