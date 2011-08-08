namespace :activemessaging do

  desc 'Run all consumers'
  task :start_consumers do
    load File.join(Rails.root, 'lib', 'poller.rb')
  end

end