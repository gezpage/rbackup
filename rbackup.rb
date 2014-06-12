#!/usr/bin/env ruby

require './s3backup'
require 'date'
require 'yaml'
require 'csv'

class RBackup

    def initialize(project, project_path = nil, folders = nil, databases = nil)
        @project = project
        @project_path = project_path
        if folders != nil
            @folders = CSV.parse(folders).first
        end
        if databases != nil
            @databases = CSV.parse(databases).first
        end

        # Check arguments are passed
        if @project == nil or @project.size == 0
            raise 'Must provide project name'
        end
        if @folders == nil and @databases == nil
            raise 'Must provide folders and/or databases to be backed up'
        end

        # Read in the parameters file
        @parameters = YAML::load_file("parameters.yml") unless defined? @parameters

        # Create s3 instance
        id = @parameters['aws']['access_key_id']
        key = @parameters['aws']['secret_access_key']
        @s3 = S3Backup.new(id, key)
        @bucket_name = @parameters['aws']['bucket_name']
        @backup_dir = @parameters['backup_dir']

        # Create the directory if it doesn't already exist
        `mkdir -p #{@backup_dir}`
    end

    def start_backup
        if @databases != nil
            @databases.each do |(database)|
                puts "--> Starting database backup: #{database}"
                backup_database(database)
                puts "--> Finished backup: #{database}"
            end
        end
        if @folders != nil
            @folders.each do |(folder)|
                puts "--> Starting folder backup: #{@project_path}/#{folder}"
                backup_folder(folder)
                puts "--> Finished backup: #{@project_path}/#{folder}"
            end
        end
        puts "All backups completed successfully"
    end

    def backup_database(database)
        filename = filename_part+'-'+sanitize_string(database)+'-database.sql.gz'
        filepath = @backup_dir+'/'+filename

        # Delete the file first if it exists
        delete_file(filepath)

        puts "--> Creating MySQL dump file #{filename}"
        cmd = "mysqldump -u #{@parameters['database']['user']} --password=#{@parameters['database']['password']} #{database} | gzip > #{filepath}"
        `#{cmd}`

        # Check file is created successfully
        check_file(filepath)

        # Upload to S3
    puts "--> Uploading file to S3 storage"
        upload_file(filepath, filename)
    end

    def backup_folder(folder)
        filename = filename_part+'-'+sanitize_string(folder)+'-folder.tar.gz'
        filepath = "#{@backup_dir}/#{filename}"
        backup_dir = "#{@project_path}/#{folder}"

	check_folder(backup_dir)

        # Delete the file first if it exists
        delete_file(filepath)

        # Create tarfile
        tar_file(filepath, backup_dir)

        # Check file is created successfully
        check_file(filepath)

        # Upload to S3
    puts "--> Uploading file to S3 storage"
        upload_file(filepath, filename)
    end

    def delete_file(file)
        if File.exist?(file)
            File.delete(file)
        end
    end

    def tar_file(file, path)
        puts "--> Creating archive #{file}"
        path[0] = ''
        `tar cvzf #{file} -C / #{path} > /dev/null`
    end

    def check_folder(folder)
        if not File.exist?(folder)
            raise "Folder error: "+folder+" not found"
        end
    end

    def check_file(filename)
        if not File.exist?(filename)
            raise "File error: "+filename+" not found"
        end
        # todo - check filetime
    end

    def filename_part
        return @project+'-'+Date.today.wday.to_s+'-'+Date::ABBR_DAYNAMES[Date.today.wday]
    end

    def upload_file(filepath, filename)
        @s3.store_backup(filepath, filename, @bucket_name)
    end

    def list_backups
        @s3.list_backups(@bucket_name)
    end

    def sanitize_string(string)
        clean_string = string.clone
        clean_string.gsub! '-', '_'
        clean_string.gsub! '/', '_'
        return clean_string
    end

end

if __FILE__ == $0
    project = ARGV[0]
    project_path = ARGV[1]
    folders = ARGV[2]
    databases = ARGV[3]
    ib = RBackup.new(project, project_path, folders, databases)

    ib.start_backup
end
