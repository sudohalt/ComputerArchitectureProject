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
	    'kh4250-05.cselabs.umn.edu', 'kh1260-06.cselabs.umn.edu',
	    'kh1260-07.cselabs.umn.edu', 'kh1260-08.cselabs.umn.edu',
	    'kh1260-09.cselabs.umn.edu', 'kh1260-10.cselabs.umn.edu',
	    'kh1260-11.cselabs.umn.edu', 'kh1260-12.cselabs.umn.edu',
	    'kh1260-13.cselabs.umn.edu', 'kh1260-14.cselabs.umn.edu',
	    'kh1260-15.cselabs.umn.edu', 'kh1260-16.cselabs.umn.edu']

# Must change these tasks to the correct replacement policy and folders 
tasks = [
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:256:32:2:l  -cache:dl2 ul2:256:32:16:f -redir:sim ~/apps/fifran/sim/anagram.simout.T1.fifo -redir:prog ~/apps/fifran/output/12 ~/apps/anagram/anagram ~/apps/anagram/words < ~/apps/anagram/anagram.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:256:32:2:l  -cache:dl2 ul2:256:32:16:f -redir:sim ~/apps/fifran/sim/gzip.simout.T1.fifo -redir:prog ~/apps/fifran/output/13 ~/apps/gzip/gzip ~/apps/gzip/input.graphic &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:256:32:2:l  -cache:dl2 ul2:256:32:16:f -redir:sim ~/apps/fifran/sim/gcc.simout.T1.fifo -redir:prog ~/apps/fifran/output/14 ~/apps/gcc/gcc -O ~/apps/gcc/166.i &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:128:64:2:l  -cache:dl2 ul2:256:64:16:f -redir:sim ~/apps/fifran/sim/go.simout.T2.fifo -redir:prog ~/apps/fifran/output/21 ~/apps/go/go 50 21 ~/apps/go/5stone21.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:128:64:2:l  -cache:dl2 ul2:256:64:16:f -redir:sim ~/apps/fifran/sim/anagram.simout.T2.fifo -redir:prog ~/apps/fifran/output/22 ~/apps/anagram/anagram ~/apps/anagram/words < ~/apps/anagram/anagram.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:128:64:2:l  -cache:dl2 ul2:256:64:16:f -redir:sim ~/apps/fifran/sim/gzip.simout.T2.fifo -redir:prog ~/apps/fifran/output/23 ~/apps/gzip/gzip ~/apps/gzip/input.graphic &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:128:64:2:l  -cache:dl2 ul2:256:64:16:f -redir:sim ~/apps/fifran/sim/gcc.simout.T2.fifo -redir:prog ~/apps/fifran/output/24 ~/apps/gcc/gcc -O ~/apps/gcc/166.i &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:64:128:2:l  -cache:dl2 ul2:256:128:16:f -redir:sim ~/apps/fifran/sim/go.simout.T3.fifo -redir:prog ~/apps/fifran/output/31 ~/apps/go/go 50 21 ~/apps/go/5stone21.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:64:128:2:l  -cache:dl2 ul2:256:128:16:f -redir:sim ~/apps/fifran/sim/anagram.simout.T3.fifo -redir:prog ~/apps/fifran/output/32 ~/apps/anagram/anagram ~/apps/anagram/words < ~/apps/anagram/anagram.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:64:128:2:l  -cache:dl2 ul2:256:128:16:f -redir:sim ~/apps/fifran/sim/gzip.simout.T3.fifo -redir:prog ~/apps/fifran/output/33 ~/apps/gzip/gzip ~/apps/gzip/input.graphic &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:64:128:2:l  -cache:dl2 ul2:256:128:16:f -redir:sim ~/apps/fifran/sim/gcc.simout.T3.fifo -redir:prog ~/apps/fifran/output/34 ~/apps/gcc/gcc -O ~/apps/gcc/166.i &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:32:256:2:l  -cache:dl2 ul2:256:256:16:f -redir:sim ~/apps/fifran/sim/go.simout.T4.fifo -redir:prog ~/apps/fifran/output/41 ~/apps/go/go 50 21 ~/apps/go/5stone21.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:32:256:2:l  -cache:dl2 ul2:256:256:16:f -redir:sim ~/apps/fifran/sim/anagram.simout.T4.fifo -redir:prog ~/apps/fifran/output/42 ~/apps/anagram/anagram ~/apps/anagram/words < ~/apps/anagram/anagram.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:32:256:2:l  -cache:dl2 ul2:256:256:16:f -redir:sim ~/apps/fifran/sim/gzip.simout.T4.fifo -redir:prog ~/apps/fifran/output/43 ~/apps/gzip/gzip ~/apps/gzip/input.graphic &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:32:256:2:l  -cache:dl2 ul2:256:256:16:f -redir:sim ~/apps/fifran/sim/gcc.simout.T4.fifo -redir:prog ~/apps/fifran/output/44 ~/apps/gcc/gcc -O ~/apps/gcc/166.i &'
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:256:32:2:l  -cache:dl2 ul2:256:32:16:r -redir:sim ~/apps/fifran/sim/go.simout.T1.random -redir:prog ~/apps/fifran/output/r11 ~/apps/go/go 50 21 ~/apps/go/5stone21.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:256:32:2:l  -cache:dl2 ul2:256:32:16:r -redir:sim ~/apps/fifran/sim/anagram.simout.T1.random -redir:prog ~/apps/fifran/output/r12 ~/apps/anagram/anagram ~/apps/anagram/words < ~/apps/anagram/anagram.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:256:32:2:l  -cache:dl2 ul2:256:32:16:r -redir:sim ~/apps/fifran/sim/gzip.simout.T1.random -redir:prog ~/apps/fifran/output/r13 ~/apps/gzip/gzip ~/apps/gzip/input.graphic &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:256:32:2:l  -cache:dl2 ul2:256:32:16:r -redir:sim ~/apps/fifran/sim/gcc.simout.T1.random -redir:prog ~/apps/fifran/output/r14 ~/apps/gcc/gcc -O ~/apps/gcc/166.i &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:128:64:2:l  -cache:dl2 ul2:256:64:16:r -redir:sim ~/apps/fifran/sim/go.simout.T2.random -redir:prog ~/apps/fifran/output/r21 ~/apps/go/go 50 21 ~/apps/go/5stone21.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:128:64:2:l  -cache:dl2 ul2:256:64:16:r -redir:sim ~/apps/fifran/sim/anagram.simout.T2.random -redir:prog ~/apps/fifran/output/r22 ~/apps/anagram/anagram ~/apps/anagram/words < ~/apps/anagram/anagram.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:128:64:2:l  -cache:dl2 ul2:256:64:16:r -redir:sim ~/apps/fifran/sim/gzip.simout.T2.random -redir:prog ~/apps/fifran/output/r23 ~/apps/gzip/gzip ~/apps/gzip/input.graphic &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:128:64:2:l  -cache:dl2 ul2:256:64:16:r -redir:sim ~/apps/fifran/sim/gcc.simout.T2.random -redir:prog ~/apps/fifran/output/r24 ~/apps/gcc/gcc -O ~/apps/gcc/166.i &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:64:128:2:l  -cache:dl2 ul2:256:128:16:r -redir:sim ~/apps/fifran/sim/go.simout.T3.random -redir:prog ~/apps/fifran/output/r31 ~/apps/go/go 50 21 ~/apps/go/5stone21.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:64:128:2:l  -cache:dl2 ul2:256:128:16:r -redir:sim ~/apps/fifran/sim/anagram.simout.T3.random -redir:prog ~/apps/fifran/output/r32 ~/apps/anagram/anagram ~/apps/anagram/words < ~/apps/anagram/anagram.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:64:128:2:l  -cache:dl2 ul2:256:128:16:r -redir:sim ~/apps/fifran/sim/gzip.simout.T3.random -redir:prog ~/apps/fifran/output/r33 ~/apps/gzip/gzip ~/apps/gzip/input.graphic &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:64:128:2:l  -cache:dl2 ul2:256:128:16:r -redir:sim ~/apps/fifran/sim/gcc.simout.T3.random -redir:prog ~/apps/fifran/output/r34 ~/apps/gcc/gcc -O ~/apps/gcc/166.i &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:32:256:2:l  -cache:dl2 ul2:256:256:16:r -redir:sim ~/apps/fifran/sim/go.simout.T4.random -redir:prog ~/apps/fifran/output/r41 ~/apps/go/go 50 21 ~/apps/go/5stone21.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:32:256:2:l  -cache:dl2 ul2:256:256:16:r -redir:sim ~/apps/fifran/sim/anagram.simout.T4.random -redir:prog ~/apps/fifran/output/r42 ~/apps/anagram/anagram ~/apps/anagram/words < ~/apps/anagram/anagram.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:32:256:2:l  -cache:dl2 ul2:256:256:16:r -redir:sim ~/apps/fifran/sim/gzip.simout.T4.random -redir:prog ~/apps/fifran/output/r43 ~/apps/gzip/gzip ~/apps/gzip/input.graphic &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:32:256:2:l  -cache:dl2 ul2:256:256:16:r -redir:sim ~/apps/fifran/sim/gcc.simout.T4.random -redir:prog ~/apps/fifran/output/r44 ~/apps/gcc/gcc -O ~/apps/gcc/166.i &'
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:16:512:2:l  -cache:dl2 ul2:256:512:16:r -redir:sim ~/apps/fifran/sim/go.simout.T5.random -redir:prog ~/apps/fifran/output/r51 ~/apps/go/go 50 21 ~/apps/go/5stone21.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:16:512:2:l  -cache:dl2 ul2:256:512:16:r -redir:sim ~/apps/fifran/sim/anagram.simout.T5.random -redir:prog ~/apps/fifran/output/r52 ~/apps/anagram/anagram ~/apps/anagram/words < ~/apps/anagram/anagram.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:16:512:2:l  -cache:dl2 ul2:256:512:16:r -redir:sim ~/apps/fifran/sim/gzip.simout.T5.random -redir:prog ~/apps/fifran/output/r53 ~/apps/gzip/gzip ~/apps/gzip/input.graphic &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:16:512:2:l  -cache:dl2 ul2:256:512:16:r -redir:sim ~/apps/fifran/sim/gcc.simout.T5.random -redir:prog ~/apps/fifran/output/r54 ~/apps/gcc/gcc -O ~/apps/gcc/166.i &'
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:16:512:2:l  -cache:dl2 ul2:256:512:16:f -redir:sim ~/apps/fifran/sim/go.simout.T5.fifo -redir:prog ~/apps/fifran/output/51 ~/apps/go/go 50 21 ~/apps/go/5stone21.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:16:512:2:l  -cache:dl2 ul2:256:512:16:f -redir:sim ~/apps/fifran/sim/anagram.simout.T5.fifo -redir:prog ~/apps/fifran/output/52 ~/apps/anagram/anagram ~/apps/anagram/words < ~/apps/anagram/anagram.in &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:16:512:2:l  -cache:dl2 ul2:256:512:16:f -redir:sim ~/apps/fifran/sim/gzip.simout.T5.fifo -redir:prog ~/apps/fifran/output/53 ~/apps/gzip/gzip ~/apps/gzip/input.graphic &',
'nohup simplesim-3.0/sim-outorder -max:inst 1000000000 -cache:dl1 dl1:16:512:2:l  -cache:dl2 ul2:256:512:16:f -redir:sim ~/apps/fifran/sim/gcc.simout.T5.fifo -redir:prog ~/apps/fifran/output/54 ~/apps/gcc/gcc -O ~/apps/gcc/166.i &'
]
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
	
