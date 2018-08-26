# -*- coding: utf-8 -*-
import os
import sys
import platform
import time
from xlpy import *
import base64

g = "\033[32;1m"
gt = "\033[0;32m"
bt = "\033[34;1m"
b = "\033[36;1m"
m = "\033[31;1m"
c = "\033[0m"
p = "\033[37;1m"
u = "\033[35;1m"
M = "\033[3;1m"
k = "\033[33;1m"
kt = "\033[0;33m"
a = "\033[30;1m"

W = '\x1b[0m'
R = '\x1b[31m'
G = '\x1b[1;32m'
O = '\x1b[33m'
B = '\x1b[34m'
P = '\x1b[35m'
C = '\x1b[36m'
GR = '\x1b[37m'



def slowprints(s):
    for c in s + '\n':
        sys.stdout.write(c)
        sys.stdout.flush()
        time.sleep(2.0/90)
def lodprint(s):
    for c in s + '\n':
        sys.stdout.write(c)
        sys.stdout.flush()
        time.sleep(7.0/90)

bintang=(gt+"""
 =======================================
 TEMBAK PAKET BY BINTANG NUR PRADANA
 MASIH DALAM TAHAP UJICOBA
 BILA INGIN DI UPDATE TIAP HARI
 FOLLOW ACCOUNT SOSMED SAYA DI BAWAH INI
 
 IG: @bintang_nur_pradana
 Fb: Bintang Nur Pradana
 Yt: Bintang Nur Pradana
 =======================================
""")
l="Harap tunggu.."

def main_menu():
    clear()
    slowprints(bintang)
    print(p+
        "   Tembak Tembakan Bintang" +
        "\n Pilih Salah Satu:"
        "\n  [1] Menu Beli Paket" + 
        "\n  [2] Minta Otp Code" +
        "\n  [3] Menu utama"
    )
    choice = str(input(" ex:1👉 "))
    exec_menu(choice)
    return

def exec_menu(choice):
    clear()
    if(choice == ''):
        menu_actions['main']()
    else:
        try:
            menu_actions[choice]()
        except KeyError:
            print("Invalid selection, please try again.\n")
            menu_actions['main']()
    return

def menu_1():
    lodprint(l)
    clear()
    print(bintang)
    print(p+"Menu Tembak Paket XL dan Axis")
    msisdn = str(input("Masukan No Misal 62xx 👉 "))
    clear()
    print(bintang)
    po = str(input(p+"Masukan Kode Otp 👉 "))
    clear()
    print(bintang)
    print (p+" 1.Xtra Kuota 30GB Rp. 10.000")
    print (p+" 2.Xtra 3GB 30day 22.900 ")
    print (p+" 3.Xtra 5GB 30day 32.900 ")
    print (p+" 4.Xtra 9GB 30day 52.900 ")
    print (p+" 5.Xtra 17GB 30day 82.900 ")
    print (p+" 6.Xtra 25GB 30day 102.900 ")
    print (p+" 7.Kuota 700mb 10k")
    print (p+" 8.xtra 10GB 30day 59k")
    print (p+" 9.Axis Play 2GB Rp1 3Hr")
    print (p+" 10.Axis Play 3GB Rp1 3Hr")
    print (p+" 11.Axis Play 6GB Rp1 3Hr")
    print (p+" 12.Axis Play 9GB Rp1 3Hr")
    print (p+" 13.Axis Play 12GB Rp1 3Hr")
    print (p+" 14.Axis 1GB Rp.0 7Hr")
    print (p+" 15.Axis 500MB Rp.0 7Hr")
    print (p+" 16.Axis 500MB Rp.0 7Hr v2")
    print (p+" 17.Axis 500MB Rp.0 14Hr")
    print (p+" 18.Axis 500MB Rp.0 7Hr v2")
    print (p+" 19.Axis 5GB Rp.0 30Hr")
    print (p+" 20.Axis Bonus Younder Music")
    print (p+" 21.Nelpon AXIS UNLIMITED 30Hr")
    print (p+" 00.Manual service id")
    pkt = str(input("Pilih Sesuai Keinginan >> "))
    
    if pkt == '1':
        i = '8110577'
    elif pkt == '2':
        i = '8211010'
    elif pkt == '3':
        i = '8211011'
    elif pkt == '4':
        i = '8211012'
    elif pkt == '5':
        i = '8211013'
    elif pkt == '6':
        i = '8211014'
    elif pkt == '7':
        i = '8211170'
    elif pkt == '8':
        i ='8211183'
    elif pkt == '9':
        i ='3212251'
    elif pkt == '10':
        i ='3212252'
    elif pkt == '11':
        i ='3212253'
    elif pkt == '12':
        i ='3212254'
    elif pkt == '13':
        i ='3212255'
    elif pkt == '14':
        i ='3110086'
    elif pkt == '15':
        i ='3212176'
    elif pkt == '16':
        i ='3110085'
    elif pkt == '17':
        i ='3110041'
    elif pkt == '18':
        i ='3212226'
    elif pkt == '19':
        i ='3212290'
    elif pkt == '20':
        i ='3212183'
    elif pkt == '21':
        i ='1110149'
    elif pkt == '00':
        i = str(input("Service ID Paket👉"))
    else:
        print("Pilihan gak tercantum")
    lodprint(l)
    serviceid = i
    xl = XL(msisdn)
    r = xl.loginWithOTP(po)
    if(r != False):
        print(xl.purchasePackage(serviceid)['message'])
        decision = str(input(p+"Ulangi Proses [Y/N]? 👉 "))
        menu_actions['main']() if(decision in ['N','n']) else menu_actions['1']()
        
def menu_2():
    lodprint(l)
    clear()
    print(bintang)
    print(p+"Minta Kode Otp")
    msisdn = str(input("Masukan Nomor 62xx👉"))
    lodprint(l)
    xl = XL(msisdn)
    print(xl.reqOTP()['message'])
    decision = str(input(p+"Ulangi Proses[Y/N]? 👉 "))
    menu_actions['main']() if(decision in ['N','n']) else menu_2()

def menu_4():
    clear()
    print(".::Password Menu::.")
    msisdn = str(input("Input your MSISDN >> "))
    xl = XL(msisdn)
    print(xl.reqPassword()['message'])
    decision = str(input("Want to repeat the process [Y/T]? >> "))
    menu_actions['main']() if(decision in ['T','t']) else menu_actions['3']()
    return

def menu_3():
     lodprint(l)
     os.system('cd ..;python dor.py')


def exit():
    sys.exit()

def clear():
    return os.system("cls") if (platform.system() == 'Windows') else os.system("clear")

menu_actions = {
    "main" : main_menu,
    "1" : menu_1,
    "2" : menu_2,
    "3" : menu_3,
    "0" : exit
}


if __name__ == "__main__":
    main_menu()
