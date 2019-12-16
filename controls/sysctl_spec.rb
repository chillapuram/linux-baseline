#
# Copyright 2015, Patrick Muench
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# author: Christoph Hartmann
# author: Dominik Richter
# author: Patrick Muench

sysctl_forwarding = attribute('sysctl_forwarding', value: false, description: 'Is network forwarding needed?')
kernel_modules_disabled = attribute('kernel_modules_disabled', value: 0, description: 'Should loading of kernel modules be disabled?')
container_execution = begin
                        virtualization.role == 'guest' && virtualization.system =~ /^(lxc|docker)$/
                      rescue NoMethodError
                        false
                      end

control 'sysctl-01' do
  impact 1.0
  title 'IPv4 Forwarding'
  desc "If you're not intending for your system to forward traffic between interfaces, or if you only have a single interface, the forwarding function must be disable."
  only_if { sysctl_forwarding == false && !container_execution }
  describe kernel_parameter('net.ipv4.ip_forward') do
    its(:value) { should eq 0 }
  end
  describe kernel_parameter('net.ipv4.conf.all.forwarding') do
    its(:value) { should eq 0 }
  end
end

control 'sysctl-02' do
  impact 1.0
  title 'Reverse path filtering'
  desc "The rp_filter can reject incoming packets if their source address doesn't match the network interface that they're arriving on, which helps to prevent IP spoofing."
  only_if { !container_execution }
  describe kernel_parameter('net.ipv4.conf.all.rp_filter') do
    its(:value) { should eq 1 }
  end
  describe kernel_parameter('net.ipv4.conf.default.rp_filter') do
    its(:value) { should eq 1 }
  end
end

control 'sysctl-03' do
  impact 1.0
  title 'ICMP ignore bogus error responses'
  desc 'Sometimes routers send out invalid responses to broadcast frames. This is a violation of RFC 1122 and the kernel will logged this. To avoid filling up your logfile with unnecessary stuff, you can tell the kernel not to issue these warnings'
  only_if { !container_execution }
  describe kernel_parameter('net.ipv4.icmp_ignore_bogus_error_responses') do
    its(:value) { should eq 1 }
  end
end

control 'sysctl-04' do
  impact 1.0
  title 'ICMP echo ignore broadcasts'
  desc 'Blocking ICMP ECHO requests to broadcast addresses'
  only_if { !container_execution }
  describe kernel_parameter('net.ipv4.icmp_echo_ignore_broadcasts') do
    its(:value) { should eq 1 }
  end
end

control 'sysctl-05' do
  impact 1.0
  title 'Disable IPv6 if it is not needed'
  desc 'Disable IPv6 if it is not needed'
  only_if { !container_execution }
  describe kernel_parameter('net.ipv6.conf.all.disable_ipv6') do
    its(:value) { should eq 1 }
  end
end

control 'sysctl-06' do
  impact 1.0
  title 'IPv6 Forwarding'
  desc "If you're not intending for your system to forward traffic between interfaces, or if you only have a single interface, the forwarding function must be disable."
  only_if { !container_execution }
  describe kernel_parameter('net.ipv6.conf.all.forwarding') do
    its(:value) { should eq 0 }
  end
end

control 'sysctl-07' do
  impact 1.0
  title 'Disable IPv6 autoconfiguration'
  desc 'The autoconf setting controls whether router advertisements can cause the system to assign a global unicast address to an interface.'
  only_if { !container_execution }
  describe kernel_parameter('net.ipv6.conf.default.autoconf') do
    its(:value) { should eq 0 }
  end
end
