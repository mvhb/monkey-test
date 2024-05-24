#!/bin/sh

#SETUP: Usar conta de teste (modo teste ativado) / Remover endereços que nao seja ramal bujari / Ativar segurança de compra
#chmod / install ffmpeg / adb 

echo 'Welcome to Monkey Test program'

echo 'Which package do you wanna test? Default value is: br.com.brainweb.ifood.qa'
default_package_name="br.com.brainweb.ifood.qa"
read package_name
if [ "$package_name" = "" ]; then
    package_name=$default_package_name
fi

echo 'How many touches do you want for this test? Default value is 5000'
default_touches=5000
read touches
if [ "$touches" = "" ]; then
    touches=$default_touches
fi

echo 'Throttle? Default value is 0'
default_throttle=0
read throttle
if [ "$throttle" = "" ]; then
    throttle=$default_throttle
fi

today=`date '+%Y_%m_%d__%H_%M_%S'`;

mkdir monkey_test_$today
cd monkey_test_$today

# Removing LOCATION permission 
adb shell pm revoke $package_name android.permission.ACCESS_COARSE_LOCATION
adb shell pm revoke $package_name android.permission.ACCESS_FINE_LOCATION

# Running the monkey test and screenrecording and generate log at the same time
adb shell "while true; do screenrecord --output-format=h264 -; done" | ffmpeg -i - monkey_test_$today.mp4 & adb logcat &> logcat_$today.txt & adb shell monkey -p $package_name --throttle $throttle -v --monitor-native-crashes $touches &> monkey_test_$today.txt 
sleep 2 
killall ffmpeg & killall adb
sleep 1

# Checking logs generated to see if a crash or ANR occour 
if grep "CRASH" monkey_test_$today.txt
then 
    echo 'Device crashed - see txt file generated'
else
    echo 'No crashes'
fi

if grep "ANR in br.com.brainweb.ifood" logcat_$today.txt
then 
    echo 'ANR on ifood - see txt file generated'
else
    echo 'No ANR on ifood'
fi



# limitar usuario a fazer pedidos - gps/usuario de teste/emulador/compra por biometria
# GUI --- shellmarks
