Gem::Specification.new do |s|
	s.name	    	= 'excel_import'
	s.version   	= '0.0.0'
	s.date	    	= '2013-12-15'
	s.summary    	= 'excel_import'
	s.description   = 'excel import simple example'
	s.authors		= ['Men Xu']
	s.email			= 'menxu_work@163.com'
	s.files			= ['lib/excel_import.rb']
	s.homepage		= 'http://rubygems.org/gems/excel_import'
	s.license		= 'MIT'

	s.files			= Dir.glob("lib/**/**") + %w(README.md)
	s.require_paths = ['lib']
	
	s.add_dependency('roo',   '1.10.3')
	s.add_dependency('axlsx', '1.3.5')

end
