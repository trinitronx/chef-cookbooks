#
# Cookbook Name:: oracle
# Recipe:: packages
#
# Copyright 2013, Biola University 
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# installs supplementary required packages for Oracle

yum_package "binutils"

yum_package "compat-libstdc++-33" do
  arch "i386"
end

yum_package "compat-libstdc++-33" do
  arch "x86_64"
end

yum_package "elfutils-libelf"

yum_package "elfutils-libelf-devel"

yum_package "gcc"

yum_package "gcc-c++"

yum_package "glibc" do
  arch "i686"
end

yum_package "glibc" do
  arch "x86_64"
end

yum_package "glibc-common"

yum_package "glibc-devel" do
  arch "x86_64"
end

yum_package "glibc-devel" do
  arch "i386"
end

yum_package "glibc-headers"

yum_package "ksh"

yum_package "libaio" do
  arch "x86_64"
end

yum_package "libaio" do
  arch "i386"
end

yum_package "libaio-devel" do
  arch "x86_64"
end

yum_package "libaio-devel" do
  arch "i386"
end

yum_package "libgcc" do
  arch "x86_64"
end

yum_package "libgcc" do
  arch "i386"
end

yum_package "libstdc++" do
  arch "x86_64"
end

yum_package "libstdc++" do
  arch "i386"
end

yum_package "libstdc++-devel"

yum_package "make"

yum_package "sysstat"

yum_package "unixODBC" do
  arch "x86_64"
end

yum_package "unixODBC" do
  arch "i386"
end

yum_package "unixODBC-devel" do
  arch "x86_64"
end

yum_package "unixODBC-devel" do
  arch "i386"
end


