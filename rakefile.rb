task default: %w[start]

task :start do 
  ruby 'config/application.rb'
end
