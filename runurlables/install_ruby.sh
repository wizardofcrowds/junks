#!/bin/bash
#
# Install Ruby
#
# Original Author: Josh Frye <joshfng@gmail.com>
# Licence: MIT
#
# Contributions from: Wayne E. Seguin <wayneeseguin@gmail.com>
# Contributions from: Ryan McGeary <ryan@mcgeary.org>
#

ruby_version="1.9.2"
ruby_version_string="1.9.2-p290"
ruby_source_url="http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.tar.gz"
ruby_source_tar_name="ruby-1.9.2-p290.tar.gz"
ruby_source_dir_name="ruby-1.9.2-p290"
railsready_path=$(cd && pwd)/railsready
log_file="$railsready_path/install.log"

script_runner=$(whoami)

mkdir -p $railsready_path/src

#test if aptitude exists and default to using that if possible
if command -v aptitude >/dev/null 2>&1 ; then
  pm="aptitude"
else
  pm="apt-get"
fi

echo -e "\nUsing $pm for package installation\n"

# Update the system before going any further
echo -e "\n=> Updating system (this may take a while)..."
sudo $pm update >> $log_file 2>&1 \
 && sudo $pm -y upgrade >> $log_file 2>&1
echo "==> done..."

# Install build tools
echo -e "\n=> Installing build tools..."
sudo $pm -y install \
    wget curl build-essential clang \
    bison openssl zlib1g \
    libxslt1.1 libssl-dev libxslt1-dev \
    libxml2 libffi-dev libyaml-dev \
    libxslt-dev autoconf libc6-dev \
    libreadline6-dev zlib1g-dev libcurl4-openssl-dev >> $log_file 2>&1
echo "==> done..."

# Install git-core
# echo -e "\n=> Installing git..."
# sudo $pm -y install git-core >> $log_file 2>&1
# echo "==> done..."

echo -e "\n=> Downloading Ruby $ruby_version_string \n"
cd $railsready_path/src && wget $ruby_source_url
echo -e "\n==> done..."
echo -e "\n=> Extracting Ruby $ruby_version_string"
tar -xzf $ruby_source_tar_name >> $log_file 2>&1
echo "==> done..."
echo -e "\n=> Building Ruby $ruby_version_string (this will take a while)..."
cd  $ruby_source_dir_name && ./configure --prefix=/usr/local >> $log_file 2>&1 \
 && make >> $log_file 2>&1 \
  && sudo make install >> $log_file 2>&1
echo "==> done..."

echo -e "\n=> Installing bundler gem \n"
sudo gem install bundler --no-ri --no-rdoc >> $log_file 2>&1
