module Compass
	module Reader
		class << self
			def load_mixins
				mixins = []
				Dir[ENV['TM_COMPASS_PATH'] + '/**/*.scss'].each do | file_name |
					File.open(file_name, 'r') do |file|
						file.each_line do |line|
							case line
							when /^@mixin /i
								match = line.scan(/^@mixin ([\w-]*)/).to_s.gsub('[["', '').gsub('"]]', '')
								mixins << {
									'display' => match,
									'match' => match,
									'insert' => find_mixin_args(match, file_name),
									'image' => "Mixin",
									'filename' => file_name.sub(ENV['TM_COMPASS_PATH'], "")
								}
							end
						end
					end
				end
				mixins.uniq_by {|o| o['display']}.sort_by {|o| o['display']}
			end

			def load_variables
				variables = []
				Dir[ENV['TM_COMPASS_PATH'] + '/**/*.scss'].each do | file_name |
					File.open(file_name, 'r') do |file|
						file.each_line do |line|
							case line
							when /^\$([\w-]*)[\s*]?[:+]?[.*]?[;+]?/i
								match = line.strip.gsub(/:\ .*$/, '')
								variables << {
									'display' => match,
									'match' => match,
									'insert' => find_var_args(match, file_name),
									'image' => "Mixin",
									'filename' => file_name.sub(ENV['TM_COMPASS_PATH'], "")
								}
							end
						end
					end
				end
				variables.uniq_by {|o| o['display']}.sort_by {|o| o['display']}
			end

			def find_mixin mixin
				mixin.gsub!(/^\+/, '')
				mixin.gsub!(/\(.*$/, '')

				Dir[ENV['TM_COMPASS_PATH'] + '/**/*.scss'].each do | file_name |
					File.open(file_name, 'r') do |file|
						index = 0
						file.each_line do |line|
							case line
							when /^@mixin #{mixin}[\(]+?/i
								return {:file => file_name, :line => index + 1}
							end

							index += 1
						end
					end
				end
				nil
			end

			def find_variable variable
				regex = Regexp.new "\\#{variable}[\s*]?[:+]?[.*]?[;+]?"

				Dir[ENV['TM_COMPASS_PATH'] + '/**/*.scss'].each do | file_name |
					File.open(file_name, 'r') do |file|
						index = 0
						file.each_line do |line|
							case line
							when regex
								return {:file => file_name, :line => index + 1}
							end

							index += 1
						end
					end
				end
				nil
			end
		private
			def find_mixin_args mixin, file_name
				args = []
				index = 0
				text = File.read(file_name)
				regex = Regexp.new "^@mixin #{mixin}\\(([^\{]+)\\)\\s\\{$", Regexp::MULTILINE
				text.scan(regex) do |x|
					x.to_s.split(',').each do |arg|
						index += 1
						args << "${#{index}:#{e_sn arg.squeeze.strip}}"
					end
				end
				return '('+args.join(', ')+')$0' unless args.empty?
				return '$0'
			end

			def find_var_args var, file_name
				args = []
				index = 0
				text = File.read(file_name)
				regex = Regexp.new "\\#{var}:(.*);"
				text.scan(regex) do |x|
					x.to_s.split(',').each do |arg|
						index += 1
						args << "${#{index}:#{e_sn arg.squeeze.strip}}"
					end
				end
				return ' : '+args.join(', ')+';$0' unless args.empty?
				return '$0'
			end
		end
	end
end
