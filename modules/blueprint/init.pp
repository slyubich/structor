#  Licensed to the Apache Software Foundation (ASF) under one or more
#   contributor license agreements.  See the NOTICE file distributed with
#   this work for additional information regarding copyright ownership.
#   The ASF licenses this file to You under the Apache License, Version 2.0
#   (the "License"); you may not use this file except in compliance with
#   the License.  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

class blueprint {
  require repos_setup
  $path="/bin:/usr/bin:/sbin:/usr/sbin"


  # Ambari doesn't facilitate secure installations but we ease the pain a bit
  # by adding an account and putting it in the users group. This will allow
  # impersonation if we use views to run jobs. Ambari should not be run as root
  # in a real setting but this can't be automated today.
  user { "ambari" : 
    ensure => present,
    before => Package["ambari-server"],
    groups => "users",
  }

  package { "ambari-server":
    ensure => installed
  }
  ->
  exec { "deploy blueprint":
    command => "curl -H \"X-Requested-By: ambari\" -X POST --data @/vagrant/files/blueprint.json -u admin:admin http://localhost:8080/api/v1/blueprints/BP",
    path => $path,
  }
 ->
  exec { "install blueprint":
    command => "curl -iv -H \"X-Requested-By: ambari\" -X POST --data @/vagrant/files/cluster.txt -u admin:admin http://localhost:8080/api/v1/clusters/supportLab",
    path => $path,
  }
}
