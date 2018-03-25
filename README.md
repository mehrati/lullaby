## nightly auto update 
this bash script for auto update/upgrade linux debian and arch base
<br>**note**<br>
after run script system is go to sleep util time specified
 <br>**install**<br>
 ```sh
$ git clone https://github.com/mehrati/lullaby.git
$ cd lullaby
$ chmod 755 install.sh
$ ./install.sh
```
 <br>**example**<br>
 ```sh
$ lullaby --time "today 16:00:30" # system power on at 16:00 and start update  
$ lullaby --time "tomorrow 3:00" --shutdown # system power on at tomorrow 10:30 and start update at end system shutdown
```
<br>**Contributing**<br>
Contributions are welcome! Please feel free to submit a Pull Request.