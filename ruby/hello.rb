require_relative 'bundle/bundler/setup'
require 'json'
require 'iron_mq'
require 'iron_worker'
require 'parse-ruby-client'
require 'mini_magick'

puts "Hello #{IronWorker.payload["name"]}!"
puts "Here is the payload: #{IronWorker.payload}"
puts "Here is my special env variable: #{ENV['YOUR_ENV_VAR']}"


imageFile = 'http://files.parsetfss.com/95f0244e-cc4d-4730-84ef-ffff312c991c/tfss-0fc95673-9c50-4eb4-a10d-fa6e223b32fb-6BE9C897-E211-430B-A9F7-B9567292F078_256.jpg'
image256 = MiniMagick::Image.open(imageFile)
image256.combine_options do |c|
	c.thumbnail "256x256>"
	c.gravity "center"
	c.extent "256x256"
end
