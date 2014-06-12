#!/usr/bin/env ruby

require 'aws/s3'

class S3Backup

    def initialize(access_key_id, secret_access_key)
        # Connect to S3
        AWS::S3::Base.establish_connection!(
            :access_key_id     => access_key_id,
            :secret_access_key => secret_access_key
        )
    end

    def list_backups(bucket_name)
        puts "Listing backups in bucket: "+bucket_name.to_s
        bucket = AWS::S3::Bucket.find(bucket_name)
        bucket.objects.each { |x| puts x.inspect }
    end

    def store_backup(filepath, filename, bucket_name)
        AWS::S3::S3Object.store(filename, open(filepath), bucket_name)
    end

    def download_backup(file, bucket_name)
    end

end
