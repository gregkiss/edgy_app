require "rails/generators"
require "fileutils"

class EdgyApp
	
	def self.create_file(template, new_file_path, name, domain)
		path_template = "/home/greg/edgy_app/lib/#{template}"
		template = File.new(path_template)
		new = File.new(new_file_path, "w")
		template.close
		FileUtils.cp(template, new)
		new.close
		
		#insert name
		content = File.read(new_file_path)
		new_content = content.gsub("APP_NAME", name).gsub("APP_CAMEL", name.capitalize).gsub("DOMAIN_NAME", domain)
		File.open(new_file_path, "w") {|file| file.puts new_content }
	end
	
	def self.new
		require "fileutils"

		print "Enter snake_case name of new app: "
		@name = gets.chomp.to_s.downcase
		print "Enter domain name including TLD (eg 'example.xyz'): "
		@domain = gets.chomp.to_s.downcase
		print "Enable email? (y/n): "
		@email = gets.chomp.to_s
		if @email.to_s.downcase != "y"
			@email = false
		else
			@email = true
		end
		print "Enable users? (y/n): "
		@user = gets.chomp.to_s
		if @user.to_s.downcase != "y"
			@user = false
		else
			@user = true
		end
		print "Business address? (n/type address): "
		@address = gets.chomp.to_s
		if @address.to_s.downcase == "n"
			@address = false
		end
		
		#CONTROLLER
		system "mkdir app/controllers/#{@name}"
		filename = "pages_controller.rb"
		new_file_path = "app/controllers/#{@name}/#{filename}"
		create_file(filename, new_file_path, @name, @domain)
		print "Created #{new_file_path}\n"
		
		#VIEWS
		system "mkdir app/views/#{@name}"
		system "mkdir app/views/#{@name}/pages"
		#home
		filename = "home.html.erb"
		new_file_path = "app/views/#{@name}/pages/#{filename}"
		create_file(filename, new_file_path, @name, @domain)
		print "Created #{new_file_path}\n"
		
		#header
		filename = "_header.html.erb"
		new_file_path = "app/views/#{@name}/pages/#{filename}"
		create_file(filename, new_file_path, @name, @domain)
		print "Created #{new_file_path}\n"
		
		#footer
		filename = "_footer.html.erb"
		new_file_path = "app/views/#{@name}/pages/#{filename}"
		create_file(filename, new_file_path, @name, @domain)
		content = File.read(new_file_path)
		if @address == false
			new_contents = content.gsub("EDGY_APP INSERT_MAP", "<%= image_tag '#{@name}/Logo.png', class:'footer-logo' %>")
		else
			new_contents = content.gsub("EDGY_APP INSERT_MAP", "\t\t<div class='map-h'>#{@address}</div>\n\t\t<iframe class='footer-map'\n\t\t\t
				src='https://www.google.com/maps/embed/v1/place?key=\#{google_api_key}&q=#{@address}'
				allowfullscreen>\n\t\t</iframe>")
		end
	  File.open(new_file_path, "w") {|file| file.puts new_contents }
		print "Created #{new_file_path}\n"
		
		#about
		filename = "about.html.erb"
		new_file_path = "app/views/#{@name}/pages/#{filename}"
		create_file(filename, new_file_path, @name, @domain)
		print "Created #{new_file_path}\n"
		
		#contact
		filename = "contact.html.erb"
		new_file_path = "app/views/#{@name}/pages/#{filename}"
		create_file(filename, new_file_path, @name, @domain)
		print "Created #{new_file_path}\n"
		
		#contact_form
		filename = "contact_form.js.erb"
		new_file_path = "app/views/#{@name}/pages/#{filename}"
		create_file(filename, new_file_path, @name, @domain)
		print "Created #{new_file_path}\n"
		
		#sitemap
		filename = "sitemap.xml"
		new_file_path = "app/views/#{@name}/pages/#{filename}"
		create_file(filename, new_file_path, @name, @domain)
		print "Created #{new_file_path}\n"
		
		#readme
		filename = "readme.txt"
		new_file_path = "app/views/#{@name}/pages/#{filename}"
		create_file(filename, new_file_path, @name, @domain)
		print "Created #{new_file_path}\n"
		
		
		#STYLESHEET
		filename = "stylesheet.css.scss"
		new_file_path = "app/assets/stylesheets/#{@name}.css.scss"
		create_file(filename, new_file_path, @name, @domain)
		print "Created #{new_file_path}\n"
		
		#ROUTES
		@completed = false
		tempfile = File.open("routes.tmp", 'w')
		f = File.new("config/routes.rb")
		f.each do |line|
			if (@completed == false) && (["\t", " "].include? line[0])
				@completed = true
				tempfile << "\n"
				tempfile << "\t##{@name.upcase}\n"
				tempfile << "\t#constraints domain: '#{@domain}' do\n"
				tempfile << "\tconstraints domain: 'localhost' do\n"
				tempfile << "\t\troot '#{@name}/pages#home', as: '#{@name}_root'\n"
				tempfile << "\t\tget 'about' => '#{@name}/pages#about', as: '#{@name}_about'\n"
				tempfile << "\t\tget 'contact' => '#{@name}/pages#contact', as: '#{@name}_contact'\n"
				tempfile << "\t\tpost 'contact_form' => '#{@name}/pages#contact_form', as: '#{@name}_contact_form'\n"
				tempfile << "\t\tget 'terms' => '#{@name}/pages#terms', as: '#{@name}_terms'\n"
				tempfile << "\t\tget 'privacy' => '#{@name}/pages#privacy', as: '#{@name}_privacy'\n"
				tempfile << "\t\tget 'sitemap.xml' => '#{@name}/pages#sitemap', defaults: {format: 'xml'}\n"
				tempfile << "\tend\n"
				tempfile << "\n"
				tempfile << line
			else
				tempfile << line
			end
		end
		f.close
		tempfile.close
		FileUtils.mv("routes.tmp", "config/routes.rb")
		print "Updated routes.rb\n"
		
		#MANIFEST.JS
		File.open('app/assets/config/manifest.js', 'a') { |f| f.write("\n//= link #{@name}.css") } #appends line
		print "Updated manifest.js\n"
		
		#USERS
		if @user == "not yet"
			@completed = false
			tempfile = File.open("user.tmp", 'w')
			f = File.new("app/models/user.rb")
			f.each do |line|
				tempfile << line.gsub("]#edgy_app insert", ", #{@name}]#edgy_app insert")
			end
			f.close
			tempfile.close
			FileUtils.mv("user.tmp", "app/models/user.rb")
			print "Updated app/models/user.rb\n"
		end
		
		#IMAGES
		system "mkdir app/assets/images/#{@name}"
		print "Created app/assets/images/#{@name}\n"
		
		#SUCCESS
		print "Generated #{@name}!\n\nYou still need to:\n"
		print "\t- Add a Logo.png to app/assets/images/#{@name}\n"
		print "\t- Add a #{@name}.png favicon to assets/images/favicons\n"
		print "\t- Update the three arrays in dev_helper.rb\n\n"
		print "When developing, remember to update the default app in the following files:\n"
		print "\t- routes.rb\n\t- application.html\n\t- sessions_helper.rb?\n"
		print "💧\n"
		
	end
end