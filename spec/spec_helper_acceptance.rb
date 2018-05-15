require 'beaker-rspec'
require 'beaker_spec_helper'

# require 'beaker/puppet_install_helper'
# run_puppet_install_helper

hosts.each do |host|

  if host['platform'] =~ /^ubuntu-(15.04|15.10)-/
    on host, "wget -O /tmp/puppet.deb http://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb"
    on host, "dpkg -i --force-all /tmp/puppet.deb"
    on host, "apt-get update"
    host.install_package('puppet-agent')
  else
    install_puppet_agent_on host, {}
  end

  # Install git so that we can install modules from github
  if host['platform'] =~ /^el-5-/
    # git is only available on EPEL for el-5
    install_package host, 'epel-release'
  end
  install_package host, 'git'

  on host, "puppet cert generate $(facter fqdn)"
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'sssd')

    hosts.each do |host|
      # dependencies
      # {"name":"puppetlabs/stdlib", "version_requirement":">= 1.0.0 < 9.9.9"},
      # {"name":"eyp/nsswitch", "version_requirement":">= 0.1.0 < 0.2.0"},
      # {"name":"eyp/sudoers", "version_requirement":">= 0.1.23 < 0.2.0"},
      # {"name":"eyp/eyplib", "version_requirement":">= 0.1.0 < 0.2.0"}
      on host, puppet('module', 'install', 'eyp-eyplib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'eyp-sudoers'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'eyp-nsswitch'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
