#!/usr/local/bin/ruby

require 'right_aws'
require 'optparse'
require 'logger'

THREADS=10

logger = Logger.new(STDOUT)

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

logger.info "s3bucket2bucket.rb initiated with options: "  + options.inspect

s3 = RightAws::S3Interface.new(options[:access_key_id], options[:secret_access_key], {:protocol => "http", :port => 80})

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
logger.info "bucket mgt done. now copy from #{options[:source_bucket]} to #{options[:dest_bucket]}: started"
s3.incrementally_list_bucket(options[:source_bucket]) do |hash|
  hash[:contents].each do |item|
    begin 
      s3.copy(options[:source_bucket], item[:key], options[:dest_bucket])
      s3.put_acl(options[:dest_bucket], item[:key], source_bucket_acl[:object]) if source_bucket_acl
      i += 1
      logger.info "copy from #{options[:source_bucket]} to #{options[:dest_bucket]}: #{i} files ended" if i%200 == 0     
    rescue
      logger.error $!.inspect
    end      
  end
end

logger.info "copy from #{options[:source_bucket]} to #{options[:dest_bucket]}: #{i} files ended"
logger.info "copy from #{options[:source_bucket]} to #{options[:dest_bucket]} completed"
