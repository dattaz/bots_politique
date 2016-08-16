#!/usr/bin/ruby
require 'twitter_ebooks'


model = Ebooks::Model.load(ARGV[0])


for i in 0..20
	puts model.make_statement(140)
	#puts model.make_response("Écolo", 130)
end
