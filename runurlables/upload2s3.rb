#!/usr/local/bin/ruby

require 'right_aws'
require 'optparse'

options = {:bucket => "hogetestbucket", :region => nil}
# region Valid Values: EU | us-west-1 | ap-southeast-1 | empty string (for the US Classic Region)
opts = OptionParser.new do |opt|
  opt.banner = "Usage: ruby upload2s3.rb -k AWS_ACCESS_KEY -s AWS_SECRET_KEY -b BUCKETNAME -r S3REGION -f FILENAME"
  opt.on('-k AWS_ACCESS_KEY') do |access_key_id|
    options[:access_key_id] = access_key_id
  end
  opt.on('-s AWS_SECRET_KEY') do |secret_access_key|
    puts secret_access_key
    options[:secret_access_key] = secret_access_key
  end
  opt.on('-b BUCKETNAME') do |bucket|
    options[:bucket] = bucket
  end
  opt.on('-r REGION') do |region|
    options[:region] = region
  end
  opt.on('-f FILEPATH') do |filepath|
    options[:filepath] = filepath
  end
  opt.on('-h') do
    puts opt
    exit
  end
  
  opt.parse!(ARGV)
end

s3 = RightAws::S3Interface.new(options[:access_key_id], options[:secret_access_key])

bucket_options = {}
bucket_options[:location] = options[:region] if options[:region]
s3.create_bucket(options[:bucket], bucket_options)

File.open(options[:filepath], 'r'){|f| s3.put(options[:bucket], File.basename(options[:filepath]), f)}

