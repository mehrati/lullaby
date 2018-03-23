## nightly auto update 
this simple bash script for auto update linux debian and arch distro
<br>**note**<br>
after run script system is go to sleep util time specified
 <br>**install**<br>
 ```sh
$ git clone https://github.com/mehrati/lullaby.git
# change directory to lullaby project 
$ chmod 755 ./install.sh
$ ./install.sh
```
 <br>**example**<br>
 ```sh
$ lullaby --time "today 16:00" -p "rootpassword" # system power on at 16:00 and auto update 
$ lullaby --time "tomorrow 10:30" -p "rootpassword" --shutdown # system power on at tomorrow 10:30 after update system shutdown
```
<br>**Contributing**<br>
Contributions are welcome! Please feel free to submit a Pull Request.