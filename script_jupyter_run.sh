#!/bin/bash
#PBS -N DA_Notebook
#PBS -l select=1:ncpus=8:ngpus=1
#PBS -l walltime=04:00:00
#PBS -q serialq
#PBS -j oe

cd $PBS_O_WORKDIR

NOTEBOOK_LOGFILE=jupyterlog.out

# get tunneling info
node=$(hostname -s)
user=$(whoami)
cluster="XX.XX.XX.XX"
## Please change the port number in both (port and export JUPYTER_PORT) to the one assigned to you.
port=9000
export JUPYTER_PORT=9000

################# -- After job submission open the connection.txt file for port forwarding -- ####################
echo -e "
Command to create ssh tunnel. Run the following command from your local machine terminal:
$ ssh -N -f -L ${port}:${node}:${port} ${user}@${cluster}

Use a Browser on your local machine and in search bar enter the following:
localhost:${port}

This will ask for the token which is available in the jupyterlog.out file in your working directory on the cluster. 
To get the token from the jupyterlog.out, do the following
tailf jupyterlog.out

You will see something like the following line:
        http://gn11:8889/?token=5ab95bd6f72986fb7b7167aed0e8259132a04a101175f35d

Just copy and paste the token without the equal sign (5ab95bd6f72986fb7b7167aed0e8259132a04a101175f35d) in the token window in browser.
Now you will be in your working directory on your local machine browser.
" > connection.txt

## This script is working for submitting jupyter runs on compute nodes.
## After submitting the runs, following commands need to be run
## 1. tail -f jupyterlog.out -- to check the output and see on which node and port the job was submitted.
##
## 2. If the job submitted on cn010 with port 8890, run the following command from another terminal
##  ssh -N -f -L localhost:7990:cn010:8890 deepakagg@antya
## If the localhost port 7990 is not being used, it will ask for the user password
## deepakagg@antya's password:
## After providing the password it will just return to
##  
##
## if these is port error as below:
## bind: Address already in use
## channel_setup_fwd_listener_tcpip: cannot listen to port: 7990
## Could not request local forwarding.
##
## Then change the port 7990 to any other port until it is successful.
##
## 3. If step 2 is successful, then open any browser on your PC and type
##    localhost:7990
##    This will ask for the token which is available in the tailf -f jupyterlog.out. Just copy and paste the token without the equal sign in the token window in browser.


module load singularity/3.4.1/3.4.1
# copy from the image the working directory
singularity run climate.simg cp -rT /workspace workspace

# launch the singularity run
singularity run --nv climate1.simg jupyter notebook --notebook-dir=/workspace/python/jupyter_notebook --ip=0.0.0.0 > ${NOTEBOOK_LOGFILE} 2>&1
#singularity run --nv climate.simg jupyter notebook --ip=${node} --port=${port} > ${NOTEBOOK_LOGFILE} 2>&1 --notebook-dir=workspace/python/jupyter_notebook 

#singularity run --nv climate.simg jupyter notebook --ip=${node} --port=${port} > ${NOTEBOOK_LOGFILE} 2>&1
#jupyter notebook --no-browser --ip=${node} --port=${port} > ${NOTEBOOK_LOGFILE} 2>&1

