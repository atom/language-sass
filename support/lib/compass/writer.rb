module Compass
	module Writer
	  	class << self
			# Register the completions menu icons with TM DIALOG.
			#
			def register_completion_images
				icon_dir = File.expand_path(File.dirname(__FILE__)) + "/../../icons"
				images = {
					"Mixin"   => "#{icon_dir}/Mixin.png"
				}

				`"$DIALOG" images --register  '#{images.to_plist}'`
			end

			# Returns true if Dialog 2 is available.
			#
			def has_dialog2
				tm_dialog = e_sh ENV['DIALOG']
				! tm_dialog.match(/2$/).nil?
			end

			# Show a DIALOG 2 tool tip if dialog 2 is available.
			# Used where a tooltip needs to be displayed in conjunction with another
			# exit type.
			#
			def tooltip(message)
				return unless message

				if has_dialog2
					`"$DIALOG" tooltip --text "#{message}"`
				end
			end

			def complete(choices, filter=nil)
				TextMate.exit_show_tool_tip("Completions need DIALOG2 to function.") unless self.has_dialog2

				if choices[0]['display'].nil?
					puts "Error, was expecting Dialog2 compatable data."
					exit
				end

				self.register_completion_images

		        pid = fork do
					STDOUT.reopen(open('/dev/null'))
					STDERR.reopen(open('/dev/null'))

					command = "#{TM_DIALOG} popup"
					command << " --alreadyTyped #{e_sh filter}" if filter != nil
					command << " --additionalWordCharacters '_ []'"

					result    = nil

					::IO.popen(command, 'w+') do |io|
						io << { 'suggestions' => choices }.to_plist
						io.close
						result = OSX::PropertyList.load io rescue nil
					end
					self.tooltip(result['filename'].to_s) unless result['filename'].to_s.empty?
				end
			end
		end
	end
end
