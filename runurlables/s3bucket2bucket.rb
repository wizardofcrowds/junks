#!/usr/local/bin/ruby

require 'right_aws'
require 'optparse'

THREADS=10

options = {}
# region Valid Values: EU | us-west-1 | ap-southeast-1 | US for the US Classic Region
opts = OptionParser.new do |opt|
  opt.banner = "Usage: ruby s3bucket2bucket.rb -k AWS_ACCESS_KEY -s AWS_SECRET_KEY -S SOURCE_BUCKETNAME -d DEST_BUCKETNAME -r DEST_S3REGION"
  opt.on('-k AWS_ACCESS_KEY') do |access_key_id|
    options[:access_key_id] = access_key_id
  end
  opt.on('-s AWS_SECRET_KEY') do |secret_access_key|
    puts secret_access_key
    options[:secret_access_key] = secret_access_key
  end
  opt.on('-S SOURCE_BUCKETNAME') do |bucket|
    options[:source_bucket] = bucket
  end
  opt.on('-d DEST_BUCKETNAME') do |bucket|
    options[:dest_bucket] = bucket
  end
  opt.on('-r DEST_REGION') do |region|
    options[:dest_region] = region
  end
  opt.on('-h') do
    puts opt
    exit
  end
  
  opt.parse!(ARGV)
end

puts options.inspect

s3 = RightAws::S3Interface.new(options[:access_key_id], options[:secret_access_key]) #, {:default_protocol => "http", :port => 80})

# preparing destination bucket
bucket_options = {}
bucket_options[:location] = options[:dest_region] if options[:dest_region]
s3.create_bucket(options[:dest_bucket], bucket_options) # to make sure the destination bucket exists
source_bucket_acl = s3.get_acl(options[:source_bucket]) rescue nil
if source_bucket_acl
  s3.put_bucket_acl(options[:dest_bucket], source_bucket_acl[:object]) # copy source ACL to dest ACL
end

# Finally copying objects in a single thread
i = 0
puts "copy from #{options[:source_bucket]} to #{options[:dest_bucket]}: started"
s3.incrementally_list_bucket(options[:source_bucket]) do |hash|
  hash[:contents].each do |item|
    begin 
      s3.copy(options[:source_bucket], item[:key], options[:dest_bucket])
      i += 1
      puts "copy from #{options[:source_bucket]} to #{options[:dest_bucket]}: #{i} files ended" if i%200 == 0     
    rescue
      puts $!.inspect
    end      
  end
end

puts "copy from #{options[:source_bucket]} to #{options[:dest_bucket]}: #{i} files ended"
puts "copy from #{options[:source_bucket]} to #{options[:dest_bucket]} completed"
