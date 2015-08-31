#!/usr/bin/env bash
################################################################################
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`

. "$bin"/config.sh

# Stop TaskManager instance(s)
readSlaves

for slave in ${SLAVES[@]}; do
    ssh -n $FLINK_SSH_OPTS $slave -- "nohup /bin/bash -l $FLINK_BIN_DIR/taskmanager.sh stop &"
done

# Stop JobManager instance(s)
if [[ -z $ZK_QUORUM ]]; then
    "$bin"/jobmanager.sh stop
else
	# HA Mode
    readMasters

    for master in ${MASTERS[@]}; do
        ssh -n $FLINK_SSH_OPTS $master -- "nohup /bin/bash -l $FLINK_BIN_DIR/jobmanager.sh stop &"
    done
fi
