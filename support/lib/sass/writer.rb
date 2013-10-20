module SASS
	module Writer
		class << self
			def render(title, result)
			  html_header(title)

			  puts '<pre>'
			  puts result
			  puts '</pre>'

			  html_footer
			end

			def convert(type)
				puts Sass::CSS.new(SELECTED_TEXT).render(type)
			end

		end
	end
end
