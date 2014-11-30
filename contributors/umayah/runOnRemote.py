# Author: Umayah Abdennabi
#
# To use you must have paramiko installed, to install it:
# run "pip install paramiko" from terminal.
#
# The program can be used as following:
#
#   python runOnRemote 'USERNAME' 'PASSWORD'
#
# Example:
#   
#   python runOnRemote 'doe001' 'password1234'
#
# (Note: The single quote ARE necessary) This will run all the 
# commands listed in tasks on any of the computers listed in machines
#

import sys 
import paramiko
import random

machines = ['kh1260-01.cselabs.umn.edu', 'kh1260-02.cselabs.umn.edu',
	    'kh1260-16.cselabs.umn.edu', 'kh1260-04.cselabs.umn.edu',
	    'kh1260-05.cselabs.umn.edu', 'kh1260-06.cselabs.umn.edu',
	    'kh1260-07.cselabs.umn.edu', 'kh1260-08.cselabs.umn.edu',
	    'kh1260-09.cselabs.umn.edu', 'kh1260-10.cselabs.umn.edu',
	    'kh1260-11.cselabs.umn.edu', 'kh1260-12.cselabs.umn.edu',
	    'kh1260-13.cselabs.umn.edu', 'kh1260-14.cselabs.umn.edu']

# Must change these tasks to the correct replacement policy and folders 
tasks = ['nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:256:32:2:l  -cache:dl2 ul2:256:32:16:i -redir:sim ~/apps/proj/sim/goSim_1 -redir:prog ~/apps/proj/output/11 ~/apps/go/go 50 21 ~/apps/go/5stone21.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:128:64:2:l  -cache:dl2 ul2:256:64:16:i -redir:sim ~/apps/proj/sim/goSim_2 -redir:prog ~/apps/proj/output/21 ~/apps/go/go 50 21 ~/apps/go/5stone21.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:64:128:2:l  -cache:dl2 ul2:256:128:16:i -redir:sim ~/apps/proj/sim/goSim_3 -redir:prog ~/apps/proj/output/31 ~/apps/go/go 50 21 ~/apps/go/5stone21.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:32:256:2:l  -cache:dl2 ul2:256:256:16:i -redir:sim ~/apps/proj/sim/goSim_4 -redir:prog ~/apps/proj/output/41 ~/apps/go/go 50 21 ~/apps/go/5stone21.in &']	 
if __name__ == "__main__":
	username = sys.argv[1] 	
	password = sys.argv[2]
	print 'Running with username %s and password %s' % (username, password)
	for i in range(len(tasks)):
		randomMachine = int(random.random() * len(machines))
		print "Execution task %d on machine %s" % (i, machines[randomMachine])
		ssh = paramiko.SSHClient()
		ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
		ssh.connect(machines[randomMachine], username = username, password = password)
		stdin, stderr, stdout = ssh.exec_command(tasks[i])
	
