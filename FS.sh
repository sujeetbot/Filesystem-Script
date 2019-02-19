#!/bin/bash

DT=`date +%Y%m%d`

# Declaration of arguments
disk=$1
vg=$2
lv=$3
mp=$4
size=$5

#RHEL5

RHEL5 ()
{
echo "OS Version is RHEL $Ver "
mkfs.ext3 /dev/mapper/$vg-$lv 1> /dev/null
cp /etc/fstab /etc/fstab.$DT
echo "/dev/mapper/$vg-$lv        $mp       ext3      defaults          1 2 " >> /etc/fstab
}


#RHEL6

RHEL6 ()
{
echo "OS Version is RHEL $Ver "
mkfs.ext4 /dev/mapper/$vg-$lv 1> /dev/null
cp /etc/fstab /etc/fstab.$DT
echo "/dev/mapper/$vg-$lv      $mp       ext4      defaults        1 2" >> /etc/fstab
}


#RHEL7

RHEL7 ()
{
echo "OS Version is RHEL $Ver "
mkfs.xfs /dev/mapper/$vg-$lv 1> /dev/null
cp /etc/fstab /etc/fstab.$DT
echo "/dev/mapper/$vg-$lv     $mp     xfs    defaults        1 2" >> /etc/fstab
}


# It will check given File System is existing or not

FS=$(df -hTP | grep -i $4 |  awk -vVAL=$4 'tolower($7)==tolower(VAL)' | awk '{print $NF}')

if [ $FS == $4 ] 2>1
   then
       echo " File system $4 already exist "
       exit
else

        OS=$(uname)
        if [ $OS == 'Linux' ]
            then

                mkdir -p $mp

                    pvcreate $disk 2> /dev/null

                if [ $? -eq 0 ]
                then

                     echo "Pv created successfully"

#Given VG is already exist or not

                     op=$(vgs | grep -i $vg | awk '{print $1}')
                     echo "$op"

                if [ $op == $vg ] 2>1
                then
                      echo " VG $vg is already exist on this server. If you want to extend "$vg" press ENTER else Ctrl + C or exit."
                      read INP

                      vgextend $vg $disk



                      if [ $? -eq 0 ]
                      then

                             echo " VG  $vg  created successfully "

                      else

                              echo " VG could not created "
                      fi

                else
                              vgcreate $vg $disk 1>/dev/null

                fi

                        lvcreate -L $size -n $lv $vg 1> /dev/null

                if [ $? -eq 0 ]
                then

                         echo " LV /dev/mapper/$vg-$lv has been created "
                else

                         echo " Not able to create LV "
                         exit
                fi

# Check for RHEL5,6,7

                        Ver=$(lsb_release -sr | cut -d "." -f1)

                        if [ $Ver -eq 5 ]
                        then

                               RHEL5


                        elif [ $Ver -eq 6 ]
                        then

                               RHEL6

                        elif [ $Ver -eq 7 ]
                        then

                               RHEL7

                        else
                               echo " Script is valid for only RHEL 5,6 and 7"
                               exit 0
                        fi

           else
                echo " PV already exist   "
                exit 0
           fi

#Mount the File system
mount /dev/mapper/$vg-$lv $4

fs=$(df -hPT | grep -i "$mp")
echo " "
echo " New File System has been created : "
echo " $fs "
exit




        else

                                echo " Script is valid for Linux only"
        fi

    fi




