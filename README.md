# rBackup

Ruby script to backup project folders and mysql databases, and upload to S3 storage. 

Works well with PHP projects where you don't need to backup the full
project directory, but there are multiple "static" folders that do. Also
allows backup of multiple mysql databases and creates tgz archives of
each folder and database separately.

## Installation

Install steps are tested on a Ubuntu Precise 12.04 server. If Ruby is already being used, note that these steps will upgrade the default ruby version to Ruby 1.9.3 along with other Ruby tools.

Install the packages:

    sudo apt-get update

    sudo apt-get install ruby1.9.1 ruby1.9.1-dev \
      rubygems1.9.1 irb1.9.1 ri1.9.1 rdoc1.9.1 \
      build-essential libopenssl-ruby1.9.1 libssl-dev zlib1g-dev

Use update-alternatives to ensure that version 1.9.3 will be used

    sudo update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.1 400 \
        --slave   /usr/share/man/man1/ruby.1.gz ruby.1.gz \
                        /usr/share/man/man1/ruby1.9.1.1.gz \
        --slave   /usr/bin/ri ri /usr/bin/ri1.9.1 \
        --slave   /usr/bin/irb irb /usr/bin/irb1.9.1 \
        --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.1

    sudo update-alternatives --config ruby
    sudo update-alternatives --config gem

Note that you might get errors if another version of Ruby is not installed - just ignore this.

Check the version shows "ruby 1.9.3p0 (2011-10-30 revision 33570) [x86_64-linux]"

    ruby --version

Now install the s3 ruby gem:

    sudo gem i aws-s3

### Configuration

Copy the distribution configuration

    cp parameters.yml{.dist,}

Now edit the `parameters.yml` file and enter the MySQL database 
credentials and the Amazon Web Services details, including the target S3 bucket name.

Important: Make sure the S3 bucket exists or the upload will fail. The
bucket needs to be in the US standard region.

Also you can specify a local backup directory where the backups will be
placed on the local host.

## Usage

    ruby rbackup.rb <projectname> <projectpath> <folders> <databases>

* `projectname` is a unique identifier for the project you are backing up
* `projectpath` is the root level path of the project to be backed up
* `folders` is a comma separated list of folders relative to the project
  path
* `databases` is a comma separated list of database names to be backed up

Important: In case there are issues with file permissions it is safest
to run the command as root. This means putting the command in the root
crontab.

### Example usage

Backing up a single folder inside the project directory and a single
mysql database:

    ruby rbackup.rb projectname /var/www/projectfolder static projectdb

Backing up 2 project folders and 2 mysql databases:

    ruby rbackup.rb projectname /var/www/projectfolder shared,static projectdb,otherdb

## Contributing

Feel free!

## Credits

Created by gezpage
