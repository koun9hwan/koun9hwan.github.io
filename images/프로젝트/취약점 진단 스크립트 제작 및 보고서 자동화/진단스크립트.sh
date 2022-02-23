echo -e "항목,취약여부,기타" > /root/result/진단결과.csv
ch=`chmod 755 /root/result/진단결과.csv`

######################################################################## U-01

telnet=`cat /etc/securetty | grep "pts"`
ssh=`cat /etc/ssh/sshd_config | grep "PermitRootLogin" | grep -v "#"`
TelnetEtc=" "
SshEtc=" "

if [ "$telnet" ]
then
        Result=취약
        TelnetEtc="[Telnet] root 접속 가능"
else
        Result=양호
fi

if [ "$ssh" ]
then
        if [[ "$ssh" == *"yes"* ]]
        then
                Result=취약
                SshEtc="[SSH] root 접속 가능"
        else
                Result=양호
        fi
else
        Result=취약
        SshEtc="[SSH] root 접속 가능"
fi

echo -e "\n"U-01,"$Result","$TelnetEtc" "$SshEtc" >> /root/result/진단결과.csv
echo -ne "# (01%)\r"

########################################################################

######################################################################## U-02

process=`cat /etc/security/pwquality.conf | grep password | grep -v "#"`
minlen=`cat /etc/security/pwquality.conf | grep password | grep -v "#" | tr " " "\n" | grep "minlen" | sed 's/[^0-9]//g'`
lcredit=`cat /etc/security/pwquality.conf | grep password | grep -v "#" | tr " " "\n" | grep "lcredit"`
ucredit=`cat /etc/security/pwquality.conf | grep password | grep -v "#" | tr " " "\n" | grep "ucredit"`
dcredit=`cat /etc/security/pwquality.conf | grep password | grep -v "#" | tr " " "\n" | grep "dcredit"`
ocredit=`cat /etc/security/pwquality.conf | grep password | grep -v "#" | tr " " "\n" | grep "ocredit"`

if [ "$process" ]
then
        if [ "$minlen" -lt 8 ]
        then
                ProcessResult=취약
                Etc="최소 8자리 이상 미적용"
        elif [ "$lcredit" ]
        then
                if [ "$ucredit" ]
                then
                        if [ "$dcredit" ]
                        then
                                if [ "$ocredit" ]
                                then
                                        ProcessResult=양호
                                        Etc=" "
                                else
                                        ProcessResult=취약
                                        Etc="최소 특수문자 1자 이상 미적용"
                                fi
                        else
                                ProcessResult=취약
                                Etc="최소 숫자 1자 이상 미적용"
                        fi
                else
                        ProcessResult=취약
                        Etc="최소 대문자 1자 이상 미적용"
                fi
        else
                ProcessResult=취약
                Etc="소문자 최소 1자 이상 미적용"
        fi
else
        ProcessResult=취약
        Etc="패스워드 정책 설정 미적용"
fi

echo -e "\n"U-02,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "# (02%)\r"

########################################################################

######################################################################## U-03

process=`cat /etc/pam.d/system-auth | grep "lib/security/pam_tally.so deny=5 unlock_time=120 no_magic_root"`
process2=`cat /etc/pam.d/system-auth | grep "lib/security/pam_tally.so no_magic_root reset"`

if [ "$process" ]
then
        if [ "$process2" ]
        then
                ProcessResult=양호
                Etc=" "
        else
                ProcessResult=취약
                Etc="root 패스워드 잠금 설정 & 실패 횟수 초기화 설정 미적용"
        fi
else
        ProcessResult=취약
        Etc="root 패스워드 잠금 설정 & 5회 잠금 & 잠금 시간 설정 미적용"
fi

echo -e "\n"U-03,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "## (03%)\r"

########################################################################

######################################################################## U-04

process=`cat /etc/passwd | cut -f 2 -d ':' | grep -v "x"`
process2=`cat /etc/passwd | grep -v "x" | cut -f 1 -d ':'`

if [ "$process" ]
then
        ProcessResult=취약
        Etc="취약한 계정 : $process2"
else
        ProcessResult=양호
        Etc=" "
fi

echo -e "\n"U-04,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "## (04%)\r"

########################################################################

######################################################################## U-05

process=`echo $PATH`

if [[ "$process" == *"."* ]] || [[ "$process" == *"::"* ]]
then
        ProcessResult=취약
        Etc="'.' 이나 '::'이 포함되어 있음 확인 필요"
else
        ProcessResult=양호
        Etc=" "
fi

echo -e "\n"U-05,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "### (05%)\r"

########################################################################

######################################################################## U-06

process=`find / -nouser -o -nogroup 2> /root/result/u-06.txt`
process2=`sed '/No such file or directory/d' /root/result/u-06.txt`

if [ "$process2" ]
then
        ProcessResult=취약
else
        ProcessResult=양호
fi

echo -e "\n"U-06,"$ProcessResult"," " >> /root/result/진단결과.csv
echo -ne "### (06%)\r"

########################################################################

######################################################################## U-07

process=`find /etc/passwd -perm -645`
process2=`find /etc/passwd -not -user root`
if [ "$process" ]
then
        ProcessResult=취약
        process3=`ls -al /etc/passwd | cut -f 1 -d '.'`
        Etc="/etc/passwd 퍼미션 : $process3"
else
        if [ "$process2" ]
        then
                ProcessResult=취약
                process4=`ls -al /etc/passwd | cut -f 3 -d ' '`
                Etc="/etc/passwd 소유자 : $process4"
        else
                ProcessResult=양호
                Etc=" "
        fi
fi

echo -e "\n"U-07,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "#### (07%)\r"

########################################################################

######################################################################## U-08

process=`find /etc/shadow -perm -401`
process2=`find /etc/shadow -not -user root`
if [ "$process" ]
then
        ProcessResult=취약
        process3=`ls -al /etc/shadow | cut -f 1 -d '.'`
        Etc="/etc/shadow 퍼미션 : $process3"
else
        if [ "$process2" ]
        then
                ProcessResult=취약
                process4=`ls -al /etc/shadow | cut -f 3 -d ' '`
                Etc="/etc/shadow 소유자 : $process4"
        else
                ProcessResult=양호
                Etc=" "
        fi
fi

echo -e "\n"U-08,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "#### (08%)\r"

########################################################################

######################################################################## U-09

process=`find /etc/hosts -perm -601`
process2=`find /etc/hosts -not -user root`
if [ "$process" ]
then
        ProcessResult=취약
        process3=`ls -al /etc/hosts | cut -f 1 -d '.'`
        Etc="/etc/hosts 퍼미션 : $process3"
else
        if [ "$process2" ]
        then
                ProcessResult=취약
                process4=`ls -al /etc/hosts | cut -f 3 -d ' '`
                Etc="/etc/hosts 소유자 : $process4"
        else
                ProcessResult=양호
                Etc=" "
        fi
fi

echo -e "\n"U-09,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "##### (09%)\r"

########################################################################

######################################################################## U-10

process=`find /etc/xinetd.conf -not -perm 600`
process2=`find /etc/xinetd.conf -not -user root`
process3=`find /etc/xinetd.d/* -not -perm 600`
process4=`find /etc/xinetd.d/* -not -user root`
if [ "$process" ] || [ "$process2" ] || [ "$process3" ] || [ "$process4" ]
then
        ProcessResult=취약
else
        ProcessResult=양호
fi

echo -e "\n"U-10,"$ProcessResult"," " >> /root/result/진단결과.csv
echo -ne "##### (10%)\r"

########################################################################

######################################################################## U-11

process=`find /etc/rsyslog.conf -perm -641`
process2=`find /etc/rsyslog.conf -not -user root`
if [ "$process" ]
then
        ProcessResult=취약
        process3=`ls -al /etc/rsyslog.conf | cut -f 1 -d '.'`
        Etc="/etc/rsyslog.conf 퍼미션 : $process3"
else
        if [ "$process2" ]
        then
                ProcessResult=취약
                process4=`ls -al /etc/rsyslog.conf | cut -f 3 -d ' '`
                Etc="/etc/rsyslog.conf 소유자 : $process4"
        else
                ProcessResult=양호
                Etc=" "
        fi
fi

echo -e "\n"U-11,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "###### (11%)\r"

########################################################################

######################################################################## U-12

process=`find /etc/services -perm -645`
process2=`find /etc/services -not -user root`
if [ "$process" ]
then
        ProcessResult=취약
        process3=`ls -al /etc/services | cut -f 1 -d '.'`
        Etc="/etc/services 퍼미션 : $process3"
else
        if [ "$process2" ]
        then
                ProcessResult=취약
                process4=`ls -al /etc/services | cut -f 3 -d ' '`
                Etc="/etc/services 소유자 : $process4"
        else
                ProcessResult=양호
                Etc=" "
        fi
fi

echo -e "\n"U-12,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "###### (12%)\r"

########################################################################

######################################################################## U-13

echo -e "\n"U-13,"담당자 확인","명령어 : find / -user root -type f \( -perm -04000 -o -perm -02000 \) -xdev -exec ls -al {} \; 2>/dev/null" >> /root/result/진단결과.csv
echo -ne "####### (13%)\r"

########################################################################

######################################################################## U-14

echo -e "\n"U-14,"담당자 확인","명령어 : ls -al /root/" >> /root/result/진단결과.csv
echo -ne "####### (14%)\r"

########################################################################

######################################################################## U-15

echo -e "\n"U-15,"담당자 확인","명령어 : find / -type f -perm -2 -exec ls -l {} \; 2>/dev/null" >> /root/result/진단결과.csv
echo -ne "######## (15%)\r"

########################################################################

######################################################################## U-16

process=`find /dev -type f -exec ls -l {} \;`
if [ "$process" ]
then
        ProcessResult=취약
else
        ProcessResult=양호
fi

echo -e "\n"U-16,"$ProcessResult"," " >> /root/result/진단결과.csv
echo -ne "######## (16%)\r"

########################################################################

######################################################################## U-17

process=`find / -name hosts.equiv`
if [ "$process" ]
then
        process2=`find "$process" -user root`
        if [ "$process2" ]
        then
                process2=`find "$process" -perm 601`
                if [ "$process2" ]
                then
                        ProcessResult=취약
                        process4=`ls -al $process | cut -f 1 -d '.'`
                        Etc="hosts.equiv 파일 퍼미션 : $process4"
                else
                        process3=`cat "$process" | grep "+"`
                        if [ "$process3" ]
                        then
                                ProcessResult=취약
                                Etc="hosts.equiv 파일 설정에 '+' 있음"
                        else
                                ProcessResult=양호
                                Etc=" "
                        fi
                fi
        else
                ProcessResult=취약
                process4=`ls -al $process | cut -f 3 -d ' '`
                Etc="hosts.equiv 파일 소유자 : $process4"
        fi
else
        ProcessResult=양호
        Etc=" "
fi


process=`find / -name .rhosts`
if [ "$process" ]
then
        process2=`find "$process" -user root`
        if [ "$process2" ]
        then
                process2=`find "$process" -perm 601`
                if [ "$process2" ]
                then
                        ProcessResult=취약
                        process4=`ls -al $process | cut -f 1 -d '.'`
                        Etc=".rhosts 파일 퍼미션 : $process4"
                else
                        process3=`cat "$process" | grep "+"`
                        if [ "$process3" ]
                        then
                                ProcessResult=취약
                                Etc=".rhosts 파일 설정에 '+' 있음"
                        else
                                ProcessResult=양호
                                Etc=" "
                        fi
                fi
        else
                ProcessResult=취약
                process4=`ls -al $process | cut -f 3 -d ' '`
                Etc=".rhosts 파일 소유자 : $process4"
        fi
else
        ProcessResult=양호
        Etc=" "
fi

echo -e "\n"U-17,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "######### (17%)\r"

########################################################################

######################################################################## U-18

process=`cat /etc/hosts.deny | grep "ALL:ALL"`
if [ "$process" ]
then
        ProcessResult=양호
        Etc=" "
else
        ProcessResult=취약
        Etc="설정 없음"
fi

echo -e "\n"U-18,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "######### (18%)\r"

########################################################################

######################################################################## U-19


port=`netstat -tulpn | grep LISTEN | grep 79`
if [ "$port" ]
then
        ProcessResult=취약
        Etc="Finger 서비스 사용중"
else
        ProcessResult=양호
        Etc=" "
fi

echo -e "\n"U-19,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "########## (19%)\r"

########################################################################

######################################################################## U-20

Anonymous=`cat /etc/vsftpd/vsftpd.conf | grep anonymous_enable`
ftp=`cat /etc/passwd | grep "ftp"`

if [ "$ftp" ]
then
        if [[ "$Anonymous" == *yes* ]]
        then
                ProcessResult=취약
                Etc="익명 FTP 접속 가능"
        else
                ProcessResult="양호"
                Etc=" "
        fi
else
        ProcessResult="양호"
        Etc=" "
fi

echo -e "\n"U-20,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "########## (20%)\r"

########################################################################

######################################################################## U-21

process=`ls -al /etc/xinetd.d/* | egrep "rsh|rlogin|rexec" | egrep -v "grep|klogin|kshell|kexec"`

if [ "$process" ]
then
        Rcommand=`cat /etc/xinetd.d/r* | grep disable`
        if [[ "$Rcommand" == *no* ]]
        then
                ProcessResult=취약
                Etc="/etc/xinetd.d/ 내 r 계열 서비스 설정 필요"
        else
                ProcessResult=양호
                Etc=" "
        fi
else
        ProcessResult=양호
        Etc=" "
fi

echo -e "\n"U-21,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "########### (21%)\r"

########################################################################

######################################################################## U-22

cmd=`find /usr/bin/crontab -perm 750 | grep crontab`
if [ "$cmd" ]
then
        cmd=`find /etc/cron* -not -perm 640`
        cmd2=`find /etc/cron* -not -user root`
        if [ "$cmd" ] || [ "$cmd2" ]
        then
                ProcessResult=취약
                Etc="cron 관련 설정파일 소유자 및 권한 설정"
        else        
                cmd=`find /var/spool/cron/ -not -perm 640`
                cmd2=`find /var/spool/cron/ -not -user root`
                if [ "$cmd" ] || [ "$cmd2" ]
                then
                        ProcessResult=취약
                        Etc="사용자별 cron 작업 목록 소유자 및 권한 설정 필요"
                else
                        ProcessResult=양호
                        Etc=" "
                fi
        fi
else
        ProcessResult=취약
        Etc="crontab 명령어 일반사용자 권한 삭제 필요"
fi

echo -e "\n"U-22,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "########### (22%)\r"

########################################################################

######################################################################## U-23

cmd=`netstat -ltup | grep -e echo -e daytime -e discard -e chargen`

if [ "$cmd" ]
then
        ProcessResult=취약
        Etc="echo/daytime/discard/chargen 서비스 확인 필요"
else
        ProcessResult=양호
        Etc=" "
fi

echo -e "\n"U-23,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "############ (23%)\r"

########################################################################

######################################################################## U-24

process=`ps -ef | egrep "nfs|statd|lockd" | grep -v "grep"`
Etc=" "

if [[ "$process" == *nfsd* ]] || [[ "$process" == *statd* ]] || [[ "$process" == *lockd* ]]
then
        ProcessResult=취약
else
        ProcessResult=양호
fi

echo -e "\n"U-24,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "############ (24%)\r"

########################################################################

######################################################################## U-25

process=`ps -ef | egrep "nfs|statd|lockd" | grep -v "grep"`
exports=`cat /etc/exports`

if [[ "$process" == *nfsd* ]] || [[ "$process" == *statd* ]] || [[ "$process" == *lockd* ]]
then
        if [ $exports ]
        then
                ProcessResult=양호
                Etc=" "
        else
                ProcessResult=취약
                Etc="everyone 공유 제한 필요"
        fi
else
        ProcessResult=양호
        Etc=" "
fi

echo -e "\n"U-25,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "############# (25%)\r"

########################################################################

######################################################################## U-26

process=`ps -ef | grep automount | grep -v "grep"`
Etc=" "
if [ "$process" ]
then
        ProcessResult=취약
else
        ProcessResult=양호
fi

echo -e "\n"U-26,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "############# (26%)\r"

########################################################################

######################################################################## U-27

echo -e "\n"U-27,"담당자 확인","명령어 : ls /etc/xinetd.d/" >> /root/result/진단결과.csv
echo -ne "############# (27%)\r"

########################################################################

######################################################################## U-28

process=`ps -ef | egrep "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated" | grep -v "grep"`
Etc=" "
if [ "$process" ]
then
        ProcessResult=취약
else
        ProcessResult=양호
fi

echo -e "\n"U-28,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "############## (28%)\r"

########################################################################

######################################################################## U-29

process=`netstat -lnup | grep -e 69 -e 517 -e 518`
if [ "$process" ]
then
        PortResult=취약
        if [[ "$process" == *69* ]]
        then
                Etc="tftp 서비스 활성화 상태"
        else
                if [[ "$process" == *517* ]]
                then
                        Etc="talk 서비스 활성화 상태"
                else
                        if [[ "$process" == *518* ]]
                        then
                                Etc="ntalk 서비스 활성화 상태"
                        else
                                Etc=" "
                        fi
                fi
        fi
else
        PortResult=양호
        Etc=" "
fi

echo -e "\n"U-29,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "############## (29%)\r"

########################################################################

######################################################################## U-30

process=`sendmail -d0.1 < /dev/null | grep -i Version`

echo -e "\n"U-30,"담당자 확인","Sendmail 버전 : $process" >> /root/result/진단결과.csv
echo -ne "############### (30%)\r"

########################################################################

######################################################################## U-31

process=`ps -ef | grep sendmail | grep -v "grep"`
if [ "$process" ]
then
        process=`cat /etc/mail/sendmail.cf | grep "R$\*" | grep "Relaying denied"`
        if [[ "$process" == *"#R$"* ]]
        then
                ProcessResult=취약
                Etc="릴레이 제한 설정 필요"
        else
                ProcessResult=양호
                Etc=" "
        fi
else
        ProcessResult=양호
        Etc=" "
fi

echo -e "\n"U-31,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "############### (31%)\r"

########################################################################

######################################################################## U-32

process=`ps -ef | grep sendmail | grep -v "grep"`
if [ "$process" ]
then
        process=`grep -v '^ *#' /etc/mail/sendmail.cf | grep PrivacyOptions`
        if [[ "$process" == *"restrictqrun"* ]]
        then
                ProcessResult=양호
                Etc=" "
        else
                ProcessResult=취약
                Etc="일반 사용자 Sendmail 실행 방지 설정 필요"
        fi
else
        ProcessResult=양호
        Etc=" "
fi

echo -e "\n"U-32,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "################ (32%)\r"

########################################################################

######################################################################## U-33

process=`named -v`

echo -e "\n"U-33,"담당자 확인","BIND 버전 : $process" >> /root/result/진단결과.csv
echo -ne "################ (33%)\r"

########################################################################

######################################################################## U-34

process=`ps -ef | grep named | grep -v "grep"`

if [ "$process" ]
then
        process=`cat /etc/named.conf | grep 'allow-transfer'`
        if [ "$process" ]
        then
                ProcessResult=양호
                Etc=" "
        else
                ProcessResult=취약
                Etc="allow-transfer 설정 필요"
        fi

        process=`cat /etc/named.conf | grep "xfrnets"`
        if [ "$process" ]
        then
                ProcessResult=양호
                Etc=" "
        else
                ProcessResult=취약
                Etc="xfrnets 설정 필요"
        fi
else
        ProcessResult=양호
        Etc=" "
fi

echo -e "\n"U-34,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "################# (34%)\r"

########################################################################

######################################################################## U-35

process=`cat /etc/httpd/conf/httpd.conf | grep "Options Indexes"`
Etc=" "

if [ "$process" ]
then
        ProcessResult=취약
else
        ProcessResult=양호
fi

echo -e "\n"U-35,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "################# (35%)\r"

########################################################################

######################################################################## U-36

process=`cat /etc/httpd/conf/httpd.conf | grep "User "`
process2=`cat /etc/httpd/conf/httpd.conf | grep "Group "`
Etc=" "

if [[ "$process" == *root* ]] || [[ "$process2" == *root* ]]
then
        ProcessResult=취약
        Etc="$process / $process2"
else
        ProcessResult=양호
fi

echo -e "\n"U-36,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "################## (36%)\r"

########################################################################

######################################################################## U-37

process=`cat /etc/httpd/conf/httpd.conf | grep "AllowOverride"`
Etc=" "

if [[ "$process" == *None* ]]
then
        ProcessResult=취약
else
        ProcessResult=양호
fi

echo -e "\n"U-37,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "################## (37%)\r"

########################################################################

######################################################################## U-38

process=`find /etc/httpd/ -name manual`
if [ "$process" ]
then
        ProcessResult=취약
        Etc="불필요한 파일 경로 : $process"
else
        ProcessResult=양호
        Etc=" "
fi

echo -e "\n"U-38,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "################### (38%)\r"

########################################################################

######################################################################## U-39

process=`cat /etc/httpd/conf/httpd.conf | grep "FollowSymLinks" | grep "Options"`

if [[ "$process" == *"FollowSymLinks"* ]]
then
        ProcessResult=취약
        Etc="FollowSymLinks 옵션 설정 필요"
else
        ProcessResult=양호
        Etc=" "
fi

echo -e "\n"U-39,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "################### (39%)\r"

########################################################################

######################################################################## U-40

process=`cat /etc/httpd/conf/httpd.conf | grep "LimitRequestBody"`
if [[ "$process" == *"5000000"* ]]
then
        ProcessResult=양호
        Etc=" "
else
        ProcessResult=취약
        Etc="파일 사이즈 제한 설정 필요"

fi

echo -e "\n"U-40,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "#################### (40%)\r"

########################################################################

######################################################################## U-41

process=`cat /etc/httpd/conf/httpd.conf | grep 'DocumentRoot "'`
if [[ "$process" == *"/usr/local/apache/htdocs"* ]] || [[ "$process" == *"/usr/local/apache2/htdocs"* ]] || [[ "$process" == *"/var/www/html"* ]]
then
        ProcessResult=취약
        Etc="웹서비스 영역 분리 필요"
else
        ProcessResult=양호
        Etc=" "
fi

echo -e "\n"U-41,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "#################### (41%)\r"

########################################################################

######################################################################## U-42

echo -e "\n"U-42,"담당자 확인","http://www.redhat.com/security/updates/eol/" >> /root/result/진단결과.csv
echo -ne "##################### (42%)\r"

########################################################################

######################################################################## U-43

echo -e "\n"U-43,"담당자 확인"," " >> /root/result/진단결과.csv
echo -ne "##################### (43%)\r"

########################################################################

######################################################################## U-44

process=`cat /etc/passwd | grep x:0: | grep -v root`
if [ "$process" ]
then
        ProcessResult=취약
        Etc="$process"
else
        ProcessResult=양호
        Etc=" "
fi

echo -e "\n"U-41,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "###################### (44%)\r"

########################################################################

######################################################################## U-45

process=`cat /etc/pam.d/su | grep "pam_wheel.so use_uid"`
if [[ "$process" == *"#"* ]]
then
        ProcessResult=취약
        Etc="주석 제거 필요"
else
        ProcessResult=양호
        Etc=" "
fi

echo -e "\n"U-45,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "###################### (45%)\r"

########################################################################

######################################################################## U-46

process=`cat /etc/login.defs | grep "PASS_MIN_LEN" | grep -v "#" | sed 's/[^0-9]//g'`
if [ "$process" -lt 8 ]
then
        ProcessResult=취약
        Etc="패스워드 길이 : $process"
else
        ProcessResult=양호
        Etc=" "
fi

echo -e "\n"U-46,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "####################### (46%)\r"

########################################################################

######################################################################## U-47

process=`cat /etc/login.defs | grep "PASS_MAX_DAYS" | grep -v "#" | sed 's/[^0-9]//g'`
if [ "$process" -lt 90 ]
then
        ProcessResult=양호
        Etc="패스워드 최대 사용기간 : $process"
else
        ProcessResult=취약
        Etc=" "
fi

echo -e "\n"U-47,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "####################### (47%)\r"

########################################################################

######################################################################## U-48

process=`cat /etc/login.defs | grep "PASS_MIN_DAYS" | grep -v "#" | sed 's/[^0-9]//g'`
if [ "$process" -lt 1 ]
then
        ProcessResult=취약
        Etc="패스워드 최소 사용기간 : $process"
else
        ProcessResult=양호
        Etc=" "
fi

echo -e "\n"U-48,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "######################## (48%)\r"

########################################################################

######################################################################## U-49

process=`cat /etc/passwd | egrep "lp|uucp|nuucp"`
Etc=" "
if [ "$process" ]
then
        ProcessResult=취약
else
        ProcessResult=양호
fi

echo -e "\n"U-49,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "######################## (49%)\r"

########################################################################

######################################################################## U-50

process=`cat /etc/group | grep :0: | cut -c 10- | tr ',' '/'`
Etc="$process"

echo -e "\n"U-50,"담당자 확인","관리자 그룹에 포함된 계정 : $Etc" >> /root/result/진단결과.csv
echo -ne "######################### (50%)\r"

########################################################################

######################################################################## U-51

process=`cut -f 1 -d ':' /etc/group | tr "\n" "\t" | sed 's/.\{1\}$//'`

echo -e "\n"U-51,"담당자 확인","현재 존재하는 그룹 : $Etc" >> /root/result/진단결과.csv
echo -ne "######################### (51%)\r"

########################################################################

######################################################################## U-52

process=`cat /etc/passwd | cut -f 3 -d ':' | uniq -c | cut -c 7-8 | sort -u | grep -v "1"`
Etc=" "

if [ "$process" ]
then
        ProcessResult=취약
else
        ProcessResult=양호
fi

echo -e "\n"U-52,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "########################## (52%)\r"

########################################################################

######################################################################## U-53

process=`cat /etc/passwd | egrep "^daemon|^bin|^sys|^adm|^listen|^nobody|^nobody4|^noaccess|^diag|^operator|^games|^gopher" | grep -v "admin" | grep -v "nologin"`
Etc=" "

if [ "$process" ]
then
        ProcessResult=취약
else
        ProcessResult=양호
fi

echo -e "\n"U-53,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "########################## (53%)\r"

########################################################################

######################################################################## U-54

process=`cat /etc/profile | grep "TMOUT"`
if [ "$process" ]
then
        process=`cat /etc/profile | grep "TMOUT" | sed 's/[^0-9]//g'`
        if [ "$process" -lt 600 ]
        then
                ProcessResult=취약
                Etc="600 이하로 설정됨"
        else
                ProcessResult=양호
                Etc=" "
        fi
else
        ProcessResult=취약
        Etc="Session Timeout 설정 필요"
fi

echo -e "\n"U-54,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "########################### (54%)\r"

########################################################################

######################################################################## U-55

process=`find / -name hosts.lpd`
Etc=" "

if [ "$process" ]
then
        process=`find / -name hosts.lpd -perm 600`
        process2=`find /etc/hosts.lpd -user root`
        if [ "$process" ] || [ "$process2" ]
        then
                ProcessResult=양호
        else
                ProcessResult=취약
                Etc="hosts.lpd 파일의 권한 or 소유자 확인 필요"
        fi
else
        ProcessResult=양호
fi

echo -e "\n"U-55,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "########################### (55%)\r"

########################################################################

######################################################################## U-56

process=`cat /etc/profile | grep "umask" | grep -v "#" | cut -c 11-13 | grep -v "022"`
Etc=" "

if [ "$process" -lt 022 ]
then
        ProcessResult=취약
        Etc="UMASK 값 : $process"
else
        ProcessResult=양호
fi

echo -e "\n"U-56,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "############################ (56%)\r"

########################################################################

######################################################################## U-57

process=`ls -ald /home/*`

echo -e "\n"U-57,"담당자 확인","명령어 : ls -ald /home/*" >> /root/result/진단결과.csv
echo -ne "############################ (57%)\r"

########################################################################

######################################################################## U-58

process=`cat /etc/passwd`

echo -e "\n"U-58,"담당자 확인","명령어 : cat /etc/passwd" >> /root/result/진단결과.csv
echo -ne "############################# (58%)\r"

########################################################################

######################################################################## U-59

echo -e "\n"U-59,"담당자 확인","숨겨진 파일 : find / -type f -name '.*' / 숨겨진 디렉터리 : find / -type d -name '.*'" >> /root/result/진단결과.csv
echo -ne "############################# (59%)\r"

########################################################################

######################################################################## U-60

process=`ps -ef | grep "telnet.socket" | grep -v "grep"`
process2=`ps -ef | grep "vsftpd" | grep -v "grep"`

if [ "$process" ] || [ "$process2" ]
then
        ProcessResult=취약
        Etc="Telnet or FTP 서비스 활성화 상태"
else
        ProcessResult=양호
        Etc=" "
fi

echo -e "\n"U-60,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "############################## (60%)\r"

########################################################################

######################################################################## U-61

process=`ps -ef | grep ftp | grep -v "grep"`
process2=`ps -ef | egrep "vsftpd|proftp" | grep -v "grep"`

if [ "$process" ] || [ "$process2" ]
then
        ProcessResult=취약
        Etc="FTP 서비스 활성화 상태"
else
        ProcessResult=양호
        Etc=" "
fi

echo -e "\n"U-61,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "############################## (61%)\r"

########################################################################

######################################################################## U-62

process=`cat /etc/passwd | grep "ftp"`

if [[ "$process" == *"/bin/false"* ]]
then
        ProcessResult=양호
        Etc=" "
else
        ProcessResult=취약
        Etc="FTP 계정에 /bin/false 쉘이 부여되어 있음"
fi

echo -e "\n"U-62,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "############################### (62%)\r"

########################################################################

######################################################################## U-63

process=`find / -name ftpusers`
Etc=" "

if [ "$process" ]
then
        process2=`find "$process" -user root`
        if [ "$process2" ]
        then
                process2=`find "$process" -perm -641`
                if [ "$process2" ]
                then
                        ProcessResult=취약
                        Etc="ftpusers 파일 권한 확인 필요"
                else
                        ProcessResult=양호
                fi
        else
                ProcessResult=취약
                Etc="ftpusers 파일 소유자 확인 필요"
        fi
else
        ProcessResult=양호
fi

echo -e "\n"U-63,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "############################### (63%)\r"

########################################################################

######################################################################## U-64

process=`ps -ef | grep "ftp" | grep -v "grep"`
Etc=" "

if [ "$process" ]
then
        process=`find / -name ftpusers`
        if [ "$process" ]
        then
                process2=`cat "$process" | grep -v "#" | grep "root"`
                if [ "$process2" ]
                then
                        ProcessResult=양호
                else
                        ProcessResult=취약
                        Etc="root 계정 차단 필요"
                fi
        else
                ProcessResult=양호
        fi
else
        ProcessResult=양호
fi

echo -e "\n"U-64,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "################################ (64%)\r"

########################################################################

######################################################################## U-65

process=`ls -l /usr/bin/at`
Etc=" "

if [ "$process" ]
then
        process=`find /usr/bin/at -perm 4750`
        if [ "$process" ]
        then
                process=`find /etc/at.* -perm -641`
                if [ "$process2" ]
                then
                        ProcessResult=취약
                        Etc="at 관련 파일 권한 확인 필요"
                else
                        ProcessResult=양호
                fi
        else
                ProcessResult=취약
                Etc="at 명령어 일반사용자 권한 삭제 필요"
        fi
else
        ProcessResult=양호
fi

echo -e "\n"U-65,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "################################ (65%)\r"

########################################################################

######################################################################## U-66

process=`ps -ef | grep snmp | grep -v "grep"`
Etc=" "

if [ "$process" ]
then
        ProcessResult=취약
else
        ProcessResult=양호
fi

echo -e "\n"U-66,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "################################# (66%)\r"

########################################################################

######################################################################## U-67

process=`cat /etc/snmp/snmpd.conf | grep com2sec | grep -v "#"`
Etc=" "

if [[ "$process" == *"public"* ]] || [[ "$process" == *"private"* ]]
then
        ProcessResult=취약
        Etc="SNMP Community 이름 확인 필요"
else
        ProcessResult=양호
fi

echo -e "\n"U-67,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "################################# (67%)\r"

########################################################################

######################################################################## U-68

process=`cat /etc/motd`
process2=`cat /etc/issue.net`
process3=`cat /etc/vsftpd/vsftpd.conf | grep "ftpd_banner" | grep -v "#"`
process4=`cat /etc/mail/sendmail.cf | grep Greeting`
Etc=" "

if [ "$process" ] && [ "$process2" ] && [ "$process3" ] && [ "$process4 "]
then
        ProcessResult=양호
else
        ProcessResult=취약
fi

echo -e "\n"U-68,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "################################## (68%)\r"

########################################################################

######################################################################## U-69

process=`find /etc/exports -perm -645`
process2=`find /etc/exports -user root`
Etc=" "

if [ "$process" ]
then
        ProcessResult=취약
        Etc="NFS 설정 파일 권한 확인 필요"
else
        if [ "$process2" ]
        then
                ProcessResult=양호
        else
                ProcessResult=취약
                Etc="NFS 설정 파일 소유자 확인 필요"
        fi
fi

echo -e "\n"U-69,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "################################## (69%)\r"

########################################################################

######################################################################## U-70

process=`ps -ef | grep "sendmail" | grep -v "grep"`
process2=`cat /etc/mail/sendmail.cf | grep "PrivacyOptions"`
Etc=" "

if [ "$process" ]
then
        if [[ "$process2" == *"goaway"* ]]
        then
                ProcessResult=양호
        else
                if [[ "$process2" == *"noexpn"* ]] && [[ "$process2" == *"novrfy"* ]]
                then
                        ProcessResult=양호
                else
                        ProcessResult=취약
                        Etc="noexpn / novrfy 옵션 설정 필요"
                fi
        fi
else
        ProcessResult=양호
fi

echo -e "\n"U-70,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "################################### (70%)\r"

########################################################################

######################################################################## U-71

process=`cat /etc/httpd/conf/httpd.conf | grep "ServerTokens" | grep "ServerSignature"`
Etc=" "

if [[ "$process" == *"Prod"* ]] && [[ "$process" == *"off"* ]]
then
        ProcessResult=양호
else
        ProcessResult=취약
        Etc="ServerTokens / ServerSignature 옵션 설정 필요"
fi

echo -e "\n"U-71,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "################################### (71%)\r"

########################################################################

######################################################################## U-72

process=`cat /etc/rsyslog.conf | grep "/var/log/messages" | grep -v "#"`
process2=`cat /etc/rsyslog.conf | grep "/var/log/secure" | grep -v "#"`
process3=`cat /etc/rsyslog.conf | grep "/var/log/maillog" | grep -v "#"`
process4=`cat /etc/rsyslog.conf | grep "/var/log/cron" | grep -v "#"`
process5=`cat /etc/rsyslog.conf | grep "/dev/console" | grep -v "#"`
process6=`cat /etc/rsyslog.conf | grep "*.emerg" | grep -v "#"`
Etc=" "

if [ "$process" ] && [ "$process2" ] && [ "$process3" ] && [ "$process4" ] && [ "$process5" ] && [ "$process6" ]
then
        ProcessResult=양호
else
        ProcessResult=취약
fi

echo -e "\n"U-72,"$ProcessResult","$Etc" >> /root/result/진단결과.csv
echo -ne "#################################### (72%)\r"

########################################################################

########################################################################

echo -ne "##################################### (74%)\r"
echo -ne "###################################### (76%)\r"
echo -ne "####################################### (78%)\r"
echo -ne "######################################## (80%)\r"
echo -ne "######################################### (82%)\r"
echo -ne "########################################## (84%)\r"
echo -ne "########################################### (86%)\r"
echo -ne "############################################ (88%)\r"
echo -ne "############################################# (90%)\r"

######################################################################## 파이썬
python3 CsvToXlsx.py

echo -ne "############################################## (92%)\r"
echo -ne "############################################### (94%)\r"
echo -ne "################################################ (96%)\r"
echo -ne "################################################# (98%)\r"
echo -ne "################################################## (100%)\r"

echo "완료되었습니다"