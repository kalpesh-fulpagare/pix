desc "Creating a admin"
  task :admin_creation => :environment do
  User.create(:first_name => "Webonise",:last_name=>"Admin",:email => "admin@webonise.com",:password => "pix6186",:password_confirmation => "pix6186",:is_admin =>true)
end